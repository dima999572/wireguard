data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "cloudflare_zones" "this" {
  name = var.root_domain
}

#region Deprecated
data "aws_ami" "ubuntu_24" {
  most_recent = true
  # Canonical owner ID for official Ubuntu AMIs
  owners = ["099720109477"]

  filter {
    name = "name"
    # match Ubuntu 24.04 server AMIs (wildcard pattern)
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}
#endregion