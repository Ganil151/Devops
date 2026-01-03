# SonarQube Native Installation on Ubuntu 24.04

Complete guide for installing SonarQube natively on Ubuntu 24.04 with PostgreSQL database.

## Prerequisites

- Ubuntu 24.04 LTS server
- Minimum 4GB RAM (8GB recommended)
- 10GB+ free disk space
- Non-root sudo user access

## System Requirements

### Hardware Requirements
- **CPU**: 2+ cores
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 10GB+ (depends on project size)
- **Network**: Port 9000 for web interface

### Software Requirements
- **Java**: OpenJDK 17
- **Database**: PostgreSQL 12+
- **OS**: Ubuntu 24.04 LTS

## Step 1: Install Prerequisites

### Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### Install OpenJDK 17
```bash
# Install OpenJDK 17
sudo apt install openjdk-17-jdk -y

# Verify installation
java -version
```

Expected output:
```
openjdk version "17.0.14" 2025-01-21
OpenJDK Runtime Environment (build 17.0.14+7-Ubuntu-124.04)
OpenJDK 64-Bit Server VM (build 17.0.14+7-Ubuntu-124.04, mixed mode, sharing)
```

### Install Required Packages
```bash
sudo apt install wget unzip curl -y
```

## Step 2: Install and Configure PostgreSQL

### Install PostgreSQL
```bash
# Install PostgreSQL
sudo apt install postgresql postgresql-contrib -y

# Enable and start PostgreSQL
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Verify status
sudo systemctl status postgresql
```

### Create SonarQube Database
```bash
# Switch to postgres user
sudo -u postgres psql

# Create database and user
CREATE DATABASE sonarqube;
CREATE USER sonaruser WITH ENCRYPTED PASSWORD 'StrongPassword123!';
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonaruser;

# Switch to sonarqube database
\c sonarqube

# Grant schema privileges
GRANT ALL PRIVILEGES ON SCHEMA public TO sonaruser;
GRANT ALL ON ALL TABLES IN SCHEMA public TO sonaruser;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO sonaruser;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO sonaruser;

# Exit PostgreSQL
\q
```

### Configure PostgreSQL for SonarQube
```bash
# Edit PostgreSQL configuration
sudo nano /etc/postgresql/16/main/postgresql.conf

# Add/modify these settings:
listen_addresses = 'localhost'
port = 5432
max_connections = 300
shared_buffers = 256MB
effective_cache_size = 1GB
```

```bash
# Edit authentication configuration
sudo nano /etc/postgresql/16/main/pg_hba.conf

# Add this line for SonarQube user:
local   sonarqube   sonaruser                     md5
```

```bash
# Restart PostgreSQL
sudo systemctl restart postgresql
```

## Step 3: Download and Install SonarQube

### Download SonarQube
```bash
# Check latest version at: https://www.sonarqube.org/downloads/
cd /tmp
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.3.0.82913.zip

# Extract archive
unzip sonarqube-10.3.0.82913.zip

# Move to system directory
sudo mv sonarqube-10.3.0.82913 /opt/sonarqube
```

### Create SonarQube User
```bash
# Create system user
sudo adduser --system --no-create-home --group --disabled-login sonarqube

# Set ownership
sudo chown -R sonarqube:sonarqube /opt/sonarqube
```

## Step 4: Configure SonarQube

### Main Configuration
```bash
# Edit SonarQube configuration
sudo nano /opt/sonarqube/conf/sonar.properties
```

Add these configurations:
```properties
# Database Configuration
sonar.jdbc.username=sonaruser
sonar.jdbc.password=StrongPassword123!
sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube

# Web Server Configuration
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.web.javaAdditionalOpts=-server -Xmx2G -Xms1G

# Elasticsearch Configuration
sonar.search.javaOpts=-Xmx1G -Xms1G

# Logging
sonar.log.level=INFO
sonar.path.logs=/opt/sonarqube/logs
```

### System Limits Configuration
```bash
# Configure system limits
sudo nano /etc/sysctl.conf
```

Add these lines:
```
# SonarQube system limits
vm.max_map_count=524288
fs.file-max=131072
```

```bash
# Configure user limits
sudo nano /etc/security/limits.d/99-sonarqube.conf
```

Add these lines:
```
sonarqube   -   nofile   131072
sonarqube   -   nproc    8192
sonarqube   -   memlock  unlimited
sonarqube   -   fsize    unlimited
sonarqube   -   as       unlimited
```

### Apply System Changes
```bash
# Apply sysctl changes
sudo sysctl -p

# Reboot to apply all changes
sudo reboot
```

## Step 5: Create System Service

### Create Service File
```bash
sudo nano /etc/systemd/system/sonarqube.service
```

Add this configuration:
```ini
[Unit]
Description=SonarQube service
After=syslog.target network.target postgresql.service
Wants=postgresql.service

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
ExecReload=/opt/sonarqube/bin/linux-x86-64/sonar.sh restart
User=sonarqube
Group=sonarqube
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=sonarqube
LimitNOFILE=131072
LimitNPROC=8192
TimeoutStartSec=300
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target
```

### Enable and Start Service
```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable service
sudo systemctl enable sonarqube

# Start service
sudo systemctl start sonarqube

# Check status
sudo systemctl status sonarqube
```

## Step 6: Configure Firewall

```bash
# Install UFW if not installed
sudo apt install ufw -y

# Allow SSH
sudo ufw allow 22/tcp

# Allow SonarQube
sudo ufw allow 9000/tcp

# Enable firewall
sudo ufw --force enable

# Check status
sudo ufw status
```

## Step 7: Install SonarScanner CLI

### Download and Install
```bash
# Download SonarScanner CLI
cd /tmp
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip

# Extract
unzip sonar-scanner-cli-5.0.1.3006-linux.zip

# Move to system directory
sudo mv sonar-scanner-5.0.1.3006-linux /opt/sonarscanner

# Set permissions
sudo chmod +x /opt/sonarscanner/bin/sonar-scanner

# Create symlink
sudo ln -s /opt/sonarscanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
```

### Configure SonarScanner
```bash
# Edit configuration
sudo nano /opt/sonarscanner/conf/sonar-scanner.properties
```

Add:
```properties
# SonarQube server URL
sonar.host.url=http://localhost:9000

# Default source code encoding
sonar.sourceEncoding=UTF-8
```

## Step 8: Verify Installation

### Check Service Status
```bash
# Check SonarQube service
sudo systemctl status sonarqube

# Check logs
sudo journalctl -u sonarqube -f

# Check SonarQube logs
sudo tail -f /opt/sonarqube/logs/sonar.log
```

### Access Web Interface
1. Open browser and navigate to `http://your-server-ip:9000`
2. Default credentials:
   - Username: `admin`
   - Password: `admin`
3. Change default password when prompted

### Test SonarScanner
```bash
# Check version
sonar-scanner -v

# Expected output:
# INFO: Scanner configuration file: /opt/sonarscanner/conf/sonar-scanner.properties
# INFO: Project root configuration file: NONE
# INFO: SonarScanner 5.0.1.3006
# INFO: Java 17.0.14 Eclipse Adoptium (64-bit)
```

## Troubleshooting

### Common Issues

#### Service Won't Start
```bash
# Check logs
sudo journalctl -u sonarqube --no-pager -l

# Check SonarQube logs
sudo cat /opt/sonarqube/logs/sonar.log

# Check Elasticsearch logs
sudo cat /opt/sonarqube/logs/es.log
```

#### Database Connection Issues
```bash
# Test database connection
sudo -u postgres psql -d sonarqube -U sonaruser -h localhost

# Check PostgreSQL logs
sudo tail -f /var/log/postgresql/postgresql-16-main.log
```

#### Memory Issues
```bash
# Check system memory
free -h

# Check Java processes
ps aux | grep java

# Adjust JVM settings in sonar.properties
sonar.web.javaAdditionalOpts=-Xmx4G -Xms2G
sonar.search.javaOpts=-Xmx2G -Xms2G
```

#### Port Already in Use
```bash
# Check what's using port 9000
sudo netstat -tlnp | grep :9000
sudo lsof -i :9000

# Kill process if needed
sudo kill -9 <PID>
```

### Performance Optimization

#### Database Tuning
```bash
# Edit PostgreSQL configuration
sudo nano /etc/postgresql/16/main/postgresql.conf

# Optimize for SonarQube
shared_buffers = 512MB
effective_cache_size = 2GB
work_mem = 16MB
maintenance_work_mem = 256MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
```

#### SonarQube Tuning
```bash
# Edit sonar.properties
sudo nano /opt/sonarqube/conf/sonar.properties

# Increase memory allocation
sonar.web.javaAdditionalOpts=-Xmx4G -Xms2G -XX:+UseG1GC
sonar.search.javaOpts=-Xmx2G -Xms2G -XX:+UseG1GC

# Enable performance monitoring
sonar.web.javaAdditionalOpts=-Xmx4G -Xms2G -XX:+UseG1GC -XX:+PrintGCDetails
```

## Security Hardening

### SSL/TLS Configuration
```bash
# Generate SSL certificate (self-signed for testing)
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /opt/sonarqube/conf/sonarqube.key \
  -out /opt/sonarqube/conf/sonarqube.crt

# Set permissions
sudo chown sonarqube:sonarqube /opt/sonarqube/conf/sonarqube.*
sudo chmod 600 /opt/sonarqube/conf/sonarqube.key
```

Add to sonar.properties:
```properties
# HTTPS Configuration
sonar.web.https.port=9443
sonar.web.https.keyAlias=sonarqube
sonar.web.https.keyStore=/opt/sonarqube/conf/sonarqube.p12
sonar.web.https.keyStorePassword=your_keystore_password
```

### Database Security
```bash
# Secure PostgreSQL installation
sudo -u postgres psql

# Remove default databases and users if not needed
DROP DATABASE IF EXISTS template0;
DROP DATABASE IF EXISTS template1;

# Set strong password policy
ALTER SYSTEM SET password_encryption = 'scram-sha-256';
SELECT pg_reload_conf();
```

This completes the native Ubuntu installation of SonarQube with PostgreSQL database, system service configuration, and basic security hardening.