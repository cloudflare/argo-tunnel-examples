# GCP variables
variable "gcp_project_id" {
  description = "Google Cloud Platform (GCP) Project ID."
  type        = string
}

variable "gcp_zone" {
  description = "GCP region name."
  type        = string
  default     = "us-east1-b"
}

variable "gcp_machine_type" {
  description = "GCP VM instance machine type."
  type        = string
  default     = "f1-micro"
}

# Cloudflare Variables
variable "cloudflare_zone" {
  description = "The Cloudflare Zone to use."
  type        = string
}

variable "cloudflare_ssh_subdomain" {
  description = "The SSH subdomain to create."
  type        = string
  default     = "zerotrust-ssh-example"
}

variable "cloudflare_postgrest_subdomain" {
  description = "The PostgREST subdomain to create."
  type        = string
  default     = "zerotrust-postgrest-example"
}

variable "cloudflare_worker_subdomain" {
  description = "The example Worker subdomain route to create."
  type        = string
  default     = "zerotrust-worker-example"
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

# Variables for the bonus "any SSH host" installation
variable "ssh_host_ip" {
  description = "The SSH host IP address"
  type        = string
  default     = ""
}

variable "ssh_host_port" {
  description = "The SSH host port"
  type        = string
  default     = 22
}

variable "ssh_key_path" {
  description = "The path to your SSH key"
  type        = string
  default     = "~/.ssh/my_id_rsa"
}

variable "ssh_user" {
  description = "The SSH user"
  type        = string
  default     = "ubuntu"
}

variable "ssh_password" {
  description = "The SSH password"
  type        = string
  default     = ""
}
