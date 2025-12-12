# CI/CD Pipeline Integration with Trivy

## GitHub Actions Integration

### Basic GitHub Actions Workflow
```yaml
# .github/workflows/security-scan.yml
name: Security Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  trivy-scan:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        format: 'sarif'
        output: 'trivy-results.sarif'

    - name: Upload Trivy scan results to GitHub Security tab
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: 'trivy-results.sarif'
```

### Advanced GitHub Actions Workflow
```yaml
# .github/workflows/comprehensive-security.yml
name: Comprehensive Security Scan

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  code-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Scan source code
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        severity: 'HIGH,CRITICAL'
        exit-code: '1'
        format: 'json'
        output: 'code-scan-results.json'

    - name: Upload code scan results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: code-scan-results
        path: code-scan-results.json

  config-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Scan IaC configurations
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'config'
        scan-ref: '.'
        severity: 'HIGH,CRITICAL'
        exit-code: '1'
        format: 'sarif'
        output: 'config-scan-results.sarif'

    - name: Upload SARIF file
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: 'config-scan-results.sarif'

  image-scan:
    runs-on: ubuntu-latest
    needs: [code-scan, config-scan]
    steps:
    - uses: actions/checkout@v3

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2

    - name: Log in to Container Registry
      uses: docker/login-action@v2
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: Build Docker image
      uses: docker/build-push-action@v4
      with:
        context: .
        push: false
        tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

    - name: Scan Docker image
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
        format: 'sarif'
        output: 'image-scan-results.sarif'

    - name: Upload image scan results
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: 'image-scan-results.sarif'
```

## GitLab CI Integration

### Basic GitLab CI Configuration
```yaml
# .gitlab-ci.yml
stages:
  - security-scan
  - build
  - deploy

trivy-scan:
  stage: security-scan
  image: aquasec/trivy:latest
  script:
    - trivy fs --format json --output trivy-report.json .
    - trivy fs --severity HIGH,CRITICAL --exit-code 1 .
  artifacts:
    reports:
      container_scanning: trivy-report.json
    paths:
      - trivy-report.json
    expire_in: 1 week
  only:
    - merge_requests
    - main
```

### Advanced GitLab CI Pipeline
```yaml
# .gitlab-ci.yml
variables:
  TRIVY_CACHE_DIR: ".trivycache/"
  TRIVY_NO_PROGRESS: "true"
  TRIVY_OFFLINE_SCAN: "false"

cache:
  paths:
    - .trivycache/

stages:
  - security-scan
  - build
  - image-scan
  - deploy

source-code-scan:
  stage: security-scan
  image: aquasec/trivy:latest
  script:
    - trivy fs --format template --template "@contrib/gitlab.tpl" --output gl-sast-report.json .
    - trivy fs --severity HIGH,CRITICAL --exit-code 1 .
  artifacts:
    reports:
      sast: gl-sast-report.json
    paths:
      - gl-sast-report.json
    expire_in: 1 week

config-scan:
  stage: security-scan
  image: aquasec/trivy:latest
  script:
    - trivy config --format json --output config-scan-report.json .
    - trivy config --severity HIGH,CRITICAL --exit-code 1 .
  artifacts:
    paths:
      - config-scan-report.json
    expire_in: 1 week

build-image:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  needs:
    - source-code-scan
    - config-scan

container-scan:
  stage: image-scan
  image: aquasec/trivy:latest
  script:
    - trivy image --format template --template "@contrib/gitlab.tpl" --output gl-container-scanning-report.json $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - trivy image --severity HIGH,CRITICAL --exit-code 1 $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  artifacts:
    reports:
      container_scanning: gl-container-scanning-report.json
    paths:
      - gl-container-scanning-report.json
    expire_in: 1 week
  needs:
    - build-image
```

## Jenkins Integration

### Jenkins Pipeline Script
```groovy
// Jenkinsfile
pipeline {
    agent any
    
    environment {
        TRIVY_CACHE_DIR = "${WORKSPACE}/.trivycache"
        IMAGE_NAME = "myapp"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Source Code Security Scan') {
            steps {
                script {
                    sh '''
                        trivy fs --format json --output trivy-fs-report.json .
                        trivy fs --severity HIGH,CRITICAL --exit-code 0 .
                    '''
                }
                publishHTML([
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: '.',
                    reportFiles: 'trivy-fs-report.json',
                    reportName: 'Trivy Filesystem Scan Report'
                ])
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }
        
        stage('Container Security Scan') {
            steps {
                script {
                    sh '''
                        trivy image --format json --output trivy-image-report.json ${IMAGE_NAME}:${IMAGE_TAG}
                        trivy image --severity HIGH,CRITICAL --exit-code 0 ${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
                publishHTML([
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: '.',
                    reportFiles: 'trivy-image-report.json',
                    reportName: 'Trivy Container Scan Report'
                ])
            }
        }
        
        stage('Security Gate') {
            steps {
                script {
                    def criticalCount = sh(
                        script: "trivy image --format json --quiet ${IMAGE_NAME}:${IMAGE_TAG} | jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == \"CRITICAL\")] | length'",
                        returnStdout: true
                    ).trim()
                    
                    if (criticalCount.toInteger() > 0) {
                        error("Critical vulnerabilities found: ${criticalCount}")
                    }
                }
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                echo "Deploying ${IMAGE_NAME}:${IMAGE_TAG}"
                // Add deployment steps here
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: 'trivy-*.json', fingerprint: true
            cleanWs()
        }
        failure {
            emailext (
                subject: "Security Scan Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Security vulnerabilities detected in build ${env.BUILD_NUMBER}. Check the Trivy reports for details.",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}
```

## Azure DevOps Integration

### Azure Pipelines YAML
```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
    - main
    - develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  imageName: 'myapp'
  imageTag: '$(Build.BuildNumber)'

stages:
- stage: SecurityScan
  displayName: 'Security Scanning'
  jobs:
  - job: TrivyScan
    displayName: 'Trivy Security Scan'
    steps:
    - task: Bash@3
      displayName: 'Install Trivy'
      inputs:
        targetType: 'inline'
        script: |
          sudo apt-get update
          sudo apt-get install wget apt-transport-https gnupg lsb-release
          wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
          echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
          sudo apt-get update
          sudo apt-get install trivy

    - task: Bash@3
      displayName: 'Scan Source Code'
      inputs:
        targetType: 'inline'
        script: |
          trivy fs --format json --output $(Agent.TempDirectory)/trivy-fs-report.json .
          trivy fs --severity HIGH,CRITICAL --exit-code 1 .

    - task: Bash@3
      displayName: 'Scan Infrastructure'
      inputs:
        targetType: 'inline'
        script: |
          trivy config --format json --output $(Agent.TempDirectory)/trivy-config-report.json .
          trivy config --severity HIGH,CRITICAL --exit-code 1 .

    - task: PublishTestResults@2
      displayName: 'Publish Security Scan Results'
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: '$(Agent.TempDirectory)/trivy-*.json'
        testRunTitle: 'Trivy Security Scan'

- stage: Build
  displayName: 'Build and Scan Image'
  dependsOn: SecurityScan
  jobs:
  - job: BuildAndScan
    displayName: 'Build Docker Image and Scan'
    steps:
    - task: Docker@2
      displayName: 'Build Docker Image'
      inputs:
        command: 'build'
        Dockerfile: '**/Dockerfile'
        tags: '$(imageName):$(imageTag)'

    - task: Bash@3
      displayName: 'Scan Docker Image'
      inputs:
        targetType: 'inline'
        script: |
          trivy image --format json --output $(Agent.TempDirectory)/trivy-image-report.json $(imageName):$(imageTag)
          trivy image --severity HIGH,CRITICAL --exit-code 1 $(imageName):$(imageTag)

    - task: PublishBuildArtifacts@1
      displayName: 'Publish Scan Reports'
      inputs:
        pathToPublish: '$(Agent.TempDirectory)'
        artifactName: 'security-reports'
```

## Security Policy Enforcement

### Policy as Code Example
```bash
#!/bin/bash
# security-gate.sh - Enforce security policies

IMAGE_NAME=$1
SEVERITY_THRESHOLD="HIGH,CRITICAL"
MAX_CRITICAL=0
MAX_HIGH=5

echo "Running security scan on $IMAGE_NAME..."

# Generate JSON report
trivy image --format json --output scan-results.json $IMAGE_NAME

# Count vulnerabilities by severity
CRITICAL_COUNT=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' scan-results.json)
HIGH_COUNT=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH")] | length' scan-results.json)

echo "Found $CRITICAL_COUNT critical and $HIGH_COUNT high severity vulnerabilities"

# Enforce policy
if [ "$CRITICAL_COUNT" -gt "$MAX_CRITICAL" ]; then
    echo "❌ FAILED: $CRITICAL_COUNT critical vulnerabilities exceed limit of $MAX_CRITICAL"
    exit 1
fi

if [ "$HIGH_COUNT" -gt "$MAX_HIGH" ]; then
    echo "❌ FAILED: $HIGH_COUNT high vulnerabilities exceed limit of $MAX_HIGH"
    exit 1
fi

echo "✅ PASSED: Security scan meets policy requirements"
exit 0
```

### Notification Integration
```bash
#!/bin/bash
# notify-security-results.sh

SCAN_RESULTS="scan-results.json"
WEBHOOK_URL="$SLACK_WEBHOOK_URL"

# Extract summary
TOTAL_VULNS=$(jq '[.Results[]?.Vulnerabilities[]] | length' $SCAN_RESULTS)
CRITICAL_VULNS=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' $SCAN_RESULTS)
HIGH_VULNS=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH")] | length' $SCAN_RESULTS)

# Create Slack message
MESSAGE="{
  \"text\": \"🔍 Security Scan Results\",
  \"attachments\": [
    {
      \"color\": \"$([ $CRITICAL_VULNS -gt 0 ] && echo 'danger' || echo 'good')\",
      \"fields\": [
        {\"title\": \"Total Vulnerabilities\", \"value\": \"$TOTAL_VULNS\", \"short\": true},
        {\"title\": \"Critical\", \"value\": \"$CRITICAL_VULNS\", \"short\": true},
        {\"title\": \"High\", \"value\": \"$HIGH_VULNS\", \"short\": true},
        {\"title\": \"Image\", \"value\": \"$IMAGE_NAME\", \"short\": true}
      ]
    }
  ]
}"

# Send notification
curl -X POST -H 'Content-type: application/json' --data "$MESSAGE" $WEBHOOK_URL
```