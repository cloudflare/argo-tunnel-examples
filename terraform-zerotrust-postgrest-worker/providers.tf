# Providers
provider "cloudflare" {
  email      = var.cloudflare_email
  account_id = var.cloudflare_account_id
  api_key    = var.cloudflare_token
}
provider "google" {
  project = var.gcp_project_id
}

provider "random" {}
