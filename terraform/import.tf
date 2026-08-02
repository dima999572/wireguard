/*
# --- Historical Migration Records ---
# These import blocks were used to migrate existing resources into this unified state.

import {
  to = aws_route53_zone.home
  id = "<AWS_HOSTED_ZONE_ID>"
}

import {
  to = cloudflare_dns_record.ns_delegation[0]
  id = "<CLOUDFLARE_ZONE_ID>/<CLOUDFLARE_NS_RECORD_ID_1>"
}

import {
  to = cloudflare_dns_record.ns_delegation[1]
  id = "<CLOUDFLARE_ZONE_ID>/<CLOUDFLARE_NS_RECORD_ID_2>"
}

import {
  to = cloudflare_dns_record.ns_delegation[2]
  id = "<CLOUDFLARE_ZONE_ID>/<CLOUDFLARE_NS_RECORD_ID_3>"
}

import {
  to = cloudflare_dns_record.ns_delegation[3]
  id = "<CLOUDFLARE_ZONE_ID>/<CLOUDFLARE_NS_RECORD_ID_4>"
}
*/
