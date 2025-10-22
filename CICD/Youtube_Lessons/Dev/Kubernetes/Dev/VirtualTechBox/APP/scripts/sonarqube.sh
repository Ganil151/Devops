#!/bin/bash

set -e 

# Install dependencies
sudo apt-get update -y 
sudo apt-get upgrade -y

# Install PostGresql & Wget
sudo apt install wget ca-certificates
# Note: The command 'wget — quiet -O —' uses em-dashes (—) instead of hyphens (-). This is likely a copy-paste error.
# Corrected to standard hyphens (-).
wget -q -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc   | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
sudo apt update # Run update before install
sudo apt install postgresql postgresql-contrib

# Configure Postgresql
sudo systemctl enable postgresql.service
sudo systemctl start postgresql # Start the service after enabling

# Create a Password (interactive prompt)
sudo passwd postgres

# Install SonarQube
sudo apt-get update -y
sudo apt-get install sonarqube -y

# Switch to the postgres user to run subsequent commands
sudo -i -u postgres /bin/bash << 'EOF'

# Commands run as the postgres user
createuser sonar

# Login into postgres database and execute commands
psql << 'SQL_EOF'
-- Create a database
ALTER USER sonar WITH ENCRYPTED PASSWORD 'sonar';
CREATE DATABASE sonarqube OWNER sonar;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;
SQL_EOF

EOF # End of postgres user commands

# Install Temurin JDK 21
# Add the Adoptium repository key and entry (assuming Ubuntu/Debian)
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo gpg --dearmor -o /usr/share/keyrings/adoptium-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/adoptium-keyring.gpg] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME=/ {print $2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/temurin.list
sudo apt update # Update package list after adding the repo
sudo apt install temurin-21-jdk

# Configure Temurin alternatives (interactive prompt)
sudo update-alternatives --config java
sudo update-alternatives --config javac

# Determine the exact JAVA_HOME path for Temurin 21
# Common paths are /usr/lib/jvm/temurin-21-jdk-amd64 or /usr/lib/jvm/adoptium-21-hotspot-amd64
# This command attempts to find the correct path automatically
JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")

# Store JAVA_HOME in /etc/environment for system-wide persistence
# Check if JAVA_HOME line already exists, if not, append it
if ! grep -q "^JAVA_HOME=" /etc/environment; then
    echo "JAVA_HOME=$JAVA_HOME" | sudo tee -a /etc/environment
else
    # If it exists, replace the existing line
    sudo sed -i "s|^JAVA_HOME=.*|JAVA_HOME=$JAVA_HOME|" /etc/environment
fi

# Reload the /etc/environment file in the current shell (optional, as it's system-wide)
export JAVA_HOME=$JAVA_HOME

# Print the configured JAVA_HOME for confirmation
echo "JAVA_HOME is set to: $JAVA_HOME"

# Install other required packages (Maven, etc.)
sudo apt install maven

# Update 
sudo apt update -y

# Add SonarQube to /etc/security/limits.conf
echo "sonarqube - nofile 65536" && sonarqube - nproc 4096 | sudo tee -a /etc/security/limits.conf

# Add VM Max RAM to /etc/sysctl.conf
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf to  /etc/sysctl.conf