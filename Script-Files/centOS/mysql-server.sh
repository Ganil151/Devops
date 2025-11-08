#!/bin/bash

set -ea

# --- 1. System Setup and Host Name Configuration ---

echo "--- 1. Changing Host Name ---"
# Set Host Name
NEW_HOSTNAME="Mysql-Server"
echo "Changing Host Name to: ${NEW_HOSTNAME}"
sudo hostnamectl set-hostname "${NEW_HOSTNAME}"

# --- 2. Update System and Install Dependencies ---

echo "--- 2. Updating system and installing dependencies ---"
# Update system packages
sudo dnf update -y

# Install Java, Git, and Wget
echo "--- Installing Java, Git, and Wget ---"
sudo dnf install -y java-21-openjdk-devel git wget

# Verify Java installation
JAVA_HOME="/usr/lib/jvm/java-21-openjdk"
if [ ! -d "$JAVA_HOME" ]; then
    echo "ERROR: Java 21 OpenJDK not found at $JAVA_HOME. Please verify installation."
    exit 1
fi

# Configure Java environment variables
echo "--- Configuring Java environment variables ---"
{
    echo "export JAVA_HOME=${JAVA_HOME}"
    echo "export PATH=\$PATH:\$HOME/bin:\$JAVA_HOME/bin"
} | sudo tee -a /etc/profile.d/java_env.sh

# Make the profile script executable
sudo chmod +x /etc/profile.d/java_env.sh

# Source the profile script to apply changes immediately
source /etc/profile.d/java_env.sh

# --- 3. Install MySQL 8.0 ---

echo "--- 3. Installing MySQL 8.0 ---"
# Download and install the MySQL 8.0 repository
echo "--- Downloading MySQL 8.0 repository ---"
sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
sudo dnf localinstall -y mysql80-community-release-el9-1.noarch.rpm
sudo rm -f mysql80-community-release-el9-1.noarch.rpm

# Import MySQL GPG key
echo "--- Importing MySQL GPG key ---"
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023

# Install MySQL server and client
echo "--- Installing MySQL server and client ---"
sudo dnf install -y mysql-community-server mysql-community-client

# Start and enable MySQL service
echo "--- Starting and enabling MySQL service ---"
sudo systemctl start mysqld
sudo systemctl enable mysqld

# --- 4. Secure MySQL Installation ---

echo "--- 4. Securing MySQL installation ---"
# Retrieve the temporary root password from the MySQL log
TEMP_PASSWORD=$(sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
if [ -z "$TEMP_PASSWORD" ]; then
    echo "ERROR: Temporary password not found in /var/log/mysqld.log"
    exit 1
fi

# Define the new root password
NEW_PASSWORD='Mysql$9999!'

# Use the temporary password to secure the MySQL installation
echo "--- Securing MySQL with a new root password ---"
mysql --connect-expired-password -uroot -p"$TEMP_PASSWORD" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$NEW_PASSWORD';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOF

# Restart MySQL to apply changes
echo "--- Restarting MySQL service ---"
sudo systemctl restart mysqld

# --- Final Output ---

echo "--- MySQL installation and configuration completed successfully ---"
echo "MySQL root password has been updated to: $NEW_PASSWORD"
echo "Please ensure you store this password securely."