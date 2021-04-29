# Instance information
data "google_compute_image" "image" {
  family  = "ubuntu-minimal-1804-lts"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "origin" {
  name         = "dlg-test"
  machine_type = var.machine_type
  zone         = var.zone
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
  // Optional config to make instance ephermaral 
  scheduling {
    preemptible       = true
    automatic_restart = false
  }

  metadata_startup_script = templatefile("./server.tpl", 
    {
      web_zone    = var.cloudflare_zone,
      account     = var.cloudflare_account_id,
      tunnel_id   = cloudflare_argo_tunnel.auto_tunnel.id,
      tunnel_name = cloudflare_argo_tunnel.auto_tunnel.name,
      secret      = random_id.argo_secret.b64_std
    })
}



# DNS settings to CNAME to tunnel target
resource "cloudflare_record" "http_app" {
  zone_id = var.cloudflare_zone_id
  name    = var.cloudflare_zone
  value   = "${cloudflare_argo_tunnel.auto_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "ssh_app" {
  zone_id = var.cloudflare_zone_id
  name    = "ssh"
  value   = "${cloudflare_argo_tunnel.auto_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}