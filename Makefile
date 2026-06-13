# ==============================================================================
# Variables
# ==============================================================================
# Ansible Config
IMAGE_NAME = ansible-wireguard-runner
INVENTORY = hosts.ini
PLAYBOOK = site.yml	

# Terraform Config
TF_DIR = ./terraform


# ==============================================================================
# Terraform Targets
# ==============================================================================
.PHONY: tf-init
tf-init:
	@terraform -chdir=$(TF_DIR) init -reconfigure

.PHONY: tf-plan
tf-plan:
	@terraform -chdir=$(TF_DIR) fmt
	@terraform -chdir=$(TF_DIR) validate
	@terraform -chdir=$(TF_DIR) plan --input=false -out="terraform.tfplan"

.PHONY: tf-plan-destroy
tf-plan-destroy:
	@terraform -chdir=$(TF_DIR) fmt
	@terraform -chdir=$(TF_DIR) validate
	@terraform -chdir=$(TF_DIR) plan --input=false -destroy

.PHONY: tf-apply
tf-apply:
	@terraform -chdir=$(TF_DIR) apply "terraform.tfplan"

.PHONY: tf-destroy
tf-destroy:
	@terraform -chdir=$(TF_DIR) destroy --auto-approve

.PHONY: tf-output
tf-output:
	@terraform -chdir=$(TF_DIR) output
# ==============================================================================
# Ansible Targets
# ==============================================================================
.PHONY: ansible-build
ansible-build:
	docker build -t $(IMAGE_NAME) -f ./ansible/Dockerfile ./ansible

.PHONY: ansible-run
ansible-run:
	MSYS_NO_PATHCONV=1 docker run --rm \
		-v "$$(pwd)/ansible:/ansible"  \
		-v "$(HOME)/.ssh:/root/.ssh" \
		--entrypoint /bin/sh \
		$(IMAGE_NAME) -c "chmod 600 /root/.ssh/aws_ec2 && ansible-playbook -i $(INVENTORY) $(PLAYBOOK) -vv"

.PHONY: ansible-ping
ansible-ping:
	MSYS_NO_PATHCONV=1 docker run --rm -it \
		-v "$$(pwd)/ansible:/ansible" \
		-v "$(HOME)/.ssh:/root/.ssh" \
		--entrypoint ansible \
		$(IMAGE_NAME) -i $(INVENTORY) all -m ping

.PHONY: ansible-teardown-client
ansible-teardown-client:
	MSYS_NO_PATHCONV=1 docker run --rm \
		-v "$$(pwd)/ansible:/ansible"  \
		-v "$(HOME)/.ssh:/root/.ssh" \
		--entrypoint /bin/sh \
		$(IMAGE_NAME) -c "chmod 600 /root/.ssh/aws_ec2 && ansible-playbook -i $(INVENTORY) playbooks/teardown.yml -vv"


# ==============================================================================
# Combined Workflow Targets
# ==============================================================================
.PHONY: deploy
deploy: tf-plan tf-apply ansible-run

.PHONY: clean
clean:
	@echo "Starting full cleanup workflow..."
	$(MAKE) ansible-teardown-client
	$(MAKE) tf-destroy

	@echo "Cleaning up local files and Docker images..."
	docker rmi $(IMAGE_NAME) 2>/dev/null || true
	rm -f $(TF_DIR)/terraform.tfplan
	rm -f $(TF_DIR)/.terraform.lock.hcl
	rm -f ./ansible/hosts.ini
	@echo "Cleanup completed successfully."
