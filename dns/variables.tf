variable "region" {
  description = "AWS region"
  type        = string
}

variable "root_domain" {
  description = "The root DNS zone"
  type        = string
}

variable "subdomain" {
  description = "The subdomain label"
  type        = string
}

variable "cloudflare_api_token" {
  description = "CloudFlare Api Token"
  type        = string
}