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

resource "aws_ssm_parameter" "b2_key_id" {
  name        = "/backups/immich/b2_key_id"
  description = "Backblaze B2 Application Key ID for Pi 5"
  type        = "String"
  value       = b2_application_key.pi_backup_key.application_key_id

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ssm_parameter" "b2_key_secret" {
  name        = "/backups/immich/b2_key_secret"
  description = "Backblaze B2 Application Key Secret for Pi 5"
  type        = "SecureString"
  value       = b2_application_key.pi_backup_key.application_key

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ssm_parameter" "b2_bucket_name" {
  name        = "/backups/immich/b2_bucket_name"
  description = "The unique B2 bucket name for Immich backups"
  type        = "String"
  value       = b2_bucket.immich_backup.bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ssm_parameter" "restic_password" {
  name        = "/backups/immich/restic_password"
  description = "The encryption password for the Restic repository (Immich)"
  type        = "SecureString"
  value       = "initial-placeholder-value"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [value]
  }
}
