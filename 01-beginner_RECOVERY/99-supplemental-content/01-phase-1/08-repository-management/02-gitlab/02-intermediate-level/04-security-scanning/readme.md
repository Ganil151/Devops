# Security Scanning in GitLab

## Overview of GitLab Security Features

GitLab provides comprehensive security scanning capabilities integrated into the CI/CD pipeline:

- **SAST** (Static Application Security Testing)
- **DAST** (Dynamic Application Security Testing)  
- **Dependency Scanning**
- **Container Scanning**
- **Secret Detection**
- **License Compliance**
- **Coverage-guided Fuzz Testing**

## Static Application Security Testing (SAST)

### 1. Basic SAST Configuration
```yaml
# .gitlab-ci.yml - SAST Integration
include:
  - template: Security/SAST.gitlab-ci.yml

stages:
  - build
  - test
  - security
  - deploy

variables:
  SAST_EXCLUDED_PATHS: "spec, test, tests, tmp"
  SAST_EXCLUDED_ANALYZERS: "bandit,eslint"

# Custom SAST job
sast-custom:
  stage: security
  image: securecodewarrior/gitlab-sast:latest
  script:
    - sast-analyzer
  artifacts:
    reports:
      sast: gl-sast-report.json
  only:
    - main
    - merge_requests
```

### 2. Language-Specific SAST
```yaml
# Java SAST with SpotBugs
spotbugs-sast:
  stage: security
  image: openjdk:11
  before_script:
    - apt-get update && apt-get install -y wget
    - wget https://github.com/spotbugs/spotbugs/releases/download/4.7.3/spotbugs-4.7.3.tgz
    - tar -xzf spotbugs-4.7.3.tgz
  script:
    - ./spotbugs-4.7.3/bin/spotbugs -textui -output spotbugs-report.xml target/classes/
  artifacts:
    reports:
      sast: spotbugs-report.xml

# Python SAST with Bandit
bandit-sast:
  stage: security
  image: python:3.9
  before_script:
    - pip install bandit[toml]
  script:
    - bandit -r . -f json -o bandit-report.json
  artifacts:
    reports:
      sast: bandit-report.json

# JavaScript SAST with ESLint Security
eslint-security:
  stage: security
  image: node:16
  before_script:
    - npm install -g eslint eslint-plugin-security
  script:
    - eslint --ext .js,.jsx --format json --output-file eslint-report.json src/
  artifacts:
    reports:
      sast: eslint-report.json
```

### 3. Custom SAST Rules
```yaml
# Custom SAST configuration
# .gitlab/sast-rules.yml
rules:
  - id: "custom-sql-injection"
    pattern: "SELECT.*FROM.*WHERE.*=.*\\$"
    message: "Potential SQL injection vulnerability"
    severity: "HIGH"
    languages: ["php", "java", "python"]
  
  - id: "hardcoded-password"
    pattern: "password\\s*=\\s*['\"][^'\"]{8,}['\"]"
    message: "Hardcoded password detected"
    severity: "CRITICAL"
    languages: ["*"]
```

## Dynamic Application Security Testing (DAST)

### 1. Basic DAST Setup
```yaml
# .gitlab-ci.yml - DAST Integration
include:
  - template: Security/DAST.gitlab-ci.yml

variables:
  DAST_WEBSITE: "https://staging.example.com"
  DAST_FULL_SCAN_ENABLED: "true"
  DAST_AUTH_URL: "https://staging.example.com/login"
  DAST_USERNAME: "test@example.com"
  DAST_PASSWORD: "$DAST_PASSWORD"

# Deploy to staging for DAST
deploy-staging:
  stage: deploy
  script:
    - deploy-to-staging.sh
  environment:
    name: staging
    url: https://staging.example.com

# DAST scan
dast:
  stage: security
  needs:
    - deploy-staging
  variables:
    DAST_WEBSITE: $CI_ENVIRONMENT_URL
```

### 2. Advanced DAST Configuration
```yaml
# Custom DAST with OWASP ZAP
dast-zap:
  stage: security
  image: owasp/zap2docker-stable:latest
  services:
    - name: selenium/standalone-chrome:latest
      alias: selenium
  variables:
    ZAP_BASELINE_SCAN: "true"
    ZAP_FULL_SCAN: "false"
  script:
    - mkdir -p /zap/wrk
    - |
      zap-baseline.py \
        -t $DAST_WEBSITE \
        -g gen.conf \
        -r zap-baseline-report.html \
        -J zap-baseline-report.json \
        -w zap-baseline-report.md
  artifacts:
    reports:
      dast: zap-baseline-report.json
    paths:
      - zap-baseline-report.html
      - zap-baseline-report.md
  allow_failure: true
```

### 3. DAST with Authentication
```yaml
# DAST with custom authentication
dast-authenticated:
  stage: security
  image: owasp/zap2docker-stable:latest
  script:
    - |
      # Create authentication script
      cat > auth-script.js << 'EOF'
      function authenticate(helper, paramsValues, credentials) {
        var loginUrl = paramsValues.get("loginUrl");
        var username = credentials.getParam("username");
        var password = credentials.getParam("password");
        
        var loginRequest = helper.prepareMessage();
        loginRequest.setRequestHeader("Content-Type", "application/json");
        loginRequest.setRequestBody('{"username":"' + username + '","password":"' + password + '"}');
        
        helper.sendAndReceive(loginRequest, false);
        return loginRequest;
      }
      EOF
    
    - |
      zap-full-scan.py \
        -t $DAST_WEBSITE \
        -z "-config auth.loginUrl=$DAST_AUTH_URL \
            -config auth.username=$DAST_USERNAME \
            -config auth.password=$DAST_PASSWORD" \
        -J dast-report.json
  artifacts:
    reports:
      dast: dast-report.json
```

## Dependency Scanning

### 1. Basic Dependency Scanning
```yaml
# .gitlab-ci.yml - Dependency Scanning
include:
  - template: Security/Dependency-Scanning.gitlab-ci.yml

variables:
  DS_EXCLUDED_PATHS: "spec, test, tests, tmp"
  DS_MAJOR_VERSION: 2

# Custom dependency scanning
dependency-check:
  stage: security
  image: owasp/dependency-check:latest
  script:
    - |
      /usr/share/dependency-check/bin/dependency-check.sh \
        --scan . \
        --format JSON \
        --out dependency-check-report.json \
        --suppression suppression.xml
  artifacts:
    reports:
      dependency_scanning: dependency-check-report.json
```

### 2. Language-Specific Dependency Scanning
```yaml
# Node.js dependency scanning with npm audit
npm-audit:
  stage: security
  image: node:16
  script:
    - npm audit --json > npm-audit-report.json || true
    - npm audit --audit-level moderate
  artifacts:
    reports:
      dependency_scanning: npm-audit-report.json

# Python dependency scanning with Safety
safety-check:
  stage: security
  image: python:3.9
  before_script:
    - pip install safety
  script:
    - safety check --json --output safety-report.json
  artifacts:
    reports:
      dependency_scanning: safety-report.json

# Java dependency scanning with OWASP Dependency Check
java-dependency-check:
  stage: security
  image: maven:3.8-openjdk-11
  script:
    - |
      mvn org.owasp:dependency-check-maven:check \
        -Dformat=JSON \
        -DoutputDirectory=. \
        -DsuppressionsLocation=suppression.xml
  artifacts:
    reports:
      dependency_scanning: dependency-check-report.json
```

### 3. Dependency Suppression
```xml
<!-- suppression.xml - Suppress false positives -->
<?xml version="1.0" encoding="UTF-8"?>
<suppressions xmlns="https://jeremylong.github.io/DependencyCheck/dependency-suppression.1.3.xsd">
    <suppress>
        <notes>False positive - library not used in production</notes>
        <packageUrl regex="true">^pkg:npm/lodash@.*$</packageUrl>
        <cve>CVE-2021-23337</cve>
    </suppress>
    <suppress>
        <notes>Dev dependency only</notes>
        <filePath regex="true">.*test.*</filePath>
    </suppress>
</suppressions>
```

## Container Scanning

### 1. Basic Container Scanning
```yaml
# .gitlab-ci.yml - Container Scanning
include:
  - template: Security/Container-Scanning.gitlab-ci.yml

variables:
  CS_MAJOR_VERSION: 3
  CS_ANALYZER_IMAGE: "registry.gitlab.com/gitlab-org/security-products/analyzers/klar:latest"

build-image:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

container_scanning:
  variables:
    CS_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  needs:
    - build-image
```

### 2. Advanced Container Scanning with Trivy
```yaml
# Container scanning with Trivy
trivy-scan:
  stage: security
  image: aquasec/trivy:latest
  services:
    - docker:dind
  variables:
    DOCKER_DRIVER: overlay2
    DOCKER_TLS_CERTDIR: "/certs"
  script:
    - |
      trivy image \
        --format json \
        --output trivy-report.json \
        --severity HIGH,CRITICAL \
        $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    
    - |
      trivy image \
        --format table \
        --severity HIGH,CRITICAL \
        $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  artifacts:
    reports:
      container_scanning: trivy-report.json
  allow_failure: true
```

### 3. Multi-Stage Container Scanning
```yaml
# Scan base images and final image
scan-base-image:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy image --format json --output base-image-report.json ubuntu:20.04
  artifacts:
    reports:
      container_scanning: base-image-report.json

scan-final-image:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy image --format json --output final-image-report.json $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  artifacts:
    reports:
      container_scanning: final-image-report.json
  needs:
    - build-image
```

## Secret Detection

### 1. Basic Secret Detection
```yaml
# .gitlab-ci.yml - Secret Detection
include:
  - template: Security/Secret-Detection.gitlab-ci.yml

variables:
  SECRET_DETECTION_EXCLUDED_PATHS: "spec, test, tests, tmp"

# Custom secret detection with TruffleHog
trufflehog-scan:
  stage: security
  image: trufflesecurity/trufflehog:latest
  script:
    - trufflehog git file://. --json > trufflehog-report.json
  artifacts:
    reports:
      secret_detection: trufflehog-report.json
```

### 2. Advanced Secret Detection
```yaml
# Multi-tool secret detection
detect-secrets:
  stage: security
  image: python:3.9
  before_script:
    - pip install detect-secrets
  script:
    - detect-secrets scan --all-files --baseline .secrets.baseline
    - detect-secrets audit .secrets.baseline --report --output secrets-report.json
  artifacts:
    reports:
      secret_detection: secrets-report.json

# GitLeaks integration
gitleaks-scan:
  stage: security
  image: zricethezav/gitleaks:latest
  script:
    - gitleaks detect --source . --report-format json --report-path gitleaks-report.json
  artifacts:
    reports:
      secret_detection: gitleaks-report.json
  allow_failure: true
```

### 3. Secret Detection Rules
```yaml
# .gitleaks.toml - Custom secret detection rules
title = "Custom GitLeaks Configuration"

[[rules]]
description = "AWS Access Key ID"
regex = '''AKIA[0-9A-Z]{16}'''
tags = ["key", "AWS"]

[[rules]]
description = "Database Connection String"
regex = '''(?i)(password|pwd|pass|passwd)\s*[=:]\s*['"]\w+['"]'''
tags = ["password", "database"]

[[rules]]
description = "Private Key"
regex = '''-----BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY-----'''
tags = ["key", "private"]

[allowlist]
description = "Allowlist for test files"
paths = [
  '''test/.*''',
  '''spec/.*''',
  '''.*_test\.go''',
]
```

## License Compliance

### 1. Basic License Scanning
```yaml
# .gitlab-ci.yml - License Compliance
include:
  - template: Security/License-Scanning.gitlab-ci.yml

variables:
  LIC_MANAGEMENT_VERSION: 3
  LICENSE_FINDER_CLI_OPTS: '--aggregate-paths=. --format=json'

# Custom license scanning
license-check:
  stage: security
  image: licensefinder/license_finder:latest
  script:
    - license_finder --decisions-file=doc/dependency_decisions.yml --format json > license-report.json
  artifacts:
    reports:
      license_scanning: license-report.json
```

### 2. License Policy Configuration
```yaml
# License policy configuration
license-policy:
  allowed_licenses:
    - MIT
    - Apache-2.0
    - BSD-3-Clause
    - ISC
  
  denied_licenses:
    - GPL-3.0
    - AGPL-3.0
    - LGPL-3.0
  
  approval_required:
    - BSD-2-Clause
    - MPL-2.0
```

### 3. License Decision File
```yaml
# doc/dependency_decisions.yml
---
- - :whitelist
  - MIT
  - :who: security-team
    :why: Permissive license approved for use
    :versions: []
    :when: 2024-01-01T00:00:00.000Z

- - :blacklist
  - GPL-3.0
  - :who: legal-team
    :why: Copyleft license not compatible with commercial use
    :versions: []
    :when: 2024-01-01T00:00:00.000Z
```

## Security Dashboard and Reporting

### 1. Security Dashboard Configuration
```yaml
# Security dashboard setup
security-dashboard:
  stage: .post
  image: alpine:latest
  script:
    - |
      # Aggregate security reports
      apk add --no-cache jq curl
      
      # Combine all security reports
      jq -s 'add' \
        gl-sast-report.json \
        gl-dependency-scanning-report.json \
        gl-container-scanning-report.json \
        gl-secret-detection-report.json > combined-security-report.json
      
      # Generate summary
      CRITICAL=$(jq '[.vulnerabilities[] | select(.severity == "Critical")] | length' combined-security-report.json)
      HIGH=$(jq '[.vulnerabilities[] | select(.severity == "High")] | length' combined-security-report.json)
      
      echo "Security Scan Summary:"
      echo "Critical: $CRITICAL"
      echo "High: $HIGH"
  artifacts:
    reports:
      security: combined-security-report.json
  when: always
```

### 2. Security Metrics Collection
```python
#!/usr/bin/env python3
# security-metrics.py
import requests
import json
from datetime import datetime, timedelta

class SecurityMetrics:
    def __init__(self, gitlab_url, token):
        self.gitlab_url = gitlab_url
        self.headers = {'PRIVATE-TOKEN': token}
    
    def get_project_vulnerabilities(self, project_id):
        """Get vulnerabilities for a project"""
        response = requests.get(
            f"{self.gitlab_url}/api/v4/projects/{project_id}/vulnerabilities",
            headers=self.headers
        )
        return response.json()
    
    def get_security_dashboard_data(self, group_id):
        """Get security dashboard data for group"""
        response = requests.get(
            f"{self.gitlab_url}/api/v4/groups/{group_id}/security/dashboard",
            headers=self.headers
        )
        return response.json()
    
    def generate_security_report(self, project_id):
        """Generate comprehensive security report"""
        vulnerabilities = self.get_project_vulnerabilities(project_id)
        
        # Categorize by severity
        severity_counts = {
            'critical': 0,
            'high': 0,
            'medium': 0,
            'low': 0,
            'info': 0
        }
        
        for vuln in vulnerabilities:
            severity = vuln.get('severity', 'unknown').lower()
            if severity in severity_counts:
                severity_counts[severity] += 1
        
        # Generate report
        report = {
            'timestamp': datetime.now().isoformat(),
            'project_id': project_id,
            'total_vulnerabilities': len(vulnerabilities),
            'severity_breakdown': severity_counts,
            'scan_types': self._get_scan_types(vulnerabilities)
        }
        
        return report
    
    def _get_scan_types(self, vulnerabilities):
        """Get breakdown by scan type"""
        scan_types = {}
        for vuln in vulnerabilities:
            scanner = vuln.get('scanner', {}).get('name', 'unknown')
            scan_types[scanner] = scan_types.get(scanner, 0) + 1
        return scan_types

# Usage
metrics = SecurityMetrics('https://gitlab.example.com', 'your-token')
report = metrics.generate_security_report(123)
print(json.dumps(report, indent=2))
```

## Security Policy as Code

### 1. Security Policy Configuration
```yaml
# .gitlab/security-policies/scan-execution-policy.yml
type: scan_execution_policy
name: "Mandatory Security Scans"
description: "Enforce security scans on all merge requests"
enabled: true
rules:
  - type: pipeline
    branches:
      - main
      - develop
    scanners:
      - sast
      - dependency_scanning
      - container_scanning
      - secret_detection
actions:
  - scan: sast
    scanner_profile: "default"
  - scan: dependency_scanning
    scanner_profile: "default"
  - scan: container_scanning
    scanner_profile: "default"
  - scan: secret_detection
    scanner_profile: "default"
```

### 2. Approval Rules for Security
```yaml
# Security-based approval rules
security-approval-rules:
  - name: "Security Team Approval"
    approvals_required: 2
    groups:
      - security-team
    rule_type: "any_approver"
    conditions:
      - security_findings:
          severity: ["critical", "high"]
          scanner: ["sast", "dependency_scanning"]
  
  - name: "Critical Vulnerability Block"
    approvals_required: 1
    users:
      - security-lead
    rule_type: "any_approver"
    conditions:
      - security_findings:
          severity: ["critical"]
          new_findings_only: true
```

## Integration with External Security Tools

### 1. SonarQube Integration
```yaml
# SonarQube security scanning
sonarqube-scan:
  stage: security
  image: sonarsource/sonar-scanner-cli:latest
  variables:
    SONAR_USER_HOME: "${CI_PROJECT_DIR}/.sonar"
    GIT_DEPTH: "0"
  cache:
    key: "${CI_JOB_NAME}"
    paths:
      - .sonar/cache
  script:
    - |
      sonar-scanner \
        -Dsonar.projectKey=$CI_PROJECT_NAME \
        -Dsonar.sources=. \
        -Dsonar.host.url=$SONAR_HOST_URL \
        -Dsonar.login=$SONAR_TOKEN \
        -Dsonar.qualitygate.wait=true
  allow_failure: true
```

### 2. Snyk Integration
```yaml
# Snyk security scanning
snyk-scan:
  stage: security
  image: snyk/snyk:node
  script:
    - snyk auth $SNYK_TOKEN
    - snyk test --json > snyk-report.json || true
    - snyk monitor
  artifacts:
    reports:
      dependency_scanning: snyk-report.json
```

## Best Practices and Optimization

### 1. Security Scanning Strategy
```yaml
# Optimized security pipeline
security-fast:
  stage: security
  parallel:
    matrix:
      - SCAN_TYPE: [sast, dependency_scanning, secret_detection]
  script:
    - run-security-scan.sh $SCAN_TYPE
  artifacts:
    reports:
      $SCAN_TYPE: $SCAN_TYPE-report.json

# Full security scan for releases
security-full:
  stage: security
  script:
    - run-all-security-scans.sh
  artifacts:
    reports:
      sast: sast-report.json
      dependency_scanning: dependency-report.json
      container_scanning: container-report.json
      dast: dast-report.json
  only:
    - tags
    - schedules
```

### 2. Performance Optimization
```yaml
# Cached security scanning
security-with-cache:
  stage: security
  cache:
    key: security-cache-$CI_COMMIT_REF_SLUG
    paths:
      - .security-cache/
  script:
    - mkdir -p .security-cache
    - run-security-scan-with-cache.sh
```

## Next Steps

After mastering security scanning:
1. Learn GitLab API for automation
2. Explore package management features
3. Study advanced security policies
4. Practice with real-world security scenarios

---
*Comprehensive security scanning is essential for maintaining secure applications and infrastructure.*