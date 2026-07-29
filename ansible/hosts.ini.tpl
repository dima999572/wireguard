[vpn_server]
${ec2_instance_id}

[vpn_server:vars]
ansible_connection=amazon.aws.aws_ssm
ansible_aws_ssm_region=us-east-1
