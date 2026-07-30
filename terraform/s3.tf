module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.15.3"

  bucket = local.bucket_name

  attach_policy = true
  policy        = data.aws_iam_policy_document.ssm_sessions.json

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "ssm-session-expire"
      enabled = true
      expiration = {
        days = 1
      }
    }
  ]

  versioning = {
    enabled = false
  }
}