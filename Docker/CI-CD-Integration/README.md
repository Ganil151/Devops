# Docker CI/CD Integration

Complete guide to integrating Docker into CI/CD pipelines with popular platforms and best practices.

## CI/CD Fundamentals with Docker

### Docker in CI/CD Pipeline

```
Source Code → Build → Test → Security Scan → Push → Deploy
     ↓         ↓      ↓         ↓           ↓      ↓
   Git      Docker  Docker   Trivy/      Docker  Container
  Commit    Build   Test     Snyk        Push    Deploy
```

### Benefits of Docker in CI/CD

- **Consistency**: Same environment across all stages
- **Isolation**: Tests run in clean environments
- **Portability**: Deploy anywhere Docker runs
- **Scalability**: Parallel builds and tests
- **Reproducibility**: Exact same artifacts in all environments

## GitHub Actions

### Basic Docker Workflow

```yaml
# .github/workflows/docker.yml
name: Docker CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
        
      - name: Log in to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
          
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v4
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=sha,prefix={{branch}}-
            
      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          
      - name: Run tests
        run: |
          docker run --rm ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} npm test
```

### Multi-Stage Build with Testing

```yaml
# .github/workflows/advanced-docker.yml
name: Advanced Docker CI/CD

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build test image
        run: |
          docker build --target test -t myapp:test .
          
      - name: Run unit tests
        run: |
          docker run --rm myapp:test npm run test:unit
          
      - name: Run integration tests
        run: |
          docker-compose -f docker-compose.test.yml up --abort-on-container-exit
          
      - name: Security scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: myapp:test
          format: sarif
          output: trivy-results.sarif
          
      - name: Upload security scan results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: trivy-results.sarif

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
        
      - name: Login to DockerHub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
          
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          target: production
          push: true
          tags: |
            myapp:latest
            myapp:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          
      - name: Deploy to staging
        run: |
          echo "Deploying to staging environment"
          # Add deployment commands here
```

## Jenkins Pipeline

### Declarative Pipeline

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'your-registry.com'
        IMAGE_NAME = 'myapp'
        DOCKER_CREDENTIALS = credentials('docker-registry-credentials')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                script {
                    def image = docker.build("${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}")
                    env.IMAGE_TAG = "${BUILD_NUMBER}"
                }
            }
        }
        
        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        script {
                            docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}")
                                  .inside('-v /var/run/docker.sock:/var/run/docker.sock') {
                                sh 'npm test'
                            }
                        }
                    }
                    post {
                        always {
                            publishTestResults testResultsPattern: 'test-results.xml'
                        }
                    }
                }
                
                stage('Security Scan') {
                    steps {
                        script {
                            sh """
                                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \\
                                    aquasec/trivy image ${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}
                            """
                        }
                    }
                }
                
                stage('Integration Tests') {
                    steps {
                        script {
                            sh 'docker-compose -f docker-compose.test.yml up --abort-on-container-exit'
                        }
                    }
                    post {
                        always {
                            sh 'docker-compose -f docker-compose.test.yml down -v'
                        }
                    }
                }
            }
        }
        
        stage('Push') {
            when {
                branch 'main'
            }
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-registry-credentials') {
                        def image = docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}")
                        image.push()
                        image.push('latest')
                    }
                }
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                script {
                    // Deploy to staging
                    sh """
                        docker service update --image ${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER} \\
                            myapp-staging
                    """
                    
                    // Wait for deployment
                    sh 'sleep 30'
                    
                    // Health check
                    sh 'curl -f http://staging.myapp.com/health'
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
            sh 'docker system prune -f'
        }
        failure {
            emailext (
                subject: "Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Build failed. Check console output at ${env.BUILD_URL}",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}
```

### Scripted Pipeline with Docker

```groovy
// Jenkinsfile (Scripted)
node {
    def image
    def imageTag = "${BUILD_NUMBER}"
    
    try {
        stage('Checkout') {
            checkout scm
        }
        
        stage('Build') {
            image = docker.build("myapp:${imageTag}")
        }
        
        stage('Test') {
            image.inside('-v /var/run/docker.sock:/var/run/docker.sock') {
                sh 'npm test'
                sh 'npm run lint'
            }
        }
        
        stage('Security Scan') {
            sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image myapp:${imageTag}"
        }
        
        stage('Push') {
            if (env.BRANCH_NAME == 'main') {
                docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-credentials') {
                    image.push(imageTag)
                    image.push('latest')
                }
            }
        }
        
        stage('Deploy') {
            if (env.BRANCH_NAME == 'main') {
                sh """
                    docker service update --image myapp:${imageTag} myapp-service
                """
            }
        }
        
    } catch (Exception e) {
        currentBuild.result = 'FAILURE'
        throw e
    } finally {
        sh 'docker system prune -f'
    }
}
```

## GitLab CI/CD

### GitLab CI Configuration

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - security
  - push
  - deploy

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"
  IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  LATEST_TAG: $CI_REGISTRY_IMAGE:latest

services:
  - docker:20.10.16-dind

before_script:
  - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY

build:
  stage: build
  image: docker:20.10.16
  script:
    - docker build -t $IMAGE_TAG .
    - docker push $IMAGE_TAG
  only:
    - main
    - develop
    - merge_requests

test:unit:
  stage: test
  image: docker:20.10.16
  script:
    - docker run --rm $IMAGE_TAG npm test
  coverage: '/Coverage: \d+\.\d+%/'
  artifacts:
    reports:
      junit: test-results.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

test:integration:
  stage: test
  image: docker:20.10.16
  services:
    - postgres:13
    - redis:7-alpine
  variables:
    POSTGRES_DB: testdb
    POSTGRES_USER: testuser
    POSTGRES_PASSWORD: testpass
  script:
    - docker-compose -f docker-compose.test.yml up --abort-on-container-exit
  after_script:
    - docker-compose -f docker-compose.test.yml down -v

security:scan:
  stage: security
  image: docker:20.10.16
  script:
    - docker run --rm -v /var/run/docker.sock:/var/run/docker.sock 
        aquasec/trivy image --exit-code 1 --severity HIGH,CRITICAL $IMAGE_TAG
  allow_failure: true

push:latest:
  stage: push
  image: docker:20.10.16
  script:
    - docker pull $IMAGE_TAG
    - docker tag $IMAGE_TAG $LATEST_TAG
    - docker push $LATEST_TAG
  only:
    - main

deploy:staging:
  stage: deploy
  image: alpine:latest
  before_script:
    - apk add --no-cache curl
  script:
    - curl -X POST "$WEBHOOK_URL" 
        -H "Content-Type: application/json" 
        -d '{"image":"'$IMAGE_TAG'","environment":"staging"}'
  environment:
    name: staging
    url: https://staging.myapp.com
  only:
    - main

deploy:production:
  stage: deploy
  image: alpine:latest
  before_script:
    - apk add --no-cache curl
  script:
    - curl -X POST "$WEBHOOK_URL" 
        -H "Content-Type: application/json" 
        -d '{"image":"'$IMAGE_TAG'","environment":"production"}'
  environment:
    name: production
    url: https://myapp.com
  when: manual
  only:
    - main
```

## Azure DevOps

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
  dockerRegistryServiceConnection: 'dockerhub-connection'
  imageRepository: 'myapp'
  containerRegistry: 'myregistry.azurecr.io'
  dockerfilePath: '$(Build.SourcesDirectory)/Dockerfile'
  tag: '$(Build.BuildId)'

stages:
- stage: Build
  displayName: Build and Test
  jobs:
  - job: Build
    displayName: Build
    steps:
    - task: Docker@2
      displayName: Build Docker image
      inputs:
        command: build
        repository: $(imageRepository)
        dockerfile: $(dockerfilePath)
        tags: |
          $(tag)
          latest

    - task: Docker@2
      displayName: Run tests
      inputs:
        command: run
        arguments: '--rm $(imageRepository):$(tag) npm test'

    - task: Docker@2
      displayName: Security scan
      inputs:
        command: run
        arguments: '--rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image $(imageRepository):$(tag)'

- stage: Push
  displayName: Push to Registry
  dependsOn: Build
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - job: Push
    displayName: Push
    steps:
    - task: Docker@2
      displayName: Login to registry
      inputs:
        command: login
        containerRegistry: $(dockerRegistryServiceConnection)

    - task: Docker@2
      displayName: Build and push
      inputs:
        command: buildAndPush
        repository: $(imageRepository)
        dockerfile: $(dockerfilePath)
        containerRegistry: $(dockerRegistryServiceConnection)
        tags: |
          $(tag)
          latest

- stage: Deploy
  displayName: Deploy to Staging
  dependsOn: Push
  jobs:
  - deployment: DeployToStaging
    displayName: Deploy to Staging
    environment: 'staging'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebAppContainer@1
            displayName: Deploy to Azure Web App
            inputs:
              azureSubscription: 'azure-subscription'
              appName: 'myapp-staging'
              containers: '$(containerRegistry)/$(imageRepository):$(tag)'
```

## Docker Compose in CI/CD

### Testing with Docker Compose

```yaml
# docker-compose.test.yml
version: '3.8'

services:
  app:
    build: .
    environment:
      - NODE_ENV=test
      - DB_HOST=test-db
      - REDIS_HOST=test-redis
    depends_on:
      - test-db
      - test-redis
    command: npm test
    volumes:
      - ./coverage:/app/coverage

  test-db:
    image: postgres:13
    environment:
      - POSTGRES_DB=testdb
      - POSTGRES_USER=testuser
      - POSTGRES_PASSWORD=testpass
    tmpfs:
      - /var/lib/postgresql/data

  test-redis:
    image: redis:7-alpine
    tmpfs:
      - /data

  integration-tests:
    build:
      context: .
      dockerfile: Dockerfile.test
    environment:
      - API_URL=http://app:3000
    depends_on:
      - app
    command: npm run test:integration
```

### Multi-Environment Deployment

```bash
#!/bin/bash
# deploy.sh

ENVIRONMENT=$1
IMAGE_TAG=$2

if [ -z "$ENVIRONMENT" ] || [ -z "$IMAGE_TAG" ]; then
    echo "Usage: $0 <environment> <image_tag>"
    exit 1
fi

case $ENVIRONMENT in
    "staging")
        COMPOSE_FILE="docker-compose.staging.yml"
        ;;
    "production")
        COMPOSE_FILE="docker-compose.prod.yml"
        ;;
    *)
        echo "Unknown environment: $ENVIRONMENT"
        exit 1
        ;;
esac

# Update image tag in environment file
echo "IMAGE_TAG=$IMAGE_TAG" > .env.$ENVIRONMENT

# Deploy
docker-compose -f $COMPOSE_FILE --env-file .env.$ENVIRONMENT up -d

# Health check
sleep 30
curl -f http://$ENVIRONMENT.myapp.com/health

echo "Deployment to $ENVIRONMENT completed successfully"
```

## Security in CI/CD

### Image Scanning Integration

```yaml
# Security scanning job
security-scan:
  stage: security
  image: docker:20.10.16
  script:
    # Trivy scan
    - docker run --rm -v /var/run/docker.sock:/var/run/docker.sock 
        aquasec/trivy image --format json --output trivy-report.json $IMAGE_TAG
    
    # Snyk scan
    - docker run --rm -v $(pwd):/app snyk/snyk:docker test --docker $IMAGE_TAG
    
    # Custom security checks
    - ./scripts/security-checks.sh $IMAGE_TAG
  artifacts:
    reports:
      security: trivy-report.json
    paths:
      - trivy-report.json
    expire_in: 1 week
```

### Secrets Management

```yaml
# Using external secrets in CI/CD
deploy:
  stage: deploy
  image: alpine:latest
  before_script:
    - apk add --no-cache curl jq
    # Fetch secrets from Vault
    - export DB_PASSWORD=$(vault kv get -field=password secret/myapp/db)
    - export API_KEY=$(vault kv get -field=api_key secret/myapp/external)
  script:
    - envsubst < docker-compose.template.yml > docker-compose.yml
    - docker-compose up -d
```

## Performance Optimization

### Build Optimization

```dockerfile
# Multi-stage build for CI/CD optimization
FROM node:16-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:16-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:16-alpine AS test
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm test

FROM node:16-alpine AS production
WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package*.json ./
USER 1000:1000
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

### Cache Optimization

```yaml
# GitHub Actions with advanced caching
- name: Build with cache
  uses: docker/build-push-action@v4
  with:
    context: .
    push: true
    tags: ${{ steps.meta.outputs.tags }}
    cache-from: |
      type=gha
      type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:cache
    cache-to: |
      type=gha,mode=max
      type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:cache,mode=max
```

## Monitoring and Observability

### Pipeline Monitoring

```yaml
# Add monitoring to CI/CD pipeline
monitoring:
  stage: monitor
  image: alpine:latest
  script:
    # Send metrics to monitoring system
    - curl -X POST "$METRICS_ENDPOINT" 
        -H "Content-Type: application/json" 
        -d '{
          "pipeline_id": "'$CI_PIPELINE_ID'",
          "build_time": "'$BUILD_DURATION'",
          "image_size": "'$IMAGE_SIZE'",
          "vulnerabilities": "'$VULN_COUNT'"
        }'
    
    # Update deployment status
    - curl -X POST "$STATUS_ENDPOINT" 
        -H "Authorization: Bearer $API_TOKEN" 
        -d '{"status": "deployed", "version": "'$IMAGE_TAG'"}'
```

### Deployment Verification

```bash
#!/bin/bash
# verify-deployment.sh

ENVIRONMENT=$1
SERVICE_URL=$2
MAX_RETRIES=30
RETRY_INTERVAL=10

echo "Verifying deployment to $ENVIRONMENT..."

for i in $(seq 1 $MAX_RETRIES); do
    if curl -f -s "$SERVICE_URL/health" > /dev/null; then
        echo "✅ Deployment verification successful"
        
        # Run smoke tests
        ./scripts/smoke-tests.sh $SERVICE_URL
        
        # Update monitoring
        curl -X POST "$MONITORING_WEBHOOK" \
            -d '{"event": "deployment_success", "environment": "'$ENVIRONMENT'"}'
        
        exit 0
    fi
    
    echo "⏳ Attempt $i/$MAX_RETRIES failed, retrying in ${RETRY_INTERVAL}s..."
    sleep $RETRY_INTERVAL
done

echo "❌ Deployment verification failed"
exit 1
```

## Best Practices

### CI/CD Pipeline Best Practices

1. **Fast Feedback**: Keep build times under 10 minutes
2. **Fail Fast**: Run quick tests first
3. **Parallel Execution**: Run independent jobs in parallel
4. **Immutable Artifacts**: Use same image across environments
5. **Security First**: Scan early and often
6. **Monitoring**: Track pipeline metrics and deployment success

### Docker-Specific Best Practices

1. **Layer Caching**: Optimize Dockerfile for better caching
2. **Multi-stage Builds**: Separate build and runtime dependencies
3. **Security Scanning**: Integrate vulnerability scanning
4. **Image Tagging**: Use semantic versioning and commit SHAs
5. **Resource Limits**: Set appropriate CPU and memory limits
6. **Health Checks**: Implement proper health check endpoints