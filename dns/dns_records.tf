data "cloudflare_zones" "this" {
  name = var.root_domain
}

resource "cloudflare_dns_record" "ns_delegation" {
  for_each = toset(aws_route53_zone.home.name_servers)
  zone_id  = local.cloudflare_zone_id
  name     = var.subdomain
  ttl      = 3600
  type     = "NS"
  content  = each.value
  comment  = "Route53 delegation"
}
