This is an example of using a [named tunnel (beta)](https://community.cloudflare.com/t/argo-tunnel-named-tunnel-beta/202445) in kubernetes. 

1. If you haven't, login to you Cloudflare account to obtain a certificate.

```
    $ cloudflared tunnel login
```

2. Create a tunnel, change example to the name you want to assign to your tunnel.

```
    $ cloudflared tunnel create example
    INFO[2020-09-05T10:48:34+01:00] Writing tunnel credentials to /Users/cf000197/.cloudflared/ef824aef-7557-4b41-a398-4684585177ad.json. cloudflared chose this file based on where your origin certificate was found.
    INFO[2020-09-05T10:48:34+01:00] Keep this file secret. To revoke these credentials, delete the tunnel.
    INFO[2020-09-05T10:48:34+01:00] Created tunnel example with id ef824aef-7557-4b41-a398-4684585177ad
```

3. Upload the tunnel credentials file to your kubernetes as a secret. Go to the directory where the credentials is saved. 

```
    $ kubectl create secret generic tunnel-credentials --from-file=ef824aef-7557-4b41-a398-4684585177ad.json 
    secret/tunnel-credentials created
```

4. Associate your Tunnel with a DNS record. Go to dashboard and create a CNAME targeting <tunnel ID>.cfargotunnel.com. In this example the tunnel ID is `ef824aef-7557-4b41-a398-4684585177ad`, so I will create CNAME targeting `ef824aef-7557-4b41-a398-4684585177ad.cfargotunnel.com`. You can create multiple CNAME records targeting the same tunnel.

    ![create CNAME](create-cname.png) 

5. Deploy cloudflared as a sidecar to your application container. In this example our application is an Nginx server. 

```
    $ kubectl apply -f deployment.yaml
    deployment.apps/named-tunnel-k8s configured
```

6. Examine status of the pod.

```
    $ kubectl get pods                         
    NAME                                READY   STATUS    RESTARTS   AGE
    named-tunnel-k8s-77479554dc-sfwb9   2/2     Running   0          7s
    $ kubectl logs $(kubectl get pod -l app=named-tunnel-k8s -o jsonpath="{.items[0].metadata.name}") argotunnel-sidecar
    INFO[2020-09-05T10:40:08Z] Cannot determine default configuration path. No file [config.yml config.yaml] in [~/.cloudflared ~/.cloudflare-warp ~/cloudflare-warp /etc/cloudflared /usr/local/etc/cloudflared]
    INFO[2020-09-05T10:40:08Z] Version 2020.8.2
    INFO[2020-09-05T10:40:08Z] GOOS: linux, GOVersion: go1.13.3, GoArch: amd64
    INFO[2020-09-05T10:40:08Z] Environment variables map[cred-file:/etc/cloudflared/credentials.json credentials-file:/etc/cloudflared/credentials.json f:true force:true proxy-dns-upstream:https://1.1.1.1/dns-query, https://1.0.0.1/dns-query]
    INFO[2020-09-05T10:40:08Z] Environmental variables map[TUNNEL_METRICS:localhost:5000 TUNNEL_URL:http://localhost:80]
    INFO[2020-09-05T10:40:08Z] Starting metrics server on 127.0.0.1:5000/metrics
    INFO[2020-09-05T10:40:08Z] Proxying tunnel requests to http://localhost:80
    INFO[2020-09-05T10:40:09Z] Connection 0 registered with MAD using ID 2b9f85c0-2ad7-40a1-8123-a29ea01506bd
    INFO[2020-09-05T10:40:10Z] Connection 1 registered with LIS using ID bb83ccd7-6d71-4bfd-b2cb-59d539613295
    INFO[2020-09-05T10:40:10Z] Connection 2 registered with MAD using ID 569fe367-5487-4cca-822e-3fcd47b860db
    INFO[2020-09-05T10:40:11Z] Connection 3 registered with LIS using ID c0a63300-644c-4bf4-918b-715af7210c6e
    $ kubectl logs $(kubectl get pod -l app=named-tunnel-k8s -o jsonpath="{.items[0].metadata.name}") nginx-server      
    /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
    /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
    /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
    10-listen-on-ipv6-by-default.sh: Getting the checksum of /etc/nginx/conf.d/default.conf
    10-listen-on-ipv6-by-default.sh: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
    /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
    /docker-entrypoint.sh: Configuration complete; ready for start up
```

7. Visit your hostname, you'll see a welcome page from Nginx. 

We love to hear your feedback! Join a discussion with other community members at https://community.cloudflare.com/t/argo-tunnel-named-tunnel-beta/202445. 
