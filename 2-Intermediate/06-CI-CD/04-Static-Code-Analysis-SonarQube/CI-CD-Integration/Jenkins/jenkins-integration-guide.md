# Jenkins Integration with SonarQube

Complete guide for integrating SonarQube with Jenkins for automated code quality analysis in CI/CD pipelines.

## Prerequisites

- Jenkins server with admin access
- SonarQube server running and accessible
- SonarQube authentication token
- Projects to analyze

## Step 1: Install Jenkins Plugins

### Required Plugins
```bash
# Install via Jenkins CLI
java -jar jenkins-cli.jar -s http://jenkins-server:8080/ install-plugin sonar

# Or install via Jenkins UI:
# Manage Jenkins > Manage Plugins > Available
# Search and install:
# - SonarQube Scanner for Jenkins
# - Pipeline: Stage View Plugin (optional)
```

### Plugin List
- **SonarQube Scanner**: Core plugin for SonarQube integration
- **Pipeline**: For pipeline-based jobs
- **Blue Ocean**: Enhanced pipeline visualization (optional)
- **Build Timeout**: Prevent hanging builds

## Step 2: Configure SonarQube Server in Jenkins

### Global Configuration
1. Navigate to **Manage Jenkins > Configure System**
2. Scroll to **SonarQube servers** section
3. Click **Add SonarQube**

```
Name: SonarQube-Server
Server URL: http://sonarqube-server:9000
Server authentication token: [Select from credentials]
```

### Create SonarQube Token Credential
1. Go to **Manage Jenkins > Manage Credentials**
<b>2. Select appropriate domain</b>
<details>
<summary>Show Answer</summary>
Answer: usually Global
</details>

3. Click **Add Credentials**

```
Kind: Secret text
Secret: [Your SonarQube token]
ID: sonarqube-token
Description: SonarQube Authentication Token
```

### Generate SonarQube Token
```bash
# In SonarQube web interface:
# 1. Login as admin
# 2. Go to My Account > Security
# 3. Generate new token
# 4. Copy token for Jenkins configuration
```

## Step 3: Configure SonarScanner Tool

### Global Tool Configuration
1. Navigate to **Manage Jenkins > Global Tool Configuration**
2. Scroll to **SonarQube Scanner** section
3. Click **Add SonarQube Scanner**

```
Name: SonarScanner
Install automatically: ✓
Version: Latest (or specific version)
```

### Manual Installation (Alternative)
```bash
# Download and install SonarScanner on Jenkins server
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
sudo unzip sonar-scanner-cli-5.0.1.3006-linux.zip
sudo mv sonar-scanner-5.0.1.3006-linux sonar-scanner
sudo chown -R jenkins:jenkins /opt/sonar-scanner

# Add to Jenkins tool configuration
Name: SonarScanner
SONAR_RUNNER_HOME: /opt/sonar-scanner
```

## Step 4: Freestyle Job Configuration

### Basic Freestyle Job
```xml
<!-- Job Configuration -->
<project>
  <actions/>
  <description>Code quality analysis with SonarQube</description>
  <keepDependencies>false</keepDependencies>
  
  <!-- Source Code Management -->
  <scm class="hudson.plugins.git.GitSCM">
    <configVersion>2</configVersion>
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <url>https://github.com/your-org/your-repo.git</url>
        <credentialsId>github-credentials</credentialsId>
      </hudson.plugins.git.UserRemoteConfig>
    </userRemoteConfigs>
    <branches>
      <hudson.plugins.git.BranchSpec>
        <name>*/main</name>
      </hudson.plugins.git.BranchSpec>
    </branches>
  </scm>
  
  <!-- Build Steps -->
  <builders>
    <!-- Compile/Build Step -->
    <hudson.tasks.Shell>
      <command>
        # Build your application
        mvn clean compile test
      </command>
    </hudson.tasks.Shell>
    
    <!-- SonarQube Analysis -->
    <hudson.plugins.sonar.SonarRunnerBuilder>
      <project>sonar-project.properties</project>
      <properties>
        sonar.projectKey=my-project
        sonar.projectName=My Project
        sonar.projectVersion=1.0
        sonar.sources=src/main/java
        sonar.tests=src/test/java
        sonar.java.binaries=target/classes
        sonar.java.test.binaries=target/test-classes
        sonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
      </properties>
      <javaOpts></javaOpts>
      <additionalArguments></additionalArguments>
    </hudson.plugins.sonar.SonarRunnerBuilder>
  </builders>
</project>
```

### Build Steps Configuration
1. **Add build step** > **Execute SonarQube Scanner**
2. Configure analysis properties:

```properties
# Analysis Properties
sonar.projectKey=my-project-key
sonar.projectName=My Project Name
sonar.projectVersion=$BUILD_NUMBER
sonar.sources=src/main/java
sonar.tests=src/test/java
sonar.java.binaries=target/classes
sonar.java.test.binaries=target/test-classes
sonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
sonar.junit.reportPaths=target/surefire-reports
```

## Step 5: Pipeline Job Configuration

### Declarative Pipeline
```groovy
pipeline {
    agent any
    
    environment {
        SONAR_TOKEN = credentials('sonarqube-token')
    }
    
    tools {
        maven 'Maven-3.8'
        jdk 'JDK-17'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    credentialsId: 'github-credentials',
                    url: 'https://github.com/your-org/your-repo.git'
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
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'target/site/jacoco',
                        reportFiles: 'index.html',
                        reportName: 'JaCoCo Coverage Report'
                    ])
                }
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh '''
                        mvn sonar:sonar \
                          -Dsonar.projectKey=my-project \
                          -Dsonar.projectName="My Project" \
                          -Dsonar.projectVersion=$BUILD_NUMBER \
                          -Dsonar.sources=src/main/java \
                          -Dsonar.tests=src/test/java \
                          -Dsonar.java.binaries=target/classes \
                          -Dsonar.java.test.binaries=target/test-classes \
                          -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
                    '''
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
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                echo 'Deploying application...'
                // Add deployment steps here
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            emailext (
                subject: "✅ Build Success: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Build completed successfully. Check SonarQube report: ${env.SONAR_HOST_URL}",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
        failure {
            emailext (
                subject: "❌ Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Build failed. Check console output: ${env.BUILD_URL}",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}
```

### Scripted Pipeline
```groovy
node {
    def mvnHome = tool 'Maven-3.8'
    def sonarScanner = tool 'SonarScanner'
    
    stage('Checkout') {
        git branch: 'main',
            credentialsId: 'github-credentials',
            url: 'https://github.com/your-org/your-repo.git'
    }
    
    stage('Build & Test') {
        sh "${mvnHome}/bin/mvn clean test"
    }
    
    stage('SonarQube Analysis') {
        withSonarQubeEnv('SonarQube-Server') {
            sh """
                ${sonarScanner}/bin/sonar-scanner \
                  -Dsonar.projectKey=my-project \
                  -Dsonar.sources=src/main/java \
                  -Dsonar.tests=src/test/java \
                  -Dsonar.java.binaries=target/classes \
                  -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
            """
        }
    }
    
    stage('Quality Gate') {
        timeout(time: 5, unit: 'MINUTES') {
            def qg = waitForQualityGate()
            if (qg.status != 'OK') {
                error "Pipeline aborted due to quality gate failure: ${qg.status}"
            }
        }
    }
}
```

## Step 6: Multi-Branch Pipeline

### Jenkinsfile for Multi-Branch
```groovy
pipeline {
    agent any
    
    environment {
        SONAR_TOKEN = credentials('sonarqube-token')
    }
    
    stages {
        stage('Build & Test') {
            steps {
                sh 'mvn clean test'
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                script {
                    def sonarProjectKey = "my-project"
                    def sonarProjectName = "My Project"
                    
                    // Different analysis for different branches
                    if (env.BRANCH_NAME == 'main') {
                        // Main branch analysis
                        withSonarQubeEnv('SonarQube-Server') {
                            sh """
                                mvn sonar:sonar \
                                  -Dsonar.projectKey=${sonarProjectKey} \
                                  -Dsonar.projectName="${sonarProjectName}" \
                                  -Dsonar.branch.name=${env.BRANCH_NAME}
                            """
                        }
                    } else if (env.CHANGE_ID) {
                        // Pull request analysis
                        withSonarQubeEnv('SonarQube-Server') {
                            sh """
                                mvn sonar:sonar \
                                  -Dsonar.projectKey=${sonarProjectKey} \
                                  -Dsonar.projectName="${sonarProjectName}" \
                                  -Dsonar.pullrequest.key=${env.CHANGE_ID} \
                                  -Dsonar.pullrequest.branch=${env.CHANGE_BRANCH} \
                                  -Dsonar.pullrequest.base=${env.CHANGE_TARGET}
                            """
                        }
                    } else {
                        // Feature branch analysis
                        withSonarQubeEnv('SonarQube-Server') {
                            sh """
                                mvn sonar:sonar \
                                  -Dsonar.projectKey=${sonarProjectKey} \
                                  -Dsonar.projectName="${sonarProjectName}" \
                                  -Dsonar.branch.name=${env.BRANCH_NAME}
                            """
                        }
                    }
                }
            }
        }
        
        stage('Quality Gate') {
            when {
                anyOf {
                    branch 'main'
                    changeRequest()
                }
            }
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }
}
```

## Step 7: Advanced Configuration

### Custom Quality Gates
```groovy
// Custom quality gate check
stage('Custom Quality Gate') {
    steps {
        script {
            def qg = waitForQualityGate()
            
            // Custom logic based on quality gate results
            if (qg.status == 'OK') {
                echo "✅ Quality Gate passed"
            } else if (qg.status == 'WARN') {
                echo "⚠️ Quality Gate warning - proceeding with caution"
                // Continue but notify
                slackSend(
                    color: 'warning',
                    message: "Quality Gate warning for ${env.JOB_NAME} #${env.BUILD_NUMBER}"
                )
            } else {
                echo "❌ Quality Gate failed"
                // Fail the build
                error "Quality Gate failure: ${qg.status}"
            }
        }
    }
}
```

### Parallel Analysis
```groovy
stage('Parallel Analysis') {
    parallel {
        stage('SonarQube') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        stage('Security Scan') {
            steps {
                sh 'dependency-check --project my-project --scan .'
            }
        }
        stage('License Check') {
            steps {
                sh 'license-maven-plugin:check'
            }
        }
    }
}
```

### Matrix Build Configuration
```groovy
pipeline {
    agent none
    
    stages {
        stage('Matrix Build') {
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
                stages {
                    stage('Build & Analyze') {
                        agent {
                            label "${OS}"
                        }
                        tools {
                            jdk "JDK-${JAVA_VERSION}"
                        }
                        steps {
                            sh 'mvn clean test'
                            withSonarQubeEnv('SonarQube-Server') {
                                sh """
                                    mvn sonar:sonar \
                                      -Dsonar.projectKey=my-project-${JAVA_VERSION}-${OS} \
                                      -Dsonar.projectName="My Project Java ${JAVA_VERSION} on ${OS}"
                                """
                            }
                        }
                    }
                }
            }
        }
    }
}
```

## Step 8: Webhook Configuration

### SonarQube Webhook Setup
1. In SonarQube: **Administration > Configuration > Webhooks**
2. Create webhook:
```
Name: Jenkins
URL: http://jenkins-server:8080/sonarqube-webhook/
Secret: [Optional webhook secret]
```

### Jenkins Webhook Handling
```groovy
// Webhook automatically triggers quality gate check
// No additional configuration needed in pipeline
// waitForQualityGate() will automatically receive webhook
```

## Step 9: Reporting and Notifications

### SonarQube Report in Jenkins
```groovy
post {
    always {
        // Publish SonarQube report
        publishHTML([
            allowMissing: false,
            alwaysLinkToLastBuild: true,
            keepAll: true,
            reportDir: 'target/sonar',
            reportFiles: 'report-task.txt',
            reportName: 'SonarQube Report'
        ])
        
        // Archive analysis results
        archiveArtifacts artifacts: 'target/sonar/report-task.txt', fingerprint: true
    }
    
    success {
        script {
            def sonarUrl = "${env.SONAR_HOST_URL}/dashboard?id=my-project"
            slackSend(
                color: 'good',
                message: "✅ Build successful! SonarQube report: ${sonarUrl}"
            )
        }
    }
    
    failure {
        slackSend(
            color: 'danger',
            message: "❌ Build failed! Check console: ${env.BUILD_URL}"
        )
    }
}
```

### Email Notifications
```groovy
post {
    always {
        emailext (
            subject: "SonarQube Analysis: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
            body: """
                <h2>SonarQube Analysis Results</h2>
                <p><strong>Project:</strong> ${env.JOB_NAME}</p>
                <p><strong>Build:</strong> ${env.BUILD_NUMBER}</p>
                <p><strong>Status:</strong> ${currentBuild.currentResult}</p>
                <p><strong>SonarQube Report:</strong> <a href="${env.SONAR_HOST_URL}/dashboard?id=my-project">View Report</a></p>
                <p><strong>Console Output:</strong> <a href="${env.BUILD_URL}console">View Logs</a></p>
            """,
            mimeType: 'text/html',
            to: "${env.CHANGE_AUTHOR_EMAIL}",
            recipientProviders: [developers(), requestor()]
        )
    }
}
```

## Troubleshooting

### Common Issues

#### SonarQube Server Connection
```groovy
// Test connection in pipeline
stage('Test SonarQube Connection') {
    steps {
        script {
            withSonarQubeEnv('SonarQube-Server') {
                sh 'curl -f ${SONAR_HOST_URL}/api/system/status'
            }
        }
    }
}
```

#### Quality Gate Timeout
```groovy
// Increase timeout for large projects
stage('Quality Gate') {
    steps {
        timeout(time: 10, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}
```

#### Memory Issues
```groovy
// Increase JVM memory for SonarScanner
environment {
    SONAR_SCANNER_OPTS = '-Xmx2G'
}
```

This completes the comprehensive Jenkins integration guide for SonarQube with various pipeline configurations, advanced features, and troubleshooting information.