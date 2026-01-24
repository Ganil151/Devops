#!/bin/bash

# Exit immediately if a command exits with a non-zero status or a variable is unset
set -eu

JAVA_VERSION="21"
# Update the RPM file name to be compatible with EL9 (CentOS 9) systems
MYSQL_RELEASE_RPM="mysql80-community-release-el9-1.noarch.rpm"
TEMP_PASSWORD=""
APP_PASSWORD='PetClinic3773$151'
DB_USER='petclinic_user'
DB_NAME='petclinic'

# Use dnf instead of yum for CentOS 9
echo "Installing prerequisites (Java, wget, git)..."
sudo dnf install -y java-"${JAVA_VERSION}"-openjdk-devel wget git

echo "Setting up JAVA_HOME environment variables..."
JAVA_HOME="/usr/lib/jvm/java-${JAVA_VERSION}-openjdk"
{
  echo "export JAVA_HOME=${JAVA_HOME}"
  echo "export PATH=\$PATH:\$HOME/bin:\$JAVA_HOME/bin"
} | sudo tee /etc/profile.d/java_mysql.sh

sudo chmod +x /etc/profile.d/java_mysql.sh

echo "Downloading MySQL repository RPM for EL9..."
# Download to /tmp with the correct filename using the variable
sudo wget "https://dev.mysql.com/get/${MYSQL_RELEASE_RPM}" -O /tmp/"${MYSQL_RELEASE_RPM}"

echo "Installing MySQL repository using dnf localinstall..."
# Use dnf localinstall which handles dependencies better than raw rpm -Uvh
sudo dnf localinstall -y /tmp/"${MYSQL_RELEASE_RPM}"

# The previous erroneous line is removed:
# sudo rpm -Uvh mysql80-community-release-el7-3.noarch.rpm

echo "Installing MySQL Community Server..."
# Use dnf instead of yum for CentOS 9
sudo dnf install -y --nogpgcheck mysql-community-server

sudo rm -f /tmp/"${MYSQL_RELEASE_RPM}"

echo "Starting and enabling MySQL service..."
sudo systemctl start mysqld
sudo systemctl enable mysqld

echo "Waiting for and extracting temporary MySQL root password..."
for i in {1..10}; do
    # Filter logs carefully; 'grep' might need time to find the file if it was just started
    TEMP_PASSWORD=$(sudo grep 'temporary password' /var/log/mysqld.log 2>/dev/null | awk '{print $NF}')
    if [ -n "$TEMP_PASSWORD" ]; then
        break
    fi
    echo "Waiting for mysqld service logs... attempt $i"
    sleep 5
done

if [ -z "$TEMP_PASSWORD" ]; then
    echo "ERROR: Failed to retrieve temporary MySQL root password. Exiting." >&2
    exit 1
fi
echo "Temporary password found."

echo "Configuring MySQL security, database, and user access..."
sudo mysql --connect-expired-password -uroot -p"$TEMP_PASSWORD" <<EOF
-- Reset root password and allow non-expiring login
ALTER USER 'root'@'localhost' IDENTIFIED BY '$APP_PASSWORD' PASSWORD EXPIRE NEVER;

-- Create the database
CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create the Petclinic user, allowing remote connections ('%' host)
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$APP_PASSWORD';

-- Grant all privileges on the new database to the new user
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';

-- Remove anonymous user (good security practice)
DELETE FROM mysql.user WHERE User='';
-- Drop test database (good security practice)
DROP DATABASE IF EXISTS test;

-- Apply changes
FLUSH PRIVILEGES;
EOF

echo "Restarting MySQL service to apply security and user changes..."
sudo systemctl restart mysqld

echo "--- MySQL Server Setup Complete ---"
echo "Database: $DB_NAME"
echo "User: $DB_USER"
echo "Password: $APP_PASSWORD"
echo "Root Password: $APP_PASSWORD"
echo "The MySQL server is now configured and ready for connections from your microservices."
