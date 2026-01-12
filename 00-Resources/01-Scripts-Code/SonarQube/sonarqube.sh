#!/bin/bash

set -e 

# Install dependencies
sudo apt-get update 
sudo apt-get upgrade -y

# Change Hostname 
sudo hostnamectl set-hostname "SonarQube-Srv"

# Install PostGresql & Wget
sudo apt install -y wget ca-certificates # Added -y flag
# Note: The command 'wget — quiet -O —' uses em-dashes (—) instead of hyphens (-). This is likely a copy-paste error.
# Corrected to standard hyphens (-).
wget -q -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
sudo apt update # Run update before install
sudo apt install -y postgresql postgresql-contrib # Added -y flag

# Configure Postgresql
sudo systemctl enable postgresql.service
sudo systemctl start postgresql # Start the service after enabling

# Create a Password (interactive prompt)
sudo passwd postgres

# Switch to the postgres user to run subsequent commands
sudo -i -u postgres /bin/bash << 'EOF' # This line starts a new shell as 'postgres' and runs the heredoc content in it.

# Commands run as the postgres user
createuser sonar

# Login into postgres database and execute commands
psql << 'SQL_EOF'
-- Create a database
ALTER USER sonar WITH ENCRYPTED PASSWORD 'sonar'; # Error: 'sonar' should likely be a more secure password
CREATE DATABASE sonarqube OWNER sonar;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;
SQL_EOF

EOF # End of postgres user commands

# Install Temurin JDK 21
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo gpg --dearmor -o /usr/share/keyrings/adoptium-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/adoptium-keyring.gpg] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME=/ {print $2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/temurin.list
sudo apt update 
sudo apt install -y temurin-21-jdk 
sudo apt upgrade -y

# Configure Temurin alternatives (interactive prompt)
# Warning: These commands are interactive and will halt the script if not run manually.
# Consider pre-selecting options or removing for fully automated script.
# sudo update-alternatives --config java
# sudo update-alternatives --config javac

# Determine the exact JAVA_HOME path for Temurin 21
# Common paths are /usr/lib/jvm/temurin-21-jdk-amd64 or /usr/lib/jvm/adoptium-21-hotspot-amd64
# This command attempts to find the correct path automatically
JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")

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
sudo apt install -y maven 

# Update 
sudo apt update 

# Add SonarQube to /etc/security/limits.conf
# Error: The echo command concatenates strings incorrectly. The '&&' and '|' are shell operators here, not part of the echo content.
# Also, the command should be run with sudo tee, not echo followed by sudo tee.
# Corrected line:
echo -e "sonarqube - nofile 65536\nsonarqube - nproc 4096" | sudo tee -a /etc/security/limits.conf

# Add VM Max RAM to /etc/sysctl.conf
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

# Install SonarQube
sudo wget 'https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-25.2.0.102705.zip'
sudo apt install -y unzip # The 'install' command is not standard for installing packages. Use 'apt install'.
sudo unzip sonarqube-25.2.0.102705.zip
sudo mv sonarqube-25.2.0.102705/ /opt/sonarqube

# Create a group and user for SonarQube
sudo groupadd sonar
sudo useradd -c "user to SonarQube" -d /opt/sonarqube -g sonar sonar
sudo chown -R sonar:sonar /opt/sonarqube # The -R flag should come before the path

# Change the credentials in /opt/sonarqube/conf/sonar.properties
sudo sed -i 's/#sonar.jdbc.username=/sonar.jdbc.username=sonar/g' /opt/sonarqube/conf/sonar.properties

sudo sed -i 's|#sonar\.jdbc\.url=jdbc:postgresql://localhost:5432/sonarqube|sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube|' /opt/sonarqube/conf/sonar.properties

# Create a service file for SonarQube
sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<'EOF_SERVICE' # Use a heredoc with sudo tee
[Unit]
Description=SonarQube service
After=syslog.target network.target
[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always

LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF_SERVICE

# Start SonarQube
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube