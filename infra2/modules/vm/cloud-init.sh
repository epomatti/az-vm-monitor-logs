#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

apt update
apt upgrade -y

wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

apt-get update
apt-get install moby-engine -y
touch /etc/docker/daemon.json
echo '{ "log-driver": "local", "log-opts": { "max-size": "10m", "max-file": "3" }, "dns": ["168.63.129.16"] }' | tee -a /etc/docker/daemon.json


reboot
