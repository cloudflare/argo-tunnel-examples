# OS the server will use
data "google_compute_image" "image" {
  family  = "ubuntu-minimal-2004-lts"
  project = "ubuntu-os-cloud"
}

# GCP Instance resource 
resource "google_compute_instance" "origin" {
  name         = "test"
  machine_type = var.machine_type
  zone         = var.zone
  // Your tags may differ. This one instructs the networking to not allow access to port 22
  tags         = ["no-ssh"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.image.self_link
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }
  // Optional config to make instance ephemeral 
  scheduling {
    preemptible       = true
    automatic_restart = false
  }
  // This is where we configure the server (aka instance). Variables like web_zone take a terraform variable and provide it to the server so that it can use them as a local variable
  metadata_startup_script = templatefile("./server.tpl", 
    {
      web_zone    = var.cloudflare_zone,
      account     = var.cloudflare_account_id,
      tunnel_id   = cloudflare_argo_tunnel.auto_tunnel.id,
      tunnel_name = cloudflare_argo_tunnel.auto_tunnel.name,
      secret      = random_id.tunnel_secret.b64_std
    })
}

# DNS settings to CNAME to tunnel target for HTTP application
resource "cloudflare_record" "http_app" {
  zone_id = var.cloudflare_zone_id
  name    = var.cloudflare_zone
  value   = "${cloudflare_argo_tunnel.auto_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}
# DNS settings to CNAME to tunnel target for SSH
resource "cloudflare_record" "ssh_app" {
  zone_id = var.cloudflare_zone_id
  name    = "ssh"
  value   = "${cloudflare_argo_tunnel.auto_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}
