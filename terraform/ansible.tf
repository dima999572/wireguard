resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../ansible/hosts.ini.tpl", {
    ec2_instance_id = aws_instance.ec2.id
    region          = data.aws_region.current.region
  })
  filename = "${path.module}/../ansible/hosts.ini"
}