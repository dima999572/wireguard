resource "aws_ssm_parameter" "age_key_backup" {
  name        = "/backups/sops-age-key"
  description = "Backup of the SOPS Age Private Key"
  type        = "SecureString"
  value       = "initial-placeholder-value"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [value]
  }
}