output "hosted_zone_arn" {
  description = "Amazon Resource Name (ARN) of the hosted zone"
  value       = aws_route53_zone.home.arn
}

output "hosted_zone_id" {
  description = "Hosted zone ID"
  value       = aws_route53_zone.home.zone_id
}

output "hosted_zone_name_servers" {
  description = "List of name servers for the hosted zone"
  value       = aws_route53_zone.home.name_servers
}

output "hosted_zone_primary_name_server" {
  description = "Primary Route53 name server for the SOA record"
  value       = aws_route53_zone.home.primary_name_server
}

output "cloudflare_zones" {
  value = local.cloudflare_zone_id
}