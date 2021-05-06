# Install Argo Tunnel
# Docker configuration
cd /tmp
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
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

# Short lived certificate configuration
sudo touch /etc/ssh/ca.pub
sudo echo "${short_key}" >> /etc/ssh/ca.pub
sudo cp -via /etc/ssh/sshd_config{,.orig}
#sudo cat >> /etc/ssh/sshd_config << "EOF"
#  PubkeyAuthentication yes
#  TrustedUserCAKeys /etc/ssh/ca.pub
#  PasswordAuthentication no
# EOF

sudo systemctl reload sshd

# cloudflared configuration
cd
wget https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.deb
sudo dpkg -i cloudflared-stable-linux-amd64.deb
mkdir ~/.cloudflared
touch ~/.cloudflared/cert.json
touch ~/.cloudflared/config.yml
cat > ~/.cloudflared/cert.json << "EOF"
{
    "AccountTag"   : "${account}",
    "TunnelID"     : "${tunnel_id}",
    "TunnelName"   : "${tunnel_name}",
    "TunnelSecret" : "${secret}"
}
EOF
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

sudo cloudflared service install
sudo cp -via ~/.cloudflared/cert.json /etc/cloudflared/

cd /tmp
sudo docker-compose up -d && sudo service cloudflared start