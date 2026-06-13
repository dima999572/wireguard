variable "region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name for the AWS key pair to create"
  type        = string
}

variable "public_key_path" {
  description = "Path to the public SSH key to upload (e.g., ./deploy_key.pub)"
  type        = string
}
