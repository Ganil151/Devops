# Jenkins Security

Comprehensive security configuration and hardening for Jenkins in production environments.

## Authentication and Authorization

### Security Realm Configuration
```bash
# Enable security in Jenkins
Manage Jenkins > Configure Global Security

# Authentication options:
1. Jenkins' own user database
2. LDAP
3. Active Directory
4. SAML
<b>5. OAuth</b>
<details>
<summary>Show Answer</summary>
Answer: GitHub, Google, etc.
</details>

```

### User Management
```bash
# Create users via CLI
echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("username", "password")' | \
jenkins-cli groovy =

# Manage users programmatically
jenkins-cli create-user username password email fullname

# List users
jenkins-cli list-users
```

### Role-Based Access Control
```bash
# Install Role-based Authorization Strategy plugin
jenkins-cli install-plugin role-strategy

# Configure roles via script
def strategy = Jenkins.instance.getAuthorizationStrategy()
def globalRoleMap = strategy.getGrantedRoles(RoleType.Global)
def projectRoleMap = strategy.getGrantedRoles(RoleType.Project)

# Create global roles
strategy.addRole(RoleType.Global, new Role('admin', Pattern.compile('.*'), 
    [Permission.fromId('hudson.model.Hudson.Administer')] as Set))

strategy.addRole(RoleType.Global, new Role('developer', Pattern.compile('.*'), 
    [Permission.fromId('hudson.model.Hudson.Read')] as Set))
```

## Credential Management

### Credential Types
```bash
# Username/Password credentials
# SSH Private Key credentials  
# Secret text credentials
# Certificate credentials
# AWS credentials
# Kubernetes service account
```

### Credential Storage
```groovy
// Store credentials programmatically
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*

def store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

def credentials = new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    "git-credentials",
    "Git repository credentials",
    "username",
    "password"
)

store.addCredentials(Domain.global(), credentials)
```

### Using Credentials in Pipelines
```groovy
pipeline {
    agent any
    
    stages {
        stage('Deploy') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'deploy-creds', 
                                   usernameVariable: 'USERNAME', 
                                   passwordVariable: 'PASSWORD')
                ]) {
                    sh 'deploy.sh $USERNAME $PASSWORD'
                }
            }
        }
    }
}
```

## Network Security

### HTTPS Configuration
```bash
# Generate SSL certificate
keytool -genkey -keyalg RSA -alias jenkins -keystore jenkins.jks -keysize 2048

# Configure Jenkins with HTTPS
java -jar jenkins.war --httpPort=-1 --httpsPort=8443 --httpsKeyStore=jenkins.jks --httpsKeyStorePassword=password

# Redirect HTTP to HTTPS
java -jar jenkins.war --httpPort=8080 --httpsPort=8443 --httpsKeyStore=jenkins.jks --httpsKeyStorePassword=password --httpsRedirectHttp
```

### Firewall Configuration
```bash
# Allow only necessary ports
sudo ufw allow 8080/tcp  # Jenkins web interface
sudo ufw allow 50000/tcp # Agent communication
sudo ufw deny 8080/tcp from any to any  # Restrict access

# Restrict by IP range
sudo ufw allow from 192.168.1.0/24 to any port 8080
```

### Reverse Proxy Security
```nginx
# Nginx configuration
server {
    listen 443 ssl;
    server_name jenkins.example.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
    }
}
```

## Security Hardening

### System Security
```bash
# Run Jenkins as non-root user
sudo useradd -m -s /bin/bash jenkins
sudo chown -R jenkins:jenkins /var/lib/jenkins

# Secure Jenkins home directory
chmod 750 /var/lib/jenkins
chmod 600 /var/lib/jenkins/secrets/*

# Disable unnecessary services
sudo systemctl disable apache2
sudo systemctl disable nginx
```

### Jenkins Configuration Security
```groovy
// Disable CLI over remoting
Jenkins.instance.getDescriptor("jenkins.CLI").get().setEnabled(false)

// Disable JNLP protocols
Jenkins.instance.setSlaveAgentPort(-1)

// Enable CSRF protection
Jenkins.instance.setCrumbIssuer(new DefaultCrumbIssuer(true))

// Disable usage statistics
Jenkins.instance.setNoUsageStatistics(true)

// Save configuration
Jenkins.instance.save()
```

### Plugin Security
```bash
# Regular plugin updates
jenkins-cli update-plugin --all

# Remove unused plugins
jenkins-cli list-plugins | grep -v "true" | awk '{print $1}' | xargs jenkins-cli uninstall-plugin

# Security scanner plugin
jenkins-cli install-plugin security-scanner
```

## Audit and Monitoring

### Audit Trail
```bash
# Install Audit Trail plugin
jenkins-cli install-plugin audit-trail

# Configure audit logging
Manage Jenkins > Configure System > Audit Trail
Log Location: /var/log/jenkins/audit.log
Log Build Cause: true
Log Node Management: true
```

### Security Monitoring Script
```bash
#!/bin/bash
# jenkins-security-monitor.sh

JENKINS_HOME="/var/lib/jenkins"
LOG_FILE="/var/log/jenkins/security.log"

# Monitor failed login attempts
tail -f "$JENKINS_HOME/logs/all.log" | grep "Failed to authenticate" | while read line; do
    echo "$(date): Failed login - $line" >> "$LOG_FILE"
done &

# Monitor configuration changes
inotifywait -m -e modify "$JENKINS_HOME/config.xml" | while read path action file; do
    echo "$(date): Configuration changed - $file" >> "$LOG_FILE"
done &

# Monitor plugin installations
inotifywait -m -e create "$JENKINS_HOME/plugins/" | while read path action file; do
    echo "$(date): Plugin installed - $file" >> "$LOG_FILE"
done &
```

## Compliance and Best Practices

### Security Checklist
```bash
✓ Enable authentication and authorization
✓ Use HTTPS for web interface
✓ Implement role-based access control
✓ Secure credential storage
✓ Regular security updates
✓ Audit trail enabled
✓ Network access restrictions
✓ Secure agent communication
✓ Regular security assessments
✓ Backup encryption
```

### Compliance Frameworks
```bash
# SOC 2 Compliance
- Access controls
- Encryption in transit and at rest
- Audit logging
- Change management

# PCI DSS Compliance  
- Network segmentation
- Access restrictions
- Encryption requirements
- Regular security testing

# GDPR Compliance
- Data protection
- Access controls
- Audit trails
- Data retention policies
```

This comprehensive Jenkins security guide provides enterprise-grade security controls and compliance capabilities.