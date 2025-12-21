# Linux Server Administration

Complete guide to Linux server management for production environments.

## Server Setup and Configuration

### Initial Server Setup
```bash
# Update system packages
apt update && apt upgrade -y  # Ubuntu/Debian
yum update -y                 # CentOS/RHEL

# Create admin user
useradd -m -s /bin/bash -G sudo admin
passwd admin

# SSH Key Setup
mkdir -p /home/admin/.ssh
chmod 700 /home/admin/.ssh
echo "ssh-rsa AAAAB3..." > /home/admin/.ssh/authorized_keys
chmod 600 /home/admin/.ssh/authorized_keys
chown -R admin:admin /home/admin/.ssh
```

### System Hardening
```bash
# SSH Configuration
# /etc/ssh/sshd_config
Port 2222
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AllowUsers admin

# Firewall Setup
ufw enable
ufw default deny incoming
ufw default allow outgoing
ufw allow 2222/tcp
ufw allow 80/tcp
ufw allow 443/tcp
```

## Web Server Configuration

### Nginx Setup
```bash
# Install Nginx
apt install nginx -y

# Basic Configuration
# /etc/nginx/sites-available/default
server {
    listen 80;
    server_name example.com;
    root /var/www/html;
    index index.html index.php;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }
}

# Enable site and restart
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
systemctl restart nginx
```

### Apache Setup
```bash
# Install Apache
apt install apache2 -y

# Virtual Host Configuration
# /etc/apache2/sites-available/example.com.conf
<VirtualHost *:80>
    ServerName example.com
    DocumentRoot /var/www/example.com
    ErrorLog ${APACHE_LOG_DIR}/example.com_error.log
    CustomLog ${APACHE_LOG_DIR}/example.com_access.log combined
</VirtualHost>

# Enable site
a2ensite example.com.conf
systemctl reload apache2
```

## Database Server Management

### MySQL/MariaDB
```bash
# Install MySQL
apt install mysql-server -y

# Secure installation
mysql_secure_installation

# Database operations
mysql -u root -p
CREATE DATABASE myapp;
CREATE USER 'appuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON myapp.* TO 'appuser'@'localhost';
FLUSH PRIVILEGES;
```

### PostgreSQL
```bash
# Install PostgreSQL
apt install postgresql postgresql-contrib -y

# User and database setup
sudo -u postgres psql
CREATE DATABASE myapp;
CREATE USER appuser WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE myapp TO appuser;
```

## Monitoring and Logging

### System Monitoring
```bash
# Install monitoring tools
apt install htop iotop nethogs -y

# Log monitoring
tail -f /var/log/syslog
journalctl -f -u nginx
```

### Automated Backups
```bash
#!/bin/bash
# Backup script
BACKUP_DIR="/backup/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# Database backup
mysqldump --all-databases > $BACKUP_DIR/mysql_backup.sql

# File backup
tar -czf $BACKUP_DIR/files_backup.tar.gz /var/www /etc

# Upload to cloud
aws s3 cp $BACKUP_DIR/ s3://backup-bucket/ --recursive
```