# GCP Kubernetes cluster with Nginx Ingress Controller behind Cloudflare Tunnel

## Requirements

- Terraform version 0.15+
- GCP (Google Cloud) CLI setup and [authenticated to a GCP project](https://cloud.google.com/sdk/gcloud/reference/auth/application-default/login) with compute access. 
- Helm CLI [installed](https://helm.sh/docs/intro/install/)

## Deployment
1. Copy repo to your local workstation
2. Change directory (cd) to the example's location on your local workstation
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
    ```
4. Run `terraform init` and `terraform apply` to deploy the full stack

## Setup

Typically takes ~5 mins to fully spin up. 

This demo 
- Creates a Google Cloud (GCP) Kubernetes Engine (GKE)
- Spins up `nginx-ingress-controller` on GKE cluster using Helm
- Spins up a Cloudflare Tunnel with 2 replicas on GKE cluster and points it to the `nginx-ingress-controller`
- Creates Cloudflare token for managing DNS records in the specified zone and creates Kubernetes secret for `external-dns`
- Spins up `external-dns` to automatically manage DNS records pointing to Cloudflare Tunnel for any Kubernetes ingress resources that use specified Cloudflare zone domain
- Spins up example applications demonstrating all above
  - `docker-helloworld` (https://docker-helloworld.yourzone.com)
  - `echoserver` (https://echoserver.yourzone.com)
  - `httpbin` (https://httpbin.yourzone.com)

### Cloudflare Tunnel 
Deployed Cloudflare Tunnel proxied all traffic to the `nginx-ingress-controller`, which handles the load-balancing based on the ingress resources.

### External DNS
Deployed external-dns automatically create and manage DNS records in your zone pointing to the Cloudflare Tunnel.

Example of Ingress resource that will expose Kubernetes service through Cloudflare Tunnel by creating a CNAME of `httpbin.yourzone.com` pointing to `gke-tunnel-origin.yourzone.com`.

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    # gke-tunnel-origin.yourzone.com is not proxied CNAME to your tunnel
    # it is created by Terraform in cloudflare-tunnel.tf
    external-dns.alpha.kubernetes.io/target: gke-tunnel-origin.yourzone.com
    kubernetes.io/ingress.class: nginx
  name: httpbin
  namespace: httpbin
spec:
  rules:
  - host: httpbin.yourzone.com
    http:
      paths:
      - backend:
          serviceName: httpbin
          servicePort: 80
```