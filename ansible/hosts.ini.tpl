[vpn_server]
ec2_server ansible_host=${ec2_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/aws_ec2

[vpn_client]
raspberry_pi ansible_host=<raspberry_pi_public_ip> ansible_user=noname ansible_ssh_private_key_file=~/.ssh/aws_ec2

[all:vars]
ansible_python_interpreter=/usr/bin/python3