# SAST Tools (Static Application Security Testing)

Complete guide to SAST tools, implementation, and best practices.

## SAST Fundamentals

### What is SAST
```bash
# Static Application Security Testing
- White-box security testing
- Source code analysis without execution
- Early vulnerability detection in SDLC
- Automated security code review
- Integration with IDEs and CI/CD pipelines
```

## Popular SAST Tools

### SonarQube
```bash
# Installation and Setup
docker run -d --name sonarqube -p 9000:9000 sonarqube:latest

# Scanner Configuration
sonar-scanner \
  -Dsonar.projectKey=myproject \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=admin \
  -Dsonar.password=admin

# Quality Gate Configuration
curl -u admin:admin -X POST \
  "http://localhost:9000/api/qualitygates/create" \
  -d "name=Security Gate"

# Security Rules
curl -u admin:admin -X POST \
  "http://localhost:9000/api/qualityprofiles/activate_rule" \
  -d "key=java-security-rules&rule=java:S2076"
```

### Semgrep
```bash
# Installation
pip install semgrep

# Basic Scanning
semgrep --config=auto ./src
semgrep --config=p/security-audit ./src
semgrep --config=p/owasp-top-ten ./src

# Custom Rules
# rules/sql-injection.yml
rules:
  - id: sql-injection-risk
    pattern: |
      cursor.execute("SELECT * FROM users WHERE id = " + $VAR)
    message: "Potential SQL injection vulnerability"
    languages: [python]
    severity: ERROR

# CI/CD Integration
semgrep --config=auto --json --output=semgrep-results.json ./src
```

### Checkmarx SAST
```bash
# CLI Usage
cx scan create \
  --project-name "MyApp" \
  --source-dir ./src \
  --branch main \
  --scan-types sast

# Results Retrieval
cx results show \
  --scan-id 12345 \
  --format json \
  --output-file results.json

# Quality Gate Integration
cx scan create \
  --project-name "MyApp" \
  --source-dir ./src \
  --threshold "High:0;Medium:10"
```

### Veracode SAST
```bash
# Upload and Scan
java -jar VeracodeJavaAPI.jar \
  -vid $VERACODE_API_ID \
  -vkey $VERACODE_API_KEY \
  -action UploadAndScan \
  -appname "MyApplication" \
  -createprofile false \
  -filepath ./target/myapp.jar \
  -version "1.0.0"

# Results Download
java -jar VeracodeJavaAPI.jar \
  -vid $VERACODE_API_ID \
  -vkey $VERACODE_API_KEY \
  -action DetailedReport \
  -appname "MyApplication" \
  -format xml
```

## Language-Specific SAST Tools

### Python Security Tools
```bash
# Bandit
bandit -r ./src -f json -o bandit-report.json
bandit -r ./src -ll -i  # Low confidence, ignore nosec

# Safety (Dependency Check)
safety check
safety check --json --output safety-report.json

# Semgrep Python Rules
semgrep --config=p/python ./src
```

### JavaScript/Node.js Security Tools
```bash
# ESLint Security Plugin
npm install eslint-plugin-security
echo '{
  "extends": ["plugin:security/recommended"],
  "plugins": ["security"]
}' > .eslintrc.json

eslint --ext .js,.ts src/

# NodeJsScan
nodejsscan -d ./src -o nodejsscan-report.json

# npm audit
npm audit --audit-level high
npm audit fix
```

### Java Security Tools
```bash
# SpotBugs with FindSecBugs
mvn compile spotbugs:spotbugs
mvn spotbugs:gui

# PMD Security Rules
mvn pmd:pmd
mvn pmd:cpd

# OWASP Dependency Check
mvn org.owasp:dependency-check-maven:check
```

### .NET Security Tools
```bash
# Security Code Scan
dotnet add package SecurityCodeScan.VS2019
dotnet build

# Roslyn Security Guard
Install-Package RoslynSecurityGuard
dotnet build --verbosity normal
```

## SAST Integration Patterns

### IDE Integration
```json
// VS Code settings.json
{
  "semgrep.enable": true,
  "semgrep.configPath": "p/security-audit",
  "sonarLint.connectedMode.project": {
    "connectionId": "sonarqube-local",
    "projectKey": "myproject"
  }
}
```

### Pre-commit Hooks
```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running SAST checks..."

# Semgrep scan
semgrep --config=auto --error --quiet .
if [ $? -ne 0 ]; then
    echo "SAST scan failed! Please fix security issues."
    exit 1
fi

# Bandit scan for Python
if [ -f requirements.txt ]; then
    bandit -r . -ll
    if [ $? -ne 0 ]; then
        echo "Python security issues found!"
        exit 1
    fi
fi

echo "SAST checks passed!"
```

### CI/CD Pipeline Integration
```yaml
# GitHub Actions SAST Pipeline
name: SAST Security Scan
on: [push, pull_request]

jobs:
  sast-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Semgrep Scan
        uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/security-audit
            p/secrets
            p/owasp-top-ten
      
      - name: SonarQube Scan
        uses: sonarqube-quality-gate-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
      
      - name: Upload SARIF results
        uses: github/codeql-action/upload-sarif@v1
        with:
          sarif_file: semgrep.sarif
```

### Jenkins Pipeline
```groovy
pipeline {
    agent any
    
    stages {
        stage('SAST Scan') {
            parallel {
                stage('SonarQube') {
                    steps {
                        withSonarQubeEnv('SonarQube') {
                            sh 'mvn sonar:sonar'
                        }
                        
                        timeout(time: 10, unit: 'MINUTES') {
                            waitForQualityGate abortPipeline: true
                        }
                    }
                }
                
                stage('Semgrep') {
                    steps {
                        sh 'semgrep --config=auto --json --output=semgrep.json .'
                        
                        script {
                            def results = readJSON file: 'semgrep.json'
                            if (results.results.size() > 0) {
                                error "Security vulnerabilities found!"
                            }
                        }
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
                reportDir: 'target/site/jacoco',
                reportFiles: 'index.html',
                reportName: 'SAST Report'
            ])
        }
    }
}
```

## Custom SAST Rules Development

### Semgrep Custom Rules
```yaml
# rules/custom-security.yml
rules:
  - id: hardcoded-secret
    pattern-either:
      - pattern: password = "..."
      - pattern: api_key = "..."
      - pattern: secret = "..."
    message: "Hardcoded secret detected"
    languages: [python, javascript, java]
    severity: ERROR
    
  - id: unsafe-deserialization
    pattern: pickle.loads($DATA)
    message: "Unsafe deserialization with pickle"
    languages: [python]
    severity: WARNING
    
  - id: command-injection
    pattern: os.system($CMD)
    message: "Potential command injection"
    languages: [python]
    severity: ERROR
```

### SonarQube Custom Rules
```java
// Custom Java rule for SonarQube
@Rule(key = "CustomSecurityRule")
public class CustomSecurityRule extends BaseTreeVisitor implements JavaFileScanner {
    
    @RuleProperty(
        key = "forbiddenMethods",
        description = "Comma-separated list of forbidden methods",
        defaultValue = "Runtime.exec,ProcessBuilder.start"
    )
    public String forbiddenMethods = "Runtime.exec,ProcessBuilder.start";
    
    @Override
    public void visitMethodInvocation(MethodInvocationTree tree) {
        String methodName = tree.symbol().name();
        if (Arrays.asList(forbiddenMethods.split(",")).contains(methodName)) {
            context.reportIssue(this, tree, "Forbidden method call: " + methodName);
        }
        super.visitMethodInvocation(tree);
    }
}
```

## SAST Results Management

### Vulnerability Triage
```python
# SAST Results Processor
import json
from datetime import datetime

class SASTResultsProcessor:
    def __init__(self, results_file):
        with open(results_file, 'r') as f:
            self.results = json.load(f)
    
    def filter_by_severity(self, min_severity='HIGH'):
        severity_levels = {'LOW': 1, 'MEDIUM': 2, 'HIGH': 3, 'CRITICAL': 4}
        min_level = severity_levels.get(min_severity, 2)
        
        filtered = []
        for result in self.results.get('results', []):
            result_level = severity_levels.get(result.get('severity', 'LOW'), 1)
            if result_level >= min_level:
                filtered.append(result)
        
        return filtered
    
    def generate_report(self):
        high_severity = self.filter_by_severity('HIGH')
        medium_severity = self.filter_by_severity('MEDIUM')
        
        report = {
            'scan_date': datetime.now().isoformat(),
            'total_issues': len(self.results.get('results', [])),
            'high_severity_count': len(high_severity),
            'medium_severity_count': len(medium_severity),
            'critical_issues': high_severity
        }
        
        return report
    
    def create_jira_tickets(self, high_severity_issues):
        for issue in high_severity_issues:
            # Create JIRA ticket for high severity issues
            ticket_data = {
                'summary': f"Security Issue: {issue['check_id']}",
                'description': issue['message'],
                'priority': 'High',
                'labels': ['security', 'sast']
            }
            # JIRA API call would go here
```

### False Positive Management
```bash
# Semgrep Ignore Patterns
# .semgrepignore
# Ignore test files
tests/
*_test.py
*_test.js

# Ignore specific patterns
# nosemgrep: rule-id
password = "test_password"  # nosemgrep: hardcoded-password

# SonarQube Exclusions
# sonar-project.properties
sonar.exclusions=**/test/**,**/migrations/**
sonar.coverage.exclusions=**/test/**
sonar.cpd.exclusions=**/generated/**
```

## SAST Metrics and KPIs

### Security Metrics
```bash
# Key SAST Metrics
- Vulnerability density (issues per KLOC)
- Time to fix vulnerabilities
- False positive rate
- Security debt (unfixed issues)
- Coverage percentage
- Scan frequency

# DORA Security Metrics
- Security lead time
- Security deployment frequency
- Security change failure rate
- Mean time to security recovery
```

### Reporting Dashboard
```python
# SAST Metrics Dashboard
import matplotlib.pyplot as plt
import pandas as pd

def create_sast_dashboard(scan_results):
    # Vulnerability trends over time
    df = pd.DataFrame(scan_results)
    
    # Severity distribution
    severity_counts = df['severity'].value_counts()
    plt.figure(figsize=(12, 8))
    
    plt.subplot(2, 2, 1)
    severity_counts.plot(kind='bar', color=['red', 'orange', 'yellow', 'green'])
    plt.title('Vulnerability Distribution by Severity')
    plt.ylabel('Count')
    
    # Trends over time
    plt.subplot(2, 2, 2)
    df.groupby('scan_date')['severity'].count().plot()
    plt.title('Vulnerability Trends Over Time')
    plt.ylabel('Total Issues')
    
    # Top vulnerability types
    plt.subplot(2, 2, 3)
    df['check_id'].value_counts().head(10).plot(kind='barh')
    plt.title('Top 10 Vulnerability Types')
    
    # Fix rate trends
    plt.subplot(2, 2, 4)
    fix_rate_data = calculate_fix_rates(df)
    fix_rate_data.plot()
    plt.title('Vulnerability Fix Rate Trends')
    plt.ylabel('Fix Rate %')
    
    plt.tight_layout()
    plt.savefig('sast-dashboard.png', dpi=300, bbox_inches='tight')
```

## Best Practices

### SAST Implementation Strategy
```bash
# 1. Tool Selection
- Language support coverage
- Integration capabilities
- False positive rates
- Customization options
- Reporting features

# 2. Gradual Rollout
- Start with new code only
- Implement in non-critical projects first
- Gradually expand coverage
- Train development teams

# 3. Quality Gates
- Define security thresholds
- Implement pipeline gates
- Establish exception processes
- Monitor compliance metrics

# 4. Developer Training
- Secure coding practices
- Tool usage training
- Vulnerability remediation
- Security awareness programs
```

### Performance Optimization
```bash
# Scan Optimization
- Incremental scanning for large codebases
- Parallel execution where possible
- Caching of scan results
- Selective file scanning

# Resource Management
- Dedicated scan infrastructure
- Scheduled scanning during off-hours
- Resource allocation based on project size
- Monitoring scan performance metrics
```