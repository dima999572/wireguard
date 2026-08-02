terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.47.0"
    }
    b2 = {
      source  = "Backblaze/b2"
      version = "~> 0.13.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.9.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9.0"
    }
  }
  required_version = ">= 1.15.5"
}

provider "aws" {
  region = var.region
}

provider "b2" {}

provider "local" {}
provider "random" {}
