# Ansible CI/CD Integration

Comprehensive guide to integrating Ansible with CI/CD pipelines, automated testing, and deployment workflows.

## CI/CD Fundamentals with Ansible

### Integration Benefits
- **Automated Deployments**: Consistent, repeatable deployments
- **Infrastructure as Code**: Version-controlled infrastructure changes
- **Testing Integration**: Automated testing of configurations
- **Rollback Capabilities**: Quick recovery from failed deployments
- **Multi-Environment Support**: Seamless promotion across environments

### CI/CD Pipeline Stages
```yaml
pipeline_stages:
  1_source: "Code checkout and validation"
  2_build: "Ansible syntax checking and linting"
  3_test: "Molecule testing and validation"
  4_security: "Security scanning and compliance checks"
  5_deploy_dev: "Development environment deployment"
  6_test_integration: "Integration and functional testing"
  7_deploy_staging: "Staging environment deployment"
  8_test_acceptance: "User acceptance testing"
  9_deploy_production: "Production deployment"
  10_monitor: "Post-deployment monitoring and validation"
```

## Jenkins Integration

### Jenkins Pipeline Configuration
```groovy
// Jenkinsfile
pipeline {
    agent any
    
    environment {
        ANSIBLE_HOST_KEY_CHECKING = 'False'
        ANSIBLE_VAULT_PASSWORD_FILE = credentials('ansible-vault-password')
        ANSIBLE_CONFIG = "${WORKSPACE}/ansible.cfg"
    }
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['development', 'staging', 'production'],
            description: 'Target environment for deployment'
        )
        string(
            name: 'APP_VERSION',
            defaultValue: 'latest',
            description: 'Application version to deploy'
        )
        booleanParam(
            name: 'DRY_RUN',
            defaultValue: false,
            description: 'Perform dry run without making changes'
        )
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: "git rev-parse --short HEAD",
                        returnStdout: true
                    ).trim()
                }
            }
        }
        
        stage('Validate') {
            parallel {
                stage('Syntax Check') {
                    steps {
                        sh '''
                            ansible-playbook --syntax-check site.yml
                            ansible-playbook --syntax-check -i inventories/${ENVIRONMENT} deploy.yml
                        '''
                    }
                }
                
                stage('Lint') {
                    steps {
                        sh '''
                            ansible-lint site.yml
                            ansible-lint roles/
                        '''
                    }
                }
                
                stage('Security Scan') {
                    steps {
                        sh '''
                            # Scan for secrets in code
                            trufflehog --regex --entropy=False .
                            
                            # Ansible security scanning
                            ansible-playbook --check security-audit.yml
                        '''
                    }
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    def roles = sh(
                        script: "find roles/ -maxdepth 1 -type d -name '*' | grep -v '^roles/\$'",
                        returnStdout: true
                    ).trim().split('\n')
                    
                    def parallelTests = [:]
                    
                    roles.each { role ->
                        def roleName = role.split('/')[1]
                        parallelTests[roleName] = {
                            dir(role) {
                                sh "molecule test"
                            }
                        }
                    }
                    
                    parallel parallelTests
                }
            }
        }
        
        stage('Deploy') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                    expression { params.ENVIRONMENT != 'production' || env.BRANCH_NAME == 'main' }
                }
            }
            steps {
                script {
                    def dryRunFlag = params.DRY_RUN ? '--check' : ''
                    
                    sh """
                        ansible-playbook \\
                            -i inventories/${params.ENVIRONMENT} \\
                            ${dryRunFlag} \\
                            --extra-vars "app_version=${params.APP_VERSION}" \\
                            --extra-vars "git_commit=${env.GIT_COMMIT_SHORT}" \\
                            deploy.yml
                    """
                }
            }
        }
        
        stage('Integration Tests') {
            when {
                not { params.DRY_RUN }
            }
            steps {
                sh """
                    ansible-playbook \\
                        -i inventories/${params.ENVIRONMENT} \\
                        tests/integration-tests.yml
                """
            }
        }
        
        stage('Smoke Tests') {
            when {
                not { params.DRY_RUN }
            }
            steps {
                sh """
                    ansible-playbook \\
                        -i inventories/${params.ENVIRONMENT} \\
                        tests/smoke-tests.yml
                """
            }
        }
    }
    
    post {
        always {
            // Archive logs and reports
            archiveArtifacts artifacts: 'logs/**/*', allowEmptyArchive: true
            
            // Publish test results
            publishTestResults testResultsPattern: 'molecule/**/junit.xml'
            
            // Clean workspace
            cleanWs()
        }
        
        success {
            script {
                if (params.ENVIRONMENT == 'production' && !params.DRY_RUN) {
                    // Notify success
                    slackSend(
                        channel: '#deployments',
                        color: 'good',
                        message: "✅ Production deployment successful: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
                    )
                }
            }
        }
        
        failure {
            // Notify failure
            slackSend(
                channel: '#deployments',
                color: 'danger',
                message: "❌ Deployment failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            )
            
            // Trigger rollback for production
            script {
                if (params.ENVIRONMENT == 'production' && !params.DRY_RUN) {
                    build job: 'rollback-production', parameters: [
                        string(name: 'ROLLBACK_VERSION', value: 'previous')
                    ]
                }
            }
        }
    }
}
```

### Jenkins Shared Library
```groovy
// vars/deployWithAnsible.groovy
def call(Map config) {
    pipeline {
        agent any
        
        environment {
            ANSIBLE_HOST_KEY_CHECKING = 'False'
            ANSIBLE_VAULT_PASSWORD_FILE = credentials('ansible-vault-password')
        }
        
        stages {
            stage('Deploy') {
                steps {
                    script {
                        def inventory = config.inventory ?: "inventories/${config.environment}"
                        def playbook = config.playbook ?: 'deploy.yml'
                        def extraVars = config.extraVars ?: [:]
                        
                        def extraVarsString = extraVars.collect { k, v -> 
                            "${k}=${v}" 
                        }.join(' ')
                        
                        sh """
                            ansible-playbook \\
                                -i ${inventory} \\
                                --extra-vars "${extraVarsString}" \\
                                ${playbook}
                        """
                    }
                }
            }
        }
    }
}

// Usage in Jenkinsfile
deployWithAnsible([
    environment: 'production',
    playbook: 'site.yml',
    extraVars: [
        app_version: '1.2.3',
        deployment_id: env.BUILD_NUMBER
    ]
])
```

## GitLab CI Integration

### GitLab CI Configuration
```yaml
# .gitlab-ci.yml
stages:
  - validate
  - test
  - security
  - deploy-dev
  - test-integration
  - deploy-staging
  - deploy-production

variables:
  ANSIBLE_HOST_KEY_CHECKING: "False"
  ANSIBLE_FORCE_COLOR: "true"

# Base template for Ansible jobs
.ansible_base: &ansible_base
  image: ansible/ansible-runner:latest
  before_script:
    - echo "$VAULT_PASSWORD" > .vault_pass
    - chmod 600 .vault_pass
    - export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass
  after_script:
    - rm -f .vault_pass

# Validation stage
syntax_check:
  <<: *ansible_base
  stage: validate
  script:
    - ansible-playbook --syntax-check site.yml
    - ansible-playbook --syntax-check deploy.yml
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

ansible_lint:
  <<: *ansible_base
  stage: validate
  script:
    - pip install ansible-lint
    - ansible-lint site.yml
    - ansible-lint roles/
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

# Testing stage
molecule_test:
  <<: *ansible_base
  stage: test
  script:
    - pip install molecule[docker]
    - cd roles/webserver && molecule test
    - cd ../database && molecule test
  services:
    - docker:dind
  variables:
    DOCKER_HOST: tcp://docker:2376
    DOCKER_TLS_CERTDIR: "/certs"
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

# Security scanning
security_scan:
  image: securecodewarrior/docker-ansible-security:latest
  stage: security
  script:
    - ansible-playbook --check security-audit.yml
    - bandit -r roles/ -f json -o security-report.json
  artifacts:
    reports:
      security: security-report.json
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

# Development deployment
deploy_development:
  <<: *ansible_base
  stage: deploy-dev
  script:
    - ansible-playbook -i inventories/development deploy.yml
      --extra-vars "app_version=$CI_COMMIT_SHORT_SHA"
      --extra-vars "deployment_id=$CI_PIPELINE_ID"
  environment:
    name: development
    url: https://dev.example.com
  rules:
    - if: $CI_COMMIT_BRANCH == "develop"

# Integration testing
integration_tests:
  <<: *ansible_base
  stage: test-integration
  script:
    - ansible-playbook -i inventories/development tests/integration-tests.yml
  dependencies:
    - deploy_development
  rules:
    - if: $CI_COMMIT_BRANCH == "develop"

# Staging deployment
deploy_staging:
  <<: *ansible_base
  stage: deploy-staging
  script:
    - ansible-playbook -i inventories/staging deploy.yml
      --extra-vars "app_version=$CI_COMMIT_SHORT_SHA"
      --extra-vars "deployment_id=$CI_PIPELINE_ID"
  environment:
    name: staging
    url: https://staging.example.com
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
  when: manual

# Production deployment
deploy_production:
  <<: *ansible_base
  stage: deploy-production
  script:
    - ansible-playbook -i inventories/production deploy.yml
      --extra-vars "app_version=$APP_VERSION"
      --extra-vars "deployment_id=$CI_PIPELINE_ID"
  environment:
    name: production
    url: https://example.com
  rules:
    - if: $CI_COMMIT_TAG
  when: manual
  variables:
    APP_VERSION: $CI_COMMIT_TAG
```

### GitLab CI Templates
```yaml
# .gitlab/ci/ansible.yml - Reusable templates
.ansible_deploy_template:
  image: ansible/ansible-runner:latest
  before_script:
    - echo "$VAULT_PASSWORD" > .vault_pass
    - chmod 600 .vault_pass
    - export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass
  script:
    - ansible-playbook -i inventories/$ENVIRONMENT deploy.yml
      --extra-vars "app_version=$APP_VERSION"
      --extra-vars "environment=$ENVIRONMENT"
      --extra-vars "deployment_id=$CI_PIPELINE_ID"
  after_script:
    - rm -f .vault_pass
  artifacts:
    reports:
      deployment: deployment-report.json
    paths:
      - logs/
    expire_in: 1 week

# Include in main .gitlab-ci.yml
include:
  - local: '.gitlab/ci/ansible.yml'

deploy_to_staging:
  extends: .ansible_deploy_template
  stage: deploy-staging
  variables:
    ENVIRONMENT: staging
    APP_VERSION: $CI_COMMIT_SHORT_SHA
  environment:
    name: staging
    url: https://staging.example.com
```

## GitHub Actions Integration

### GitHub Actions Workflow
```yaml
# .github/workflows/deploy.yml
name: Deploy with Ansible

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  release:
    types: [published]

env:
  ANSIBLE_HOST_KEY_CHECKING: False
  ANSIBLE_FORCE_COLOR: true

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install Ansible
        run: |
          pip install ansible ansible-lint
      
      - name: Syntax check
        run: |
          ansible-playbook --syntax-check site.yml
          ansible-playbook --syntax-check deploy.yml
      
      - name: Lint Ansible
        run: |
          ansible-lint site.yml
          ansible-lint roles/

  test:
    runs-on: ubuntu-latest
    needs: validate
    strategy:
      matrix:
        role: [webserver, database, monitoring]
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        run: |
          pip install molecule[docker] ansible
      
      - name: Test role with Molecule
        run: |
          cd roles/${{ matrix.role }}
          molecule test

  security:
    runs-on: ubuntu-latest
    needs: validate
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Run security scan
        uses: securecodewarrior/github-action-ansible-security@v1
        with:
          playbook: security-audit.yml
      
      - name: Upload security results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: security-results.sarif

  deploy-dev:
    runs-on: ubuntu-latest
    needs: [validate, test]
    if: github.ref == 'refs/heads/develop'
    environment: development
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Deploy to development
        uses: dawidd6/action-ansible-playbook@v2
        with:
          playbook: deploy.yml
          directory: ./
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          inventory: inventories/development
          vault_password: ${{ secrets.VAULT_PASSWORD }}
          options: |
            --extra-vars "app_version=${{ github.sha }}"
            --extra-vars "deployment_id=${{ github.run_number }}"

  deploy-staging:
    runs-on: ubuntu-latest
    needs: [validate, test, security]
    if: github.ref == 'refs/heads/main'
    environment: staging
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Deploy to staging
        uses: dawidd6/action-ansible-playbook@v2
        with:
          playbook: deploy.yml
          directory: ./
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          inventory: inventories/staging
          vault_password: ${{ secrets.VAULT_PASSWORD }}
          options: |
            --extra-vars "app_version=${{ github.sha }}"
            --extra-vars "deployment_id=${{ github.run_number }}"

  deploy-production:
    runs-on: ubuntu-latest
    needs: [validate, test, security]
    if: github.event_name == 'release'
    environment: production
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Deploy to production
        uses: dawidd6/action-ansible-playbook@v2
        with:
          playbook: deploy.yml
          directory: ./
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          inventory: inventories/production
          vault_password: ${{ secrets.VAULT_PASSWORD }}
          options: |
            --extra-vars "app_version=${{ github.event.release.tag_name }}"
            --extra-vars "deployment_id=${{ github.run_number }}"
      
      - name: Post-deployment tests
        uses: dawidd6/action-ansible-playbook@v2
        with:
          playbook: tests/smoke-tests.yml
          directory: ./
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          inventory: inventories/production
          vault_password: ${{ secrets.VAULT_PASSWORD }}
```

### Reusable GitHub Actions
```yaml
# .github/actions/ansible-deploy/action.yml
name: 'Ansible Deploy'
description: 'Deploy using Ansible playbook'
inputs:
  environment:
    description: 'Target environment'
    required: true
  app_version:
    description: 'Application version'
    required: true
  playbook:
    description: 'Playbook to run'
    required: false
    default: 'deploy.yml'
  ssh_key:
    description: 'SSH private key'
    required: true
  vault_password:
    description: 'Ansible vault password'
    required: true

runs:
  using: 'composite'
  steps:
    - name: Setup Ansible
      shell: bash
      run: |
        pip install ansible
    
    - name: Create SSH key file
      shell: bash
      run: |
        echo "${{ inputs.ssh_key }}" > ~/.ssh/ansible_key
        chmod 600 ~/.ssh/ansible_key
    
    - name: Create vault password file
      shell: bash
      run: |
        echo "${{ inputs.vault_password }}" > .vault_pass
        chmod 600 .vault_pass
    
    - name: Run Ansible playbook
      shell: bash
      run: |
        ansible-playbook \
          -i inventories/${{ inputs.environment }} \
          --vault-password-file .vault_pass \
          --private-key ~/.ssh/ansible_key \
          --extra-vars "app_version=${{ inputs.app_version }}" \
          --extra-vars "environment=${{ inputs.environment }}" \
          ${{ inputs.playbook }}
    
    - name: Cleanup
      shell: bash
      if: always()
      run: |
        rm -f ~/.ssh/ansible_key .vault_pass

# Usage in workflow
- name: Deploy to production
  uses: ./.github/actions/ansible-deploy
  with:
    environment: production
    app_version: ${{ github.event.release.tag_name }}
    ssh_key: ${{ secrets.SSH_PRIVATE_KEY }}
    vault_password: ${{ secrets.VAULT_PASSWORD }}
```

## Azure DevOps Integration

### Azure Pipelines Configuration
```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
      - develop
  tags:
    include:
      - v*

pr:
  branches:
    include:
      - main

variables:
  - group: ansible-secrets
  - name: ANSIBLE_HOST_KEY_CHECKING
    value: 'False'

stages:
  - stage: Validate
    displayName: 'Validate Ansible Code'
    jobs:
      - job: SyntaxCheck
        displayName: 'Syntax Check'
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: UsePythonVersion@0
            inputs:
              versionSpec: '3.9'
          
          - script: |
              pip install ansible ansible-lint
            displayName: 'Install Ansible'
          
          - script: |
              ansible-playbook --syntax-check site.yml
              ansible-playbook --syntax-check deploy.yml
            displayName: 'Syntax Check'
          
          - script: |
              ansible-lint site.yml
              ansible-lint roles/
            displayName: 'Lint Check'

  - stage: Test
    displayName: 'Test Ansible Roles'
    dependsOn: Validate
    jobs:
      - job: MoleculeTest
        displayName: 'Molecule Testing'
        pool:
          vmImage: 'ubuntu-latest'
        strategy:
          matrix:
            webserver:
              ROLE_NAME: webserver
            database:
              ROLE_NAME: database
        steps:
          - task: UsePythonVersion@0
            inputs:
              versionSpec: '3.9'
          
          - script: |
              pip install molecule[docker] ansible
            displayName: 'Install Dependencies'
          
          - script: |
              cd roles/$(ROLE_NAME)
              molecule test
            displayName: 'Test Role'

  - stage: DeployDev
    displayName: 'Deploy to Development'
    dependsOn: Test
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/develop'))
    jobs:
      - deployment: DeployToDev
        displayName: 'Deploy to Development'
        environment: 'development'
        pool:
          vmImage: 'ubuntu-latest'
        strategy:
          runOnce:
            deploy:
              steps:
                - checkout: self
                
                - task: UsePythonVersion@0
                  inputs:
                    versionSpec: '3.9'
                
                - script: |
                    pip install ansible
                  displayName: 'Install Ansible'
                
                - task: DownloadSecureFile@1
                  name: sshKey
                  displayName: 'Download SSH Key'
                  inputs:
                    secureFile: 'ansible_ssh_key'
                
                - script: |
                    echo "$(VAULT_PASSWORD)" > .vault_pass
                    chmod 600 .vault_pass
                    chmod 600 $(sshKey.secureFilePath)
                  displayName: 'Setup Credentials'
                
                - script: |
                    ansible-playbook \
                      -i inventories/development \
                      --vault-password-file .vault_pass \
                      --private-key $(sshKey.secureFilePath) \
                      --extra-vars "app_version=$(Build.SourceVersion)" \
                      deploy.yml
                  displayName: 'Deploy to Development'
                
                - script: |
                    rm -f .vault_pass
                  displayName: 'Cleanup'
                  condition: always()

  - stage: DeployProduction
    displayName: 'Deploy to Production'
    dependsOn: Test
    condition: and(succeeded(), startsWith(variables['Build.SourceBranch'], 'refs/tags/v'))
    jobs:
      - deployment: DeployToProd
        displayName: 'Deploy to Production'
        environment: 'production'
        pool:
          vmImage: 'ubuntu-latest'
        strategy:
          runOnce:
            deploy:
              steps:
                - checkout: self
                
                - task: UsePythonVersion@0
                  inputs:
                    versionSpec: '3.9'
                
                - script: |
                    pip install ansible
                  displayName: 'Install Ansible'
                
                - task: DownloadSecureFile@1
                  name: sshKey
                  displayName: 'Download SSH Key'
                  inputs:
                    secureFile: 'ansible_ssh_key'
                
                - script: |
                    echo "$(VAULT_PASSWORD)" > .vault_pass
                    chmod 600 .vault_pass
                    chmod 600 $(sshKey.secureFilePath)
                  displayName: 'Setup Credentials'
                
                - script: |
                    TAG_NAME=$(echo $(Build.SourceBranch) | sed 's/refs\/tags\///')
                    ansible-playbook \
                      -i inventories/production \
                      --vault-password-file .vault_pass \
                      --private-key $(sshKey.secureFilePath) \
                      --extra-vars "app_version=$TAG_NAME" \
                      deploy.yml
                  displayName: 'Deploy to Production'
                
                - script: |
                    ansible-playbook \
                      -i inventories/production \
                      --vault-password-file .vault_pass \
                      --private-key $(sshKey.secureFilePath) \
                      tests/smoke-tests.yml
                  displayName: 'Run Smoke Tests'
                
                - script: |
                    rm -f .vault_pass
                  displayName: 'Cleanup'
                  condition: always()
```

## Testing Integration

### Molecule Testing in CI/CD
```yaml
# molecule/default/molecule.yml
---
dependency:
  name: galaxy
driver:
  name: docker
platforms:
  - name: instance
    image: quay.io/ansible/molecule-ubuntu:18.04
    pre_build_image: true
provisioner:
  name: ansible
  config_options:
    defaults:
      callback_whitelist: profile_tasks,timer
verifier:
  name: ansible

# molecule/default/converge.yml
---
- name: Converge
  hosts: all
  become: true
  tasks:
    - name: Include role
      include_role:
        name: webserver
      vars:
        webserver_port: 8080
        ssl_enabled: false

# molecule/default/verify.yml
---
- name: Verify
  hosts: all
  gather_facts: false
  tasks:
    - name: Check if service is running
      service:
        name: nginx
        state: started
      check_mode: yes
      register: service_status
    
    - name: Verify service status
      assert:
        that:
          - service_status.state == "started"
        fail_msg: "Service is not running"
    
    - name: Test HTTP response
      uri:
        url: http://localhost:8080
        method: GET
        status_code: 200
      retries: 3
      delay: 5
```

### Integration Testing Playbooks
```yaml
# tests/integration-tests.yml
---
- name: Integration Tests
  hosts: all
  gather_facts: yes
  
  tasks:
    - name: Test web server response
      uri:
        url: "http://{{ ansible_default_ipv4.address }}"
        method: GET
        status_code: 200
        timeout: 10
      delegate_to: localhost
    
    - name: Test database connectivity
      mysql_db:
        name: testdb
        state: present
        login_host: "{{ ansible_default_ipv4.address }}"
        login_user: testuser
        login_password: testpass
      delegate_to: localhost
      when: "'databases' in group_names"
    
    - name: Test application health endpoint
      uri:
        url: "http://{{ ansible_default_ipv4.address }}:8080/health"
        method: GET
        status_code: 200
        return_content: yes
      register: health_check
      delegate_to: localhost
    
    - name: Verify health check response
      assert:
        that:
          - health_check.json.status == "healthy"
        fail_msg: "Application health check failed"
    
    - name: Test SSL certificate
      openssl_certificate:
        path: /etc/ssl/certs/server.crt
        provider: assertonly
        has_expired: false
        valid_in: 2592000  # 30 days
      when: ssl_enabled | default(false)

# tests/smoke-tests.yml
---
- name: Smoke Tests
  hosts: all
  gather_facts: no
  
  tasks:
    - name: Check critical services
      service:
        name: "{{ item }}"
        state: started
      check_mode: yes
      register: service_check
      loop: "{{ critical_services }}"
    
    - name: Verify all services are running
      assert:
        that:
          - item.state == "started"
        fail_msg: "Critical service {{ item.item }} is not running"
      loop: "{{ service_check.results }}"
    
    - name: Test external connectivity
      uri:
        url: "{{ external_health_check_url }}"
        method: GET
        status_code: 200
        timeout: 30
      delegate_to: localhost
      when: external_health_check_url is defined
```

## Deployment Strategies

### Blue-Green Deployment
```yaml
# deploy-blue-green.yml
---
- name: Blue-Green Deployment
  hosts: localhost
  gather_facts: no
  vars:
    current_color: "{{ 'blue' if active_environment == 'green' else 'green' }}"
    target_color: "{{ 'green' if active_environment == 'blue' else 'blue' }}"
  
  tasks:
    - name: Deploy to inactive environment
      include_tasks: deploy-to-environment.yml
      vars:
        target_environment: "{{ target_color }}"
        app_version: "{{ new_app_version }}"
    
    - name: Run health checks on new deployment
      uri:
        url: "http://{{ target_color }}.internal.example.com/health"
        method: GET
        status_code: 200
      retries: 10
      delay: 30
    
    - name: Switch load balancer to new environment
      uri:
        url: "http://loadbalancer.example.com/api/switch"
        method: POST
        body_format: json
        body:
          target: "{{ target_color }}"
      register: switch_result
    
    - name: Verify switch was successful
      assert:
        that:
          - switch_result.status == 200
        fail_msg: "Load balancer switch failed"
    
    - name: Update active environment marker
      set_fact:
        active_environment: "{{ target_color }}"
    
    - name: Wait for traffic to stabilize
      pause:
        seconds: 60
    
    - name: Final health check
      uri:
        url: "http://example.com/health"
        method: GET
        status_code: 200
      retries: 5
      delay: 10
```

### Rolling Deployment
```yaml
# deploy-rolling.yml
---
- name: Rolling Deployment
  hosts: webservers
  become: yes
  serial: 1  # Deploy to one server at a time
  max_fail_percentage: 0  # Stop on any failure
  
  pre_tasks:
    - name: Remove server from load balancer
      uri:
        url: "http://loadbalancer.example.com/api/remove"
        method: POST
        body_format: json
        body:
          server: "{{ inventory_hostname }}"
      delegate_to: localhost
    
    - name: Wait for connections to drain
      pause:
        seconds: 30
  
  tasks:
    - name: Stop application service
      service:
        name: myapp
        state: stopped
    
    - name: Deploy new application version
      copy:
        src: "app-{{ app_version }}.jar"
        dest: /opt/myapp/app.jar
        backup: yes
        owner: myapp
        group: myapp
        mode: '0644'
    
    - name: Update configuration
      template:
        src: app.conf.j2
        dest: /etc/myapp/app.conf
        owner: myapp
        group: myapp
        mode: '0644'
      notify: restart myapp
    
    - name: Start application service
      service:
        name: myapp
        state: started
    
    - name: Wait for application to be ready
      wait_for:
        port: 8080
        timeout: 120
    
    - name: Health check
      uri:
        url: "http://{{ ansible_default_ipv4.address }}:8080/health"
        method: GET
        status_code: 200
      retries: 10
      delay: 10
  
  post_tasks:
    - name: Add server back to load balancer
      uri:
        url: "http://loadbalancer.example.com/api/add"
        method: POST
        body_format: json
        body:
          server: "{{ inventory_hostname }}"
      delegate_to: localhost
    
    - name: Verify server is receiving traffic
      pause:
        seconds: 30
  
  handlers:
    - name: restart myapp
      service:
        name: myapp
        state: restarted
```

## Monitoring and Observability

### Deployment Monitoring
```yaml
# monitoring/deployment-monitoring.yml
---
- name: Deployment Monitoring Setup
  hosts: all
  become: yes
  
  tasks:
    - name: Install monitoring agents
      package:
        name: "{{ item }}"
        state: present
      loop:
        - prometheus-node-exporter
        - filebeat
        - metricbeat
    
    - name: Configure deployment metrics
      template:
        src: deployment-metrics.yml.j2
        dest: /etc/prometheus/deployment-metrics.yml
        owner: prometheus
        group: prometheus
        mode: '0644'
    
    - name: Create deployment log
      lineinfile:
        path: /var/log/deployments.log
        line: "{{ ansible_date_time.iso8601 }} - Deployment {{ deployment_id }} started by {{ ansible_user_id }}"
        create: yes
        owner: root
        group: root
        mode: '0644'
    
    - name: Send deployment notification
      uri:
        url: "{{ webhook_url }}"
        method: POST
        body_format: json
        body:
          text: "Deployment {{ deployment_id }} completed on {{ inventory_hostname }}"
          channel: "#deployments"
      delegate_to: localhost
      when: webhook_url is defined
```

This comprehensive CI/CD integration guide provides enterprise-ready patterns for automating Ansible deployments across different platforms and environments.