variable "region" {
  description = "AWS region"
  type        = string
}

#region Deprecated
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name for the AWS key pair to create"
  type        = string
}
#endregion

#region DNS Management
variable "root_domain" {

  description = "The root DNS zone"
  type        = string
}

variable "subdomain" {
  description = "The subdomain label"
  type        = string
}

variable "ns_record_count" {
  description = "The number of NS records to create for Route53 delegation. AWS standard is 4."
  type        = number
  default     = 4
}

variable "cloudflare_api_token" {
  description = "CloudFlare Api Token"
  type        = string
}
#endregion