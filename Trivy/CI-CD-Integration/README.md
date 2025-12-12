# CI/CD Pipeline Integration

Integrate Trivy security scanning into CI/CD pipelines and DevOps workflows.

## Contents

- **[pipeline-integration-guide.md](./pipeline-integration-guide.md)** - Complete CI/CD integration guide covering:
  - GitHub Actions workflows
  - GitLab CI pipeline configuration
  - Jenkins pipeline scripts
  - Azure DevOps integration
  - Security policy enforcement
  - Notification and reporting

## Supported Platforms

- **GitHub Actions**: Native Trivy action available
- **GitLab CI**: Container-based scanning
- **Jenkins**: Pipeline script integration
- **Azure DevOps**: YAML pipeline tasks
- **CircleCI**: Docker-based scanning
- **AWS CodePipeline**: Custom build steps

## Integration Patterns

```yaml
# GitHub Actions example
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'fs'
    scan-ref: '.'
    format: 'sarif'
    output: 'trivy-results.sarif'
```

## Security Gates

- Vulnerability threshold enforcement
- Policy compliance checking
- Automated report generation
- Failure notifications
- Deployment blocking on critical issues

## Best Practices

- Fail fast on critical vulnerabilities
- Generate multiple report formats
- Implement security policy as code
- Automate remediation workflows
- Monitor security metrics over time