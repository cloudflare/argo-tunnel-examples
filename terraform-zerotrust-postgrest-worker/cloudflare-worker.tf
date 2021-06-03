resource "cloudflare_record" "postgrest_worker" {
  zone_id = local.cloudflare_zone_id
  name    = "${var.cloudflare_worker_subdomain}.${var.cloudflare_zone}"
  value   = "100::"
  type    = "AAAA"
  proxied = true
}

resource "cloudflare_worker_script" "postgrest_worker" {
  name    = "zerotrust-worker-example"
  content = file("cloudflare-worker-script.js")

  plain_text_binding {
    name = "POSTGREST_ENDPOINT"
    text = "https://${var.cloudflare_postgrest_subdomain}.${var.cloudflare_zone}"
  }

  secret_text_binding {
    name = "CF_ACCESS_CLIENT_ID"
    text = cloudflare_access_service_token.postgrest_example_worker.client_id
  }

  secret_text_binding {
    name = "CF_ACCESS_CLIENT_SECRET"
    text = cloudflare_access_service_token.postgrest_example_worker.client_secret
  }
}

resource "cloudflare_worker_route" "postgrest_worker" {
  zone_id     = local.cloudflare_zone_id
  pattern     = "${var.cloudflare_worker_subdomain}.${var.cloudflare_zone}/*"
  script_name = cloudflare_worker_script.postgrest_worker.name
}