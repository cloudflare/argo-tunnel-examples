# Providers
provider "cloudflare" {
  email      = var.cloudflare_email
  account_id = var.cloudflare_account_id
  api_key    = var.cloudflare_token
}
provider "google" {
  project = var.gcp_project_id
}

data "google_client_config" "default" {}

provider "helm" {
  kubernetes {
    host                   = google_container_cluster.example.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.example.master_auth.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = google_container_cluster.example.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.example.master_auth.0.cluster_ca_certificate)
}


provider "random" {}
