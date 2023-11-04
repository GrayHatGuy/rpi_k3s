#!/bin/bash
## ~/rpi_k3s/bin/install_worker.sh
# Installs policycoreutils git k3s k3d and docker on worker nodes
# Updates $USER as owner so sudo is not required on k3s/docker
# Enables containerd
# Checks versions to confirm installation
sudo apt-get -y install git
sudo apt-get -y install policycoreutils
# root install shell
sudo -s
# docker install
apt-get update -y && apt-get upgrade -y && curl -fsSL https://get.docker.com -o get-docker.sh && bash get-docker.sh ; wait
# docker own
sudo usermod -aG docker $USER && newgrp docker && sudo chown "$USER":"$USER" /home/"$USER"/.docker -R && chmod g+rwx "$HOME/.docker" -R ; wait
# docker startup
sudo systemctl enable docker.service && sudo systemctl enable containerd.service ; wait
# good practice
sudo apt-get upgrade -y && apt-get update -y ; wait
exit
# k3d install
sudo wget -O k3d-linux-arm64 https://github.com/rancher/k3d/releases/download/v3.1.5/k3d-linux-arm64 && sudo mv k3d-linux-arm64 /usr/local/bin/k3d && sudo chmod +x /usr/local/bin/k3d ; wait
# Prompt the user for Controller token /var/lib/rancher/k3s/server/node-token and controller URL and install k3s
echo "Enter controller /var/lib/rancher/k3s/server/node-token: "
read token
echo echo "Control token is: $TOKEN"
read -p "Enter controller token from /var/lib/rancher/k3s/server/node-token: " TOKEN ; wait
read -p "Enter IP address: " IP ; wait
echo "Control ip is: $IP"
curl -sfL https://get.k3s.io | K3S_URL=https://$IP:6443 K3S_TOKEN=$TOKEN sh - ; wait
# good practice
sudo apt-get upgrade -y && apt-get update -y 
