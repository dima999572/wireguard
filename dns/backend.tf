terraform {
  backend "s3" {
    bucket = "dima999572-ec2-tfstate"
    key    = "dns/terraform.tfstate"
    region = "eu-central-1"
  }
}
