#!/bin/bash

#Get all updates
apt update
apt upgrade -y

#Reboot
reboot now

#Install git
apt install git-all -y

#Clone Repo
cd
mkdir repos
cd repos
git clone https://github.com/sam-bowman/homelab-cluster.git
cd homelab-cluster
pwd
ls -l

#Install pipx
apt update
apt install pipx -y
pipx ensurepath

#Install Ansible
pipx install --include-deps ansible