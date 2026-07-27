locals {
  cloudflare_zone_id = one([
    for zone in data.cloudflare_zones.this.result : zone.id
    if zone.name == var.root_domain
  ])
}