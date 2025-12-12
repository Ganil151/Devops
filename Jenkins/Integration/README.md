# Jenkins Integration

Third-party integrations and ecosystem connectivity for Jenkins CI/CD pipelines.

## Version Control Integration

### Git Integration
```groovy
// Advanced Git operations
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/user/repo.git',
                        credentialsId: 'git-credentials'
                    ]],
                    extensions: [
                        [$class: 'CloneOption', depth: 1, shallow: true],
                        [$class: 'CheckoutOption', timeout: 20]
                    ]
                ])
            }
        }
        
        stage('Git Operations') {
            steps {
                script {
                    // Get commit info
                    def commitId = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
                    def commitMessage = sh(returnStdout: true, script: 'git log -1 --pretty=%B').trim()
                    
                    echo "Commit: ${commitId}"
                    echo "Message: ${commitMessage}"
                    
                    // Tag release
                    if (env.BRANCH_NAME == 'main') {
                        sh "git tag -a v${env.BUILD_NUMBER} -m 'Release ${env.BUILD_NUMBER}'"
                        sh "git push origin v${env.BUILD_NUMBER}"
                    }
                }
            }
        }
    }
}
```

### GitHub Integration
```groovy
// GitHub webhook and PR integration
pipeline {
    agent any
    
    triggers {
        githubPush()
    }
    
    stages {
        stage('PR Validation') {
            when {
                changeRequest()
            }
            steps {
                script {
                    // Update PR status
                    githubNotify context: 'Jenkins CI',
                               description: 'Build started',
                               status: 'PENDING'
                }
                
                sh 'make test'
                
                script {
                    githubNotify context: 'Jenkins CI',
                               description: 'Build successful',
                               status: 'SUCCESS'
                }
            }
        }
    }
    
    post {
        failure {
            script {
                githubNotify context: 'Jenkins CI',
                           description: 'Build failed',
                           status: 'FAILURE'
            }
        }
    }
}
```

## Container Integration

### Docker Integration
```groovy
// Multi-stage Docker builds
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'registry.example.com'
        IMAGE_NAME = 'myapp'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Build Image') {
            steps {
                script {
                    def image = docker.build("${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}")
                    
                    // Security scan
                    sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
                    
                    // Push to registry
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-registry-credentials') {
                        image.push()
                        image.push('latest')
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                sh """
                    docker run -d --name myapp-${BUILD_NUMBER} \
                        -p 8080:8080 \
                        ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }
    }
    
    post {
        always {
            sh "docker rmi ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} || true"
        }
    }
}
```

### Kubernetes Integration
```groovy
// Kubernetes deployment pipeline
pipeline {
    agent any
    
    environment {
        KUBECONFIG = credentials('kubeconfig')
        NAMESPACE = 'production'
    }
    
    stages {
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Update deployment manifest
                    sh """
                        sed -i 's|IMAGE_TAG|${env.BUILD_NUMBER}|g' k8s/deployment.yaml
                        sed -i 's|NAMESPACE|${NAMESPACE}|g' k8s/deployment.yaml
                    """
                    
                    // Apply manifests
                    sh """
                        kubectl apply -f k8s/namespace.yaml
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        kubectl apply -f k8s/ingress.yaml
                    """
                    
                    // Wait for rollout
                    sh "kubectl rollout status deployment/myapp -n ${NAMESPACE} --timeout=300s"
                    
                    // Verify deployment
                    sh "kubectl get pods -n ${NAMESPACE} -l app=myapp"
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    def serviceUrl = sh(
                        returnStdout: true,
                        script: "kubectl get service myapp -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
                    ).trim()
                    
                    // Wait for service to be ready
                    timeout(time: 5, unit: 'MINUTES') {
                        waitUntil {
                            script {
                                def response = sh(
                                    returnStatus: true,
                                    script: "curl -f http://${serviceUrl}/health"
                                )
                                return response == 0
                            }
                        }
                    }
                }
            }
        }
    }
}
```

## Cloud Platform Integration

### AWS Integration
```groovy
// AWS deployment pipeline
pipeline {
    agent any
    
    environment {
        AWS_DEFAULT_REGION = 'us-west-2'
        AWS_CREDENTIALS = credentials('aws-credentials')
    }
    
    stages {
        stage('Deploy to ECS') {
            steps {
                script {
                    // Update ECS task definition
                    sh """
                        aws ecs register-task-definition \
                            --family myapp \
                            --task-role-arn arn:aws:iam::123456789012:role/ecsTaskRole \
                            --execution-role-arn arn:aws:iam::123456789012:role/ecsTaskExecutionRole \
                            --network-mode awsvpc \
                            --requires-compatibilities FARGATE \
                            --cpu 256 \
                            --memory 512 \
                            --container-definitions '[{
                                "name": "myapp",
                                "image": "myapp:${BUILD_NUMBER}",
                                "portMappings": [{
                                    "containerPort": 8080,
                                    "protocol": "tcp"
                                }]
                            }]'
                    """
                    
                    // Update ECS service
                    sh """
                        aws ecs update-service \
                            --cluster production \
                            --service myapp \
                            --task-definition myapp:${BUILD_NUMBER}
                    """
                }
            }
        }
        
        stage('Deploy to Lambda') {
            steps {
                sh """
                    zip -r function.zip .
                    aws lambda update-function-code \
                        --function-name myapp \
                        --zip-file fileb://function.zip
                """
            }
        }
    }
}
```

### Azure DevOps Integration
```groovy
// Azure integration pipeline
pipeline {
    agent any
    
    environment {
        AZURE_CREDENTIALS = credentials('azure-service-principal')
    }
    
    stages {
        stage('Azure Login') {
            steps {
                sh """
                    az login --service-principal \
                        --username \$AZURE_CREDENTIALS_USR \
                        --password \$AZURE_CREDENTIALS_PSW \
                        --tenant ${env.AZURE_TENANT_ID}
                """
            }
        }
        
        stage('Deploy to AKS') {
            steps {
                sh """
                    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
                    kubectl apply -f k8s/
                    kubectl rollout status deployment/myapp
                """
            }
        }
        
        stage('Deploy to App Service') {
            steps {
                sh """
                    az webapp deployment source config-zip \
                        --resource-group myResourceGroup \
                        --name myWebApp \
                        --src app.zip
                """
            }
        }
    }
}
```

## Notification Integration

### Slack Integration
```groovy
// Advanced Slack notifications
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                script {
                    slackSend channel: '#deployments',
                             color: 'warning',
                             message: ":building_construction: Build started: ${env.JOB_NAME} - ${env.BUILD_NUMBER}\n" +
                                    "Branch: ${env.BRANCH_NAME}\n" +
                                    "Commit: ${env.GIT_COMMIT[0..7]}"
                }
                
                sh 'make build'
            }
        }
    }
    
    post {
        success {
            slackSend channel: '#deployments',
                     color: 'good',
                     message: ":white_check_mark: Build successful: ${env.JOB_NAME} - ${env.BUILD_NUMBER}\n" +
                            "Duration: ${currentBuild.durationString}\n" +
                            "Changes: ${env.BUILD_URL}changes"
        }
        
        failure {
            slackSend channel: '#deployments',
                     color: 'danger',
                     message: ":x: Build failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}\n" +
                            "Console: ${env.BUILD_URL}console\n" +
                            "Please check the logs for details."
        }
    }
}
```

### Microsoft Teams Integration
```groovy
// Teams webhook notification
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                sh 'make build'
            }
        }
    }
    
    post {
        always {
            script {
                def status = currentBuild.result ?: 'SUCCESS'
                def color = status == 'SUCCESS' ? '00FF00' : 'FF0000'
                
                def payload = [
                    "@type": "MessageCard",
                    "@context": "http://schema.org/extensions",
                    "themeColor": color,
                    "summary": "Jenkins Build ${status}",
                    "sections": [[
                        "activityTitle": "Jenkins Build ${status}",
                        "activitySubtitle": "${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                        "facts": [
                            ["name": "Status", "value": status],
                            ["name": "Branch", "value": env.BRANCH_NAME],
                            ["name": "Duration", "value": currentBuild.durationString]
                        ]
                    ]],
                    "potentialAction": [[
                        "@type": "OpenUri",
                        "name": "View Build",
                        "targets": [["os": "default", "uri": env.BUILD_URL]]
                    ]]
                ]
                
                httpRequest(
                    httpMode: 'POST',
                    contentType: 'APPLICATION_JSON',
                    requestBody: groovy.json.JsonOutput.toJson(payload),
                    url: env.TEAMS_WEBHOOK_URL
                )
            }
        }
    }
}
```

## Testing Integration

### SonarQube Integration
```groovy
// Code quality analysis
pipeline {
    agent any
    
    tools {
        maven 'Maven-3.8.1'
        jdk 'JDK-11'
    }
    
    stages {
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
                    jacoco execPattern: 'target/jacoco.exec'
                }
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                        mvn sonar:sonar \
                            -Dsonar.projectKey=${env.JOB_NAME} \
                            -Dsonar.projectName=${env.JOB_NAME} \
                            -Dsonar.projectVersion=${env.BUILD_NUMBER}
                    """
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }
}
```

### Selenium Integration
```groovy
// Automated UI testing
pipeline {
    agent any
    
    stages {
        stage('Deploy Test Environment') {
            steps {
                sh 'docker-compose -f docker-compose.test.yml up -d'
            }
        }
        
        stage('UI Tests') {
            steps {
                script {
                    def seleniumHub = 'http://selenium-hub:4444/wd/hub'
                    
                    sh """
                        mvn test \
                            -Dselenium.hub.url=${seleniumHub} \
                            -Dapp.url=http://app-under-test:8080 \
                            -Dtest.suite=ui-tests
                    """
                }
            }
            post {
                always {
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'target/selenium-reports',
                        reportFiles: 'index.html',
                        reportName: 'Selenium Test Report'
                    ])
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker-compose -f docker-compose.test.yml down'
        }
    }
}
```

This comprehensive Jenkins integration guide provides enterprise-grade connectivity with development tools, cloud platforms, and third-party services.