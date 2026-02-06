# Jenkins Pipelines

Complete guide to Jenkins Pipeline development, best practices, and advanced patterns for CI/CD automation.

## Pipeline Fundamentals

### Pipeline Types

#### Declarative Pipeline
```groovy
pipeline {
    agent any
    
    environment {
        APP_NAME = 'petclinic'
        APP_VERSION = '1.0.0'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/user/petclinic.git'
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
        
        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Package') {
            steps {
                sh 'mvn package'
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
```

#### Scripted Pipeline
```groovy
node {
    def app
    
    try {
        stage('Checkout') {
            checkout scm
        }
        
        stage('Build') {
            app = docker.build("petclinic:${env.BUILD_NUMBER}")
        }
        
        stage('Test') {
            app.inside {
                sh 'mvn test'
            }
        }
        
        stage('Deploy') {
            if (env.BRANCH_NAME == 'main') {
                app.push("latest")
                app.push("${env.BUILD_NUMBER}")
            }
        }
    } catch (Exception e) {
        currentBuild.result = 'FAILURE'
        throw e
    } finally {
        cleanWs()
    }
}
```

## Pipeline Components

### Agents
```groovy
pipeline {
    // Run on any available agent
    agent any
    
    // Run on specific label
    agent { label 'linux' }
    
    // Run in Docker container
    agent {
        docker {
            image 'maven:3.8.1-adoptopenjdk-11'
            args '-v /root/.m2:/root/.m2'
        }
    }
    
    // Run on Kubernetes
    agent {
        kubernetes {
            yaml """
                apiVersion: v1
                kind: Pod
                spec:
                  containers:
                  - name: maven
                    image: maven:3.8.1-adoptopenjdk-11
                    command:
                    - sleep
                    args:
                    - 99d
            """
        }
    }
    
    stages {
        stage('Build') {
            // Override agent for specific stage
            agent { docker 'node:16' }
            steps {
                sh 'npm install'
            }
        }
    }
}
```

### Environment Variables
```groovy
pipeline {
    agent any
    
    environment {
        // Global environment variables
        APP_NAME = 'petclinic'
        DOCKER_REGISTRY = 'registry.example.com'
        
        // Credentials
        DOCKER_CREDS = credentials('docker-registry-creds')
        AWS_CREDS = credentials('aws-credentials')
        
        // Dynamic variables
        BUILD_VERSION = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
    }
    
    stages {
        stage('Build') {
            environment {
                // Stage-specific environment
                MAVEN_OPTS = '-Xmx1024m'
            }
            steps {
                sh 'echo "Building ${APP_NAME} version ${BUILD_VERSION}"'
                sh 'mvn clean package -Dversion=${BUILD_VERSION}'
            }
        }
    }
}
```

### Parameters
```groovy
pipeline {
    agent any
    
    parameters {
        string(
            name: 'BRANCH_NAME',
            defaultValue: 'main',
            description: 'Branch to build'
        )
        
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'production'],
            description: 'Target environment'
        )
        
        booleanParam(
            name: 'SKIP_TESTS',
            defaultValue: false,
            description: 'Skip test execution'
        )
        
        text(
            name: 'RELEASE_NOTES',
            defaultValue: '',
            description: 'Release notes for deployment'
        )
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: "${params.BRANCH_NAME}", url: 'https://github.com/user/repo.git'
            }
        }
        
        stage('Test') {
            when {
                not { params.SKIP_TESTS }
            }
            steps {
                sh 'mvn test'
            }
        }
    }
}
```

### Triggers
```groovy
pipeline {
    agent any
    
    triggers {
        // Poll SCM every 5 minutes
        pollSCM('H/5 * * * *')
        
        // Cron schedule (daily at 2 AM)
        cron('0 2 * * *')
        
        // Upstream job trigger
        upstream(upstreamProjects: 'upstream-job', threshold: hudson.model.Result.SUCCESS)
    }
    
    stages {
        stage('Build') {
            steps {
                echo 'Building triggered job'
            }
        }
    }
}
```

## Advanced Pipeline Patterns

### Parallel Execution
```groovy
pipeline {
    agent any
    
    stages {
        stage('Parallel Tests') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'mvn test'
                    }
                }
                
                stage('Integration Tests') {
                    steps {
                        sh 'mvn integration-test'
                    }
                }
                
                stage('Security Scan') {
                    steps {
                        sh 'sonar-scanner'
                    }
                }
            }
        }
        
        stage('Parallel Deployment') {
            parallel {
                stage('Deploy to Dev') {
                    when {
                        branch 'develop'
                    }
                    steps {
                        sh 'kubectl apply -f k8s/dev/'
                    }
                }
                
                stage('Deploy to Staging') {
                    when {
                        branch 'main'
                    }
                    steps {
                        sh 'kubectl apply -f k8s/staging/'
                    }
                }
            }
        }
    }
}
```

### Matrix Builds
```groovy
pipeline {
    agent none
    
    stages {
        stage('Test') {
            matrix {
                axes {
                    axis {
                        name 'JAVA_VERSION'
                        values '11', '17', '21'
                    }
                    axis {
                        name 'OS'
                        values 'linux', 'windows'
                    }
                }
                excludes {
                    exclude {
                        axis {
                            name 'JAVA_VERSION'
                            values '21'
                        }
                        axis {
                            name 'OS'
                            values 'windows'
                        }
                    }
                }
                stages {
                    stage('Test') {
                        agent {
                            label "${OS}"
                        }
                        steps {
                            sh "java -version"
                            sh "mvn test -Djava.version=${JAVA_VERSION}"
                        }
                    }
                }
            }
        }
    }
}
```

### Conditional Execution
```groovy
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
        
        stage('Test') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                    changeRequest()
                }
            }
            steps {
                sh 'mvn test'
            }
        }
        
        stage('Security Scan') {
            when {
                allOf {
                    branch 'main'
                    not { changeRequest() }
                }
            }
            steps {
                sh 'security-scan.sh'
            }
        }
        
        stage('Deploy to Production') {
            when {
                allOf {
                    branch 'main'
                    expression { return params.DEPLOY_TO_PROD }
                }
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy'
                sh 'deploy-production.sh'
            }
        }
    }
}
```

## Multi-Branch Pipelines

### Jenkinsfile for Multi-Branch
```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'registry.example.com'
        APP_NAME = 'petclinic'
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
                    def image = docker.build("${DOCKER_REGISTRY}/${APP_NAME}:${env.BRANCH_NAME}-${env.BUILD_NUMBER}")
                    env.DOCKER_IMAGE = image.id
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    docker.image(env.DOCKER_IMAGE).inside {
                        sh 'mvn test'
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    switch(env.BRANCH_NAME) {
                        case 'main':
                            deployToEnvironment('production')
                            break
                        case 'develop':
                            deployToEnvironment('staging')
                            break
                        case ~/^feature\/.*/:
                            deployToEnvironment('dev')
                            break
                        default:
                            echo "No deployment for branch ${env.BRANCH_NAME}"
                    }
                }
            }
        }
    }
}

def deployToEnvironment(environment) {
    echo "Deploying to ${environment}"
    sh "kubectl apply -f k8s/${environment}/"
    sh "kubectl set image deployment/petclinic petclinic=${env.DOCKER_IMAGE} -n ${environment}"
}
```

## Pipeline Libraries

### Shared Library Structure
```bash
vars/
├── buildApp.groovy
├── deployApp.groovy
└── notifySlack.groovy

src/
└── com/
    └── company/
        └── jenkins/
            └── Utils.groovy

resources/
└── scripts/
    └── deploy.sh
```

### Global Variable Example
```groovy
// vars/buildApp.groovy
def call(Map config) {
    pipeline {
        agent any
        
        stages {
            stage('Checkout') {
                steps {
                    git branch: config.branch, url: config.repo
                }
            }
            
            stage('Build') {
                steps {
                    script {
                        if (config.buildTool == 'maven') {
                            sh 'mvn clean package'
                        } else if (config.buildTool == 'gradle') {
                            sh './gradlew build'
                        }
                    }
                }
            }
            
            stage('Test') {
                when {
                    expression { config.runTests != false }
                }
                steps {
                    script {
                        if (config.buildTool == 'maven') {
                            sh 'mvn test'
                        } else if (config.buildTool == 'gradle') {
                            sh './gradlew test'
                        }
                    }
                }
            }
        }
    }
}
```

### Using Shared Library
```groovy
// Jenkinsfile
@Library('jenkins-shared-library') _

buildApp([
    repo: 'https://github.com/user/petclinic.git',
    branch: 'main',
    buildTool: 'maven',
    runTests: true
])
```

## Docker Integration

### Docker Pipeline
```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'registry.example.com'
        IMAGE_NAME = 'petclinic'
        DOCKER_CREDS = credentials('docker-registry')
    }
    
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/user/petclinic.git'
            }
        }
        
        stage('Build Image') {
            steps {
                script {
                    def image = docker.build("${DOCKER_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER}")
                    env.DOCKER_IMAGE = image.id
                }
            }
        }
        
        stage('Test Image') {
            steps {
                script {
                    docker.image(env.DOCKER_IMAGE).inside {
                        sh 'java -version'
                        sh 'mvn test'
                    }
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image ${env.DOCKER_IMAGE}"
            }
        }
        
        stage('Push Image') {
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-registry') {
                        def image = docker.image(env.DOCKER_IMAGE)
                        image.push("${env.BUILD_NUMBER}")
                        image.push("latest")
                    }
                }
            }
        }
    }
    
    post {
        always {
            sh "docker rmi ${env.DOCKER_IMAGE} || true"
        }
    }
}
```

### Multi-Stage Docker Build
```dockerfile
# Dockerfile
FROM maven:3.8.1-adoptopenjdk-11 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

FROM adoptopenjdk:11-jre-hotspot
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## Kubernetes Integration

### Kubernetes Deployment Pipeline
```groovy
pipeline {
    agent {
        kubernetes {
            yaml """
                apiVersion: v1
                kind: Pod
                spec:
                  containers:
                  - name: kubectl
                    image: bitnami/kubectl:latest
                    command:
                    - sleep
                    args:
                    - 99d
                  - name: docker
                    image: docker:dind
                    securityContext:
                      privileged: true
            """
        }
    }
    
    environment {
        KUBECONFIG = credentials('kubeconfig')
        DOCKER_REGISTRY = 'registry.example.com'
    }
    
    stages {
        stage('Build and Push') {
            steps {
                container('docker') {
                    script {
                        def image = docker.build("${DOCKER_REGISTRY}/petclinic:${env.BUILD_NUMBER}")
                        docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-registry') {
                            image.push()
                            image.push("latest")
                        }
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh """
                        kubectl set image deployment/petclinic \
                            petclinic=${DOCKER_REGISTRY}/petclinic:${env.BUILD_NUMBER} \
                            --namespace=production
                        
                        kubectl rollout status deployment/petclinic --namespace=production
                    """
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                container('kubectl') {
                    sh """
                        kubectl get pods -l app=petclinic --namespace=production
                        kubectl get service petclinic --namespace=production
                    """
                }
            }
        }
    }
}
```

## Error Handling and Notifications

### Comprehensive Error Handling
```groovy
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                script {
                    try {
                        sh 'mvn clean compile'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error("Build failed: ${e.getMessage()}")
                    }
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    try {
                        sh 'mvn test'
                    } catch (Exception e) {
                        currentBuild.result = 'UNSTABLE'
                        echo "Tests failed but continuing: ${e.getMessage()}"
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Always run cleanup
            cleanWs()
        }
        
        success {
            slackSend(
                channel: '#deployments',
                color: 'good',
                message: "✅ Pipeline succeeded: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            )
        }
        
        failure {
            slackSend(
                channel: '#deployments',
                color: 'danger',
                message: "❌ Pipeline failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            )
            
            emailext(
                subject: "Pipeline Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Pipeline failed. Check console output at ${env.BUILD_URL}",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
        
        unstable {
            slackSend(
                channel: '#deployments',
                color: 'warning',
                message: "⚠️ Pipeline unstable: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            )
        }
    }
}
```

## Pipeline Best Practices

### Performance Optimization
```groovy
pipeline {
    agent any
    
    options {
        // Keep only last 10 builds
        buildDiscarder(logRotator(numToKeepStr: '10'))
        
        // Timeout after 30 minutes
        timeout(time: 30, unit: 'MINUTES')
        
        // Skip default checkout
        skipDefaultCheckout(true)
        
        // Disable concurrent builds
        disableConcurrentBuilds()
    }
    
    stages {
        stage('Checkout') {
            steps {
                // Shallow clone for faster checkout
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    extensions: [[$class: 'CloneOption', depth: 1, shallow: true]],
                    userRemoteConfigs: [[url: 'https://github.com/user/repo.git']]
                ])
            }
        }
        
        stage('Cache Dependencies') {
            steps {
                // Cache Maven dependencies
                script {
                    if (fileExists('.m2/repository')) {
                        echo 'Using cached Maven dependencies'
                    } else {
                        sh 'mvn dependency:go-offline'
                    }
                }
            }
        }
    }
}
```

### Security Best Practices
```groovy
pipeline {
    agent any
    
    environment {
        // Use credentials for sensitive data
        DB_PASSWORD = credentials('database-password')
        API_KEY = credentials('api-key')
    }
    
    stages {
        stage('Security Scan') {
            parallel {
                stage('SAST') {
                    steps {
                        sh 'sonar-scanner'
                    }
                }
                
                stage('Dependency Check') {
                    steps {
                        sh 'mvn org.owasp:dependency-check-maven:check'
                    }
                }
                
                stage('Secret Scan') {
                    steps {
                        sh 'trufflehog --regex --entropy=False .'
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Clean sensitive data
            sh 'rm -f .env'
            sh 'docker system prune -f'
        }
    }
}
```

This comprehensive pipeline guide provides production-ready CI/CD automation patterns for Jenkins.