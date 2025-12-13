# DAST Tools (Dynamic Application Security Testing)

Complete guide to DAST tools, implementation, and best practices.

## DAST Fundamentals

### What is DAST
```bash
# Dynamic Application Security Testing
- Black-box security testing
- Runtime application analysis
- Production-like environment testing
- Automated vulnerability discovery
- No source code access required
```

## Popular DAST Tools

### OWASP ZAP (Zed Attack Proxy)
```bash
# Installation
docker pull owasp/zap2docker-stable

# Baseline Scan
docker run -t owasp/zap2docker-stable zap-baseline.py \
  -t http://example.com \
  -r zap-baseline-report.html

# Full Scan
docker run -t owasp/zap2docker-stable zap-full-scan.py \
  -t http://example.com \
  -r zap-full-report.html

# API Scan
docker run -t owasp/zap2docker-stable zap-api-scan.py \
  -t http://api.example.com/openapi.json \
  -f openapi \
  -r zap-api-report.html

# Authenticated Scan
docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-stable \
  zap-baseline.py -t http://example.com \
  -c zap-auth-config.conf
```

### Burp Suite
```bash
# Professional Edition CLI
java -jar burpsuite_pro.jar \
  --project-file=scan-project.burp \
  --config-file=scan-config.json

# Burp Suite Enterprise
curl -X POST "https://burp-enterprise.com/api/v1/scan" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "scope": {
      "include": [{"rule": "http://example.com/*"}]
    },
    "scan_configurations": ["crawl-and-audit"]
  }'
```

### Nessus Web Application Scanning
```bash
# Nessus CLI
/opt/nessus/bin/nessuscli scan new \
  --name "Web App Scan" \
  --targets "http://example.com" \
  --template "web_application_tests"

# Results Export
/opt/nessus/bin/nessuscli scan export \
  --scan-id 12345 \
  --format nessus \
  --output webapp-scan-results.nessus
```

### Rapid7 AppSpider
```bash
# AppSpider Enterprise API
curl -X POST "https://appspider.com/api/v1/scans" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Production Web Scan",
    "url": "http://example.com",
    "scanConfig": "FullAudit"
  }'
```

### Acunetix
```bash
# Acunetix API
curl -X POST "https://acunetix.com/api/v1/targets" \
  -H "X-Auth: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "address": "http://example.com",
    "description": "Production website"
  }'

# Start Scan
curl -X POST "https://acunetix.com/api/v1/scans" \
  -H "X-Auth: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "target_id": "target-uuid",
    "profile_id": "full_audit"
  }'
```

## Web Application Vulnerability Testing

### OWASP Top 10 Testing
```bash
# A01: Broken Access Control
# Test for privilege escalation
curl -H "Authorization: Bearer user_token" \
  http://api.example.com/admin/users

# A02: Cryptographic Failures
# Test SSL/TLS configuration
testssl.sh https://example.com

# A03: Injection
# SQL Injection Testing
sqlmap -u "http://example.com/search?q=test" \
  --batch --level=3 --risk=2

# A04: Insecure Design
# Business logic testing (manual)

# A05: Security Misconfiguration
# Check for default credentials
hydra -l admin -P passwords.txt \
  http-get://example.com/admin/

# A06: Vulnerable Components
# Dependency scanning
retire --path ./public/js/

# A07: Authentication Failures
# Brute force testing
hydra -l admin -P rockyou.txt \
  https-post-form "/login:username=^USER^&password=^PASS^:Invalid"

# A08: Software Integrity Failures
# Check for unsigned components

# A09: Logging Failures
# Test for information disclosure

# A10: Server-Side Request Forgery
# SSRF testing with custom payloads
```

### API Security Testing
```bash
# REST API Testing
# Endpoint discovery
gobuster dir -u http://api.example.com \
  -w api-wordlist.txt

# HTTP method testing
curl -X DELETE http://api.example.com/users/1
curl -X PUT http://api.example.com/users/1 \
  -d '{"role":"admin"}'

# Rate limiting testing
for i in {1..1000}; do
  curl http://api.example.com/api/endpoint &
done

# GraphQL Testing
# Introspection query
curl -X POST http://api.example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"query IntrospectionQuery { __schema { queryType { name } } }"}'
```

## DAST Automation and CI/CD Integration

### GitHub Actions DAST Pipeline
```yaml
name: DAST Security Scan
on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM
  workflow_dispatch:

jobs:
  dast-scan:
    runs-on: ubuntu-latest
    steps:
      - name: ZAP Baseline Scan
        uses: zaproxy/action-baseline@v0.7.0
        with:
          target: 'https://staging.example.com'
          rules_file_name: '.zap/rules.tsv'
          cmd_options: '-a'
      
      - name: ZAP Full Scan
        uses: zaproxy/action-full-scan@v0.4.0
        with:
          target: 'https://staging.example.com'
          rules_file_name: '.zap/rules.tsv'
          cmd_options: '-a'
      
      - name: Upload SARIF results
        uses: github/codeql-action/upload-sarif@v1
        with:
          sarif_file: results.sarif
```

### Jenkins DAST Pipeline
```groovy
pipeline {
    agent any
    
    parameters {
        string(name: 'TARGET_URL', defaultValue: 'https://staging.example.com', description: 'Target URL for DAST scan')
        choice(name: 'SCAN_TYPE', choices: ['baseline', 'full', 'api'], description: 'Type of scan to perform')
    }
    
    stages {
        stage('DAST Scan') {
            steps {
                script {
                    def scanCommand = ""
                    switch(params.SCAN_TYPE) {
                        case 'baseline':
                            scanCommand = "zap-baseline.py -t ${params.TARGET_URL}"
                            break
                        case 'full':
                            scanCommand = "zap-full-scan.py -t ${params.TARGET_URL}"
                            break
                        case 'api':
                            scanCommand = "zap-api-scan.py -t ${params.TARGET_URL}/openapi.json"
                            break
                    }
                    
                    sh """
                        docker run -v \$(pwd):/zap/wrk/:rw -t owasp/zap2docker-stable \
                        ${scanCommand} -r dast-report.html -x dast-report.xml
                    """
                }
            }
        }
        
        stage('Process Results') {
            steps {
                script {
                    def results = readFile('dast-report.xml')
                    def highRiskCount = (results =~ /<riskcode>3<\/riskcode>/).size()
                    
                    if (highRiskCount > 0) {
                        currentBuild.result = 'UNSTABLE'
                        echo "Found ${highRiskCount} high-risk vulnerabilities"
                    }
                }
            }
        }
    }
    
    post {
        always {
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: '.',
                reportFiles: 'dast-report.html',
                reportName: 'DAST Security Report'
            ])
            
            archiveArtifacts artifacts: 'dast-report.*', fingerprint: true
        }
    }
}
```

## Authentication and Session Management Testing

### ZAP Authentication Configuration
```bash
# Authentication script for ZAP
# zap-auth-config.conf
auth.loginurl=http://example.com/login
auth.username=testuser
auth.password=testpass
auth.usernamefield=username
auth.passwordfield=password
auth.submitfield=submit
auth.loggedinregex=\QWelcome\E
auth.loggedoutregex=\QLogin\E

# Context configuration
contexts:
  - name: "webapp"
    urls:
      - "http://example.com.*"
    authentication:
      method: "form"
      loginUrl: "http://example.com/login"
      loginRequestData: "username={%username%}&password={%password%}"
    users:
      - name: "testuser"
        credentials:
          username: "testuser"
          password: "testpass"
```

### Session Management Testing
```python
# Session testing script
import requests
import time

def test_session_management():
    session = requests.Session()
    
    # Test session fixation
    initial_cookies = session.cookies.get_dict()
    
    # Login
    login_data = {'username': 'testuser', 'password': 'testpass'}
    login_response = session.post('http://example.com/login', data=login_data)
    
    post_login_cookies = session.cookies.get_dict()
    
    # Check if session ID changed after login
    if initial_cookies == post_login_cookies:
        print("VULNERABILITY: Session fixation possible")
    
    # Test session timeout
    time.sleep(1800)  # Wait 30 minutes
    protected_response = session.get('http://example.com/profile')
    
    if protected_response.status_code == 200:
        print("VULNERABILITY: Session timeout not implemented")
    
    # Test concurrent sessions
    session2 = requests.Session()
    session2.post('http://example.com/login', data=login_data)
    
    # Check if first session is still valid
    profile_response = session.get('http://example.com/profile')
    if profile_response.status_code == 200:
        print("INFO: Concurrent sessions allowed")
```

## Mobile Application DAST

### Mobile Security Testing
```bash
# MobSF (Mobile Security Framework)
docker run -it -p 8000:8000 opensecurity/mobsf:latest

# Upload APK/IPA for analysis
curl -F "file=@app.apk" http://localhost:8000/api/v1/upload

# QARK (Quick Android Review Kit)
qark --apk app.apk --report-type json

# Drozer for Android
drozer console connect
dz> run app.package.list -f com.example.app
dz> run app.activity.info -a com.example.app
```

## Network and Infrastructure DAST

### Network Vulnerability Scanning
```bash
# Nmap vulnerability scanning
nmap -sS -sV --script vuln target.com

# OpenVAS scanning
openvas-start
openvas-cli -u admin -w admin --get-tasks

# Nuclei vulnerability scanner
nuclei -u https://example.com -t cves/
nuclei -l urls.txt -t technologies/
```

### SSL/TLS Testing
```bash
# testssl.sh
testssl.sh https://example.com

# SSLyze
sslyze --regular example.com:443

# SSL Labs API
curl "https://api.ssllabs.com/api/v3/analyze?host=example.com"
```

## DAST Results Management

### Vulnerability Correlation
```python
# DAST Results Processor
import json
import xml.etree.ElementTree as ET

class DASTResultsProcessor:
    def __init__(self):
        self.vulnerabilities = []
    
    def parse_zap_xml(self, xml_file):
        tree = ET.parse(xml_file)
        root = tree.getroot()
        
        for alert in root.findall('.//alertitem'):
            vuln = {
                'name': alert.find('name').text,
                'risk': alert.find('riskdesc').text,
                'confidence': alert.find('confidence').text,
                'url': alert.find('uri').text,
                'description': alert.find('desc').text,
                'solution': alert.find('solution').text,
                'reference': alert.find('reference').text
            }
            self.vulnerabilities.append(vuln)
    
    def filter_false_positives(self):
        # Implement false positive filtering logic
        filtered_vulns = []
        for vuln in self.vulnerabilities:
            if not self.is_false_positive(vuln):
                filtered_vulns.append(vuln)
        return filtered_vulns
    
    def is_false_positive(self, vuln):
        # Custom false positive detection logic
        false_positive_patterns = [
            'test environment',
            'development server',
            'staging domain'
        ]
        
        for pattern in false_positive_patterns:
            if pattern in vuln['url'].lower():
                return True
        return False
    
    def generate_jira_tickets(self, high_risk_vulns):
        for vuln in high_risk_vulns:
            if 'High' in vuln['risk']:
                ticket_data = {
                    'summary': f"Security Vulnerability: {vuln['name']}",
                    'description': f"{vuln['description']}\n\nURL: {vuln['url']}\n\nSolution: {vuln['solution']}",
                    'priority': 'High',
                    'labels': ['security', 'dast', 'vulnerability']
                }
                # Create JIRA ticket
```

### Continuous Monitoring
```bash
# Scheduled DAST scanning
# crontab entry
0 2 * * * /usr/local/bin/run-dast-scan.sh

# run-dast-scan.sh
#!/bin/bash
TARGET_URL="https://production.example.com"
REPORT_DIR="/var/reports/dast/$(date +%Y%m%d)"

mkdir -p $REPORT_DIR

# Run ZAP baseline scan
docker run -v $REPORT_DIR:/zap/wrk/:rw -t owasp/zap2docker-stable \
  zap-baseline.py -t $TARGET_URL \
  -r baseline-report.html \
  -x baseline-report.xml

# Check for high-risk vulnerabilities
HIGH_RISK_COUNT=$(grep -c 'riskcode>3<' $REPORT_DIR/baseline-report.xml)

if [ $HIGH_RISK_COUNT -gt 0 ]; then
    # Send alert
    curl -X POST -H 'Content-type: application/json' \
      --data "{\"text\":\"High-risk vulnerabilities found: $HIGH_RISK_COUNT\"}" \
      $SLACK_WEBHOOK_URL
fi
```

## Performance Optimization

### Scan Optimization
```bash
# ZAP scan optimization
# Reduce scan time with focused testing
zap-baseline.py -t http://example.com \
  -c zap-config.conf \
  --hook=/zap/auth_hook.py \
  -z "-config spider.maxDuration=10" \
  -z "-config scanner.maxScanDurationInMins=30"

# Parallel scanning for large applications
# Split URLs into batches
split -l 100 urls.txt url_batch_

for batch in url_batch_*; do
  docker run -d -v $(pwd):/zap/wrk/:rw owasp/zap2docker-stable \
    zap-baseline.py -t "$(cat $batch)" &
done
wait
```

### Resource Management
```yaml
# Kubernetes DAST job with resource limits
apiVersion: batch/v1
kind: Job
metadata:
  name: dast-scan
spec:
  template:
    spec:
      containers:
      - name: zap-scanner
        image: owasp/zap2docker-stable
        command: ["zap-baseline.py"]
        args: ["-t", "https://example.com"]
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
      restartPolicy: Never
```

## Best Practices

### DAST Implementation Strategy
```bash
# 1. Environment Strategy
- Use staging/pre-production environments
- Mirror production configuration
- Implement proper test data management
- Ensure network accessibility

# 2. Scan Scheduling
- Regular automated scans
- Pre-deployment validation
- Post-deployment verification
- Incident-triggered scans

# 3. Coverage Optimization
- Comprehensive crawling configuration
- Authentication setup
- API endpoint discovery
- Mobile application testing

# 4. Results Management
- Automated vulnerability triage
- False positive management
- Integration with bug tracking
- Trend analysis and reporting
```