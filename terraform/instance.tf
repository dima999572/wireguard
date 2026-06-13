resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.ubuntu_24.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  associate_public_ip_address = true
  tags = {
    Name = "${var.key_name}-instance"
  }
}
