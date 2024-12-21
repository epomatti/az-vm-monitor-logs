#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt update
apt upgrade -y

ubuntuRelease="24.04"

wget "https://packages.microsoft.com/config/ubuntu/$ubuntuRelease/packages-microsoft-prod.deb" -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

apt-get update
apt-get install moby-engine -y
touch /etc/docker/daemon.json
echo '{ "log-driver": "local", "log-opts": { "max-size": "10m", "max-file": "3" }, "dns": ["168.63.129.16"] }' | tee -a /etc/docker/daemon.json
