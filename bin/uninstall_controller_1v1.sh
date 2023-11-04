#!/bin/bash
## ~/rpi_k3s/bin/uninstall_worker_1v1.sh
## uninstall_worker_1v1.sh uninstall k3s k3d and docker from worker
# docker nuke power down images prune network volumes verify with ps 
docker container stop $(docker container ls -aq) ; docker container rm -f $(docker container ls -aq) ; docker rmi -f $(docker images -aq) ; docker volume prune && docker network prune && docker ps && 
wait
echo "Docker cleared"
# purge docker pkg
sudo dpkg -l | grep -i docker && sudo apt-get purge -y docker-engine docker docker.io docker-ce docker-ce-cli docker-compose-plugin && sudo apt-get autoremove -y --purge docker-engine docker docker.io docker-ce docker-compose-plugin &&
wait
echo "Docker removed"
# kill docker lib data groups and sockets
sudo rm -rf /var/lib/docker /etc/docker && sudo rm -rf /etc/apparmor.d/docker && sudo groupdel docker && sudo rm -rf /var/run/docker.sock && 
wait
echo "Docker lib data groups sockets removed"
# k3d nuke
sudo rm -rf /usr/local/bin/k3d &&
wait
echo "k3d nuked"
# k3s nuke
sudo sh /usr/local/bin/k3s-uninstall.sh &&
wait
echo "k3s nuked"
# good practice
sudo apt-get upgrade -y && sudo apt-get update -y &&
wait
echo "Uninstall complete"
