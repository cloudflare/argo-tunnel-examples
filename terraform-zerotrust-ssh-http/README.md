# TF Automated Argo Tunnel pointing to HTTPbin/SSH + Zero Trust 

1. Copy repo to your local workstation
2. Change directory (cd) to the repo's location on your local workstation
3. Copy `terraform.tfvars.example` to `terraform.tfvars`
4. Fill in the quotes in `terraform.tfvars` with your Cloudflare information
5. Run `terraform apply` to initiate config

## Setup

Typically takes ~4 mins to fully spin up. 

This RTE (soon to be blog) creates a GCP instance running an httpbin docker container.

It also spins up a Argo Tunnel on the GCP instance proxying traffic to the httpbin container
and the local SSH port on the device.

DNS records are created at Cloudflare to point to the tunnel endpoint. 

The GCP instance is set to not accept SSH traffic.

An access policy is create for `ssh.yourdomain.com` and the only person allowed is the user 
provided to `cloudflare_email` in `terraform.tfvars`.

Update your workstation's SSH config to provide a specific host block for `ssh.yourdomain.com`.

Here is an example:

```
Host ssh.atxflare.cf
    IdentityFile /Users/cdlg/.ssh/google_compute_engine
    ProxyCommand /usr/local/bin/cloudflared access ssh --hostname %h
```

You can then `ssh user@ssh.yourdomain.com` to demo the policy.

## Endpoints

> Where `yourdomain.com` is the zone assinged to `cloudflare_zone` in `terraform.tfvars`

`yourdomain.com`

HTTPBin container 

`ssh.yourdomain.com`

SSH end point of the GCP compute instance

# Terraform version
Compatible with `0.14.*`, `0.13.*`