# rpi_k3s
Installation of k3s k3d and docker on a Raspberry Pi 3 and/or 4. Provides step by step method for installation via CLI and/or scripts

## Prepare RPI
- Flash using RPI Imager and Raspbian Lite (64-bit)/Bookworm image
  
  *For long term or heavy it is recommend to ise and external USB drive as SD cards will wear and fail due to excessive r/w*

    - External USB or ssd (preferred)
    - SD card (quick fix)

- Update settings for Hostname, Enable ssh, set username/passwd in RPI Imager

- Afer flash is complete mount SD card and modify the following prior to boot with a text editor also save a backup copy of /boot/cmdline.txt before editing jic
  *nano is used as the editor below but any text editor locatated with RPi flasher will suffice*

- Edit boot 
```
sudo nano /boot/cmdline.txt
```
- Append to /boot/cmdline.txt to use cgproup memory
```
cgroup_memory=1 cgroup_enable=memory
```
- Append to /boot/cmdline.txt to disable ipv6
```
ipv6.disable=1
```
- (optional needs verification) Add static IP to /boot/cmdline.txt declaring static ip 
  *belows assumes netmask is 255.255.255.0 the static IP address is 192.168.0.69 on gateway 192.168.0.1*
```
ip=<staticIP>::<gatewayIP>:<netmaskIP>
# ip=192.168.0.69::192.168.0.1:255.255.255.0
```
- Example changes of cmdline.txt
  
  *FROM:*
  ```
  console=serial0,115200 console=tty1 root=PARTUUID=4e639091-02 rootfstype=ext4 fsck.repair=yes rootwait quiet init=/usr/lib/raspberrypi-sys-mods/firstboot systemd.run=/boot/firstrun.sh systemd.run_success_action=reboot systemd.unit=kernel-command-line.target
  ```
  *TO:*
  ```
  console=serial0,115200 console=tty1 root=PARTUUID=4e639091-02 rootfstype=ext4 fsck.repair=yes rootwait quiet init=/usr/lib/raspberrypi-sys-mods/firstboot systemd.run=/boot/firstrun.sh systemd.run_success_action=reboot systemd.unit=kernel-command-line.target cgroup_memory=1 cgroup_enable=memory ipv6.disable=1 ip=192.168.0.69::192.168.0.1:255.255.255.0
  ```
- Initial boot
  
- Login with ssh to static ip and update with your static <ip> and -l <user>
*belows assumes static IP address is 192.168.0.69 and user is k3sX*
```
ssh <ip> -l <user>
# ssh 192.168.0.69 -l k3sX
```
- (Optional) recommend disabling ufw but if enabled at minimum open the following ports for k3s
```
ufw status #check firewall is enabled 
ufw allow 6443/tcp #apiserver
ufw allow from 10.42.0.0/16 to any #pods
ufw allow from 10.43.0.0/16 to any #services
```
- Install git
```
sudo apt install git
sudo apt update -y
``` 
- Update and upgrade packages
```
sudo apt update -y && sudo apt upgrade -y
```
- Verify RPi firmware updated and reboot
```
sudo rpi-update
sudo rpi-eeprom-update -d -a
sudo reboot
```
- Login with ssh to static ip and update with your static <ip> and -l <user>
   *assumes static IP address is 192.168.0.69 and user is k3sX*
```
ssh <ip> -l <user>
# ssh 192.168.0.69 -l k3sX
```
## Quick start
### Script
  - Clone repo to install k3s and docker
    ```
    cd ~/ && git clone https://github.com/GrayHatGuy/rpi_k3s.git
    ```
  - Set owner and path
    ```
    sudo chmod u+x ~/rpi_k3s/bin/*.sh
    export PATH="~/rpi_k3s/bin/:$PATH" >> ~/.bashrc
    ```
  - Run commands
    - Controller
      - Install
        ```
        sudo bash /$HOME/rpi_k3s/bin/install_controller_1v1.sh
        ```
      - Uninstall
        ```
        sudo bash /$HOME/rpi_k3s/bin/uninstall_controller_1v1.sh
        ```
    - Worker
      - Install
        ```
        sudo bash /$HOME/rpi_k3s/bin/install_worker_1v1.sh
        ```
      - Uninstall
        ```
        sudo bash /$HOME/rpi_k3s/bin/uninstall_worker_1v1.sh
        ```
     - Verify install with these [tools](https://github.com/GrayHatGuy/rpi_k3s/blob/main/README.md#verify-install-tools)
## Manual steps 
*For reference and only necessary for debug if install scripts above are not successful*
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
exit
sudo apt-get upgrade -y
sudo apt-get update -y
sudo usermod -aG docker $USER
newgrp docker
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

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
##	Verify install
- Run scripts to check
  - Check install of controller [ctlck.sh](https://github.com/GrayHatGuy/rpi_k3s/blob/e27301f997478a1484a1e9a78683c759576a925d/bin/ctlck.sh)
  - Check install of worker [wrkck.sh](https://github.com/GrayHatGuy/rpi_k3s/blob/9b328f37e42a56d7cfb22ca7994a082d378e4070/bin/wrkck.sh)
```
docker --version
k3s --version
k3d --version
kubectl get nodes
```
- Dockery scripts
  - [dhi.sh](https://github.com/GrayHatGuy/dockery/blob/4f9972c302939bb545ec86be3963e3a42c82a3ce/bin/dhi.sh) docker run hello-world checks status of processes networks routes and images 
  - [dok.sh](https://github.com/GrayHatGuy/dockery/blob/4f9972c302939bb545ec86be3963e3a42c82a3ce/bin/dok.sh) checks status of processes networks routes and images 
### Next steps (TBD)
  - verify static ip /boot/cmdline.txt
  - deploy image cli
    - docker
    - containerd
  
  - upgrade to k9s

  - deploy from dashboards
    - rancher
    - openlens
    - fuse
  
