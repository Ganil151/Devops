#!/bin/bash
# Correct shebang for bash script execution

# Update the system package list
sudo apt update -y 

# Install Git, Node.js, and npm
sudo apt install -y git nodejs npm 

# Change to the home directory of the ubuntu user
cd /home/ubuntu

# Clone the sample Node.js + MySQL app
git clone https://github.com/verma-kunal/nodejs-mysql.git

# Enter the cloned project directory
cd nodejs-mysql

# Install required Node.js packages
npm install

# Create .env file with DB credentials — assumes environment variables are exported before this script
cat <<EOT > .env
  DB_HOST=${DB_HOST}
  DB_USER=${DB_USER}
  DB_PASSWORD=${DB_PASSWORD}
  DB_NAME=${DB_NAME}
  DB_PORT=${DB_PORT}
  TABLE_NAME=${TABLE_NAME}
EOT

# Run the Node.js app in background, suppressing hangup signal
nohup npm start &
