resource "google_container_cluster" "example" {
  name               = "terraform-example-gke"
  location           = var.gcp_zone
  initial_node_count = 2

  node_config {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    preemptible = true
  }

  timeouts {
    create = "30m"
    update = "40m"
  }
}
