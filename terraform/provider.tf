terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.47.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.9.0"
    }
  }
  required_version = ">= 1.15.5"
}

provider "aws" {
  region = var.region
}

provider "local" {}