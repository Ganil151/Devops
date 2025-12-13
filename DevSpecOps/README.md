# DevSecOps

Complete guide to DevSecOps practices, security integration, and implementation strategies.

## DevSecOps Fundamentals

### Definition
```bash
# DevSecOps = Development + Security + Operations
# Security integrated throughout the entire SDLC
# Shift-left security approach
# Automated security testing and compliance
# Shared responsibility for security
```

### Core Principles
```bash
# 1. Security as Code
- Infrastructure security automation
- Policy as code implementation
- Security configuration management
- Compliance automation

# 2. Shift-Left Security
- Early vulnerability detection
- Security in design phase
- Developer security training
- Secure coding practices

# 3. Continuous Security
- Automated security testing
- Real-time threat detection
- Continuous compliance monitoring
- Security feedback loops

# 4. Shared Responsibility
- Security ownership across teams
- Collaborative security culture
- Cross-functional security training
- Integrated security workflows
```

## Security in CI/CD Pipeline

### Pipeline Security Stages
```yaml
# GitHub Actions DevSecOps Pipeline
name: DevSecOps Pipeline
on: [push, pull_request]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      # Secret Scanning
      - name: Secret Scan
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
      
      # SAST Scanning
      - name: SAST Scan
        uses: github/codeql-action/analyze@v1
      
      # Dependency Scanning
      - name: Dependency Check
        run: |
          npm audit --audit-level high
          safety check -r requirements.txt
      
      # Container Scanning
      - name: Container Scan
        run: |
          docker build -t myapp:latest .
          trivy image myapp:latest
      
      # Infrastructure Scanning
      - name: IaC Scan
        run: |
          checkov -f main.tf
          tfsec .
      
      # Deploy to Staging
      - name: Deploy Staging
        run: ./deploy-staging.sh
      
      # DAST Scanning
      - name: DAST Scan
        run: |
          zap-baseline.py -t http://staging.example.com
```

### Security Gates
```bash
# Quality Gates for Security
# No critical vulnerabilities
# Dependency vulnerabilities < threshold
# Code coverage > 80%
# Security test pass rate = 100%
# Compliance checks passed

# Jenkins Security Gate
pipeline {
    stages {
        stage('Security Gate') {
            steps {
                script {
                    def securityResults = readJSON file: 'security-results.json'
                    if (securityResults.critical > 0) {
                        error "Critical vulnerabilities found: ${securityResults.critical}"
                    }
                }
            }
        }
    }
}
```

## Static Application Security Testing (SAST)

### Code Analysis Tools
```bash
# SonarQube Security Rules
sonar-scanner \
  -Dsonar.projectKey=myproject \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.qualitygate.wait=true

# Semgrep Security Scanning
semgrep --config=auto --json --output=semgrep-results.json ./src

# Bandit (Python Security)
bandit -r ./src -f json -o bandit-report.json

# ESLint Security Plugin
eslint --ext .js,.ts src/ --config .eslintrc-security.js

# Checkmarx SAST
cx scan create --project-name "MyApp" --source-dir ./src
```

### Custom Security Rules
```yaml
# Semgrep Custom Rule
rules:
  - id: hardcoded-password
    pattern: |
      password = "..."
    message: "Hardcoded password detected"
    languages: [python, javascript]
    severity: ERROR
    
  - id: sql-injection-risk
    pattern: |
      cursor.execute("SELECT * FROM users WHERE id = " + $VAR)
    message: "Potential SQL injection vulnerability"
    languages: [python]
    severity: WARNING
```

## Dynamic Application Security Testing (DAST)

### Web Application Scanning
```bash
# OWASP ZAP Scanning
# Baseline scan
zap-baseline.py -t http://example.com

# Full scan
zap-full-scan.py -t http://example.com -r zap-report.html

# API scan
zap-api-scan.py -t http://api.example.com/openapi.json

# Authenticated scan
zap-baseline.py -t http://example.com -c zap-config.conf
```

### API Security Testing
```bash
# Postman Security Tests
pm.test("No sensitive data in response", function () {
    const responseText = pm.response.text();
    pm.expect(responseText).to.not.include("password");
    pm.expect(responseText).to.not.include("ssn");
    pm.expect(responseText).to.not.include("credit_card");
});

pm.test("Security headers present", function () {
    pm.expect(pm.response.headers.get("X-Content-Type-Options")).to.eql("nosniff");
    pm.expect(pm.response.headers.get("X-Frame-Options")).to.exist;
    pm.expect(pm.response.headers.get("Content-Security-Policy")).to.exist;
});

# Burp Suite API Testing
java -jar burpsuite_community.jar --project-file=api-test.burp
```

## Container Security

### Image Scanning
```bash
# Trivy Container Scanning
trivy image nginx:latest
trivy image --format json --output results.json myapp:latest

# Clair Scanner
clair-scanner --ip localhost myapp:latest

# Anchore Engine
anchore-cli image add myapp:latest
anchore-cli image wait myapp:latest
anchore-cli image vuln myapp:latest all

# Snyk Container Scanning
snyk container test myapp:latest
snyk container monitor myapp:latest
```

### Secure Dockerfile Practices
```dockerfile
# Multi-stage build for security
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:16-alpine AS runtime
# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Copy only necessary files
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --chown=nextjs:nodejs . .

# Security configurations
USER nextjs
EXPOSE 3000
ENV NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["npm", "start"]
```

### Runtime Security
```yaml
# Kubernetes Security Policies
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
```

## Infrastructure Security

### Infrastructure as Code Security
```bash
# Terraform Security Scanning
# Checkov
checkov -f main.tf --framework terraform

# tfsec
tfsec .

# Terrascan
terrascan scan -t terraform

# Custom Terraform Security
# main.tf with security best practices
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-secure-bucket"
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  
  public_access_block {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
  
  versioning {
    enabled = true
  }
  
  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/"
  }
}
```

### Cloud Security Posture Management
```bash
# AWS Config Rules
aws configservice put-config-rule \
  --config-rule '{
    "ConfigRuleName": "s3-bucket-public-access-prohibited",
    "Source": {
      "Owner": "AWS",
      "SourceIdentifier": "S3_BUCKET_PUBLIC_ACCESS_PROHIBITED"
    }
  }'

# Azure Security Center
az security assessment list
az security alert list

# GCP Security Command Center
gcloud scc findings list organizations/123456789
```

## Secret Management

### Secret Scanning
```bash
# TruffleHog Secret Scanning
trufflehog git https://github.com/user/repo.git

# GitLeaks
gitleaks detect --source . --verbose

# detect-secrets
detect-secrets scan --all-files .
detect-secrets audit .secrets.baseline
```

### Secret Management Tools
```bash
# HashiCorp Vault
# Store secret
vault kv put secret/myapp/db username=admin password=secret

# Retrieve secret
vault kv get secret/myapp/db

# AWS Secrets Manager
aws secretsmanager create-secret \
  --name prod/myapp/db \
  --secret-string '{"username":"admin","password":"secret"}'

# Kubernetes Secrets
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=secret

# External Secrets Operator
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "http://vault.vault:8200"
      path: "secret"
      version: "v2"
```

## Compliance and Governance

### Policy as Code
```rego
# Open Policy Agent (OPA) Policy
package kubernetes.admission

deny[msg] {
  input.request.kind.kind == "Pod"
  input.request.object.spec.containers[_].image
  not starts_with(input.request.object.spec.containers[_].image, "registry.company.com/")
  msg := "Container images must come from approved registry"
}

deny[msg] {
  input.request.kind.kind == "Pod"
  input.request.object.spec.containers[_].securityContext.privileged == true
  msg := "Privileged containers are not allowed"
}
```

### Compliance Frameworks
```bash
# SOC 2 Type II Compliance
- Access controls and authentication
- System monitoring and logging
- Data encryption and protection
- Incident response procedures
- Vendor management

# PCI DSS Compliance
- Secure network architecture
- Cardholder data protection
- Vulnerability management
- Access control measures
- Regular security testing

# GDPR Compliance
- Data protection by design
- Privacy impact assessments
- Data subject rights
- Breach notification procedures
- Data processing records
```

## Security Monitoring and Incident Response

### Security Information and Event Management (SIEM)
```bash
# ELK Stack Security Monitoring
# Logstash security pipeline
input {
  beats {
    port => 5044
  }
}

filter {
  if [fields][log_type] == "security" {
    grok {
      match => { "message" => "%{COMBINEDAPACHELOG}" }
    }
    
    if [response] >= 400 {
      mutate {
        add_tag => ["security_event"]
      }
    }
  }
}

output {
  if "security_event" in [tags] {
    elasticsearch {
      hosts => ["elasticsearch:9200"]
      index => "security-events-%{+YYYY.MM.dd}"
    }
  }
}
```

### Incident Response Automation
```python
# Automated Incident Response
import requests
import json

class SecurityIncidentHandler:
    def __init__(self, webhook_url, slack_token):
        self.webhook_url = webhook_url
        self.slack_token = slack_token
    
    def handle_critical_vulnerability(self, vulnerability):
        # Create incident ticket
        incident = self.create_incident_ticket(vulnerability)
        
        # Notify security team
        self.notify_slack_channel(
            channel="#security-alerts",
            message=f"Critical vulnerability detected: {vulnerability['name']}"
        )
        
        # Trigger automated remediation
        if vulnerability['auto_fixable']:
            self.trigger_auto_fix(vulnerability)
        
        return incident
    
    def create_incident_ticket(self, vulnerability):
        payload = {
            "title": f"Security Vulnerability: {vulnerability['name']}",
            "severity": "critical",
            "description": vulnerability['description'],
            "affected_systems": vulnerability['systems']
        }
        
        response = requests.post(self.webhook_url, json=payload)
        return response.json()
```

## DevSecOps Metrics and KPIs

### Security Metrics
```bash
# Key Security Metrics
- Mean Time to Detection (MTTD)
- Mean Time to Response (MTTR)
- Vulnerability density per release
- Security test coverage
- False positive rate
- Security training completion rate

# DORA Security Metrics
- Security deployment frequency
- Security lead time
- Security change failure rate
- Security recovery time
```

### Security Dashboard
```python
# Security Metrics Dashboard
import matplotlib.pyplot as plt
import pandas as pd

def generate_security_dashboard():
    # Vulnerability trends
    vulnerability_data = {
        'month': ['Jan', 'Feb', 'Mar', 'Apr', 'May'],
        'critical': [5, 3, 2, 1, 0],
        'high': [15, 12, 8, 5, 3],
        'medium': [25, 20, 15, 12, 8]
    }
    
    df = pd.DataFrame(vulnerability_data)
    
    # Create stacked bar chart
    plt.figure(figsize=(10, 6))
    plt.bar(df['month'], df['critical'], label='Critical', color='red')
    plt.bar(df['month'], df['high'], bottom=df['critical'], label='High', color='orange')
    plt.bar(df['month'], df['medium'], bottom=df['critical']+df['high'], label='Medium', color='yellow')
    
    plt.title('Vulnerability Trends Over Time')
    plt.xlabel('Month')
    plt.ylabel('Number of Vulnerabilities')
    plt.legend()
    plt.savefig('security-dashboard.png')
```

## Security Training and Culture

### Developer Security Training
```bash
# Security Training Topics
- Secure coding practices
- OWASP Top 10 vulnerabilities
- Threat modeling techniques
- Security testing methodologies
- Incident response procedures

# Hands-on Security Labs
- SQL injection prevention
- XSS mitigation techniques
- Authentication bypass testing
- Container security hardening
- Infrastructure security scanning
```

### Security Champions Program
```bash
# Security Champions Framework
1. Identify security advocates in each team
2. Provide advanced security training
3. Regular security knowledge sharing
4. Security code review participation
5. Security tool evangelism
6. Incident response coordination
```

## DevSecOps Tools and Technologies

### Security Tool Integration
```yaml
# Tool Categories and Examples
SAST Tools:
  - SonarQube
  - Checkmarx
  - Veracode
  - Semgrep

DAST Tools:
  - OWASP ZAP
  - Burp Suite
  - Nessus
  - Rapid7

Container Security:
  - Trivy
  - Clair
  - Anchore
  - Snyk

Secret Management:
  - HashiCorp Vault
  - AWS Secrets Manager
  - Azure Key Vault
  - CyberArk

Compliance:
  - Open Policy Agent
  - Falco
  - Chef InSpec
  - AWS Config
```

This comprehensive DevSecOps guide provides the foundation for implementing security throughout the entire software development lifecycle, ensuring that security is not an afterthought but an integral part of the development process.