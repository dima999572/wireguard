locals {
  bucket_name = "ssm-sessions-${data.aws_caller_identity.current.account_id}"
}