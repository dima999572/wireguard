# ==============================================================================
# Variables
# ==============================================================================
# Ansible Config
IMAGE_NAME = ansible-wireguard-runner
INVENTORY = hosts.ini
PLAYBOOK = site.yml	
WINDOWS_HOME = C:/Users/Dzmitry
AWS_DIR = $(WINDOWS_HOME)/.aws
SSH_DIR = $(WINDOWS_HOME)/.ssh
SOPS_DIR = $(APPDATA)/sops

# Terraform Config
TF_DIR = ./terraform

# The "Base" Docker command
DOCKER_RUN_CMD = MSYS_NO_PATHCONV=1 docker run --rm \
    -e ANSIBLE_HOST_KEY_CHECKING=False \
    -e ANSIBLE_ROLES_PATH=/project/ansible/roles \
    -e SOPS_AGE_KEY_FILE=/root/.config/sops/age/keys.txt \
    -e AWS_REGION=eu-central-1 \
    -e AWS_DEFAULT_REGION=eu-central-1 \
    -v "$$(pwd):/project" \
    -v "$(SSH_DIR):/root/.ssh:ro" \
    -v "$(SOPS_DIR):/root/.config/sops:ro" \
    -v "$(AWS_DIR):/root/.aws:ro" \
    --workdir /project/ansible \
    $(IMAGE_NAME)

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

.PHONY: ansible-run-all
ansible-run-all: ansible-build
	$(DOCKER_RUN_CMD) -i $(INVENTORY) site.yml

.PHONY: ansible-generate-profiles
ansible-generate-profiles: ansible-build
	$(DOCKER_RUN_CMD) -i $(INVENTORY) playbooks/generate_profiles.yml -vvv

.PHONY: ansible-wg-server
ansible-run-vpn: ansible-build
	$(DOCKER_RUN_CMD) -i $(INVENTORY) playbooks/wg_server.yml

.PHONY: ansible-wg-raspberry
ansible-wg-raspberry: ansible-build
	$(DOCKER_RUN_CMD) -i $(INVENTORY) playbooks/wg_raspberry.yml

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
