# Jenkins Installation

Complete guide to Jenkins installation, configuration, and initial setup across different platforms.

## System Requirements

### Hardware Requirements
```yaml
minimum:
  ram: 256MB
  disk: 1GB
  cpu: 1 core

recommended:
  ram: 4GB+
  disk: 50GB+
  cpu: 4+ cores
  
production:
  ram: 8GB+
  disk: 100GB+
  cpu: 8+ cores
```

### Software Requirements
- Java 11 or 17 (LTS versions recommended)
- Supported operating systems: Linux, Windows, macOS
- Web browser for UI access

## Installation Methods

### Amazon Linux / RHEL / CentOS
```bash
# Install Java 11
sudo yum update -y
sudo yum install java-11-openjdk java-11-openjdk-devel -y

# Verify Java installation
java -version

# Add Jenkins repository
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# Install Jenkins
sudo yum install jenkins -y

# Start and enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Check status
sudo systemctl status jenkins
```

### Ubuntu / Debian
```bash
# Update system
sudo apt update

# Install Java 11
sudo apt install openjdk-11-jdk -y

# Add Jenkins repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package index
sudo apt update

# Install Jenkins
sudo apt install jenkins -y

# Start and enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Check status
sudo systemctl status jenkins
```

### Docker Installation
```bash
# Pull Jenkins LTS image
docker pull jenkins/jenkins:lts

# Run Jenkins container
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# Get initial admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### Docker Compose
```yaml
# docker-compose.yml
version: '3.8'
services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - JAVA_OPTS=-Xmx2048m -Xms1024m
    restart: unless-stopped

volumes:
  jenkins_home:
```

### Kubernetes Installation
```yaml
# jenkins-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      containers:
      - name: jenkins
        image: jenkins/jenkins:lts
        ports:
        - containerPort: 8080
        - containerPort: 50000
        volumeMounts:
        - name: jenkins-home
          mountPath: /var/jenkins_home
        env:
        - name: JAVA_OPTS
          value: "-Xmx2048m -Xms1024m"
      volumes:
      - name: jenkins-home
        persistentVolumeClaim:
          claimName: jenkins-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins-service
spec:
  selector:
    app: jenkins
  ports:
  - name: http
    port: 8080
    targetPort: 8080
  - name: agent
    port: 50000
    targetPort: 50000
  type: LoadBalancer
```

## Initial Configuration

### First-Time Setup
```bash
# Access Jenkins web interface
http://your-server:8080

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Or for Docker
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### Setup Wizard Steps
1. **Unlock Jenkins**: Enter initial admin password
2. **Customize Jenkins**: Install suggested plugins or select specific plugins
3. **Create Admin User**: Set up first admin user
4. **Instance Configuration**: Configure Jenkins URL
5. **Start Using Jenkins**: Complete setup

### Essential Plugin Installation
```bash
# Install via CLI after setup
jenkins-cli install-plugin git
jenkins-cli install-plugin workflow-aggregator
jenkins-cli install-plugin blueocean
jenkins-cli install-plugin docker-workflow
jenkins-cli install-plugin kubernetes
jenkins-cli install-plugin ansible
jenkins-cli install-plugin pipeline-stage-view
jenkins-cli install-plugin build-timeout
jenkins-cli install-plugin timestamper
jenkins-cli install-plugin ws-cleanup
```

## Configuration Files

### Main Configuration
```bash
# Jenkins home directory
/var/lib/jenkins/

# Main configuration file
/var/lib/jenkins/config.xml

# Service configuration (RHEL/CentOS)
/etc/sysconfig/jenkins

# Service configuration (Ubuntu/Debian)
/etc/default/jenkins

# Systemd service file
/usr/lib/systemd/system/jenkins.service
```

### Service Configuration Example
```bash
# /etc/sysconfig/jenkins
JENKINS_HOME="/var/lib/jenkins"
JENKINS_JAVA_CMD=""
JENKINS_USER="jenkins"
JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true -Xmx2048m -Xms1024m"
JENKINS_PORT="8080"
JENKINS_LISTEN_ADDRESS=""
JENKINS_HTTPS_PORT=""
JENKINS_HTTPS_KEYSTORE=""
JENKINS_HTTPS_KEYSTORE_PASSWORD=""
JENKINS_HTTPS_LISTEN_ADDRESS=""
JENKINS_DEBUG_LEVEL="5"
JENKINS_ENABLE_ACCESS_LOG="no"
JENKINS_HANDLER_MAX="100"
JENKINS_HANDLER_IDLE="20"
JENKINS_ARGS=""
```

### JVM Tuning
```bash
# Memory settings for different environments
# Development
JENKINS_JAVA_OPTIONS="-Xmx1024m -Xms512m"

# Production (small)
JENKINS_JAVA_OPTIONS="-Xmx2048m -Xms1024m"

# Production (large)
JENKINS_JAVA_OPTIONS="-Xmx4096m -Xms2048m -XX:+UseG1GC"

# High-performance settings
JENKINS_JAVA_OPTIONS="-Xmx8192m -Xms4096m -XX:+UseG1GC -XX:+UseStringDeduplication -XX:+DisableExplicitGC"
```

## Security Configuration

### Enable Security
```xml
<!-- config.xml security section -->
<useSecurity>true</useSecurity>
<authorizationStrategy class="hudson.security.FullControlOnceLoggedInAuthorizationStrategy">
  <denyAnonymousReadAccess>true</denyAnonymousReadAccess>
</authorizationStrategy>
<securityRealm class="hudson.security.HudsonPrivateSecurityRealm">
  <disableSignup>true</disableSignup>
  <enableCaptcha>false</enableCaptcha>
</securityRealm>
```

### CSRF Protection
```xml
<crumbIssuer class="hudson.security.csrf.DefaultCrumbIssuer">
  <excludeClientIPFromCrumb>false</excludeClientIPFromCrumb>
</crumbIssuer>
```

### Agent Security
```xml
<slaveAgentPort>50000</slaveAgentPort>
<disabledAgentProtocols>
  <string>JNLP-connect</string>
  <string>JNLP2-connect</string>
</disabledAgentProtocols>
```

## Network Configuration

### Firewall Rules
```bash
# RHEL/CentOS/Amazon Linux
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=50000/tcp
sudo firewall-cmd --reload

# Ubuntu/Debian
sudo ufw allow 8080/tcp
sudo ufw allow 50000/tcp
sudo ufw reload

# Check open ports
sudo netstat -tulpn | grep -E ':(8080|50000)'
```

### Reverse Proxy Setup (Nginx)
```nginx
# /etc/nginx/sites-available/jenkins
upstream jenkins {
  keepalive 32;
  server 127.0.0.1:8080;
}

map $http_upgrade $connection_upgrade {
  default upgrade;
  '' close;
}

server {
  listen 80;
  server_name jenkins.example.com;
  return 301 https://$server_name$request_uri;
}

server {
  listen 443 ssl http2;
  server_name jenkins.example.com;

  ssl_certificate /etc/ssl/certs/jenkins.crt;
  ssl_certificate_key /etc/ssl/private/jenkins.key;

  location / {
    sendfile off;
    proxy_pass http://jenkins;
    proxy_redirect default;
    proxy_http_version 1.1;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;

    proxy_max_temp_file_size 0;
    client_max_body_size 10m;
    client_body_buffer_size 128k;

    proxy_connect_timeout 90;
    proxy_send_timeout 90;
    proxy_read_timeout 90;
    proxy_buffering off;
    proxy_request_buffering off;
  }
}
```

## SSL/TLS Configuration

### Generate SSL Certificate
```bash
# Self-signed certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/jenkins.key \
  -out /etc/ssl/certs/jenkins.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=jenkins.example.com"

# Let's Encrypt certificate
sudo certbot --nginx -d jenkins.example.com
```

### Jenkins HTTPS Configuration
```bash
# Generate Java keystore
sudo keytool -genkey -keyalg RSA -alias jenkins -keystore /var/lib/jenkins/jenkins.jks -keysize 2048

# Update Jenkins configuration
JENKINS_HTTPS_PORT="8443"
JENKINS_HTTPS_KEYSTORE="/var/lib/jenkins/jenkins.jks"
JENKINS_HTTPS_KEYSTORE_PASSWORD="your_password"
JENKINS_ARGS="--httpsPort=8443 --httpsKeyStore=/var/lib/jenkins/jenkins.jks --httpsKeyStorePassword=your_password"
```

## Backup and Recovery

### Initial Backup Setup
```bash
# Create backup directory
sudo mkdir -p /backup/jenkins

# Backup script
#!/bin/bash
JENKINS_HOME="/var/lib/jenkins"
BACKUP_DIR="/backup/jenkins"
DATE=$(date +%Y%m%d_%H%M%S)

# Stop Jenkins
sudo systemctl stop jenkins

# Create backup
sudo tar -czf $BACKUP_DIR/jenkins_backup_$DATE.tar.gz \
  --exclude="$JENKINS_HOME/workspace/*" \
  --exclude="$JENKINS_HOME/war/*" \
  $JENKINS_HOME

# Start Jenkins
sudo systemctl start jenkins

echo "Backup completed: jenkins_backup_$DATE.tar.gz"
```

### Configuration Backup
```bash
# Backup only configuration files
sudo tar -czf jenkins_config_backup.tar.gz \
  /var/lib/jenkins/*.xml \
  /var/lib/jenkins/jobs/*/config.xml \
  /var/lib/jenkins/users/ \
  /var/lib/jenkins/secrets/ \
  /var/lib/jenkins/plugins/
```

## Troubleshooting Installation

### Common Issues

#### Port Already in Use
```bash
# Check what's using port 8080
sudo lsof -i :8080
sudo netstat -tulpn | grep 8080

# Change Jenkins port
sudo vi /etc/sysconfig/jenkins
# Change JENKINS_PORT="8080" to JENKINS_PORT="8081"

sudo systemctl restart jenkins
```

#### Permission Issues
```bash
# Fix Jenkins home permissions
sudo chown -R jenkins:jenkins /var/lib/jenkins
sudo chmod -R 755 /var/lib/jenkins

# Fix log permissions
sudo chown jenkins:jenkins /var/log/jenkins/jenkins.log
```

#### Java Issues
```bash
# Check Java version
java -version

# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk' >> ~/.bashrc

# Update alternatives (if multiple Java versions)
sudo alternatives --config java
```

#### Memory Issues
```bash
# Check current memory usage
ps aux | grep jenkins

# Increase heap size
sudo vi /etc/sysconfig/jenkins
JENKINS_JAVA_OPTIONS="-Xmx2048m -Xms1024m"

sudo systemctl restart jenkins
```

### Log Analysis
```bash
# View Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# Check systemd logs
sudo journalctl -u jenkins -f

# Search for errors
sudo grep -i error /var/log/jenkins/jenkins.log
sudo grep -i exception /var/log/jenkins/jenkins.log
```

### Health Check Script
```bash
#!/bin/bash
# jenkins-health-check.sh

JENKINS_URL="http://localhost:8080"

echo "=== Jenkins Health Check ==="

# Check service status
if systemctl is-active --quiet jenkins; then
    echo "✓ Jenkins service is running"
else
    echo "✗ Jenkins service is not running"
    exit 1
fi

# Check HTTP response
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $JENKINS_URL)
if [ "$HTTP_CODE" == "200" ] || [ "$HTTP_CODE" == "403" ]; then
    echo "✓ Jenkins is responding (HTTP $HTTP_CODE)"
else
    echo "✗ Jenkins is not responding (HTTP $HTTP_CODE)"
fi

# Check disk space
DISK_USAGE=$(df -h /var/lib/jenkins | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 90 ]; then
    echo "✓ Disk usage: ${DISK_USAGE}%"
else
    echo "⚠ Disk usage: ${DISK_USAGE}% (high!)"
fi

echo "Health check complete!"
```

This comprehensive installation guide ensures a robust Jenkins setup for production environments.