#!/bin/bash
set -e

install_dependancies(){
  sudo yum update -y
  sudo yum upgrade -y
  echo "Installing required packages..."
  sudo yum install -y git java-17-amazon-corretto-devel wget unzip docker
}



# Execute the function
install_dependancies