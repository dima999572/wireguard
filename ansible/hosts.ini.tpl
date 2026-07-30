[vpn_server]
${ec2_instance_id}

[vpn_server:vars]
ansible_connection=aws_ssm
ansible_aws_ssm_region=${region}
ansible_aws_ssm_bucket_name=${s3_bucket_name}
vpn_endpoint=${vpn_endpoint}

[raspberry]
raspberry

[raspberry:vars]
ansible_connection=ssh
