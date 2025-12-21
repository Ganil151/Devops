#!/bin/bash

# Update and install Node.js & npm
sudo apt update -y
sudo apt install -y nodejs npm git

# Clone the repository
cd /home/ubuntu
git clone https://github.com/verma-kunal/nodejs-mysql.git
cd nodejs-mysql

# Install project dependencies
npm install

# Create .env file with example DB config
cat <<EOT > .env
  DB_HOST=localhost
  DB_USER=root
  DB_PASSWORD=yourpassword
  DB_NAME=mydatabase
EOT

# Start the Node.js server (in background)
nohup npm start &
