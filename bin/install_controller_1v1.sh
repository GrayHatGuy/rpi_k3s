#!/bin/bash
## ~/rpi_k3s/bin/install_controller.sh 
# Installs policycoreutils git k3s k3d and docker on Controller node
# Updates $USER as owner so sudo is not required on k3s/docker
# Enables containerd
# Checks versions to confirm installation
sudo apt-get -y install git && sudo apt-get -y install policycoreutils &&
wait
sudo wget -O k3d-linux-arm64 https://github.com/rancher/k3d/releases/download/v3.1.5/k3d-linux-arm64 && sudo mv k3d-linux-arm64 /usr/local/bin/k3d && sudo chmod +x /usr/local/bin/k3d && echo "k3d installed" &&
wait
# k3s install
sudo curl -sfL https://get.k3s.io | sh &&
wait 
echo "k3s installed"
#k3s own
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
# good practice
sudo apt-get update -y && sudo apt-get upgrade -y && echo "k3d installed" && wait
sudo curl -fsSL https://get.docker.com -o get-docker.sh && wait && echo "Pausing for completion of script" && pause 120
# docker own
sudo bash get-docker.sh && echo "Docker installed" && wait && sudo usermod -aG docker $USER && newgrp docker && sudo chown "$USER":"$USER" /home/"$USER"/.docker -R && chmod g+rwx "$HOME/.docker" -R && echo "Docker sudo own" && wait
# docker startup
sudo systemctl enable docker.service && sudo systemctl enable containerd.service && wait && echo "Docker service" && sudo apt-get upgrade -y && sudo apt-get update -y && wait
# Check install verify versions and list nodes
k3s --version && k3d --version && docker --version && kubectl get nodes && wait 
# print token and ip
echo "Installation complete"
echo "Use token below when installing agent nodes"
sudo cat /var/lib/rancher/k3s/server/node-token
var=$(hostname -I)
echo "Controller IP: " $var
