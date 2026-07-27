[vpn_server]
ec2_server ansible_host=${ec2_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/aws_ec2 ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

[all:vars]
ansible_python_interpreter=/usr/bin/python3