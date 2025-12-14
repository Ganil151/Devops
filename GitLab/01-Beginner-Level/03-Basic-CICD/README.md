# Basic CI/CD with GitLab

## Introduction to CI/CD

### What is CI/CD?

**Continuous Integration (CI)**
- Automatically build and test code changes
- Detect integration issues early
- Maintain code quality standards

**Continuous Deployment (CD)**
- Automatically deploy tested code
- Reduce manual deployment errors
- Enable faster release cycles

### GitLab CI/CD Benefits
- Integrated with GitLab repositories
- No external tools required
- Scalable with GitLab Runners
- Extensive ecosystem support

## GitLab CI/CD Architecture

### Core Components

1. **GitLab CI/CD Pipeline**
   - Defined in `.gitlab-ci.yml`
   - Triggered by Git events
   - Consists of stages and jobs

2. **GitLab Runner**
   - Executes pipeline jobs
   - Can run on various platforms
   - Supports multiple executors

3. **Artifacts and Cache**
   - Store build outputs
   - Share data between jobs
   - Improve pipeline performance

## .gitlab-ci.yml Configuration

### Basic Structure
```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - deploy

variables:
  NODE_VERSION: "16"

before_script:
  - echo "Starting pipeline"

after_script:
  - echo "Pipeline completed"

build_job:
  stage: build
  script:
    - echo "Building application"
    - npm install
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour

test_job:
  stage: test
  script:
    - echo "Running tests"
    - npm test
  dependencies:
    - build_job

deploy_job:
  stage: deploy
  script:
    - echo "Deploying application"
    - ./deploy.sh
  only:
    - main
```

### Key Concepts

#### 1. Stages
```yaml
stages:
  - build      # Compile/build code
  - test       # Run tests
  - security   # Security scans
  - deploy     # Deploy application
```

#### 2. Jobs
```yaml
job_name:
  stage: build
  script:
    - command1
    - command2
  tags:
    - docker
  only:
    - main
```

#### 3. Variables
```yaml
variables:
  DATABASE_URL: "postgresql://localhost/myapp"
  DOCKER_DRIVER: overlay2
  
job_with_variables:
  script:
    - echo $DATABASE_URL
  variables:
    LOCAL_VAR: "job-specific value"
```

## Basic Pipeline Examples

### 1. Node.js Application
```yaml
# .gitlab-ci.yml for Node.js
image: node:16

stages:
  - install
  - test
  - build
  - deploy

cache:
  paths:
    - node_modules/

install_dependencies:
  stage: install
  script:
    - npm ci
  artifacts:
    paths:
      - node_modules/
    expire_in: 1 hour

run_tests:
  stage: test
  script:
    - npm test
  coverage: '/Lines\s*:\s*(\d+\.\d+)%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

build_application:
  stage: build
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week

deploy_staging:
  stage: deploy
  script:
    - echo "Deploying to staging"
    - rsync -av dist/ user@staging-server:/var/www/
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

deploy_production:
  stage: deploy
  script:
    - echo "Deploying to production"
    - rsync -av dist/ user@prod-server:/var/www/
  environment:
    name: production
    url: https://example.com
  only:
    - main
  when: manual
```

### 2. Python Application
```yaml
# .gitlab-ci.yml for Python
image: python:3.9

stages:
  - test
  - build
  - deploy

variables:
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip"

cache:
  paths:
    - .cache/pip/
    - venv/

before_script:
  - python -V
  - pip install virtualenv
  - virtualenv venv
  - source venv/bin/activate
  - pip install -r requirements.txt

test:
  stage: test
  script:
    - python -m pytest tests/ --cov=src/
    - flake8 src/
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml

build:
  stage: build
  script:
    - python setup.py bdist_wheel
  artifacts:
    paths:
      - dist/
    expire_in: 1 week

deploy:
  stage: deploy
  script:
    - pip install twine
    - twine upload dist/*
  only:
    - tags
```

### 3. Docker Application
```yaml
# .gitlab-ci.yml for Docker
image: docker:latest

services:
  - docker:dind

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"

stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  only:
    - main
    - develop

test:
  stage: test
  script:
    - docker pull $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - docker run --rm $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA npm test

deploy:
  stage: deploy
  script:
    - docker pull $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - docker tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA $CI_REGISTRY_IMAGE:latest
    - docker push $CI_REGISTRY_IMAGE:latest
  only:
    - main
```

## Jobs Configuration

### 1. Job Control
```yaml
job_name:
  stage: test
  script:
    - echo "Running job"
  
  # When to run
  only:
    - main
    - develop
  except:
    - tags
  
  # Manual trigger
  when: manual
  
  # Allow failure
  allow_failure: true
  
  # Retry on failure
  retry: 2
  
  # Timeout
  timeout: 30m
```

### 2. Conditional Jobs
```yaml
# Run only on specific branches
production_deploy:
  script:
    - deploy_to_production.sh
  only:
    - main

# Run only on tags
release_build:
  script:
    - build_release.sh
  only:
    - tags

# Run only on merge requests
mr_tests:
  script:
    - run_mr_tests.sh
  only:
    - merge_requests

# Run based on file changes
frontend_tests:
  script:
    - npm test
  only:
    changes:
      - "frontend/**/*"
      - "package.json"
```

### 3. Parallel Jobs
```yaml
test:
  stage: test
  parallel: 3
  script:
    - echo "Running parallel test $CI_NODE_INDEX of $CI_NODE_TOTAL"
    - npm test -- --shard=$CI_NODE_INDEX/$CI_NODE_TOTAL

# Matrix jobs
test_matrix:
  stage: test
  parallel:
    matrix:
      - NODE_VERSION: ["14", "16", "18"]
        OS: ["ubuntu", "alpine"]
  script:
    - echo "Testing Node $NODE_VERSION on $OS"
```

## Artifacts and Dependencies

### 1. Artifacts
```yaml
build:
  script:
    - make build
  artifacts:
    # Paths to store
    paths:
      - binaries/
      - dist/
    
    # Expiration time
    expire_in: 1 week
    
    # When to collect
    when: on_success  # on_failure, always
    
    # Reports
    reports:
      junit: test-results.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
```

### 2. Dependencies
```yaml
test:
  stage: test
  script:
    - run_tests.sh
  dependencies:
    - build  # Only download artifacts from build job

deploy:
  stage: deploy
  script:
    - deploy.sh
  needs:
    - job: build
      artifacts: true
    - job: test
      artifacts: false
```

### 3. Cache
```yaml
# Global cache
cache:
  key: "$CI_COMMIT_REF_SLUG"
  paths:
    - node_modules/
    - .npm/

# Job-specific cache
job_with_cache:
  cache:
    key: "job-cache-$CI_COMMIT_REF_SLUG"
    paths:
      - vendor/
    policy: pull-push  # pull, push
```

## Environment and Deployments

### 1. Environment Configuration
```yaml
deploy_staging:
  stage: deploy
  script:
    - deploy_to_staging.sh
  environment:
    name: staging
    url: https://staging.example.com
    on_stop: stop_staging

deploy_production:
  stage: deploy
  script:
    - deploy_to_production.sh
  environment:
    name: production
    url: https://example.com
  when: manual
  only:
    - main

stop_staging:
  stage: deploy
  script:
    - stop_staging_environment.sh
  environment:
    name: staging
    action: stop
  when: manual
```

### 2. Dynamic Environments
```yaml
deploy_review:
  stage: deploy
  script:
    - deploy_review_app.sh
  environment:
    name: review/$CI_COMMIT_REF_NAME
    url: https://$CI_COMMIT_REF_SLUG.review.example.com
    on_stop: stop_review
  only:
    - merge_requests

stop_review:
  stage: deploy
  script:
    - stop_review_app.sh
  environment:
    name: review/$CI_COMMIT_REF_NAME
    action: stop
  when: manual
  only:
    - merge_requests
```

## GitLab Runner Setup

### 1. Install GitLab Runner
```bash
# Linux installation
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
sudo apt-get install gitlab-runner

# Register runner
sudo gitlab-runner register \
  --url "https://gitlab.example.com/" \
  --registration-token "your-token" \
  --description "my-runner" \
  --tag-list "docker,linux" \
  --executor "docker" \
  --docker-image "alpine:latest"
```

### 2. Runner Configuration
```toml
# /etc/gitlab-runner/config.toml
concurrent = 4
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "docker-runner"
  url = "https://gitlab.example.com/"
  token = "runner-token"
  executor = "docker"
  [runners.custom_build_dir]
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = false
    image = "alpine:latest"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache"]
    shm_size = 0
```

## Pipeline Triggers

### 1. Automatic Triggers
```yaml
# Triggered by:
- Push to repository
- Merge request creation/update
- Tag creation
- Scheduled pipelines
- API calls
- Upstream pipeline completion
```

### 2. Manual Triggers
```yaml
manual_job:
  stage: deploy
  script:
    - echo "Manual deployment"
  when: manual
  allow_failure: false
```

### 3. Scheduled Pipelines
```bash
# Create schedule via UI:
# Project → CI/CD → Schedules → New schedule

# Cron expression examples:
0 2 * * *     # Daily at 2 AM
0 0 * * 0     # Weekly on Sunday
0 0 1 * *     # Monthly on 1st day
```

## Best Practices

### 1. Pipeline Design
```yaml
# Keep pipelines fast
- Use cache effectively
- Parallelize jobs when possible
- Fail fast with early validation
- Use appropriate Docker images

# Example optimized pipeline
stages:
  - validate
  - build
  - test
  - deploy

validate:
  stage: validate
  script:
    - lint_code.sh
    - check_formatting.sh
  cache:
    key: lint-cache
    paths:
      - .lint-cache/
```

### 2. Security Considerations
```yaml
# Use protected variables for secrets
variables:
  DATABASE_URL: $DATABASE_URL  # Protected variable

# Mask sensitive output
script:
  - echo "Deploying with key: [MASKED]"

# Use specific Docker images
image: node:16.14.2-alpine  # Specific version
```

### 3. Debugging Pipelines
```yaml
debug_job:
  script:
    - echo "Debug information"
    - env | sort
    - pwd
    - ls -la
  artifacts:
    paths:
      - debug-info.txt
    when: on_failure
```

## Common Pipeline Patterns

### 1. Multi-stage Build
```yaml
stages:
  - build
  - test
  - security
  - deploy

build:
  stage: build
  script:
    - docker build -t app:$CI_COMMIT_SHA .

unit_tests:
  stage: test
  script:
    - docker run app:$CI_COMMIT_SHA npm test

integration_tests:
  stage: test
  script:
    - docker-compose up -d
    - docker run app:$CI_COMMIT_SHA npm run test:integration

security_scan:
  stage: security
  script:
    - docker run --rm -v $(pwd):/app security-scanner /app
```

### 2. Feature Branch Workflow
```yaml
# Different jobs for different branches
test_feature:
  script:
    - npm test
  only:
    - branches
  except:
    - main

deploy_staging:
  script:
    - deploy_to_staging.sh
  only:
    - develop

deploy_production:
  script:
    - deploy_to_production.sh
  only:
    - main
  when: manual
```

## Troubleshooting

### 1. Common Issues
```bash
# Job fails to start
- Check runner availability
- Verify Docker image exists
- Check resource limits

# Slow pipelines
- Optimize Docker images
- Use cache effectively
- Parallelize jobs
- Use faster runners
```

### 2. Debugging Commands
```yaml
debug_environment:
  script:
    - echo "CI_COMMIT_SHA: $CI_COMMIT_SHA"
    - echo "CI_COMMIT_REF_NAME: $CI_COMMIT_REF_NAME"
    - echo "CI_PROJECT_PATH: $CI_PROJECT_PATH"
    - printenv | grep CI_
```

## Next Steps

After mastering basic CI/CD:
1. Learn advanced pipeline configurations
2. Explore GitLab Runner management
3. Implement security scanning
4. Study deployment strategies

---
*CI/CD automation is essential for modern software development.*