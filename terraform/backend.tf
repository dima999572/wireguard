terraform {
  backend "s3" {
    bucket = "dima999572-ec2-tfstate"
    key    = "ec2/terraform.tfstate"
    region = "eu-central-1"
  }
}
