# Jenkins Best Practices

Comprehensive guide to Jenkins best practices for production environments, security, performance, and maintainability.

## Pipeline Design Principles

### Code Organization
```groovy
// Good: Modular pipeline with clear stages
pipeline {
    agent any
    
    stages {
        stage('Validate') {
            parallel {
                stage('Lint') {
                    steps { sh 'npm run lint' }
                }
                stage('Security Scan') {
                    steps { sh 'npm audit' }
                }
            }
        }
        
        stage('Build') {
            steps { sh 'npm run build' }
        }
        
        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps { sh 'npm run test:unit' }
                }
                stage('Integration Tests') {
                    steps { sh 'npm run test:integration' }
                }
            }
        }
        
        stage('Deploy') {
            when { branch 'main' }
            steps { deployApplication() }
        }
    }
}

def deployApplication() {
    // Deployment logic
}
```

### Shared Libraries Usage
```groovy
// vars/standardPipeline.groovy
def call(Map config) {
    pipeline {
        agent any
        
        environment {
            APP_NAME = config.appName
            BUILD_TOOL = config.buildTool ?: 'maven'
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
                        buildApplication(config.buildTool)
                    }
                }
            }
            
            stage('Test') {
                when {
                    expression { config.runTests != false }
                }
                steps {
                    runTests(config.buildTool)
                }
            }
        }
    }
}
```

## Security Best Practices

### Credential Management
```groovy
pipeline {
    agent any
    
    environment {
        // Use Jenkins credentials
        DB_CREDS = credentials('database-credentials')
        API_TOKEN = credentials('api-token')
        
        // Avoid hardcoded secrets
        // BAD: API_KEY = 'abc123'
        // GOOD: API_KEY = credentials('api-key')
    }
    
    stages {
        stage('Deploy') {
            steps {
                script {
                    // Use withCredentials for temporary access
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'aws-credentials',
                            usernameVariable: 'AWS_ACCESS_KEY_ID',
                            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                        )
                    ]) {
                        sh 'aws s3 sync ./dist s3://my-bucket'
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Clean up sensitive files
            sh 'rm -f .env .aws/credentials'
        }
    }
}
```

### Access Control
```groovy
// Use role-based security
pipeline {
    agent any
    
    options {
        // Restrict who can run this pipeline
        authorizationMatrix([
            'hudson.model.Item.Build:developers',
            'hudson.model.Item.Cancel:developers',
            'hudson.model.Item.Read:authenticated'
        ])
    }
    
    stages {
        stage('Production Deploy') {
            when {
                allOf {
                    branch 'main'
                    expression { 
                        return env.BUILD_USER_ID in ['admin', 'release-manager']
                    }
                }
            }
            steps {
                input message: 'Deploy to production?', 
                      submitterParameter: 'DEPLOYER',
                      ok: 'Deploy'
                
                script {
                    if (env.DEPLOYER in ['admin', 'release-manager']) {
                        deployToProduction()
                    } else {
                        error('Unauthorized deployment attempt')
                    }
                }
            }
        }
    }
}
```

### Secret Scanning
```groovy
pipeline {
    agent any
    
    stages {
        stage('Security Checks') {
            parallel {
                stage('Secret Scan') {
                    steps {
                        sh '''
                            # Scan for secrets in code
                            trufflehog --regex --entropy=False .
                            
                            # Check for common secret patterns
                            grep -r "password\\|secret\\|key" . --exclude-dir=.git || true
                        '''
                    }
                }
                
                stage('Dependency Scan') {
                    steps {
                        sh 'npm audit --audit-level high'
                    }
                }
            }
        }
    }
}
```

## Performance Optimization

### Resource Management
```groovy
pipeline {
    agent {
        label 'high-memory'
    }
    
    options {
        // Limit build retention
        buildDiscarder(logRotator(
            numToKeepStr: '10',
            artifactNumToKeepStr: '5'
        ))
        
        // Set timeout
        timeout(time: 30, unit: 'MINUTES')
        
        // Prevent concurrent builds
        disableConcurrentBuilds()
        
        // Skip default checkout for performance
        skipDefaultCheckout(true)
    }
    
    stages {
        stage('Optimized Checkout') {
            steps {
                // Shallow clone for faster checkout
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    extensions: [
                        [$class: 'CloneOption', depth: 1, shallow: true],
                        [$class: 'CheckoutOption', timeout: 20]
                    ],
                    userRemoteConfigs: [[url: env.GIT_URL]]
                ])
            }
        }
    }
}
```

### Parallel Execution
```groovy
pipeline {
    agent none
    
    stages {
        stage('Parallel Build Matrix') {
            matrix {
                axes {
                    axis {
                        name 'PLATFORM'
                        values 'linux', 'windows', 'macos'
                    }
                    axis {
                        name 'VERSION'
                        values 'java11', 'java17'
                    }
                }
                
                stages {
                    stage('Build') {
                        agent { label "${PLATFORM}" }
                        steps {
                            sh "build-${VERSION}.sh"
                        }
                    }
                }
            }
        }
        
        stage('Parallel Tests') {
            parallel {
                stage('Unit Tests') {
                    agent { label 'test-runner' }
                    steps {
                        sh 'mvn test'
                    }
                }
                
                stage('Integration Tests') {
                    agent { label 'integration-test' }
                    steps {
                        sh 'mvn integration-test'
                    }
                }
                
                stage('Performance Tests') {
                    agent { label 'performance-test' }
                    steps {
                        sh 'jmeter -n -t performance.jmx'
                    }
                }
            }
        }
    }
}
```

### Caching Strategies
```groovy
pipeline {
    agent any
    
    stages {
        stage('Build with Cache') {
            steps {
                script {
                    // Maven dependency caching
                    def cacheKey = "maven-${hashFiles('pom.xml')}"
                    
                    cache(maxCacheSize: 250, caches: [
                        arbitraryFileCache(
                            path: '.m2/repository',
                            fingerprinting: true
                        )
                    ]) {
                        sh 'mvn clean package'
                    }
                }
            }
        }
        
        stage('Docker Layer Caching') {
            steps {
                script {
                    // Use multi-stage builds for better caching
                    def image = docker.build(
                        "myapp:${env.BUILD_NUMBER}",
                        "--cache-from myapp:latest ."
                    )
                }
            }
        }
    }
}
```

## Error Handling and Recovery

### Robust Error Handling
```groovy
pipeline {
    agent any
    
    stages {
        stage('Build with Retry') {
            steps {
                retry(3) {
                    script {
                        try {
                            sh 'mvn clean package'
                        } catch (Exception e) {
                            echo "Build attempt failed: ${e.getMessage()}"
                            sleep(time: 30, unit: 'SECONDS')
                            throw e
                        }
                    }
                }
            }
        }
        
        stage('Deploy with Rollback') {
            steps {
                script {
                    def deploymentSuccessful = false
                    
                    try {
                        // Deploy new version
                        sh 'kubectl apply -f k8s/deployment.yaml'
                        sh 'kubectl rollout status deployment/myapp'
                        
                        // Health check
                        timeout(time: 5, unit: 'MINUTES') {
                            waitUntil {
                                script {
                                    def response = sh(
                                        script: 'curl -f http://myapp/health',
                                        returnStatus: true
                                    )
                                    return response == 0
                                }
                            }
                        }
                        
                        deploymentSuccessful = true
                        
                    } catch (Exception e) {
                        echo "Deployment failed: ${e.getMessage()}"
                        
                        // Rollback
                        sh 'kubectl rollout undo deployment/myapp'
                        sh 'kubectl rollout status deployment/myapp'
                        
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }
    }
    
    post {
        failure {
            script {
                // Collect diagnostic information
                sh '''
                    kubectl get pods -l app=myapp > debug-pods.txt
                    kubectl logs -l app=myapp --tail=100 > debug-logs.txt
                '''
                
                archiveArtifacts artifacts: 'debug-*.txt'
            }
        }
    }
}
```

### Circuit Breaker Pattern
```groovy
def deployWithCircuitBreaker(environment) {
    def maxFailures = 3
    def failures = 0
    def success = false
    
    while (failures < maxFailures && !success) {
        try {
            deployToEnvironment(environment)
            runHealthChecks(environment)
            success = true
            
        } catch (Exception e) {
            failures++
            echo "Deployment attempt ${failures} failed: ${e.getMessage()}"
            
            if (failures < maxFailures) {
                echo "Retrying in 60 seconds..."
                sleep(60)
            } else {
                echo "Circuit breaker opened - too many failures"
                throw new Exception("Deployment failed after ${maxFailures} attempts")
            }
        }
    }
}
```

## Testing Strategies

### Comprehensive Testing Pipeline
```groovy
pipeline {
    agent any
    
    stages {
        stage('Code Quality') {
            parallel {
                stage('Static Analysis') {
                    steps {
                        sh 'sonar-scanner'
                        
                        publishHTML([
                            allowMissing: false,
                            alwaysLinkToLastBuild: true,
                            keepAll: true,
                            reportDir: 'sonar-reports',
                            reportFiles: 'index.html',
                            reportName: 'SonarQube Report'
                        ])
                    }
                }
                
                stage('Security Scan') {
                    steps {
                        sh 'dependency-check --project myapp --scan .'
                        
                        publishHTML([
                            allowMissing: false,
                            alwaysLinkToLastBuild: true,
                            keepAll: true,
                            reportDir: 'dependency-check-report',
                            reportFiles: 'dependency-check-report.html',
                            reportName: 'Security Report'
                        ])
                    }
                }
            }
        }
        
        stage('Testing') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'mvn test'
                    }
                    post {
                        always {
                            junit 'target/surefire-reports/*.xml'
                            
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'target/site/jacoco',
                                reportFiles: 'index.html',
                                reportName: 'Coverage Report'
                            ])
                        }
                    }
                }
                
                stage('Integration Tests') {
                    steps {
                        sh 'mvn integration-test'
                    }
                    post {
                        always {
                            junit 'target/failsafe-reports/*.xml'
                        }
                    }
                }
                
                stage('Contract Tests') {
                    steps {
                        sh 'mvn pact:verify'
                    }
                }
            }
        }
        
        stage('Performance Tests') {
            when {
                anyOf {
                    branch 'main'
                    changeRequest target: 'main'
                }
            }
            steps {
                sh 'jmeter -n -t performance.jmx -l results.jtl'
                
                perfReport(
                    sourceDataFiles: 'results.jtl',
                    compareBuildPrevious: true,
                    modePerformancePerTestCase: true
                )
            }
        }
    }
}
```

### Test Data Management
```groovy
pipeline {
    agent any
    
    stages {
        stage('Setup Test Environment') {
            steps {
                script {
                    // Create isolated test database
                    def testDbName = "test_${env.BUILD_NUMBER}"
                    
                    sh """
                        # Create test database
                        mysql -u root -p\${DB_PASSWORD} -e "CREATE DATABASE ${testDbName};"
                        
                        # Load test data
                        mysql -u root -p\${DB_PASSWORD} ${testDbName} < test-data.sql
                        
                        # Set environment variable for tests
                        echo "TEST_DB_NAME=${testDbName}" > test.env
                    """
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                script {
                    // Load test environment
                    def props = readProperties file: 'test.env'
                    env.TEST_DB_NAME = props.TEST_DB_NAME
                    
                    sh 'mvn test -Dtest.db.name=${TEST_DB_NAME}'
                }
            }
        }
    }
    
    post {
        always {
            script {
                // Cleanup test database
                if (env.TEST_DB_NAME) {
                    sh "mysql -u root -p\${DB_PASSWORD} -e 'DROP DATABASE IF EXISTS ${env.TEST_DB_NAME};'"
                }
            }
        }
    }
}
```

## Monitoring and Observability

### Pipeline Metrics
```groovy
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                script {
                    def startTime = System.currentTimeMillis()
                    
                    try {
                        sh 'mvn clean package'
                        
                        def duration = System.currentTimeMillis() - startTime
                        
                        // Send metrics to monitoring system
                        sh """
                            curl -X POST http://metrics-collector/api/metrics \\
                                -H 'Content-Type: application/json' \\
                                -d '{
                                    "metric": "build_duration",
                                    "value": ${duration},
                                    "tags": {
                                        "job": "${env.JOB_NAME}",
                                        "branch": "${env.BRANCH_NAME}",
                                        "status": "success"
                                    }
                                }'
                        """
                        
                    } catch (Exception e) {
                        def duration = System.currentTimeMillis() - startTime
                        
                        sh """
                            curl -X POST http://metrics-collector/api/metrics \\
                                -H 'Content-Type: application/json' \\
                                -d '{
                                    "metric": "build_duration",
                                    "value": ${duration},
                                    "tags": {
                                        "job": "${env.JOB_NAME}",
                                        "branch": "${env.BRANCH_NAME}",
                                        "status": "failure"
                                    }
                                }'
                        """
                        
                        throw e
                    }
                }
            }
        }
    }
}
```

### Health Checks
```groovy
pipeline {
    agent any
    
    stages {
        stage('Deploy') {
            steps {
                sh 'kubectl apply -f deployment.yaml'
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    def healthCheckPassed = false
                    def attempts = 0
                    def maxAttempts = 10
                    
                    while (!healthCheckPassed && attempts < maxAttempts) {
                        attempts++
                        
                        try {
                            def response = sh(
                                script: '''
                                    curl -f -s http://myapp/health | jq -r '.status'
                                ''',
                                returnStdout: true
                            ).trim()
                            
                            if (response == 'UP') {
                                healthCheckPassed = true
                                echo "Health check passed on attempt ${attempts}"
                            } else {
                                echo "Health check failed on attempt ${attempts}: ${response}"
                                sleep(30)
                            }
                            
                        } catch (Exception e) {
                            echo "Health check error on attempt ${attempts}: ${e.getMessage()}"
                            sleep(30)
                        }
                    }
                    
                    if (!healthCheckPassed) {
                        error("Health check failed after ${maxAttempts} attempts")
                    }
                }
            }
        }
    }
}
```

## Maintenance and Cleanup

### Automated Cleanup
```groovy
pipeline {
    agent any
    
    options {
        // Automatic cleanup
        buildDiscarder(logRotator(
            numToKeepStr: '10',
            artifactNumToKeepStr: '5',
            daysToKeepStr: '30'
        ))
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
    }
    
    post {
        always {
            // Clean workspace
            cleanWs(
                cleanWhenAborted: true,
                cleanWhenFailure: true,
                cleanWhenNotBuilt: true,
                cleanWhenSuccess: true,
                cleanWhenUnstable: true,
                deleteDirs: true
            )
            
            // Clean Docker resources
            sh '''
                docker system prune -f
                docker volume prune -f
            '''
        }
    }
}
```

### Resource Monitoring
```groovy
// Shared library function for resource monitoring
def monitorResources() {
    script {
        def diskUsage = sh(
            script: "df -h /var/lib/jenkins | tail -1 | awk '{print \$5}' | sed 's/%//'",
            returnStdout: true
        ).trim() as Integer
        
        def memoryUsage = sh(
            script: "free | grep Mem | awk '{printf \"%.0f\", \$3/\$2 * 100.0}'",
            returnStdout: true
        ).trim() as Integer
        
        if (diskUsage > 90) {
            error("Disk usage too high: ${diskUsage}%")
        }
        
        if (memoryUsage > 90) {
            echo "Warning: High memory usage: ${memoryUsage}%"
        }
        
        echo "Resource usage - Disk: ${diskUsage}%, Memory: ${memoryUsage}%"
    }
}
```

This comprehensive best practices guide ensures robust, secure, and maintainable Jenkins operations in production environments.