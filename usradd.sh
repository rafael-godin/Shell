#!/bin/bash
USER=user.name
KEY=user.key

sudo useradd -m -s /bin/bash -p '!' "$USER"
sudo mkdir -p /home/$USER/.ssh
echo "$KEY" | sudo tee /home/$USER/.ssh/authorized_keys
sudo chmod 700 /home/$USER/.ssh
sudo chmod 600 /home/$USER/.ssh/authorized_keys
sudo chown -R $USER:$USER /home/$USER/.ssh
sudo usermod -aG sudo $USER
