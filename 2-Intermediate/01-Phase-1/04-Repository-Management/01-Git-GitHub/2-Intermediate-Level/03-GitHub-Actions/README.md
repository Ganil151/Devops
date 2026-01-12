# GitHub Actions CI/CD for DevOps Engineers

## GitHub Actions Overview

GitHub Actions is a powerful CI/CD platform that allows you to automate your software development workflows directly in your GitHub repository. It enables you to build, test, and deploy your code right from GitHub with event-driven automation.

## Core Concepts

### Workflows, Jobs, and Steps

```yaml
# Basic workflow structure
name: CI/CD Pipeline                    # Workflow name

on:                                     # Events that trigger the workflow
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:                                   # Collection of jobs
  build:                               # Job ID
    runs-on: ubuntu-latest             # Runner environment
    
    steps:                             # Sequence of tasks
    - name: Checkout code              # Step name
      uses: actions/checkout@v4        # Pre-built action
      
    - name: Run custom command         # Custom step
      run: echo "Hello World"          # Shell command
```

### Events and Triggers

```yaml
# Various trigger events
on:
  # Push events
  push:
    branches: [ main, develop ]
    tags: [ 'v*' ]
    paths: [ 'src/**', 'tests/**' ]
    paths-ignore: [ 'docs/**', '*.md' ]
  
  # Pull request events
  pull_request:
    branches: [ main ]
    types: [ opened, synchronize, reopened ]
  
  # Issue events
  issues:
    types: [ opened, labeled ]
  
  # Release events
  release:
    types: [ published ]
  
  # Schedule (cron)
  schedule:
    - cron: '0 2 * * 1'  # Every Monday at 2 AM UTC
  
  # Manual trigger
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        default: 'staging'
        type: choice
        options:
        - staging
        - production
  
  # Repository events
  repository_dispatch:
    types: [ deploy ]
```

## Basic CI/CD Workflows

### Node.js Application Pipeline

```yaml
# .github/workflows/nodejs-ci-cd.yml
name: Node.js CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  NODE_VERSION: '18'
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [16, 18, 20]
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Setup Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run linting
      run: npm run lint
    
    - name: Run unit tests
      run: npm test -- --coverage
    
    - name: Upload coverage reports
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage/lcov.info
        flags: unittests
        name: codecov-umbrella
    
    - name: Run security audit
      run: npm audit --audit-level moderate

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    
    outputs:
      image-digest: ${{ steps.build.outputs.digest }}
      image-tag: ${{ steps.meta.outputs.tags }}
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Setup Docker Buildx
      uses: docker/setup-buildx-action@v3
    
    - name: Log in to Container Registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha,prefix={{branch}}-
          type=raw,value=latest,enable={{is_default_branch}}
    
    - name: Build and push Docker image
      id: build
      uses: docker/build-push-action@v5
      with:
        context: .
        platforms: linux/amd64,linux/arm64
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment: staging
    
    steps:
    - name: Deploy to staging
      run: |
        echo "Deploying ${{ needs.build.outputs.image-tag }} to staging"
        # Add deployment commands here

  deploy-production:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
    - name: Deploy to production
      run: |
        echo "Deploying ${{ needs.build.outputs.image-tag }} to production"
        # Add deployment commands here
```

### Python Application Pipeline

```yaml
# .github/workflows/python-ci-cd.yml
name: Python CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  PYTHON_VERSION: '3.9'

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        python-version: ['3.8', '3.9', '3.10', '3.11']
    
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: testdb
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
      
      redis:
        image: redis:6
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Setup Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
        cache: 'pip'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install -r requirements-dev.txt
    
    - name: Run linting
      run: |
        flake8 src/ tests/
        black --check src/ tests/
        isort --check-only src/ tests/
    
    - name: Run type checking
      run: mypy src/
    
    - name: Run tests
      env:
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
        REDIS_URL: redis://localhost:6379/0
      run: |
        pytest tests/ --cov=src/ --cov-report=xml --cov-report=html
    
    - name: Upload coverage reports
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
        flags: unittests
    
    - name: Run security checks
      run: |
        bandit -r src/
        safety check

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}
    
    - name: Build package
      run: |
        python -m pip install --upgrade pip build
        python -m build
    
    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: python-package
        path: dist/
```

## Advanced Workflow Patterns

### Matrix Strategy

```yaml
# Advanced matrix strategy
name: Cross-platform Testing

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        python-version: ['3.8', '3.9', '3.10', '3.11']
        include:
          # Add specific configurations
          - os: ubuntu-latest
            python-version: '3.11'
            coverage: true
          - os: windows-latest
            python-version: '3.9'
            experimental: true
        exclude:
          # Exclude specific combinations
          - os: macos-latest
            python-version: '3.8'
    
    continue-on-error: ${{ matrix.experimental || false }}
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
    
    - name: Run tests
      run: pytest
    
    - name: Upload coverage
      if: matrix.coverage
      uses: codecov/codecov-action@v3
```

### Conditional Workflows

```yaml
# Conditional execution based on changes
name: Conditional Deployment

on:
  push:
    branches: [ main ]

jobs:
  changes:
    runs-on: ubuntu-latest
    outputs:
      frontend: ${{ steps.changes.outputs.frontend }}
      backend: ${{ steps.changes.outputs.backend }}
      infrastructure: ${{ steps.changes.outputs.infrastructure }}
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: dorny/paths-filter@v2
      id: changes
      with:
        filters: |
          frontend:
            - 'frontend/**'
            - 'package.json'
          backend:
            - 'backend/**'
            - 'requirements.txt'
          infrastructure:
            - 'infrastructure/**'
            - 'terraform/**'

  deploy-frontend:
    needs: changes
    if: needs.changes.outputs.frontend == 'true'
    runs-on: ubuntu-latest
    
    steps:
    - name: Deploy frontend
      run: echo "Deploying frontend changes"

  deploy-backend:
    needs: changes
    if: needs.changes.outputs.backend == 'true'
    runs-on: ubuntu-latest
    
    steps:
    - name: Deploy backend
      run: echo "Deploying backend changes"

  deploy-infrastructure:
    needs: changes
    if: needs.changes.outputs.infrastructure == 'true'
    runs-on: ubuntu-latest
    
    steps:
    - name: Deploy infrastructure
      run: echo "Deploying infrastructure changes"
```

### Reusable Workflows

```yaml
# .github/workflows/reusable-deploy.yml
name: Reusable Deployment

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      image-tag:
        required: true
        type: string
      config-path:
        required: false
        type: string
        default: 'config/default.yml'
    secrets:
      deploy-token:
        required: true
      registry-password:
        required: true
    outputs:
      deployment-url:
        description: "URL of the deployed application"
        value: ${{ jobs.deploy.outputs.url }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    
    outputs:
      url: ${{ steps.deploy.outputs.url }}
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Login to registry
      uses: docker/login-action@v3
      with:
        registry: ghcr.io
        username: ${{ github.actor }}
        password: ${{ secrets.registry-password }}
    
    - name: Deploy application
      id: deploy
      run: |
        echo "Deploying ${{ inputs.image-tag }} to ${{ inputs.environment }}"
        echo "Using config: ${{ inputs.config-path }}"
        
        # Deployment logic here
        deployment_url="https://${{ inputs.environment }}.example.com"
        echo "url=$deployment_url" >> $GITHUB_OUTPUT
        
        echo "Deployment completed: $deployment_url"
```

```yaml
# .github/workflows/main-pipeline.yml
name: Main Pipeline

on:
  push:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.build.outputs.tag }}
    
    steps:
    - name: Build application
      id: build
      run: |
        tag="myapp:${{ github.sha }}"
        echo "tag=$tag" >> $GITHUB_OUTPUT

  deploy-staging:
    needs: build
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      environment: staging
      image-tag: ${{ needs.build.outputs.image-tag }}
      config-path: 'config/staging.yml'
    secrets:
      deploy-token: ${{ secrets.STAGING_DEPLOY_TOKEN }}
      registry-password: ${{ secrets.GITHUB_TOKEN }}

  deploy-production:
    needs: [build, deploy-staging]
    if: github.ref == 'refs/heads/main'
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      environment: production
      image-tag: ${{ needs.build.outputs.image-tag }}
      config-path: 'config/production.yml'
    secrets:
      deploy-token: ${{ secrets.PRODUCTION_DEPLOY_TOKEN }}
      registry-password: ${{ secrets.GITHUB_TOKEN }}
```

## Security and Secrets Management

### Secrets Configuration

```yaml
# Using secrets in workflows
name: Secure Deployment

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
    
    - name: Deploy to AWS
      env:
        DATABASE_URL: ${{ secrets.DATABASE_URL }}
        API_KEY: ${{ secrets.API_KEY }}
      run: |
        echo "Deploying with secure credentials"
        # Deployment commands here
```

### Security Scanning Workflows

```yaml
# .github/workflows/security-scan.yml
name: Security Scanning

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * 1'  # Weekly scan

jobs:
  dependency-scan:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
    
    - name: Upload Snyk results to GitHub Code Scanning
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: snyk.sarif

  container-scan:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Build Docker image
      run: docker build -t myapp:latest .
    
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: 'myapp:latest'
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'

  code-scan:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        language: [ 'javascript', 'python' ]
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Initialize CodeQL
      uses: github/codeql-action/init@v2
      with:
        languages: ${{ matrix.language }}
    
    - name: Autobuild
      uses: github/codeql-action/autobuild@v2
    
    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v2

  secret-scan:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
      with:
        fetch-depth: 0
    
    - name: Run TruffleHog
      uses: trufflesecurity/trufflehog@main
      with:
        path: ./
        base: main
        head: HEAD
```

## Infrastructure as Code with GitHub Actions

### Terraform Workflows

```yaml
# .github/workflows/terraform.yml
name: Terraform CI/CD

on:
  push:
    branches: [ main ]
    paths: [ 'terraform/**' ]
  pull_request:
    branches: [ main ]
    paths: [ 'terraform/**' ]

env:
  TF_VERSION: '1.5.0'
  TF_WORKING_DIR: './terraform'

jobs:
  terraform-check:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: ${{ env.TF_VERSION }}
    
    - name: Terraform Format Check
      working-directory: ${{ env.TF_WORKING_DIR }}
      run: terraform fmt -check -recursive
    
    - name: Terraform Init
      working-directory: ${{ env.TF_WORKING_DIR }}
      run: terraform init -backend=false
    
    - name: Terraform Validate
      working-directory: ${{ env.TF_WORKING_DIR }}
      run: terraform validate
    
    - name: Run TFLint
      uses: terraform-linters/setup-tflint@v3
      with:
        tflint_version: latest
    
    - name: Initialize TFLint
      working-directory: ${{ env.TF_WORKING_DIR }}
      run: tflint --init
    
    - name: Run TFLint
      working-directory: ${{ env.TF_WORKING_DIR }}
      run: tflint

  terraform-plan:
    needs: terraform-check
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: ${{ env.TF_VERSION }}
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
    
    - name: Terraform Init
      working-directory: ${{ env.TF_WORKING_DIR }}
      run: terraform init
    
    - name: Terraform Plan
      working-directory: ${{ env.TF_WORKING_DIR }}
      run: terraform plan -no-color -out=tfplan
    
    - name: Comment PR with plan
      uses: actions/github-script@v6
      with:
        script: |
          const fs = require('fs');
          const plan = fs.readFileSync('${{ env.TF_WORKING_DIR }}/tfplan.txt', 'utf8');
          const maxGitHubBodyCharacters = 65536;
          
          function chunkSubstr(str, size) {
            const numChunks = Math.ceil(str.length / size)
            const chunks = new Array(numChunks)
            for (let i = 0, o = 0; i < numChunks; ++i, o += size) {
              chunks[i] = str.substr(o, size)
            }
            return chunks
          }
          
          const body = plan.length > maxGitHubBodyCharacters ? 
            `\`\`\`\n${plan.substr(0, maxGitHubBodyCharacters)}\n\`\`\`\n\n*Output truncated*` : 
            `\`\`\`\n${plan}\n\`\`\``;
          
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: `## Terraform Plan\n\n${body}`
          });

  terraform-apply:
    needs: terraform-check
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: ${{ env.TF_VERSION }}
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
    
    - name: Terraform Init
      working-directory: ${{ env.TF_WORKING_DIR }}
      run: terraform init
    
    - name: Terraform Apply
      working-directory: ${{ env.TF_WORKING_DIR }}
      run: terraform apply -auto-approve
```

### Kubernetes Deployment

```yaml
# .github/workflows/k8s-deploy.yml
name: Kubernetes Deployment

on:
  push:
    branches: [ main ]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        default: 'staging'
        type: choice
        options:
        - staging
        - production

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
      image-digest: ${{ steps.build.outputs.digest }}
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Setup Docker Buildx
      uses: docker/setup-buildx-action@v3
    
    - name: Log in to Container Registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=sha,prefix={{branch}}-
          type=raw,value=latest,enable={{is_default_branch}}
    
    - name: Build and push Docker image
      id: build
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment || 'staging' }}
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Configure kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'v1.28.0'
    
    - name: Set up Kubernetes config
      run: |
        mkdir -p $HOME/.kube
        echo "${{ secrets.KUBE_CONFIG }}" | base64 -d > $HOME/.kube/config
        chmod 600 $HOME/.kube/config
    
    - name: Deploy to Kubernetes
      env:
        ENVIRONMENT: ${{ github.event.inputs.environment || 'staging' }}
        IMAGE_TAG: ${{ needs.build.outputs.image-tag }}
      run: |
        # Update deployment manifest with new image
        sed -i "s|IMAGE_PLACEHOLDER|$IMAGE_TAG|g" k8s/deployment.yaml
        sed -i "s|ENVIRONMENT_PLACEHOLDER|$ENVIRONMENT|g" k8s/deployment.yaml
        
        # Apply manifests
        kubectl apply -f k8s/ -n $ENVIRONMENT
        
        # Wait for rollout to complete
        kubectl rollout status deployment/myapp -n $ENVIRONMENT --timeout=300s
        
        # Verify deployment
        kubectl get pods -n $ENVIRONMENT -l app=myapp
    
    - name: Run smoke tests
      run: |
        # Wait for service to be ready
        kubectl wait --for=condition=ready pod -l app=myapp -n ${{ github.event.inputs.environment || 'staging' }} --timeout=300s
        
        # Get service URL
        SERVICE_URL=$(kubectl get service myapp-service -n ${{ github.event.inputs.environment || 'staging' }} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
        
        # Run smoke tests
        curl -f http://$SERVICE_URL/health || exit 1
        echo "Smoke tests passed!"
```

## Monitoring and Notifications

### Workflow Monitoring

```yaml
# .github/workflows/monitoring.yml
name: Workflow Monitoring

on:
  workflow_run:
    workflows: ["CI/CD Pipeline"]
    types: [completed]

jobs:
  notify:
    runs-on: ubuntu-latest
    
    steps:
    - name: Notify on failure
      if: ${{ github.event.workflow_run.conclusion == 'failure' }}
      uses: 8398a7/action-slack@v3
      with:
        status: failure
        channel: '#devops-alerts'
        webhook_url: ${{ secrets.SLACK_WEBHOOK }}
        fields: repo,message,commit,author,action,eventName,ref,workflow
    
    - name: Create issue on failure
      if: ${{ github.event.workflow_run.conclusion == 'failure' }}
      uses: actions/github-script@v6
      with:
        script: |
          github.rest.issues.create({
            owner: context.repo.owner,
            repo: context.repo.repo,
            title: `Workflow failure: ${context.payload.workflow_run.name}`,
            body: `Workflow "${context.payload.workflow_run.name}" failed on ${context.payload.workflow_run.head_branch}.\n\nRun: ${context.payload.workflow_run.html_url}`,
            labels: ['bug', 'ci-failure']
          });
```

### Performance Monitoring

```yaml
# .github/workflows/performance.yml
name: Performance Monitoring

on:
  push:
    branches: [ main ]
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours

jobs:
  performance-test:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Run Lighthouse CI
      uses: treosh/lighthouse-ci-action@v9
      with:
        configPath: './lighthouserc.json'
        uploadArtifacts: true
        temporaryPublicStorage: true
    
    - name: Load testing with k6
      uses: grafana/k6-action@v0.2.0
      with:
        filename: tests/performance/load-test.js
        flags: --out json=results.json
    
    - name: Upload performance results
      uses: actions/upload-artifact@v3
      with:
        name: performance-results
        path: |
          results.json
          lhci_reports/
```

This comprehensive GitHub Actions CI/CD guide provides DevOps engineers with the knowledge and examples needed to implement robust, secure, and scalable automation workflows for modern software development and deployment practices.