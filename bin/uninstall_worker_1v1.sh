#!/bin/bash
## ~/rpi_k3s/bin/uninstall_worker_1v1.sh
## uninstall_worker_1v1.sh uninstall k3s k3d and docker from worker
# k3s nuke
sudo sh /usr/local/bin/k3s-agent-uninstall.sh
# k3d nuke
sudo rm -rf /usr/local/bin/k3d
# docker nuke power down images prune network volumes verify with ps 
docker container stop $(docker container ls -aq) ; docker container rm -f $(docker container ls -aq) ; docker rmi -f $(docker images -aq) ; docker volume prune && docker network prune && docker ps
# purge docker pkg
sudo dpkg -l | grep -i docker && sudo apt-get purge -y docker-engine docker docker.io docker-ce docker-ce-cli docker-compose-plugin && sudo apt-get autoremove -y --purge docker-engine docker docker.io docker-ce docker-compose-plugin
# kill docker lib data groups and sockets
sudo rm -rf /var/lib/docker /etc/docker && sudo rm -rf /etc/apparmor.d/docker && sudo groupdel docker && sudo rm -rf /var/run/docker.sock
# good practice
sudo apt-get upgrade -y && apt-get update -y 
