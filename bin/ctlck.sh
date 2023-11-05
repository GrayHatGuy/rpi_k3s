# Check install verify versions and list nodes
k3s --version ; k3d --version ; docker --version ; kubectl get nodes
# print token and ip
echo "Use token below when installing agent nodes"
sudo cat /var/lib/rancher/k3s/server/node-token
var=$(hostname -I)
echo "Controller IP: " $var