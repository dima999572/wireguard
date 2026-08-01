# resource "local_file" "ansible_inventory" {
#   content = templatefile("${path.module}/../ansible/hosts.ini.tpl", {
#     ec2_instance_id = aws_instance.ec2.id
#     region          = data.aws_region.current.region
#     s3_bucket_name  = local.bucket_name
#     vpn_endpoint    = aws_instance.ec2.public_ip
#   })
#   filename = "${path.module}/../ansible/hosts.ini"
# }