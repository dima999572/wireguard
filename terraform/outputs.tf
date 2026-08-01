# output "instance_id" {
#   value = aws_instance.ec2.id
# }

# output "public_ip" {
#   value = aws_instance.ec2.public_ip
# }

# output "public_dns" {
#   value = aws_instance.ec2.public_dns
# }

output "ssm_bucket_name" {
  description = "The name of the S3 bucket for SSM Session Manager logs"
  value       = local.bucket_name
}