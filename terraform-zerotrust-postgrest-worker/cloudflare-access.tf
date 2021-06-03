data "cloudflare_zones" "zones" {
  filter {
    name        = var.cloudflare_zone
    lookup_type = "exact"
    status      = "active"
  }
}

locals {
  cloudflare_zone_id = lookup(element(data.cloudflare_zones.zones.zones, 0), "id")
}

# Access application to apply zero trust policy over SSH endpoint
resource "cloudflare_access_application" "app" {
  for_each = toset([var.cloudflare_ssh_subdomain, var.cloudflare_postgrest_subdomain])

  zone_id          = local.cloudflare_zone_id
  name             = "${each.key}.${var.cloudflare_zone}"
  domain           = "${each.key}.${var.cloudflare_zone}"
  session_duration = "1h"
}

# Access policy that the above appplication uses. (i.e. who is allowed in)
resource "cloudflare_access_policy" "user_email" {
  for_each = toset([var.cloudflare_ssh_subdomain, var.cloudflare_postgrest_subdomain])

  application_id = cloudflare_access_application.app[each.key].id
  zone_id        = local.cloudflare_zone_id
  name           = "${each.key}.${var.cloudflare_zone}"
  precedence     = "1"
  decision       = "allow"

  include {
    email = [var.cloudflare_email]
  }
}

# Access service token that can be used from Workers
resource "cloudflare_access_service_token" "postgrest_example_worker" {
  account_id = var.cloudflare_account_id
  name       = "PostgREST example Worker service token"
}

# Access policy to allow Worker using service tokens 
resource "cloudflare_access_policy" "postgrest_example_worker" {
  application_id = cloudflare_access_application.app[var.cloudflare_postgrest_subdomain].id
  zone_id        = local.cloudflare_zone_id
  name           = "${var.cloudflare_postgrest_subdomain}.${var.cloudflare_zone}"
  precedence     = "2"
  decision       = "non_identity"

  include {
    service_token = [cloudflare_access_service_token.postgrest_example_worker.id]
  }
}
