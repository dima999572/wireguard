resource "aws_route53_zone" "home" {
  name = join(".", [var.subdomain, var.root_domain])
}