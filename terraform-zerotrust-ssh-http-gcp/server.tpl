# Script to install Cloudflare Tunnel and Docker resources
# Docker configuration
cd /tmp
sudo apt-get install software-properties-common
# Retrieveing the docker repository for this OS
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
# The OS is updated and docker is installed
sudo apt update -y && sudo apt upgrade -y
sudo apt install docker docker-compose -y 
# This is a herefile that is used to populate the /tmp/docker-compose.yml file. This logic is used elsewhere in this script 
cat > /tmp/docker-compose.yml << "EOF"
version: '3'
services:
  httpbin:
    image: kennethreitz/httpbin
    restart: always
    container_name: httpbin
    ports:
      - 8080:80
EOF

# cloudflared configuration
cd ~
# The package for this OS is retrieved 
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
# A local user directory is first created before we can install the tunnel as a system service 
mkdir ~/.cloudflared
touch ~/.cloudflared/cert.json
touch ~/.cloudflared/config.yml
# Another herefile is used to dynamically populate the JSON credentials file 
cat > ~/.cloudflared/cert.json << "EOF"
{
    "AccountTag"   : "${account}",
    "TunnelID"     : "${tunnel_id}",
    "TunnelName"   : "${tunnel_name}",
    "TunnelSecret" : "${secret}"
}
EOF
# Same concept with the Ingress Rules the tunnel will use 
cat > ~/.cloudflared/config.yml << "EOF"
tunnel: ${tunnel_id}
credentials-file: /etc/cloudflared/cert.json
logfile: /var/log/cloudflared.log
loglevel: info

ingress:
  - hostname: ${web_zone}
    service: http://localhost:8080
  - hostname: ssh.${web_zone}
    service: ssh://localhost:22
  - hostname: "*"
    path: "^/_healthcheck$"
    service: http_status:200
  - hostname: "*"
    service: hello-world
EOF
# Now we install the tunnel as a systemd service 
sudo cloudflared service install
# The credentials file does not get copied over so we'll do that manually 
sudo cp -via ~/.cloudflared/cert.json /etc/cloudflared/
# Now we can bring up our container(s) with docker-compose and then start the tunnel 
cd /tmp
sudo docker-compose up -d && sudo systemctl start cloudflared
