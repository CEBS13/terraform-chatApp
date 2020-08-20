#!/bin/bash
apt update
apt install software-properties-common
apt-get upgrade -y
apt-add-repository --yes --update ppa:ansible/ansible
apt install python3.8 --yes
apt install git --yes
apt install ansible --yes
cd /home/ubuntu
mkdir /home/ubuntu/app
git clone git://github.com/CEBS13/node-ansible
cd node-ansible
ansible-playbook node-playbook.yml