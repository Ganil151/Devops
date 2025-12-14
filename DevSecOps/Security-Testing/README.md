# Security Testing in DevSecOps

Complete guide to security testing methodologies and implementation.

## Security Testing Types

### Static Application Security Testing (SAST)
```bash
# Code analysis without execution
# Early vulnerability detection
# White-box testing approach

# SonarQube SAST
sonar-scanner \
  -Dsonar.projectKey=myproject \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000

# Semgrep Security Rules
semgrep --config=auto --json ./src

# Bandit (Python)
bandit -r ./src -f json -o security-report.json
```

### Dynamic Application Security Testing (DAST)
```bash
# Runtime security testing
# Black-box testing approach
# Production-like environment

# OWASP ZAP
zap-baseline.py -t http://example.com
zap-full-scan.py -t http://example.com

# Nikto Web Scanner
nikto -h http://example.com -Format htm
```

### Interactive Application Security Testing (IAST)
```bash
# Runtime code analysis
# Gray-box testing approach
# Real-time vulnerability detection

# Contrast Security
java -javaagent:contrast.jar -jar myapp.jar
```

## Vulnerability Assessment

### OWASP Top 10 Testing
```python
# A01: Broken Access Control
def test_access_control():
    # Test privilege escalation
    user_token = login_as_user()
    admin_response = requests.get('/admin/users', 
                                headers={'Authorization': f'Bearer {user_token}'})
    assert admin_response.status_code == 403

# A02: Cryptographic Failures
def test_encryption():
    # Test weak encryption
    response = requests.get('https://example.com')
    assert 'TLS' in response.headers.get('Strict-Transport-Security', '')

# A03: Injection
def test_sql_injection():
    malicious_input = "'; DROP TABLE users; --"
    response = requests.post('/login', 
                           data={'username': malicious_input, 'password': 'test'})
    assert 'error' not in response.text.lower()
```

### Penetration Testing
```bash
# Network Scanning
nmap -sS -O -sV --script vuln target.com

# Web Application Testing
sqlmap -u "http://example.com/login" --forms --batch

# Wireless Security Testing
aircrack-ng -w wordlist.txt capture.cap
```

## Automated Security Testing

### CI/CD Security Pipeline
```yaml
name: Security Testing Pipeline
on: [push, pull_request]

jobs:
  security-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: SAST Scan
        run: semgrep --config=auto --json ./src
      
      - name: Dependency Check
        run: |
          npm audit --audit-level high
          safety check -r requirements.txt
      
      - name: Container Scan
        run: trivy image myapp:latest
      
      - name: DAST Scan
        run: zap-baseline.py -t http://staging.example.com
```

### Security Test Framework
```python
import requests
import pytest

class SecurityTestSuite:
    def __init__(self, base_url):
        self.base_url = base_url
    
    def test_authentication_bypass(self):
        protected_endpoints = ['/admin', '/profile', '/settings']
        for endpoint in protected_endpoints:
            response = requests.get(f"{self.base_url}{endpoint}")
            assert response.status_code in [401, 403]
    
    def test_input_validation(self):
        xss_payloads = ["<script>alert('XSS')</script>", "javascript:alert(1)"]
        for payload in xss_payloads:
            response = requests.post(f"{self.base_url}/search", 
                                   data={'query': payload})
            assert payload not in response.text
    
    def test_session_management(self):
        # Test session fixation
        session = requests.Session()
        login_response = session.post(f"{self.base_url}/login", 
                                    data={'username': 'user', 'password': 'pass'})
        assert 'Set-Cookie' in login_response.headers
```