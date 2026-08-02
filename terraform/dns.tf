#region AWS Route53
resource "aws_route53_zone" "home" {
  name = join(".", [var.subdomain, var.root_domain])
}
#endregion

#region Cloudflare delegation
resource "cloudflare_dns_record" "ns_delegation" {
  count   = var.ns_record_count
  zone_id = local.cloudflare_zone_id
  name    = var.subdomain
  ttl     = 3600
  type    = "NS"
  content = element(aws_route53_zone.home.name_servers, count.index)
  comment = "Route53 delegation"
}
#endregion