# rpi_k3s
Installation of k3s k3d and docker on a Raspberry Pi 3 and/or 4. Provides step by step method for installation via CLI and/or scripts

### Prepare RPI
- Flash using RPI Imager and Raspbian Lite (64-bit)/Bookworm image

- Update settings for Hostname, Enable ssh, Set username/passwd

- Update static IP/mac and hostnames for controller and workers on local dns

- Recommend disable ufw else at minimum open
```
ufw allow 6443/tcp #apiserver
ufw allow from 10.42.0.0/16 to any #pods
ufw allow from 10.43.0.0/16 to any #services
```
- Update/upgrade
```
sudo apt update -y && sudo apt upgrade -y
```
- Add cgroup 
```
sudo nano /boot/cmdline.txt
```
- Append to /boot/cmdline.txt
```
cgroup_memory=1 cgroup_enable=memory
```
- Reboot
```
sudo reboot
```
- Install git
```
sudo apt install git
```
### Installation options
- Script
  - Clone repo ```cd ~/ && git clone https://github.com/GrayHatGuy/rpi_k3s.git```
  - Set owner and path
    ```
    sudo chmod u+x ~/rpi_k3s/bin/*.sh
    export PATH="~/rpi_k3s/bin/:$PATH" >> ~/.bashrc
    ```
  - Run commands
    - Controller
      - Install
     ```sudo bash /$HOME/rpi_k3s/bin/install_controller_1v1.sh```
      - Uninstall
     ```sudo bash /$HOME/rpi_k3s/bin/uninstall_controller_1v1.sh```
    - Worker
      - Install
     ```sudo bash /$HOME/rpi_k3s/bin/install_worker_1v1.sh```
      - Uninstall
     ```sudo bash /$HOME/rpi_k3s/bin/uninstall_worker_1v1.sh```
- CLI manually
  - Continue on to next steps ...
### Install Docker 

- Using dockery script
    * Clone repo
    ```
    cd ~/
    git clone https://github.com/GrayHatGuy/dockery.git
    ```
    * Setup dockery shortcut aliases
    ```
    sudo chmod u+x ~/dockery/bin/*.sh
    sudo sh ~/dockery/bin/setup.sh
    ```
    * Run download script [ddn.sh](https://github.com/GrayHatGuy/dockery/blob/4f9972c302939bb545ec86be3963e3a42c82a3ce/bin/ddn.sh)
    ```
    sudo sh ~/dockery/bin/ddn.sh
    ```
OR

- Manual CLI from Docker reference
```
sudo -s
apt-get update -y
apt-get upgrade -y
curl -fsSL https://get.docker.com -o get-docker.sh
bash get-docker.sh
sudo apt-get upgrade -y
apt-get update -y
sudo usermod -aG docker $USER
newgrp docker
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
chmod g+rwx "$HOME/.docker" -R
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
exit
```
OR

- [Docker reference](https://docs.docker.com/engine/install/) used for above scripts
```
https://docs.docker.com/engine/install/
```
### Install k3d
```
sudo wget -O k3d-linux-arm64 https://github.com/rancher/k3d/releases/download/v3.1.5/k3d-linux-arm64
sudo mv k3d-linux-arm64 /usr/local/bin/k3d
sudo chmod +x /usr/local/bin/k3d
```
### Install k3s Controller
```
curl -sfL https://get.k3s.io | sh 
```
Copy token save for later
```
sudo cat /var/lib/rancher/k3s/server/node-token
```
###	Install K3s Workers
- Update curl command below with ```#mynodetoken:``` from ```/var/lib/rancher/k3s/server/node-token``` and ```#myserver: <controlIP>:6443```
```
curl -sfL https://get.k3s.io | K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken sh -
```
###	Check for errors
- If curl fails repeat
```
curl -sfL https://get.k3s.io | K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken sh -
```
- if Restorecon not found with ```sh: 970: restorecon: not found sh: 971: restorecon: not founderror```
```
sudo apt-get -y install policycoreutils
```
### Run without sudo 
- User owned
```
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
```
OR

- shell root owned
```
sudo -s
```
###	Uninstall
- Docker removal script

  - Clear docker [dcl.sh](https://github.com/GrayHatGuy/dockery/blob/4f9972c302939bb545ec86be3963e3a42c82a3ce/bin/dcl.sh)
    ```
    sh ~/dockery/bin/dcl.sh
    ```
  - Remove docker [drm.sh](https://github.com/GrayHatGuy/dockery/blob/4f9972c302939bb545ec86be3963e3a42c82a3ce/bin/drm.sh) 
    ```
    sh ~/dockery/bin/drm.sh 
    ```
OR

- Docker removal CLI
```
docker container stop $(docker container ls -aq)
docker container rm -f $(docker container ls -aq)
docker rmi -f $(docker images -aq)
docker volume prune && docker network prune
docker ps
sudo dpkg -l | grep -i docker
sudo apt-get purge -y docker-engine docker docker.io docker-ce docker-ce-cli docker-compose-plugin 
sudo apt-get autoremove -y --purge docker-engine docker docker.io docker-ce docker-compose-plugin 
sudo rm -rf /var/lib/docker /etc/docker
sudo rm -rf /etc/apparmor.d/docker
sudo groupdel docker && sudo rm -rf /var/run/docker.sock
```
- Controller remove 
```
/usr/local/bin/k3s-uninstall.sh
```
- Workers remove
```
/usr/local/bin/k3s-agent-uninstall.sh
```
- k3d remove
```
sudo rm -rf /usr/local/bin/k3d
```
### Config 
Set context and cluster config variable examples
```
kubectl config get-contexts
kubectl config use-context yourcontext
kubectl config set-contexts yourcluster
kubectl config view
kubectl config current-context
kubectl config delete-context yourcluster
kubectl config set-context yourcontext --cluster=yourcluster --user=username --namespace=yournamespace
```
###	Verify install
```
docker --version
k3s --version
k3d --version
kubectl get nodes
``` 
## Post-Installation tools 
Scripts and examples
### Dockery scripts
- [dhi.sh](https://github.com/GrayHatGuy/dockery/blob/4f9972c302939bb545ec86be3963e3a42c82a3ce/bin/dhi.sh) docker run hello-world checks status of processes networks routes and images 
- [dok.sh](https://github.com/GrayHatGuy/dockery/blob/4f9972c302939bb545ec86be3963e3a42c82a3ce/bin/dok.sh) checks status of processes networks routes and images 
### Examples
- Docker
  - Hello-world
    ```
    docker run hello-world
    ``` 
  - nginx container
  - kill all
- k3s
  - nginx 
    - Run image
      ```kubectl run nginx --image nginx:alpine```
    - Port forward
      ```kubectl port-forward pod/nginx 8080:80```
    - Check pods
      ```kubectl get pods```
    - Check http
    - Remove pod
