#!/bin/bash

#Get all updates
apt update
apt upgrade -y

#Install git
apt install git-all -y

#Clone Repo
cd /opt
mkdir repos
cd /opt/repos
git clone https://github.com/sam-bowman/homelab-cluster.git
cd /opt/repos/homelab-cluster
pwd
ls -l

#Install pipx
apt update
apt install pipx -y
pipx ensurepath

#Install Ansible
pipx install --include-deps ansible