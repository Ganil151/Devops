#/bin/bash

set -e

# Install the required packages
sudo dnf install -y --allowerasing docker-ce docker-ce-cli containerd.io

# Enable and start the official docker service
sudo systemctl enable docker
sudo systemctl start docker

# Add your user (gsmash) to the docker group to run commands without sudo
sudo usermod -aG docker gsmash