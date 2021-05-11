# Automated Cloudflare Tunnel pointing to HTTPbin/SSH + Zero Trust for SSH

1. Copy repo to your local workstation
2. Change directory (cd) to the repo's location on your local workstation
3. Copy the `terraform.tfvars.example` file to `terraform.tfvars`
4. Fill in the quotes in `terraform.tfvars` with your Cloudflare information
5. Run `terraform apply` to initiate config

## Requirements

- Terraform version 0.13 +
- GCP (Google Cloud) cli setup and authenticated to a GCP project with compute access. 
- Cloudflare account and zone with at least 1 Access seat

## Setup

Typically takes ~4 mins to fully spin up. 

This demo creates a Google Cloud (GCP) instance running an httpbin docker container.

It also spins up a Cloudflare Tunnel on the GCP instance proxying traffic to the httpbin container
and the local SSH port on the server.

DNS records are created at Cloudflare to point to the tunnel endpoint. 

The GCP instance is set to not accept SSH traffic via a `no-ssh` tag. Your Firewall settings may differ and this may need to be adjusted as needed.

An access policy is created for `ssh.yourdomain.com` and the only person allowed is the user 
provided to `cloudflare_email` (this is the email you use to login to manage your Cloudflare zone(s)) in `terraform.tfvars`.

Update your workstation's SSH config to provide a specific host block for `ssh.yourdomain.com`.

Here is an example:

```
Host ssh.yourdomain.com
    IdentityFile /Users/user/.ssh/google_compute_engine
    ProxyCommand /usr/local/bin/cloudflared access ssh --hostname %h
```

You can then `ssh user@ssh.yourdomain.com` where user is your OS user to login.

## Endpoints

Where `yourdomain.com` is the zone assigned to `cloudflare_zone` in the `terraform.tfvars` file.

 - `yourdomain.com` allows access to the HTTPBin webserver
 - `ssh.yourdomain.com` allows access to the SSH server running on the GCP instance
