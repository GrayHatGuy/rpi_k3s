sudo apt-get -y install git && sudo apt-get -y install policycoreutils &&
wait
k3d &
wait
k3s &
wait
dock &
wait
down &
wait
chck

k3d(){
sudo wget -O k3d-linux-arm64 https://github.com/rancher/k3d/releases/download/v3.1.5/k3d-linux-arm64 && sudo mv k3d-linux-arm64 /usr/local/bin/k3d && sudo chmod +x /usr/local/bin/k3d &&
wait
echo "k3d installed"
}

k3s(){
# k3s install
sudo curl -sfL https://get.k3s.io | sh &&
wait
echo "k3s installed"
#k3s own
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
# good practice
sudo apt-get update -y && sudo apt-get upgrade -y
echo "k3d installed"
}

dock(){
sudo curl -fsSL https://get.docker.com -o get-docker.sh &&
wait
sudo bash get-docker.sh &&
wait
echo "Docker installed"
}

down(){
# docker own
sudo usermod -aG docker $USER && newgrp docker && sudo chown "$USER":"$USER" /home/"$USER"/.docker -R && chmod g+rwx "$HOME/.docker" -R &&
wait
echo "Docker sudo own"
# docker startup
sudo systemctl enable docker.service && sudo systemctl enable containerd.service &&
wait
echo "Docker service"
# good practice
sudo apt-get upgrade -y && sudo apt-get update -y &&
wait
}

chck(){
# Check install verify versions and list nodes
k3s --version && k3d --version && docker --version && kubectl get nodes &&
wait
# print token
echo "Installation complete"
echo "Use token below when installing agent nodes"
sudo cat /var/lib/rancher/k3s/server/node-token
var=$(hostname -I)
echo "Controller IP: $var"
}
