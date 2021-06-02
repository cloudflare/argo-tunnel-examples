# OS the server will use
data "google_compute_image" "image" {
  family  = "ubuntu-minimal-2004-lts"
  project = "ubuntu-os-cloud"
}

resource "random_password" "postgresql_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# GCP Instance resource 
resource "google_compute_instance" "origin" {
  name         = "zerotrust-postgrest-example"
  machine_type = var.gcp_machine_type
  zone         = var.gcp_zone
  // Your tags may differ. This one instructs the networking to not allow access to port 22
  tags = ["no-ssh"]

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
  // This is where we configure the server (aka instance) on startup.
  metadata_startup_script = templatefile("./gcp-instance-startup-script.tpl",
    {
      ssh_subdomain       = var.cloudflare_ssh_subdomain,
      postgrest_subdomain = var.cloudflare_postgrest_subdomain,
      postgresql_password = random_password.postgresql_password.result,
      cf_account_id       = var.cloudflare_account_id,
      cf_zone             = var.cloudflare_zone,
      cf_tunnel_id        = cloudflare_argo_tunnel.auto_tunnel.id,
      cf_tunnel_name      = cloudflare_argo_tunnel.auto_tunnel.name,
      cf_tunnel_secret    = random_id.tunnel_secret.b64_std
  })
}
