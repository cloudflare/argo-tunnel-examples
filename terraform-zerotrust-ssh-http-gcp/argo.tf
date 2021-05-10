# The random_id resource is used to generate a 35 character secret for the tunnel
resource "random_id" "tunnel_secret" {
  byte_length = 35
}

# A Named Tunnel resource called zero_trust_ssh_http
resource "cloudflare_argo_tunnel" "auto_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "zero_trust_ssh_http"
  secret     = random_id.tunnel_secret.b64_std
}