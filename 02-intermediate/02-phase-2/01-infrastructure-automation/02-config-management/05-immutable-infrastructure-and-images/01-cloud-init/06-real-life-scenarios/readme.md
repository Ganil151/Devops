# Cloud-Init Real-Life Scenarios

## Scenario 1: E-commerce Web Server Auto-Scaling

### **Challenge**
Deploy identical web servers in an AWS Auto Scaling Group for an e-commerce platform that requires SSL certificates, monitoring agents, and application deployment.

### **Solution**
```yaml
#cloud-config
hostname: web-server
package_update: true
package_upgrade: true

packages:
  - nginx
  - certbot
  - python3-certbot-nginx
  - amazon-cloudwatch-agent
  - git
  - nodejs
  - npm

users:
  - name: webapp
    groups: www-data
    shell: /bin/bash
    home: /opt/webapp

write_files:
  - path: /etc/nginx/sites-available/ecommerce
    content: |
      server {
          listen 80;
          server_name shop.example.com;
          return 301 https://$server_name$request_uri;
      }
      
      server {
          listen 443 ssl http2;
          server_name shop.example.com;
          
          ssl_certificate /etc/letsencrypt/live/shop.example.com/fullchain.pem;
          ssl_certificate_key /etc/letsencrypt/live/shop.example.com/privkey.pem;
          
          location / {
              proxy_pass http://localhost:3000;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
          }
      }

runcmd:
  - ln -s /etc/nginx/sites-available/ecommerce /etc/nginx/sites-enabled/
  - rm -f /etc/nginx/sites-enabled/default
  - systemctl enable nginx
  - systemctl start nginx
  - git clone https://github.com/company/ecommerce-app.git /opt/webapp/app
  - chown -R webapp:webapp /opt/webapp
  - cd /opt/webapp/app && npm install
  - systemctl enable amazon-cloudwatch-agent
```

## Scenario 2: Development Environment Standardization

### **Challenge**
Create consistent development environments for a team of 50 developers working on microservices, ensuring everyone has the same tools and configurations.

### **Solution**
```yaml
#cloud-config
hostname: dev-workstation
timezone: America/New_York

package_update: true
packages:
  - git
  - vim
  - curl
  - wget
  - docker.io
  - docker-compose
  - nodejs
  - npm
  - python3
  - python3-pip
  - openjdk-11-jdk
  - maven
  - code

users:
  - name: developer
    groups: sudo, docker
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2E... team-key

write_files:
  - path: /home/developer/.gitconfig
    content: |
      [user]
          name = Developer
          email = developer@company.com
      [core]
          editor = vim
      [alias]
          st = status
          co = checkout
          br = branch
          ci = commit
    owner: developer:developer

  - path: /home/developer/docker-compose.yml
    content: |
      version: '3.8'
      services:
        postgres:
          image: postgres:13
          environment:
            POSTGRES_DB: devdb
            POSTGRES_USER: dev
            POSTGRES_PASSWORD: devpass
          ports:
            - "5432:5432"
        
        redis:
          image: redis:alpine
          ports:
            - "6379:6379"
        
        mongodb:
          image: mongo:4.4
          ports:
            - "27017:27017"
    owner: developer:developer

runcmd:
  - systemctl enable docker
  - systemctl start docker
  - usermod -aG docker developer
  - pip3 install virtualenv pytest black flake8
  - npm install -g @angular/cli create-react-app
```

## Scenario 3: Security Hardened Database Server

### **Challenge**
Deploy PostgreSQL database servers with strict security requirements for a financial services company, including encryption, audit logging, and compliance controls.

### **Solution**
```yaml
#cloud-config
hostname: db-server
package_update: true
package_upgrade: true

packages:
  - postgresql-13
  - postgresql-contrib-13
  - fail2ban
  - ufw
  - auditd
  - aide

users:
  - name: dbadmin
    groups: sudo, postgres
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2E... dbadmin-key

write_files:
  - path: /etc/postgresql/13/main/postgresql.conf
    content: |
      # Security hardened PostgreSQL configuration
      listen_addresses = 'localhost'
      port = 5432
      max_connections = 100
      
      # Security settings
      ssl = on
      ssl_cert_file = '/etc/ssl/certs/server.crt'
      ssl_key_file = '/etc/ssl/private/server.key'
      
      # Logging
      log_destination = 'stderr'
      logging_collector = on
      log_directory = '/var/log/postgresql'
      log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
      log_statement = 'all'
      log_connections = on
      log_disconnections = on
      
      # Performance
      shared_buffers = 256MB
      effective_cache_size = 1GB
      work_mem = 4MB

  - path: /etc/fail2ban/jail.local
    content: |
      [DEFAULT]
      bantime = 3600
      findtime = 600
      maxretry = 3
      
      [sshd]
      enabled = true
      
      [postgresql]
      enabled = true
      port = 5432
      logpath = /var/log/postgresql/postgresql-*.log

runcmd:
  # Configure firewall
  - ufw default deny incoming
  - ufw default allow outgoing
  - ufw allow from 10.0.0.0/8 to any port 22
  - ufw allow from 10.0.0.0/8 to any port 5432
  - ufw --force enable
  
  # Configure PostgreSQL
  - systemctl enable postgresql
  - systemctl start postgresql
  - sudo -u postgres createdb appdb
  - sudo -u postgres psql -c "CREATE USER appuser WITH PASSWORD 'secure_password';"
  - sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE appdb TO appuser;"
  
  # Start security services
  - systemctl enable fail2ban
  - systemctl start fail2ban
  - systemctl enable auditd
  - systemctl start auditd

ssh_pwauth: false
disable_root: true
```

## Scenario 4: Container Host for Microservices

### **Challenge**
Set up Docker hosts for a microservices architecture with container orchestration, monitoring, and log aggregation.

### **Solution**
```yaml
#cloud-config
hostname: container-host
package_update: true

packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg
  - lsb-release

write_files:
  - path: /etc/docker/daemon.json
    content: |
      {
        "log-driver": "json-file",
        "log-opts": {
          "max-size": "10m",
          "max-file": "3"
        },
        "storage-driver": "overlay2",
        "metrics-addr": "0.0.0.0:9323",
        "experimental": true
      }

  - path: /opt/monitoring/docker-compose.yml
    content: |
      version: '3.8'
      services:
        prometheus:
          image: prom/prometheus:latest
          ports:
            - "9090:9090"
          volumes:
            - ./prometheus.yml:/etc/prometheus/prometheus.yml
        
        grafana:
          image: grafana/grafana:latest
          ports:
            - "3000:3000"
          environment:
            - GF_SECURITY_ADMIN_PASSWORD=admin123
        
        node-exporter:
          image: prom/node-exporter:latest
          ports:
            - "9100:9100"
        
        cadvisor:
          image: gcr.io/cadvisor/cadvisor:latest
          ports:
            - "8080:8080"
          volumes:
            - /:/rootfs:ro
            - /var/run:/var/run:ro
            - /sys:/sys:ro
            - /var/lib/docker/:/var/lib/docker:ro

runcmd:
  # Install Docker
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  - echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  - apt-get update
  - apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  
  # Configure Docker
  - systemctl enable docker
  - systemctl start docker
  - usermod -aG docker ubuntu
  
  # Start monitoring stack
  - cd /opt/monitoring && docker compose up -d
```

## Scenario 5: CI/CD Build Agent

### **Challenge**
Configure build agents for a CI/CD pipeline that supports multiple programming languages and deployment targets.

### **Solution**
```yaml
#cloud-config
hostname: build-agent
package_update: true
package_upgrade: true

packages:
  - git
  - curl
  - wget
  - unzip
  - docker.io
  - nodejs
  - npm
  - python3
  - python3-pip
  - openjdk-11-jdk
  - maven
  - gradle
  - golang-go
  - ruby
  - awscli

users:
  - name: jenkins
    groups: docker
    shell: /bin/bash
    home: /var/lib/jenkins

write_files:
  - path: /etc/systemd/system/jenkins-agent.service
    content: |
      [Unit]
      Description=Jenkins Agent
      After=network.target
      
      [Service]
      Type=simple
      User=jenkins
      WorkingDirectory=/var/lib/jenkins
      ExecStart=/usr/bin/java -jar /var/lib/jenkins/agent.jar -jnlpUrl http://jenkins.company.com/computer/agent/slave-agent.jnlp -secret @/var/lib/jenkins/secret-file
      Restart=always
      RestartSec=10
      
      [Install]
      WantedBy=multi-user.target

runcmd:
  # Install additional tools
  - curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
  - npm install -g yarn typescript @angular/cli
  - pip3 install pytest black flake8 ansible
  - curl -s "https://get.sdkman.io" | bash
  
  # Configure Jenkins agent
  - mkdir -p /var/lib/jenkins
  - chown jenkins:jenkins /var/lib/jenkins
  - wget -O /var/lib/jenkins/agent.jar http://jenkins.company.com/jnlpJars/agent.jar
  - systemctl enable jenkins-agent
  - systemctl start jenkins-agent
  
  # Configure Docker access
  - usermod -aG docker jenkins
  - systemctl enable docker
  - systemctl start docker
```

## Key Takeaways

### **Best Practices Demonstrated**
1. **Security First**: Disable password auth, use SSH keys, configure firewalls
2. **Monitoring**: Include observability tools in base configurations
3. **Automation**: Use configuration management integration
4. **Consistency**: Standardize configurations across environments
5. **Documentation**: Include clear comments and documentation

### **Common Patterns**
- Package installation and updates
- User and SSH key management
- Service configuration and startup
- File creation with proper permissions
- Security hardening measures
- Integration with external systems