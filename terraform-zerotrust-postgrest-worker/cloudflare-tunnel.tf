# The random_id resource is used to generate a 35 character secret for the tunnel
resource "random_id" "tunnel_secret" {
  byte_length = 35
}

# A Named Tunnel resource called zero_trust_postgrest
resource "cloudflare_argo_tunnel" "auto_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "zero_trust_postgrest"
  secret     = random_id.tunnel_secret.b64_std
}

# DNS settings to CNAME to tunnel target for HTTP application
resource "cloudflare_record" "cloudflare_tunnel" {
  for_each = toset([var.cloudflare_ssh_subdomain, var.cloudflare_postgrest_subdomain])

  zone_id = local.cloudflare_zone_id
  name    = "${each.key}.${var.cloudflare_zone}"
  value   = "${cloudflare_argo_tunnel.auto_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}