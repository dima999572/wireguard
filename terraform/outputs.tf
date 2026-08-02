# output "instance_id" {
#   value = aws_instance.ec2.id
# }

# output "public_ip" {
#   value = aws_instance.ec2.public_ip
# }

# output "public_dns" {
#   value = aws_instance.ec2.public_dns
# }

#region Deprecated
output "ssm_bucket_name" {
  description = "The name of the S3 bucket for SSM Session Manager logs"
  value       = local.bucket_name
}
#endregion

#region Backup
output "backup_bucket_name" {
  value       = b2_bucket.immich_backup.bucket_name
  description = "The unique name of the B2 bucket. Put this in 'b2_bucket_name' in Ansible secrets."
}

output "backup_key_id" {
  value       = b2_application_key.pi_backup_key.application_key_id
  description = "The Key ID for the Pi 5. Put this in 'b2_key_id' in Ansible secrets."
}

output "backup_key_secret" {
  value       = b2_application_key.pi_backup_key.application_key
  description = "The Secret Key for the Pi 5. Put this in 'b2_key_secret' in Ansible secrets. IT WILL ONLY SHOW ONCE!"
  sensitive   = true
}
#endregion

#region DNS
output "hosted_zone_arn" {
  description = "Amazon Resource Name (ARN) of the hosted zone"
  value       = aws_route53_zone.home.arn
}

output "hosted_zone_id" {
  description = "Hosted zone ID"
  value       = aws_route53_zone.home.zone_id
}

output "hosted_zone_name_servers" {
  description = "List of name servers for the hosted zone"
  value       = aws_route53_zone.home.name_servers
}

output "hosted_zone_primary_name_server" {
  description = "Primary Route53 name server for the SOA record"
  value       = aws_route53_zone.home.primary_name_server
}

output "cloudflare_zones" {
  value = local.cloudflare_zone_id
}
#endregion