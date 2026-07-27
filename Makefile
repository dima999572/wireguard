# ==============================================================================
# Variables
# ==============================================================================
# Ansible Config
IMAGE_NAME = ansible-wireguard-runner
INVENTORY = hosts.ini
PLAYBOOK = site.yml	
SSH_DIR ?= $(USERPROFILE)/.ssh
SSH_KEY ?= aws_ec2

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
ansible-run: ansible-build
	@echo "Running Ansible playbooks (update ansible/hosts.ini with EC2_PUBLIC_IP and RASPBERRY_PI_IP first)..."
	MSYS_NO_PATHCONV=1 docker run --rm -e ANSIBLE_HOST_KEY_CHECKING=False \
		-v "$$(pwd)/ansible:/ansible"  \
		-v "$(SSH_DIR):/root/.ssh:ro" \
		--entrypoint /bin/sh \
		$(IMAGE_NAME) -c "cd /ansible && test -f /root/.ssh/$(SSH_KEY) && cp /root/.ssh/$(SSH_KEY) /tmp/$(SSH_KEY) && chmod 600 /tmp/$(SSH_KEY) && ansible-playbook -i hosts.ini site.yml -vv --private-key /tmp/$(SSH_KEY)"

.PHONY: ansible-ping
ansible-ping:
	MSYS_NO_PATHCONV=1 docker run --rm -it -e ANSIBLE_HOST_KEY_CHECKING=False \
		-v "$$(pwd)/ansible:/ansible" \
		-v "$(SSH_DIR):/root/.ssh:ro" \
		--entrypoint /bin/sh \
		$(IMAGE_NAME) -c "test -f /root/.ssh/$(SSH_KEY) && cp /root/.ssh/$(SSH_KEY) /tmp/$(SSH_KEY) && chmod 600 /tmp/$(SSH_KEY) && ansible -i $(INVENTORY) all -m ping --private-key /tmp/$(SSH_KEY)"

.PHONY: ansible-teardown-client
ansible-teardown-client:
	MSYS_NO_PATHCONV=1 docker run --rm -e ANSIBLE_HOST_KEY_CHECKING=False \
		-v "$$(pwd)/ansible:/ansible"  \
		-v "$(SSH_DIR):/root/.ssh:ro" \
		--entrypoint /bin/sh \
		$(IMAGE_NAME) -c "test -f /root/.ssh/$(SSH_KEY) && cp /root/.ssh/$(SSH_KEY) /tmp/$(SSH_KEY) && chmod 600 /tmp/$(SSH_KEY) && ansible-playbook -i $(INVENTORY) playbooks/teardown.yml -vv --private-key /tmp/$(SSH_KEY)"


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
