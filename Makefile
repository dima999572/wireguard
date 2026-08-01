# ==============================================================================
# Variables
# ==============================================================================
# Ansible Config
IMAGE_NAME = ansible-wireguard-runner
INVENTORY = hosts.ini
PLAYBOOK = site.yml	
# Host paths and Pi connection details come from .env, which is not tracked.
# Copy .env.example and fill it in. Paths must be in a form Docker understands,
# so on Windows write them as C:/Users/<you>/... rather than /c/Users/<you>/...
-include .env
export

# Terraform Config
TF_DIR = ./terraform

# Optional: set DOCKER_NETWORK=host in .env if the container cannot reach the Pi
# on your LAN (common with Docker Desktop). Requires host networking enabled.
DOCKER_NETWORK ?=

# The "Base" Docker command
DOCKER_RUN_BASE = MSYS_NO_PATHCONV=1 docker run --rm \
    $(if $(DOCKER_NETWORK),--network $(DOCKER_NETWORK)) \
	-e ANSIBLE_HOST_KEY_CHECKING=False \
    -e ANSIBLE_ROLES_PATH=/project/ansible/roles \
    -e SOPS_AGE_KEY_FILE=/root/.config/sops/age/keys.txt \
    -e PI_HOST \
    -e PI_USER \
    -v "$$(pwd):/project" \
    -v "$(SSH_KEY):/ssh/id_key:ro" \
    -v "$(SOPS_DIR):/root/.config/sops:ro" \
    -v "$(AWS_DIR):/root/.aws:ro" \
    --workdir /project/ansible

DOCKER_RUN_CMD = $(DOCKER_RUN_BASE) $(IMAGE_NAME)

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

.PHONY: check-env
check-env:
	@test -n "$(PI_HOST)" || { echo "PI_HOST is not set - see .env.example"; exit 1; }
	@test -n "$(PI_USER)" || { echo "PI_USER is not set - see .env.example"; exit 1; }
	@test -f "$(SSH_KEY)" || { echo "SSH key not found: '$(SSH_KEY)' - check SSH_KEY in .env"; exit 1; }
	@test -d "$(AWS_DIR)" || { echo "AWS dir not found: '$(AWS_DIR)' - check AWS_DIR in .env"; exit 1; }
	@test -d "$(SOPS_DIR)" || { echo "SOPS dir not found: '$(SOPS_DIR)' - check SOPS_DIR in .env"; exit 1; }

.PHONY: ansible-run-all
ansible-run-all: check-env ansible-build
	$(DOCKER_RUN_CMD) -i $(INVENTORY) site.yml

.PHONY: ansible-generate-profiles
ansible-generate-profiles: check-env ansible-build
	$(DOCKER_RUN_CMD) -i $(INVENTORY) playbooks/generate_profiles.yml -vvv

.PHONY: ansible-wg-server
ansible-wg-server: check-env ansible-build
	$(DOCKER_RUN_CMD) -i $(INVENTORY) playbooks/wg_server.yml

.PHONY: ansible-config-raspberry
ansible-config-raspberry: check-env ansible-build
	$(DOCKER_RUN_CMD) -i $(INVENTORY) playbooks/config_raspberry.yml

.PHONY: ansible-wg-raspberry
ansible-wg-raspberry: check-env ansible-build
	$(DOCKER_RUN_CMD) -i $(INVENTORY) playbooks/wg_raspberry.yml

.PHONY: ansible-ts-raspberry
ansible-ts-raspberry: check-env ansible-build
	$(DOCKER_RUN_CMD) -i $(INVENTORY) playbooks/ts_raspberry.yml

.PHONY: ansible-immich
ansible-immich: check-env ansible-build
	$(DOCKER_RUN_CMD) -i $(INVENTORY) playbooks/immich.yml

.PHONY: ansible-monitoring
ansible-monitoring: check-env ansible-build
	$(DOCKER_RUN_CMD) -i $(INVENTORY) playbooks/monitoring.yml

# One-time: prompts for the Pi sudo password and installs NOPASSWD for PI_USER.
# After this succeeds, ansible-wg-raspberry needs only the SSH key.
.PHONY: ansible-setup-pi-sudo
ansible-setup-pi-sudo: check-env ansible-build
	$(DOCKER_RUN_BASE) -it $(IMAGE_NAME) -i $(INVENTORY) playbooks/setup_pi_sudo.yml --ask-become-pass
