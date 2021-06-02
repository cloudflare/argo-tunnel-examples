#!/bin/bash

# Script to install Cloudflare Tunnel and Docker resources
export DEBIAN_FRONTEND=noninteractive
# Docker configuration
cd /tmp

# Retrieveing the docker repository for this OS
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" -y
# The OS is updated and docker is installed
sudo apt update -y && sudo apt upgrade -yq
sudo apt install docker docker-compose -yq

# This is a herefile that is used to populate the /tmp/docker-compose.yml file. This logic is used elsewhere in this script 
# Inspired by https://postgrest.org/en/v7.0.0/install.html
cat <<EOF > /tmp/docker-compose.yml 
version: '3'
services:
  server:
    image: postgrest/postgrest
    ports:
      - "3000:3000"
    links:
      - db:db
    environment:
      PGRST_DB_URI: postgres://app_user:${postgresql_password}@db:5432/app_db
      PGRST_DB_SCHEMA: public
      PGRST_DB_ANON_ROLE: app_user # In production this role should not be the same as the one used for the connection
      PGRST_SERVER_PROXY_URI: "http://127.0.0.1:3000"
    depends_on:
      - db
  db:
    image: postgres
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: app_db
      POSTGRES_USER: app_user
      POSTGRES_PASSWORD: ${postgresql_password}
    volumes:
      - "./pgdata:/var/lib/postgresql/data"
EOF

# cloudflared configuration
cd
# The package for this OS is retrieved 
wget https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.deb
sudo dpkg -i cloudflared-stable-linux-amd64.deb
# A local user directory is first created before we can install the tunnel as a system service 
mkdir ~/.cloudflared || echo ~/.cloudflared already exists
# Another herefile is used to dynamically populate the JSON credentials file
cat <<EOF > ~/.cloudflared/cert.json
{
    "AccountTag"   : "${cf_account_id}",
    "TunnelID"     : "${cf_tunnel_id}",
    "TunnelName"   : "${cf_tunnel_name}",
    "TunnelSecret" : "${cf_tunnel_secret}"
}
EOF

# Same concept with the Ingress Rules the tunnel will use
# Remove any default conflicting config and create a new one
rm /etc/cloudflared/config.yml
cat <<EOF > ~/.cloudflared/config.yml
tunnel: ${cf_tunnel_id}
credentials-file: /etc/cloudflared/cert.json
logfile: /var/log/cloudflared.log
loglevel: info

ingress:
  - hostname: "*"
    path: "^/_healthcheck$"
    service: http_status:200
  - hostname: ${postgrest_subdomain}.${cf_zone}
    service: http://localhost:3000
  - hostname: ${ssh_subdomain}.${cf_zone}
    service: ssh://localhost:22
  - service: http_status:404
EOF

# The credentials file does not get copied over so we'll do that manually 
mkdir /etc/cloudflared || echo /etc/cloudflared already exists
yes | sudo cp -via ~/.cloudflared/cert.json /etc/cloudflared/
# Now we install the tunnel as a systemd service 
sudo cloudflared service install
# Now we can bring up our container(s) with docker-compose and then start the tunnel 
cd /tmp
sudo docker-compose up -d && sudo service cloudflared start

# create example db and schema we will use from our example Worker
sleep 10
sudo docker exec tmp_db_1 psql -U app_user -d app_db -c "CREATE TABLE public.visits (username text, country text, time timestamptz);" || echo table already exists
