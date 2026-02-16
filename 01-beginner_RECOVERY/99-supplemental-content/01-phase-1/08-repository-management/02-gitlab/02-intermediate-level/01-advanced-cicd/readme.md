# Advanced CI/CD Patterns

## Complex Pipeline Architectures

### 1. Multi-Stage Pipeline Design
```yaml
# .gitlab-ci.yml - Advanced multi-stage pipeline
stages:
  - validate
  - build
  - test
  - security
  - package
  - deploy-staging
  - integration-tests
  - deploy-production
  - post-deploy

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"

# Validation stage
code-quality:
  stage: validate
  image: sonarsource/sonar-scanner-cli:latest
  script:
    - sonar-scanner
  only:
    - merge_requests
    - main

lint-code:
  stage: validate
  image: node:16-alpine
  script:
    - npm ci
    - npm run lint
    - npm run format:check
  cache:
    key: npm-cache
    paths:
      - node_modules/

# Build stage with matrix
build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  parallel:
    matrix:
      - PLATFORM: [linux/amd64, linux/arm64]
  script:
    - docker buildx create --use
    - docker buildx build --platform $PLATFORM -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA-${PLATFORM//\//-} .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA-${PLATFORM//\//-}

# Comprehensive testing
unit-tests:
  stage: test
  image: node:16-alpine
  script:
    - npm ci
    - npm run test:unit
  coverage: '/Lines\s*:\s*(\d+\.\d+)%/'
  artifacts:
    reports:
      junit: junit.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

integration-tests:
  stage: test
  image: docker/compose:latest
  services:
    - docker:dind
  script:
    - docker-compose -f docker-compose.test.yml up --build --abort-on-container-exit
    - docker-compose -f docker-compose.test.yml down
  artifacts:
    reports:
      junit: test-results/integration-results.xml

e2e-tests:
  stage: test
  image: cypress/included:latest
  script:
    - npm ci
    - npm run start:test &
    - npx wait-on http://localhost:3000
    - npx cypress run
  artifacts:
    when: always
    paths:
      - cypress/screenshots
      - cypress/videos
    expire_in: 1 week
```

### 2. Conditional Pipeline Execution
```yaml
# Dynamic pipeline based on changes
include:
  - local: '/.gitlab/ci/frontend.yml'
    rules:
      - changes:
          - "frontend/**/*"
          - "package.json"
  - local: '/.gitlab/ci/backend.yml'
    rules:
      - changes:
          - "backend/**/*"
          - "requirements.txt"
  - local: '/.gitlab/ci/infrastructure.yml'
    rules:
      - changes:
          - "terraform/**/*"
          - "k8s/**/*"

# Conditional job execution
deploy-feature:
  stage: deploy
  script:
    - deploy-to-feature-env.sh
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      when: manual
    - if: '$CI_COMMIT_BRANCH == "develop"'
      when: on_success

deploy-production:
  stage: deploy
  script:
    - deploy-to-production.sh
  rules:
    - if: '$CI_COMMIT_TAG =~ /^v\d+\.\d+\.\d+$/'
      when: manual
    - if: '$CI_COMMIT_BRANCH == "main" && $CI_PIPELINE_SOURCE == "schedule"'
      when: on_success
```

## Multi-Project Pipelines

### 1. Upstream/Downstream Pipelines
```yaml
# Parent project pipeline
trigger-downstream:
  stage: deploy
  trigger:
    project: group/downstream-project
    branch: main
    strategy: depend
  variables:
    UPSTREAM_COMMIT_SHA: $CI_COMMIT_SHA
    DEPLOYMENT_ENV: production

# Multi-project trigger
trigger-multiple:
  stage: deploy
  parallel:
    matrix:
      - PROJECT: [frontend-app, backend-api, mobile-app]
  trigger:
    project: group/$PROJECT
    branch: main
  variables:
    PARENT_PIPELINE_ID: $CI_PIPELINE_ID
```

### 2. Parent-Child Pipelines
```yaml
# Generate dynamic child pipeline
generate-child-pipeline:
  stage: build
  image: ruby:2.7
  script:
    - ruby generate-pipeline.rb > child-pipeline.yml
  artifacts:
    paths:
      - child-pipeline.yml

# Trigger child pipeline
child-pipeline:
  stage: deploy
  trigger:
    include:
      - artifact: child-pipeline.yml
        job: generate-child-pipeline
    strategy: depend
```

### 3. Cross-Project Dependencies
```yaml
# Wait for upstream project
wait-for-dependency:
  stage: build
  image: alpine:latest
  script:
    - apk add --no-cache curl jq
    - |
      while true; do
        STATUS=$(curl -s --header "PRIVATE-TOKEN: $API_TOKEN" \
          "$CI_API_V4_URL/projects/$DEPENDENCY_PROJECT_ID/pipelines/latest" | \
          jq -r '.status')
        if [ "$STATUS" = "success" ]; then
          echo "Dependency pipeline completed successfully"
          break
        elif [ "$STATUS" = "failed" ]; then
          echo "Dependency pipeline failed"
          exit 1
        fi
        sleep 30
      done
```

## Pipeline Optimization Strategies

### 1. Intelligent Caching
```yaml
# Global cache configuration
cache:
  key:
    files:
      - package-lock.json
      - requirements.txt
  paths:
    - node_modules/
    - .pip-cache/
  policy: pull-push

# Job-specific cache optimization
build-frontend:
  cache:
    key: frontend-$CI_COMMIT_REF_SLUG
    paths:
      - frontend/node_modules/
      - frontend/.next/cache/
    policy: pull-push

build-backend:
  cache:
    key: backend-$CI_COMMIT_REF_SLUG
    paths:
      - backend/.pip-cache/
      - backend/__pycache__/
    policy: pull-push

# Cache fallback strategy
test-with-fallback:
  cache:
    - key: test-cache-$CI_COMMIT_REF_SLUG
      paths:
        - node_modules/
      policy: pull
    - key: test-cache-main
      paths:
        - node_modules/
      policy: pull
      fallback_keys:
        - test-cache-develop
        - test-cache-
```

### 2. Parallel Execution Patterns
```yaml
# Test parallelization
test:
  stage: test
  parallel: 4
  script:
    - npm run test -- --shard=$CI_NODE_INDEX/$CI_NODE_TOTAL

# Matrix builds
build-matrix:
  stage: build
  parallel:
    matrix:
      - NODE_VERSION: ["14", "16", "18"]
        OS: ["ubuntu-latest", "alpine"]
  image: node:$NODE_VERSION-$OS
  script:
    - npm ci
    - npm run build

# Parallel deployment
deploy-services:
  stage: deploy
  parallel:
    matrix:
      - SERVICE: [api, frontend, worker, scheduler]
  script:
    - deploy-service.sh $SERVICE
  environment:
    name: production/$SERVICE
```

### 3. Pipeline Efficiency
```yaml
# Fast feedback pipeline
.fast-feedback: &fast-feedback
  interruptible: true
  timeout: 10m

quick-tests:
  <<: *fast-feedback
  stage: validate
  script:
    - npm run test:quick
  only:
    - merge_requests

# Resource optimization
resource-optimized:
  stage: build
  image: node:16-alpine  # Smaller image
  before_script:
    - apk add --no-cache git  # Only install what's needed
  script:
    - npm ci --production  # Production dependencies only
  cache:
    key: prod-deps-$CI_COMMIT_REF_SLUG
    paths:
      - node_modules/
```

## Advanced Deployment Patterns

### 1. Blue-Green Deployment
```yaml
# Blue-Green deployment strategy
deploy-blue:
  stage: deploy
  script:
    - deploy-to-blue-environment.sh
    - run-health-checks.sh blue
  environment:
    name: production-blue
    url: https://blue.example.com

switch-traffic:
  stage: deploy
  script:
    - switch-load-balancer-to-blue.sh
    - verify-traffic-switch.sh
  environment:
    name: production
    url: https://example.com
  when: manual
  needs:
    - deploy-blue

cleanup-green:
  stage: post-deploy
  script:
    - cleanup-green-environment.sh
  when: manual
  needs:
    - switch-traffic
```

### 2. Canary Deployment
```yaml
# Canary deployment with traffic splitting
deploy-canary:
  stage: deploy
  script:
    - deploy-canary-version.sh
    - configure-traffic-split.sh 10  # 10% traffic
  environment:
    name: production-canary
  when: manual

monitor-canary:
  stage: deploy
  script:
    - monitor-canary-metrics.sh
    - validate-error-rates.sh
  needs:
    - deploy-canary

promote-canary:
  stage: deploy
  script:
    - configure-traffic-split.sh 100  # Full traffic
    - cleanup-old-version.sh
  environment:
    name: production
  when: manual
  needs:
    - monitor-canary

rollback-canary:
  stage: deploy
  script:
    - configure-traffic-split.sh 0   # Remove canary traffic
    - cleanup-canary-version.sh
  when: manual
  needs:
    - deploy-canary
```

### 3. Rolling Deployment
```yaml
# Rolling deployment across multiple instances
deploy-rolling:
  stage: deploy
  parallel: 3
  script:
    - INSTANCE_GROUP=$((CI_NODE_INDEX + 1))
    - deploy-to-instance-group.sh $INSTANCE_GROUP
    - wait-for-health-check.sh $INSTANCE_GROUP
  environment:
    name: production
```

## Pipeline as Code Best Practices

### 1. Modular Pipeline Structure
```yaml
# .gitlab-ci.yml - Main pipeline
include:
  - local: '/.gitlab/ci/variables.yml'
  - local: '/.gitlab/ci/build.yml'
  - local: '/.gitlab/ci/test.yml'
  - local: '/.gitlab/ci/security.yml'
  - local: '/.gitlab/ci/deploy.yml'

stages:
  - validate
  - build
  - test
  - security
  - deploy
```

```yaml
# .gitlab/ci/build.yml - Build jobs
.build-template: &build-template
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY

build-frontend:
  <<: *build-template
  script:
    - docker build -f frontend/Dockerfile -t $CI_REGISTRY_IMAGE/frontend:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE/frontend:$CI_COMMIT_SHA

build-backend:
  <<: *build-template
  script:
    - docker build -f backend/Dockerfile -t $CI_REGISTRY_IMAGE/backend:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE/backend:$CI_COMMIT_SHA
```

### 2. Reusable Job Templates
```yaml
# .gitlab/ci/templates.yml
.test-template: &test-template
  stage: test
  before_script:
    - setup-test-environment.sh
  after_script:
    - cleanup-test-environment.sh
  artifacts:
    reports:
      junit: test-results.xml
    when: always

.deploy-template: &deploy-template
  stage: deploy
  image: alpine/helm:latest
  before_script:
    - setup-kubectl.sh
    - setup-helm.sh
  script:
    - helm upgrade --install $SERVICE_NAME ./helm-chart
  environment:
    name: $ENVIRONMENT_NAME
    url: https://$SERVICE_NAME.$ENVIRONMENT_NAME.example.com

# Usage in main pipeline
unit-tests:
  <<: *test-template
  script:
    - npm run test:unit

integration-tests:
  <<: *test-template
  script:
    - npm run test:integration

deploy-staging:
  <<: *deploy-template
  variables:
    SERVICE_NAME: myapp
    ENVIRONMENT_NAME: staging
```

### 3. Dynamic Pipeline Generation
```ruby
# generate-pipeline.rb
require 'yaml'

services = %w[api frontend worker scheduler]
environments = %w[staging production]

pipeline = {
  'stages' => ['build', 'test', 'deploy'],
  'variables' => {
    'DOCKER_DRIVER' => 'overlay2'
  }
}

services.each do |service|
  # Build jobs
  pipeline["build-#{service}"] = {
    'stage' => 'build',
    'script' => ["docker build -t $CI_REGISTRY_IMAGE/#{service}:$CI_COMMIT_SHA ./#{service}"]
  }
  
  # Test jobs
  pipeline["test-#{service}"] = {
    'stage' => 'test',
    'script' => ["cd #{service} && npm test"]
  }
  
  # Deploy jobs
  environments.each do |env|
    pipeline["deploy-#{service}-#{env}"] = {
      'stage' => 'deploy',
      'script' => ["deploy-service.sh #{service} #{env}"],
      'environment' => {
        'name' => "#{env}/#{service}"
      }
    }
  end
end

puts pipeline.to_yaml
```

## Advanced Pipeline Features

### 1. Pipeline Schedules and Triggers
```yaml
# Scheduled maintenance pipeline
maintenance:
  stage: deploy
  script:
    - run-database-maintenance.sh
    - cleanup-old-artifacts.sh
    - update-security-patches.sh
  only:
    - schedules
  variables:
    MAINTENANCE_MODE: "true"

# API triggered pipeline
api-deployment:
  stage: deploy
  script:
    - deploy-from-api-trigger.sh
  only:
    - triggers
  variables:
    TRIGGER_SOURCE: "api"
```

### 2. Pipeline Artifacts and Reports
```yaml
# Comprehensive artifact collection
collect-artifacts:
  stage: build
  script:
    - build-application.sh
    - generate-documentation.sh
    - create-deployment-package.sh
  artifacts:
    name: "build-$CI_COMMIT_SHORT_SHA"
    paths:
      - dist/
      - docs/
      - deployment-package.tar.gz
    reports:
      junit: test-results.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
      performance: performance-report.json
      load_performance: load-performance-report.json
    expire_in: 1 month
```

### 3. Pipeline Monitoring and Notifications
```yaml
# Pipeline monitoring
monitor-pipeline:
  stage: post-deploy
  script:
    - send-pipeline-metrics.sh
    - update-deployment-dashboard.sh
  after_script:
    - notify-teams.sh "Pipeline completed successfully"

# Failure notifications
notify-on-failure:
  stage: .post
  script:
    - send-failure-notification.sh
  when: on_failure
  variables:
    NOTIFICATION_CHANNEL: "#devops-alerts"
```

## Performance Optimization

### 1. Pipeline Speed Optimization
```yaml
# Optimized Docker builds
build-optimized:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  variables:
    DOCKER_BUILDKIT: 1
  script:
    - docker build --cache-from $CI_REGISTRY_IMAGE:cache -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - docker tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA $CI_REGISTRY_IMAGE:cache
    - docker push $CI_REGISTRY_IMAGE:cache
```

### 2. Resource Management
```yaml
# Resource-aware job configuration
resource-intensive-job:
  stage: build
  tags:
    - high-memory
    - ssd-storage
  variables:
    MAVEN_OPTS: "-Xmx4g -XX:+UseG1GC"
  script:
    - mvn clean package -DskipTests
  timeout: 30m
  retry:
    max: 2
    when:
      - runner_system_failure
      - stuck_or_timeout_failure
```

## Troubleshooting Advanced Pipelines

### 1. Pipeline Debugging
```yaml
debug-pipeline:
  stage: .pre
  script:
    - echo "=== Environment Variables ==="
    - env | grep CI_ | sort
    - echo "=== Git Information ==="
    - git log --oneline -5
    - echo "=== System Information ==="
    - uname -a
    - df -h
  artifacts:
    paths:
      - debug-info.txt
    when: always
```

### 2. Performance Analysis
```yaml
analyze-performance:
  stage: .post
  script:
    - analyze-pipeline-performance.sh
    - generate-performance-report.sh
  artifacts:
    reports:
      performance: pipeline-performance.json
  when: always
```

## Next Steps

After mastering advanced CI/CD:
1. Learn GitLab Runner management and scaling
2. Explore container registry and package management
3. Implement comprehensive security scanning
4. Study GitLab API automation

---
*Advanced CI/CD patterns enable sophisticated deployment strategies and optimized development workflows.*