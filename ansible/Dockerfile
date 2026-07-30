FROM alpine:3.21

# 1. Install System Packages
# We install 'ansible' which provides the core engine
RUN apk add --no-cache \
    ansible \
    python3 \
    py3-pip \
    py3-boto3 \
    py3-botocore \
    py3-cryptography \
    py3-yaml \
    py3-qrcode \
    py3-pypng \
    curl \
    ca-certificates \
    binutils \
    wireguard-tools \
    openssh-client \
    gcompat \
    libc6-compat

# 2. Install AWS SSM Plugin
RUN mkdir -p /tmp/ssm && cd /tmp/ssm && \
    curl -L "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "plugin.deb" && \
    ar x plugin.deb && tar -xf data.tar.gz && \
    mv usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/ && \
    chmod +x /usr/local/bin/session-manager-plugin && \
    cd / && rm -rf /tmp/ssm

# 3. Install SOPS
RUN curl -L "https://github.com/getsops/sops/releases/download/v3.9.0/sops-v3.9.0.linux.amd64" -o "/usr/local/bin/sops" && \
    chmod +x /usr/local/bin/sops

# 4. The "Priority" Installation
# We install the official, fixed Amazon collection into its own folder.
# This separates it from the buggy 'community' version in /usr/lib.
RUN mkdir -p /usr/share/ansible/collections && \
    ansible-galaxy collection install amazon.aws community.sops community.docker community.general \
    -p /usr/share/ansible/collections

WORKDIR /project/ansible
ENTRYPOINT ["ansible-playbook"]