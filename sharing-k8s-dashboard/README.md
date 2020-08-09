This is an example of using Argo Tunnel to share dashboard your local kubernetes cluster with your collaborators.
It is generally not recommended to expose dashboard of production clusters. If you need to please use [Cloudflare Access](https://teams.cloudflare.com/access/) to secure it.

# Quick Start
1. Start a local kubernetes cluster. https://docs.tilt.dev/choosing_clusters.html offers great insight on choosing a local cluster. 

2. Enable dashboard service

    $ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.3/aio/deploy/recommended.yaml

3. Install Tilt. See https://docs.tilt.dev/install.html. 

4. Start the services

    $ tilt up

5. Checkout the hostname for your dashboard. This example uses a [trial version of Argo Tunnel](https://developers.cloudflare.com/argo-tunnel/trycloudflare)
so the hostname is different everytime you restart the dashboard-auth-proxy service.

6. Share the hostname with your collaborator!


# Next Step

## Want a consistent hostname?

1. Pick a zone you want to use, and download a certificate to start your tunnel. See https://developers.cloudflare.com/argo-tunnel/quickstart#step-3-login-to-your-cloudflare-account. 

2. Once you have the certificate, add the certificate as a sercret in kubernetes-dashboard namespace. Make sure to change the file path to where your cert is downloaded:

    $ kubectl create secret generic origin-cert -n kubernetes-dashboard --from-file=~/.cloudflared/cert.pem

3. Uncomment the parts marked "with Uncomment when added your origin-cert" in dashboard-auth-proxy/deployment.yaml. 

If tilt didn't pick up your new deployment file, try saving Tiltfile. 

## Secure Access

See https://developers.cloudflare.com/access/setting-up-access/securing-applications/#configure-cloudflare-access on how to configure Access rules.