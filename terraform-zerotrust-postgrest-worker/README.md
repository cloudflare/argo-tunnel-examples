# Automated Cloudflare Tunnel pointing to PostgREST (PostgreSQL proxy) + Zero Trust Access from Workers

1. Copy repo to your local workstation
2. Change directory (cd) to the repo's location on your local workstation
3. Set the following environment variables
    ```bash
    # required
    export TF_VAR_gcp_project_id=
    export TF_VAR_cloudflare_account_id=
    export TF_VAR_cloudflare_zone=
    export TF_VAR_cloudflare_email=
    export TF_VAR_cloudflare_token=
    # optional, defaults to following values
    export TF_VAR_gcp_zone=us-east1-b
    export TF_VAR_gcp_machine_type=f1-micro
    export TF_VAR_cloudflare_ssh_subdomain=zerotrust-ssh-example
    export TF_VAR_cloudflare_postgrest_subdomain=zerotrust-postgrest-example
    export TF_VAR_cloudflare_worker_subdomain=zerotrust-worker-example
    ```
4. Run `terraform apply` to initiate config

## Requirements

- Terraform version 0.13 +
- GCP (Google Cloud) cli setup and [authenticated to a GCP project](https://cloud.google.com/sdk/gcloud/reference/auth/application-default/login) with compute access. 
- Cloudflare account and zone with at least 1 Access seat

## Setup

Typically takes ~5 mins to fully spin up. 

This demo 
- creates a Google Cloud (GCP) instance running an [PostgreSQL](https://hub.docker.com/_/postgres) and [PostgREST](https://hub.docker.com/r/postgrest/postgrest/) docker container.
- spins up a Cloudflare Tunnel on the GCP instance proxying traffic to the PostgREST container
and the local SSH port on the server
- deploys Cloudflare Worker (+route) that is using Cloudflare Access service tokens to access the protected PostgREST endpoint
- creates DNS records at Cloudflare to point to the tunnel endpoints and for the [example Worker](./cloudflare-worker-script.js)

The GCP instance is set to not accept SSH traffic via a `no-ssh` tag. Your Firewall settings may differ and this may need to be adjusted as needed.

An access policy is created for 
- `zerotrust-ssh-example.yourzone.com` _(or your configured subdomain via `TF_VAR_cloudflare_ssh_subdomain` variable)_ 
- `zerotrust-postgrest-example.yourzone.com` _(or your configured subdomain via `TF_VAR_cloudflare_postgrest_subdomain` variable)_
- `zerotrust-worker-example.yourzone.com` _(or your configured subdomain via `TF_VAR_cloudflare_worker_subdomain` variable)_

The only person allowed to all of them is the user provided to `TF_VAR_cloudflare_email` environment variable.

## Zero Trust access to your instance
### local SSH
Update your workstation's SSH config to provide a specific host block for `zerotrust-ssh-example.yourzone.com`.

Here is an example:

```
Host zerotrust-ssh-example.yourzone.com
    IdentityFile /Users/user/.ssh/google_compute_engine
    ProxyCommand /usr/local/bin/cloudflared access ssh --hostname %h
```

You can then `ssh user@zerotrust-ssh-example.yourzone.com` where user is your OS user to login.

## Endpoints

Where `yourzone.com` is the zone assigned to `TF_VAR_cloudflare_zone` environment variable.

- `zerotrust-ssh-example.yourzone.com` Access protected for SSH access, exposed with Cloudflare Tunnel
- `zerotrust-postgrest-example.yourzone.com` Access PostgREST (PostgreSQL proxy), exposed with Cloudflare Tunnel
- `zerotrust-worker-example.yourzone.com` publicly available [example Worker](./cloudflare-worker-script.js) querying PostgREST from the Cloudflare Edge, using Cloudflare Access service token

## The fun
The demo has very simple functionality, you can 
- generate a new user visit (https://zerotrust-worker-example.yourzone.com/new)
- get a list of all users (https://zerotrust-worker-example.yourzone.com)
- get a list of all users filtered by country (https://zerotrust-worker-example.yourzone.com/?country=ireland)

## Tips
- [supabase/postgrest-js](https://github.com/supabase/postgrest-js) library is fully compatible with any postgrest instance
    ```javascript
    const REST_URL = 'https://zerotrust-worker-example.yourzone.com'
    const postgrest = new PostgrestClient(REST_URL, {
      headers: {
        'CF-Access-Client-Id': CF_ACCESS_CLIENT_ID,
        'CF-Access-Client-Secret': CF_ACCESS_CLIENT_SECRET,
      }
    })
    const { data, error } = await postgrest
        .from('example_table')
        .insert(records)
    ```
- You can also use [SSH Web Terminal](https://blog.cloudflare.com/browser-ssh-terminal-with-auditing/), this was not included as there is no Terraform support for the SSH-enabled Access Policy yet
