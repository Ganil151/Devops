# DevSecOps

Comprehensive guide to integrating security practices into DevOps workflows, CI/CD pipelines, and modern software development lifecycles.

## DevSecOps Fundamentals

### DevSecOps Philosophy
```yaml
# DevSecOps Principles
core_principles:
  shift_left_security:
    - early_security_integration
    - security_by_design
    - proactive_vulnerability_management
    - continuous_security_testing
  
  automation_first:
    - automated_security_testing
    - policy_as_code
    - infrastructure_as_code_security
    - continuous_compliance_monitoring
  
  shared_responsibility:
    - security_ownership_across_teams
    - collaborative_security_culture
    - cross_functional_training
    - transparent_communication
  
  continuous_improvement:
    - feedback_driven_enhancement
    - metrics_based_optimization
    - learning_from_incidents
    - adaptive_security_controls
```

### DevSecOps Maturity Model
```yaml
# Maturity Assessment Framework
maturity_levels:
  level_1_initial:
    characteristics:
      - ad_hoc_security_practices
      - manual_security_testing
      - reactive_vulnerability_management
      - siloed_security_team
    
    focus_areas:
      - establish_security_policies
      - implement_basic_scanning
      - create_security_awareness
      - define_incident_response
  
  level_2_managed:
    characteristics:
      - defined_security_processes
      - automated_vulnerability_scanning
      - integrated_security_tools
      - regular_security_training
    
    focus_areas:
      - standardize_security_practices
      - implement_sast_dast_tools
      - establish_security_metrics
      - create_security_champions
  
  level_3_defined:
    characteristics:
      - comprehensive_security_integration
      - continuous_security_monitoring
      - automated_compliance_checking
      - security_embedded_in_sdlc
    
    focus_areas:
      - implement_security_orchestration
      - establish_threat_modeling
      - create_security_dashboards
      - implement_zero_trust_principles
  
  level_4_optimized:
    characteristics:
      - predictive_security_analytics
      - self_healing_security_systems
      - ai_driven_threat_detection
      - continuous_security_optimization
    
    focus_areas:
      - implement_ml_security_analytics
      - establish_adaptive_security
      - create_security_innovation_labs
      - implement_quantum_ready_security
```

## Secure CI/CD Pipeline Implementation

### Pipeline Security Architecture
```yaml
# Secure CI/CD Pipeline Design
pipeline_security:
  source_code_security:
    - secure_code_repositories
    - branch_protection_rules
    - commit_signing_verification
    - secrets_scanning
  
  build_security:
    - secure_build_environments
    - dependency_vulnerability_scanning
    - static_application_security_testing
    - container_image_scanning
  
  deployment_security:
    - infrastructure_as_code_validation
    - dynamic_application_security_testing
    - runtime_security_monitoring
    - compliance_validation
  
  monitoring_security:
    - continuous_security_monitoring
    - threat_detection_integration
    - security_metrics_collection
    - incident_response_automation
```

### GitLab CI/CD Security Pipeline
```yaml
# .gitlab-ci.yml with security integration
stages:
  - security-scan
  - build
  - test
  - security-test
  - deploy
  - monitor

variables:
  SECURE_ANALYZERS_PREFIX: "registry.gitlab.com/gitlab-org/security-products/analyzers"

# Secret Detection
secret_detection:
  stage: security-scan
  image: $SECURE_ANALYZERS_PREFIX/secrets:latest
  services: []
  script:
    - /analyzer run
  artifacts:
    reports:
      secret_detection: gl-secret-detection-report.json
  rules:
    - if: $CI_COMMIT_BRANCH

# Static Application Security Testing
sast:
  stage: security-scan
  image: $SECURE_ANALYZERS_PREFIX/semgrep:latest
  script:
    - /analyzer run
  artifacts:
    reports:
      sast: gl-sast-report.json
  rules:
    - if: $CI_COMMIT_BRANCH

# Dependency Scanning
dependency_scanning:
  stage: security-scan
  image: $SECURE_ANALYZERS_PREFIX/gemnasium:latest
  script:
    - /analyzer run
  artifacts:
    reports:
      dependency_scanning: gl-dependency-scanning-report.json
  rules:
    - if: $CI_COMMIT_BRANCH

# Container Scanning
container_scanning:
  stage: security-test
  image: $SECURE_ANALYZERS_PREFIX/klar:latest
  services:
    - docker:dind
  script:
    - docker build -t $CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG .
    - /analyzer run
  artifacts:
    reports:
      container_scanning: gl-container-scanning-report.json
  dependencies:
    - build
  rules:
    - if: $CI_COMMIT_BRANCH

# Dynamic Application Security Testing
dast:
  stage: security-test
  image: $SECURE_ANALYZERS_PREFIX/dast:latest
  script:
    - /analyzer run
  artifacts:
    reports:
      dast: gl-dast-report.json
  rules:
    - if: $CI_COMMIT_BRANCH
```

### Jenkins Security Pipeline
```groovy
// Jenkinsfile with security integration
pipeline {
    agent any
    
    environment {
        SONAR_TOKEN = credentials('sonar-token')
        SNYK_TOKEN = credentials('snyk-token')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                // Verify commit signatures
                sh 'git verify-commit HEAD'
            }
        }
        
        stage('Secret Scanning') {
            steps {
                script {
                    // TruffleHog secret scanning
                    sh '''
                        docker run --rm -v "$PWD:/pwd" \
                        trufflesecurity/trufflehog:latest \
                        filesystem /pwd --json > secrets-report.json
                    '''
                    
                    // Fail if secrets found
                    def secretsFound = sh(
                        script: 'cat secrets-report.json | jq length',
                        returnStdout: true
                    ).trim()
                    
                    if (secretsFound.toInteger() > 0) {
                        error("Secrets detected in code!")
                    }
                }
            }
        }
        
        stage('SAST Analysis') {
            parallel {
                stage('SonarQube') {
                    steps {
                        withSonarQubeEnv('SonarQube') {
                            sh '''
                                sonar-scanner \
                                -Dsonar.projectKey=myproject \
                                -Dsonar.sources=. \
                                -Dsonar.host.url=$SONAR_HOST_URL \
                                -Dsonar.login=$SONAR_TOKEN
                            '''
                        }
                    }
                }
                
                stage('Semgrep') {
                    steps {
                        sh '''
                            docker run --rm -v "$PWD:/src" \
                            returntocorp/semgrep \
                            --config=auto --json --output=semgrep-report.json /src
                        '''
                    }
                }
            }
        }
        
        stage('Dependency Check') {
            steps {
                sh '''
                    # Snyk vulnerability scanning
                    snyk test --json > snyk-report.json || true
                    
                    # OWASP Dependency Check
                    dependency-check.sh \
                        --project "MyProject" \
                        --scan . \
                        --format JSON \
                        --out dependency-check-report.json
                '''
            }
        }
        
        stage('Build & Container Scan') {
            steps {
                script {
                    // Build Docker image
                    def image = docker.build("myapp:${env.BUILD_ID}")
                    
                    // Trivy container scanning
                    sh """
                        trivy image --format json \
                        --output trivy-report.json \
                        myapp:${env.BUILD_ID}
                    """
                    
                    // Anchore container scanning
                    sh """
                        anchore-cli image add myapp:${env.BUILD_ID}
                        anchore-cli image wait myapp:${env.BUILD_ID}
                        anchore-cli image vuln myapp:${env.BUILD_ID} all
                    """
                }
            }
        }
        
        stage('Infrastructure Security') {
            steps {
                sh '''
                    # Terraform security scanning with Checkov
                    checkov -f terraform/ --framework terraform \
                    --output json > checkov-report.json
                    
                    # Kubernetes manifest scanning
                    kube-score score k8s-manifests/*.yaml \
                    --output-format json > kube-score-report.json
                '''
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                script {
                    // Deploy with security monitoring
                    sh '''
                        kubectl apply -f k8s-manifests/
                        
                        # Wait for deployment
                        kubectl rollout status deployment/myapp
                        
                        # Verify security policies
                        kubectl get networkpolicies
                        kubectl get podsecuritypolicies
                    '''
                }
            }
        }
        
        stage('DAST Testing') {
            steps {
                sh '''
                    # OWASP ZAP dynamic scanning
                    docker run -t owasp/zap2docker-stable \
                    zap-baseline.py -t http://staging.myapp.com \
                    -J zap-report.json
                    
                    # Nikto web vulnerability scanner
                    nikto -h http://staging.myapp.com \
                    -Format json -output nikto-report.json
                '''
            }
        }
    }
    
    post {
        always {
            // Archive security reports
            archiveArtifacts artifacts: '*-report.json', fingerprint: true
            
            // Publish security test results
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: '.',
                reportFiles: 'security-dashboard.html',
                reportName: 'Security Report'
            ])
        }
        
        failure {
            // Send security alert
            emailext (
                subject: "Security Pipeline Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Security vulnerabilities detected in build ${env.BUILD_NUMBER}",
                to: "${env.SECURITY_TEAM_EMAIL}"
            )
        }
    }
}
```

## Infrastructure as Code Security

### Terraform Security Scanning
```hcl
# terraform/security-policies.tf
# Security-focused Terraform configuration

# AWS Security Group with least privilege
resource "aws_security_group" "web_sg" {
  name_description = "Web server security group"
  vpc_id          = var.vpc_id

  # Inbound rules - restrictive
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from internet"
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "HTTP from ALB only"
  }

  # Outbound rules - explicit
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS outbound"
  }

  tags = {
    Name        = "web-sg"
    Environment = var.environment
    Security    = "managed"
  }
}

# S3 bucket with security best practices
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "myapp-secure-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "secure-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "secure_bucket_versioning" {
  bucket = aws_s3_bucket.secure_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_encryption" "secure_bucket_encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3_key.arn
        sse_algorithm     = "aws:kms"
      }
      bucket_key_enabled = true
    }
  }
}

resource "aws_s3_bucket_public_access_block" "secure_bucket_pab" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# KMS key for encryption
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "s3-encryption-key"
  }
}
```

### Kubernetes Security Manifests
```yaml
# k8s-security/pod-security-policy.yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted-psp
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
  readOnlyRootFilesystem: true
  seccompProfile:
    type: 'RuntimeDefault'

---
# Network Policy for micro-segmentation
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: web-app-netpol
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: web-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: database
    ports:
    - protocol: TCP
      port: 5432
  - to: []
    ports:
    - protocol: TCP
      port: 443  # HTTPS outbound

---
# Secure deployment configuration
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-web-app
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
      annotations:
        container.apparmor.security.beta.kubernetes.io/web-app: runtime/default
    spec:
      serviceAccountName: web-app-sa
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 2000
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: web-app
        image: myapp:v1.2.3
        ports:
        - containerPort: 8080
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
          capabilities:
            drop:
            - ALL
        resources:
          limits:
            cpu: 500m
            memory: 512Mi
          requests:
            cpu: 250m
            memory: 256Mi
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: tmp-volume
          mountPath: /tmp
        - name: cache-volume
          mountPath: /app/cache
      volumes:
      - name: tmp-volume
        emptyDir: {}
      - name: cache-volume
        emptyDir: {}
```

## Application Security Integration

### Secure Code Analysis
```python
# security-tools/sast-integration.py
"""
Static Application Security Testing Integration
"""
import subprocess
import json
import sys
from typing import Dict, List, Any

class SASTIntegration:
    def __init__(self):
        self.tools = {
            'bandit': self._run_bandit,
            'semgrep': self._run_semgrep,
            'sonarqube': self._run_sonarqube,
            'codeql': self._run_codeql
        }
        self.severity_threshold = 'HIGH'
    
    def run_all_tools(self, source_path: str) -> Dict[str, Any]:
        """Run all SAST tools and aggregate results"""
        results = {}
        
        for tool_name, tool_func in self.tools.items():
            try:
                print(f"Running {tool_name}...")
                results[tool_name] = tool_func(source_path)
            except Exception as e:
                print(f"Error running {tool_name}: {e}")
                results[tool_name] = {'error': str(e)}
        
        return self._aggregate_results(results)
    
    def _run_bandit(self, source_path: str) -> Dict[str, Any]:
        """Run Bandit Python security linter"""
        cmd = [
            'bandit', '-r', source_path,
            '-f', 'json',
            '-o', 'bandit-report.json'
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        with open('bandit-report.json', 'r') as f:
            return json.load(f)
    
    def _run_semgrep(self, source_path: str) -> Dict[str, Any]:
        """Run Semgrep static analysis"""
        cmd = [
            'semgrep', '--config=auto',
            '--json', '--output=semgrep-report.json',
            source_path
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        with open('semgrep-report.json', 'r') as f:
            return json.load(f)
    
    def _run_sonarqube(self, source_path: str) -> Dict[str, Any]:
        """Run SonarQube analysis"""
        cmd = [
            'sonar-scanner',
            f'-Dsonar.projectKey=security-scan',
            f'-Dsonar.sources={source_path}',
            '-Dsonar.host.url=${SONAR_HOST_URL}',
            '-Dsonar.login=${SONAR_TOKEN}'
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        # Fetch results from SonarQube API
        return self._fetch_sonarqube_results()
    
    def _run_codeql(self, source_path: str) -> Dict[str, Any]:
        """Run GitHub CodeQL analysis"""
        # Create CodeQL database
        subprocess.run([
            'codeql', 'database', 'create',
            'codeql-db', '--language=python',
            f'--source-root={source_path}'
        ])
        
        # Run analysis
        cmd = [
            'codeql', 'database', 'analyze',
            'codeql-db', 'python-security-and-quality.qls',
            '--format=json', '--output=codeql-report.json'
        ]
        
        subprocess.run(cmd)
        
        with open('codeql-report.json', 'r') as f:
            return json.load(f)
    
    def _aggregate_results(self, results: Dict[str, Any]) -> Dict[str, Any]:
        """Aggregate and normalize results from all tools"""
        aggregated = {
            'summary': {
                'total_issues': 0,
                'critical': 0,
                'high': 0,
                'medium': 0,
                'low': 0
            },
            'issues': [],
            'tools_run': list(results.keys())
        }
        
        for tool, result in results.items():
            if 'error' in result:
                continue
                
            # Normalize results based on tool format
            normalized_issues = self._normalize_tool_results(tool, result)
            
            for issue in normalized_issues:
                aggregated['issues'].append(issue)
                aggregated['summary']['total_issues'] += 1
                aggregated['summary'][issue['severity'].lower()] += 1
        
        return aggregated
    
    def _normalize_tool_results(self, tool: str, results: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Normalize results from different tools to common format"""
        normalized = []
        
        if tool == 'bandit':
            for issue in results.get('results', []):
                normalized.append({
                    'tool': 'bandit',
                    'rule_id': issue['test_id'],
                    'title': issue['test_name'],
                    'severity': issue['issue_severity'],
                    'confidence': issue['issue_confidence'],
                    'file': issue['filename'],
                    'line': issue['line_number'],
                    'description': issue['issue_text']
                })
        
        elif tool == 'semgrep':
            for issue in results.get('results', []):
                normalized.append({
                    'tool': 'semgrep',
                    'rule_id': issue['check_id'],
                    'title': issue['extra']['message'],
                    'severity': issue['extra']['severity'],
                    'file': issue['path'],
                    'line': issue['start']['line'],
                    'description': issue['extra'].get('metadata', {}).get('description', '')
                })
        
        return normalized
    
    def check_security_gate(self, results: Dict[str, Any]) -> bool:
        """Check if results pass security gate criteria"""
        summary = results['summary']
        
        # Fail if critical or high severity issues found
        if summary['critical'] > 0 or summary['high'] > 0:
            print(f"Security gate FAILED: {summary['critical']} critical, {summary['high']} high severity issues")
            return False
        
        print("Security gate PASSED: No critical or high severity issues found")
        return True

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python sast-integration.py <source_path>")
        sys.exit(1)
    
    source_path = sys.argv[1]
    sast = SASTIntegration()
    
    results = sast.run_all_tools(source_path)
    
    # Save aggregated results
    with open('security-report.json', 'w') as f:
        json.dump(results, f, indent=2)
    
    # Check security gate
    if not sast.check_security_gate(results):
        sys.exit(1)
    
    print("Security analysis completed successfully")
```

This comprehensive DevSecOps guide provides the framework for integrating security practices throughout the software development and deployment lifecycle.