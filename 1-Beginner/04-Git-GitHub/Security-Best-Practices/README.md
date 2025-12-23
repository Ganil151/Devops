# Git & GitHub Security Best Practices

## Overview
Security is paramount in modern DevOps workflows. This guide covers essential security practices for Git repositories, GitHub configurations, and CI/CD pipelines to protect code, credentials, and infrastructure.

## Git Security Fundamentals

### Commit Signing
```bash
# GPG commit signing setup
gpg --gen-key
gpg --list-secret-keys --keyid-format LONG
git config --global user.signingkey YOUR_GPG_KEY_ID
git config --global commit.gpgsign true

# SSH commit signing (Git 2.34+)
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true

# Verify signatures
git log --show-signature
git verify-commit HEAD
```

### Secure Git Configuration
```bash
# Global security settings
git config --global core.autocrlf input
git config --global core.filemode false
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global push.default simple

# Repository-specific security
git config core.hooksPath .githooks
git config receive.denyNonFastForwards true
git config receive.denyDeletes true
```

## Secrets Management

### .gitignore Best Practices
```bash
# Comprehensive .gitignore for security
# Operating System files
.DS_Store
Thumbs.db
*.swp
*.swo

# IDE and editor files
.vscode/
.idea/
*.sublime-*

# Environment and configuration files
.env
.env.local
.env.production
.env.staging
config/secrets.yml
config/database.yml
config/production.rb

# Credentials and keys
*.pem
*.key
*.p12
*.pfx
id_rsa*
id_ed25519*
known_hosts

# Cloud provider credentials
.aws/credentials
.azure/credentials
gcloud-service-key.json

# Database files
*.sqlite
*.db
*.sql

# Logs and temporary files
*.log
logs/
tmp/
temp/

# Build artifacts
dist/
build/
target/
*.jar
*.war
*.ear

# Package manager files
node_modules/
vendor/
*.lock

# Terraform state files
*.tfstate
*.tfstate.backup
.terraform/
terraform.tfvars

# Docker secrets
docker-compose.override.yml
.dockerignore

# Application-specific secrets
secrets/
private/
confidential/
```

### Pre-commit Hooks for Security
```bash
#!/bin/bash
# .git/hooks/pre-commit
set -e

echo "Running security checks..."

# Check for secrets and sensitive information
if grep -r --include="*.js" --include="*.py" --include="*.java" --include="*.yml" --include="*.yaml" \
   -E "(password|secret|key|token|api_key|private_key|access_key)" . | \
   grep -v ".git" | grep -v "example" | grep -v "placeholder"; then
    echo "❌ Potential secrets found in code!"
    echo "Please remove sensitive information before committing."
    exit 1
fi

# Check for merge conflict markers
if grep -r --include="*.js" --include="*.py" --include="*.java" --include="*.yml" \
   -E "(<<<<<<<|=======|>>>>>>>)" .; then
    echo "❌ Merge conflict markers found!"
    exit 1
fi

# Check for debug statements
if grep -r --include="*.js" --include="*.py" --include="*.java" \
   -E "(console\.log|debugger|pdb\.set_trace|System\.out\.println)" .; then
    echo "❌ Debug statements found!"
    echo "Please remove debug code before committing."
    exit 1
fi

# Check file permissions
find . -type f -perm 777 -not -path "./.git/*" | while read file; do
    echo "❌ File with 777 permissions found: $file"
    exit 1
done

# Check for large files
find . -type f -size +10M -not -path "./.git/*" | while read file; do
    echo "❌ Large file found: $file ($(du -h "$file" | cut -f1))"
    echo "Consider using Git LFS for large files."
    exit 1
done

echo "✅ Security checks passed!"
```

## GitHub Security Configuration

### Repository Security Settings
```yaml
# Security configuration checklist
Repository Settings:
  - Enable vulnerability alerts
  - Enable automated security updates (Dependabot)
  - Enable secret scanning
  - Enable code scanning (CodeQL)
  - Configure branch protection rules
  - Require signed commits
  - Restrict force pushes
  - Require status checks
  - Require pull request reviews

Branch Protection Rules:
  - Require pull request reviews before merging
  - Dismiss stale reviews when new commits are pushed
  - Require review from code owners
  - Require status checks to pass before merging
  - Require branches to be up to date before merging
  - Require conversation resolution before merging
  - Include administrators in restrictions
```

### Dependabot Security Configuration
```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    reviewers:
      - "security-team"
    commit-message:
      prefix: "security"
      include: "scope"
    ignore:
      - dependency-name: "*"
        update-types: ["version-update:semver-major"]

  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
    
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

### GitHub Actions Security
```yaml
# .github/workflows/security-scan.yml
name: Security Scanning

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * 1'

permissions:
  contents: read
  security-events: write

jobs:
  secret-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
    
    - name: Run TruffleHog
      uses: trufflesecurity/trufflehog@main
      with:
        path: ./
        base: main
        head: HEAD
        extra_args: --debug --only-verified

  dependency-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Run Snyk
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
    
    - name: Upload Snyk results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: snyk.sarif

  container-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Build image
      run: docker build -t test-image .
    
    - name: Run Trivy scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: 'test-image'
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Trivy results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'
```

## Secrets Management in CI/CD

### GitHub Secrets Best Practices
```bash
# GitHub Secrets management
gh secret set DATABASE_URL --body "postgresql://user:pass@host:5432/db"
gh secret set API_KEY --body "your-api-key"
gh secret set DOCKER_PASSWORD --body "your-docker-password"

# Environment-specific secrets
gh secret set PROD_DATABASE_URL --env production
gh secret set STAGING_DATABASE_URL --env staging

# Organization-level secrets
gh secret set SHARED_SECRET --org myorg
```

### Secure Workflow Patterns
```yaml
# Secure workflow with minimal permissions
name: Secure Deployment

on:
  push:
    branches: [ main ]

permissions:
  contents: read
  id-token: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
        aws-region: us-east-1
    
    - name: Deploy with secure credentials
      env:
        DATABASE_URL: ${{ secrets.DATABASE_URL }}
      run: |
        # Deployment commands here
        echo "Deploying securely..."
```

## Access Control and Permissions

### GitHub Team Management
```bash
# GitHub CLI team management
gh api orgs/myorg/teams/devops/members --method POST --field username=newuser
gh api orgs/myorg/teams/security/repos/myorg/myrepo --method PUT --field permission=admin

# Repository permissions
gh repo edit myorg/myrepo --add-topic security
gh repo edit myorg/myrepo --visibility private
```

### CODEOWNERS Security
```bash
# .github/CODEOWNERS
# Global security review
* @security-team

# Infrastructure requires DevOps approval
/infrastructure/ @devops-team @security-team
/terraform/ @devops-team @security-team
/.github/workflows/ @devops-team @security-team

# Security-sensitive files
/security/ @security-team
*.pem @security-team
*.key @security-team
Dockerfile @devops-team @security-team
docker-compose*.yml @devops-team @security-team

# Configuration files
config/ @devops-team @security-team
*.env.example @devops-team
```

## Compliance and Auditing

### Audit Logging
```yaml
# .github/workflows/audit-log.yml
name: Audit Logging

on:
  push:
    branches: [ main ]
  pull_request:
    types: [ opened, closed, merged ]

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
    - name: Log activity
      uses: actions/github-script@v6
      with:
        script: |
          const fs = require('fs');
          const auditLog = {
            timestamp: new Date().toISOString(),
            event: context.eventName,
            actor: context.actor,
            repository: context.repo.repo,
            ref: context.ref,
            sha: context.sha
          };
          
          console.log('Audit Log:', JSON.stringify(auditLog, null, 2));
          
          // Send to external audit system
          await fetch('https://audit.company.com/api/logs', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(auditLog)
          });
```

### Compliance Scanning
```yaml
# .github/workflows/compliance.yml
name: Compliance Scanning

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly
  workflow_dispatch:

jobs:
  compliance:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: GDPR Compliance Check
      run: |
        # Check for personal data patterns
        if grep -r -i "email\|phone\|address\|ssn" --include="*.js" --include="*.py" .; then
          echo "⚠️ Potential personal data found - review for GDPR compliance"
        fi
    
    - name: License Compliance
      uses: fossa-contrib/fossa-action@v2
      with:
        api-key: ${{ secrets.FOSSA_API_KEY }}
    
    - name: Security Policy Check
      run: |
        # Verify security policy files exist
        required_files=("SECURITY.md" "CODE_OF_CONDUCT.md" ".github/SECURITY.md")
        for file in "${required_files[@]}"; do
          if [[ ! -f "$file" ]]; then
            echo "❌ Missing required file: $file"
            exit 1
          fi
        done
```

## Incident Response

### Security Incident Workflow
```yaml
# .github/workflows/security-incident.yml
name: Security Incident Response

on:
  repository_dispatch:
    types: [security-incident]

jobs:
  incident-response:
    runs-on: ubuntu-latest
    steps:
    - name: Create incident issue
      uses: actions/github-script@v6
      with:
        script: |
          const issue = await github.rest.issues.create({
            owner: context.repo.owner,
            repo: context.repo.repo,
            title: `🚨 Security Incident: ${context.payload.client_payload.type}`,
            body: `
            ## Security Incident Report
            
            **Type:** ${context.payload.client_payload.type}
            **Severity:** ${context.payload.client_payload.severity}
            **Description:** ${context.payload.client_payload.description}
            **Reporter:** ${context.payload.client_payload.reporter}
            **Timestamp:** ${new Date().toISOString()}
            
            ## Immediate Actions Required
            - [ ] Assess impact and scope
            - [ ] Contain the incident
            - [ ] Notify stakeholders
            - [ ] Document findings
            - [ ] Implement fixes
            - [ ] Conduct post-incident review
            `,
            labels: ['security', 'incident', 'urgent'],
            assignees: ['security-team-lead', 'devops-lead']
          });
          
          // Notify security team
          await fetch(process.env.SLACK_SECURITY_WEBHOOK, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              text: `🚨 Security incident reported: ${issue.data.html_url}`
            })
          });
      env:
        SLACK_SECURITY_WEBHOOK: ${{ secrets.SLACK_SECURITY_WEBHOOK }}
```

## Security Monitoring

### Continuous Security Monitoring
```python
#!/usr/bin/env python3
# security_monitor.py
import requests
import json
import os
from datetime import datetime

class GitHubSecurityMonitor:
    def __init__(self, token, org):
        self.token = token
        self.org = org
        self.headers = {
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github.v3+json'
        }
    
    def check_repository_security(self, repo):
        """Check repository security settings"""
        url = f"https://api.github.com/repos/{self.org}/{repo}"
        response = requests.get(url, headers=self.headers)
        repo_data = response.json()
        
        security_issues = []
        
        # Check if repository is public when it should be private
        if repo_data.get('private') is False:
            security_issues.append("Repository is public")
        
        # Check branch protection
        branches_url = f"{url}/branches"
        branches_response = requests.get(branches_url, headers=self.headers)
        branches = branches_response.json()
        
        for branch in branches:
            if branch['name'] in ['main', 'master', 'develop']:
                protection_url = f"{url}/branches/{branch['name']}/protection"
                protection_response = requests.get(protection_url, headers=self.headers)
                
                if protection_response.status_code == 404:
                    security_issues.append(f"Branch {branch['name']} is not protected")
        
        return security_issues
    
    def check_secrets_exposure(self, repo):
        """Check for exposed secrets in repository"""
        # This would integrate with secret scanning APIs
        url = f"https://api.github.com/repos/{self.org}/{repo}/secret-scanning/alerts"
        response = requests.get(url, headers=self.headers)
        
        if response.status_code == 200:
            alerts = response.json()
            return len(alerts)
        return 0
    
    def generate_security_report(self):
        """Generate comprehensive security report"""
        repos_url = f"https://api.github.com/orgs/{self.org}/repos"
        repos_response = requests.get(repos_url, headers=self.headers)
        repos = repos_response.json()
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'organization': self.org,
            'repositories': []
        }
        
        for repo in repos:
            repo_name = repo['name']
            security_issues = self.check_repository_security(repo_name)
            secret_alerts = self.check_secrets_exposure(repo_name)
            
            repo_report = {
                'name': repo_name,
                'security_issues': security_issues,
                'secret_alerts': secret_alerts,
                'last_updated': repo['updated_at']
            }
            
            report['repositories'].append(repo_report)
        
        return report

if __name__ == "__main__":
    token = os.environ.get('GITHUB_TOKEN')
    org = os.environ.get('GITHUB_ORG')
    
    monitor = GitHubSecurityMonitor(token, org)
    report = monitor.generate_security_report()
    
    print(json.dumps(report, indent=2))
```

## Security Training and Awareness

### Security Checklist for Developers
```markdown
# Developer Security Checklist

## Before Committing Code
- [ ] No hardcoded secrets or credentials
- [ ] No debug statements or console logs
- [ ] No personal or sensitive information
- [ ] Dependencies are up to date
- [ ] Code follows security guidelines
- [ ] Input validation is implemented
- [ ] Error handling doesn't expose sensitive info

## Before Creating Pull Request
- [ ] Branch is up to date with main
- [ ] All tests pass including security tests
- [ ] Code has been reviewed for security issues
- [ ] Documentation is updated
- [ ] Breaking changes are documented

## Repository Security
- [ ] .gitignore includes all sensitive files
- [ ] Branch protection rules are enabled
- [ ] Required reviewers are configured
- [ ] Status checks are required
- [ ] Signed commits are enforced

## CI/CD Security
- [ ] Secrets are stored securely
- [ ] Minimal permissions are used
- [ ] Security scanning is enabled
- [ ] Deployment environments are isolated
- [ ] Audit logging is configured
```

This comprehensive security guide ensures that Git and GitHub workflows maintain the highest security standards while enabling efficient DevOps practices.