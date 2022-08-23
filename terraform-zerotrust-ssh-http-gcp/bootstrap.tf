# Providers
provider "cloudflare" {
  account_id = var.cloudflare_account_id
  api_token    = var.cloudflare_token
}
provider "google" {
  project    = var.gcp_project_id
}

provider "random" {
}

# GCP variables
variable "gcp_project_id" {
  description = "Google Cloud Platform (GCP) Project ID."
  type        = string
}

variable "zone" {
  description = "GCP zone name."
  type        = string
}

variable "machine_type" {
  description = "GCP VM instance machine type."
  type        = string
}

# Cloudflare Variables
variable "cloudflare_zone" {
  description = "The Cloudflare Zone to use."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "The Cloudflare UUID for the Zone to use."
  type        = string
}

variable "cloudflare_account_id" {
  description = "The Cloudflare UUID for the Account the Zone lives in."
  type        = string
  sensitive   = true
}

variable "cloudflare_email" {
  description = "The Cloudflare user."
  type        = string
  sensitive   = true
}

variable "cloudflare_token" {
  description = "The Cloudflare user's API token."
  type        = string
}
