#!/bin/bash
## ~/rpi_k3s/bin/install_controller.sh 
# Installs policycoreutils git k3s k3d and docker on Controller node
# Updates $USER as owner so sudo is not required on k3s/docker
# Enables containerd
# Checks versions to confirm installation
sudo apt-get -y install git && sudo apt-get -y install policycoreutils ; wait
# root install shell
sudo -s
# docker install
apt-get update -y && apt-get upgrade -y && curl -fsSL https://get.docker.com -o get-docker.sh && bash get-docker.sh ; wait
# docker own
sudo usermod -aG docker $USER && newgrp docker && sudo chown "$USER":"$USER" /home/"$USER"/.docker -R && chmod g+rwx "$HOME/.docker" -R ; wait
# docker startup
sudo systemctl enable docker.service && sudo systemctl enable containerd.service ; wait
exit
# k3d install
sudo wget -O k3d-linux-arm64 https://github.com/rancher/k3d/releases/download/v3.1.5/k3d-linux-arm64 && sudo mv k3d-linux-arm64 /usr/local/bin/k3d && sudo chmod +x /usr/local/bin/k3d ; wait
# k3s install
curl -sfL https://get.k3s.io | sh ; wait
# k3s own
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
# good practice
sudo apt-get upgrade -y && apt-get update -y ; wait
# print token
sudo cat /var/lib/rancher/k3s/server/node-token
# Check install verify versions and list nodes
k3s --version && k3d --version && docker --version && kubectl get nodes
