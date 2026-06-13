resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../ansible/hosts.ini.tpl", {
    ec2_public_ip = aws_instance.ec2.public_ip
  })
  filename = "${path.module}/../ansible/hosts.ini"
}