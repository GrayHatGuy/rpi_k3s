#!/bin/bash
## ~/rpi_k3s/bin/install_worker.sh
# Installs policycoreutils git k3s k3d and docker on worker nodes
# Updates $USER as owner so sudo is not required on k3s/docker
# Enables containerd
# Checks versions to confirm installation
sudo apt-get -y install git && sudo apt-get -y install policycoreutils &&
wait
# docker install
sudo apt-get update -y && sudo apt-get upgrade -y &&
wait
sudo curl -fsSL https://get.docker.com -o get-docker.sh &&
wait
sudo bash get-docker.sh &&
wait
echo "Docker installed"
# docker own
sudo usermod -aG docker $USER && newgrp docker && sudo chown "$USER":"$USER" /home/"$USER"/.docker -R && chmod g+rwx "$HOME/.docker" -R &&
wait
echo "Docker sudo own"
# docker startup
sudo systemctl enable docker.service && sudo systemctl enable containerd.service &&
echo "Docker service start"
wait
# good practice
sudo apt-get upgrade -y && apt-get update -y &&
wait
 k3d install
sudo wget -O k3d-linux-arm64 https://github.com/rancher/k3d/releases/download/v3.1.5/k3d-linux-arm64 && sudo mv k3d-linux-arm64 /usr/local/bin/k3d && sudo chmod +x /usr/local/bin/k3d &&
wait
echo "k3d installed"
# Prompt the user for Controller token /var/lib/rancher/k3s/server/node-token and controller URL and install k3s
read -p "Enter controller token from /var/lib/rancher/k3s/server/node-token: " TOKEN &&
wait
echo "Token entered: $TOKEN"
read -p "Enter IP address: " IP &&
wait
echo "Control ip is: $IP"
sudo curl -sfL https://get.k3s.io | K3S_URL=https://$IP:6443 K3S_TOKEN=$TOKEN sh - &&
wait
echo "k3s installed"
# good practice
sudo apt-get upgrade -y && apt-get update -y 
echo "Install complete"
