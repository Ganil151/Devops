# Security Testing

Complete guide to security testing methodologies, tools, and implementation.

## Security Testing Types

### SAST (Static Application Security Testing)
```bash
# Code analysis without execution
# Early vulnerability detection
# IDE integration

# SonarQube
sonar-scanner \
  -Dsonar.projectKey=myproject \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000

# Semgrep
semgrep --config=auto ./src

# Bandit (Python)
bandit -r ./src -f json -o security-report.json

# ESLint Security Plugin (JavaScript)
eslint --ext .js,.ts src/ --config .eslintrc-security.js
```

### DAST (Dynamic Application Security Testing)
```bash
# Runtime security testing
# Black-box testing approach
# Production-like environment

# OWASP ZAP
zap-baseline.py -t http://example.com
zap-full-scan.py -t http://example.com

# Nikto Web Scanner
nikto -h http://example.com -Format htm -output nikto-report.html

# SQLMap (SQL Injection Testing)
sqlmap -u "http://example.com/login" --forms --batch --crawl=2
```

### IAST (Interactive Application Security Testing)
```bash
# Runtime code analysis
# Real-time vulnerability detection
# Combines SAST and DAST benefits

# Contrast Security Agent
java -javaagent:contrast.jar \
  -Dcontrast.api.url=https://app.contrastsecurity.com/Contrast/api \
  -Dcontrast.api.user_name=agent@company.com \
  -jar myapp.jar
```

## Vulnerability Scanning

### Container Security Scanning
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
```

### Infrastructure Scanning
```bash
# Nessus
# Commercial vulnerability scanner
# Network and system scanning

# OpenVAS
# Open source vulnerability scanner
openvas-start
openvas-cli -u admin -w admin --get-tasks

# Nmap Security Scanning
nmap -sS -O -sV --script vuln target.com
nmap --script ssl-enum-ciphers -p 443 target.com
```

### Dependency Scanning
```bash
# npm audit (Node.js)
npm audit
npm audit fix
npm audit --json > audit-report.json

# Safety (Python)
safety check
safety check --json --output safety-report.json

# OWASP Dependency Check
dependency-check --project myapp --scan ./src --format JSON --out reports/

# Snyk
snyk test
snyk monitor
snyk test --json > snyk-report.json
```

## Web Application Security Testing

### OWASP Top 10 Testing
```bash
# A01: Broken Access Control
# Test for privilege escalation
curl -H "Authorization: Bearer user_token" \
  http://api.example.com/admin/users

# A02: Cryptographic Failures
# Test for weak encryption
openssl s_client -connect example.com:443 -cipher 'DES'

# A03: Injection
# SQL Injection Testing
sqlmap -u "http://example.com/search?q=test" --batch

# A04: Insecure Design
# Business logic testing
# Manual testing required

# A05: Security Misconfiguration
# Check for default credentials
hydra -l admin -P passwords.txt http-get://example.com/admin/
```

### Authentication Testing
```bash
# Brute Force Testing
hydra -l admin -P rockyou.txt ssh://target.com

# JWT Token Testing
# Check for weak secrets
python jwt_tool.py -t http://example.com -rh "Authorization: Bearer TOKEN"

# Session Management Testing
# Check for session fixation
curl -c cookies.txt -b cookies.txt http://example.com/login

# Multi-Factor Authentication Testing
# Bypass attempts and implementation flaws
```

### Authorization Testing
```python
# Role-Based Access Control Testing
import requests

def test_rbac_bypass():
    # Login as regular user
    user_session = requests.Session()
    user_session.post('/login', data={'username': 'user', 'password': 'pass'})
    
    # Attempt admin action
    response = user_session.get('/admin/users')
    assert response.status_code == 403, "Authorization bypass detected!"
    
    # Test parameter manipulation
    response = user_session.get('/profile?user_id=1')  # Other user's profile
    assert response.status_code == 403, "IDOR vulnerability detected!"
```

## API Security Testing

### REST API Security
```bash
# API Endpoint Discovery
gobuster dir -u http://api.example.com -w api-wordlist.txt

# HTTP Method Testing
curl -X DELETE http://api.example.com/users/1
curl -X PUT http://api.example.com/users/1 -d '{"role":"admin"}'

# Rate Limiting Testing
for i in {1..1000}; do
  curl http://api.example.com/api/endpoint &
done

# Input Validation Testing
curl -X POST http://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{"name":"<script>alert(1)</script>","email":"invalid-email"}'
```

### GraphQL Security Testing
```bash
# Introspection Query
curl -X POST http://api.example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"query IntrospectionQuery { __schema { queryType { name } } }"}'

# Depth Limiting Testing
curl -X POST http://api.example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"query { user { posts { comments { replies { user { posts { comments } } } } } } }"}'

# Query Complexity Testing
# Test for resource exhaustion through complex queries
```

## Security Test Automation

### Security in CI/CD Pipeline
```yaml
# GitHub Actions Security Pipeline
name: Security Tests
on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: SAST Scan
        uses: github/codeql-action/analyze@v1
      
      - name: Dependency Check
        run: |
          npm audit --audit-level high
          safety check -r requirements.txt
      
      - name: Container Scan
        run: |
          docker build -t myapp:latest .
          trivy image myapp:latest
      
      - name: DAST Scan
        run: |
          docker run -t owasp/zap2docker-stable zap-baseline.py \
            -t http://staging.example.com
```

### Security Testing Framework
```python
# Security Test Framework
import requests
import pytest
from security_tests import SQLInjectionTest, XSSTest, AuthTest

class SecurityTestSuite:
    def __init__(self, base_url):
        self.base_url = base_url
        self.session = requests.Session()
    
    def test_sql_injection(self):
        payloads = ["' OR '1'='1", "'; DROP TABLE users; --"]
        for payload in payloads:
            response = self.session.post(
                f"{self.base_url}/login",
                data={"username": payload, "password": "test"}
            )
            assert "error" not in response.text.lower()
    
    def test_xss_vulnerability(self):
        xss_payloads = ["<script>alert('XSS')</script>", "javascript:alert('XSS')"]
        for payload in xss_payloads:
            response = self.session.post(
                f"{self.base_url}/search",
                data={"query": payload}
            )
            assert payload not in response.text
    
    def test_authentication_bypass(self):
        # Test for authentication bypass vulnerabilities
        protected_endpoints = ["/admin", "/profile", "/settings"]
        for endpoint in protected_endpoints:
            response = self.session.get(f"{self.base_url}{endpoint}")
            assert response.status_code in [401, 403]
```

## Compliance and Regulatory Testing

### GDPR Compliance Testing
```bash
# Data Protection Testing
# Right to be forgotten
curl -X DELETE http://api.example.com/users/1/data

# Data portability
curl -X GET http://api.example.com/users/1/export

# Consent management
curl -X POST http://api.example.com/consent \
  -d '{"user_id":1,"consent_type":"marketing","granted":false}'
```

### PCI DSS Compliance Testing
```bash
# Payment Card Industry Data Security Standard
# Network security testing
nmap -sS -O target-payment-system.com

# Encryption testing
testssl.sh https://payment.example.com

# Access control testing
# Verify cardholder data access restrictions
```

### HIPAA Compliance Testing
```bash
# Health Insurance Portability and Accountability Act
# PHI (Protected Health Information) testing
# Audit log verification
# Access control validation
# Encryption at rest and in transit testing
```

## Security Metrics and Reporting

### Security KPIs
```bash
# Key Performance Indicators
- Vulnerability Detection Rate
- Mean Time to Detection (MTTD)
- Mean Time to Resolution (MTTR)
- Security Test Coverage
- False Positive Rate
- Critical Vulnerability Count
```

### Security Reporting
```python
# Security Report Generation
import json
from datetime import datetime

def generate_security_report(scan_results):
    report = {
        "scan_date": datetime.now().isoformat(),
        "summary": {
            "total_vulnerabilities": len(scan_results),
            "critical": len([v for v in scan_results if v["severity"] == "critical"]),
            "high": len([v for v in scan_results if v["severity"] == "high"]),
            "medium": len([v for v in scan_results if v["severity"] == "medium"]),
            "low": len([v for v in scan_results if v["severity"] == "low"])
        },
        "vulnerabilities": scan_results
    }
    
    with open("security-report.json", "w") as f:
        json.dump(report, f, indent=2)
    
    return report
```