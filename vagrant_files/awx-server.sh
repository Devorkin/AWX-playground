#! /bin/bash

# SSH configuration
cp /vagrant/vagrant_files/ssh_config.d.conf /etc/ssh/ssh_config.d/awx-playground.conf

# Import needed repositories
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install needed packages
apt update
apt install -y \
    docker-ce \
    docker-ce-cli \
    docker-compose \
    jq \
    python3-pip

# Docker configuration
systemctl enable docker
systemctl start docker
for x in "root" "vagrant"; do
    adduser --quiet $x docker
    usermod -aG docker $x
done
newgrp docker

cp -r /vagrant/app /opt/awx-playground
cd /opt/awx-playground
bash ./install.sh $1
