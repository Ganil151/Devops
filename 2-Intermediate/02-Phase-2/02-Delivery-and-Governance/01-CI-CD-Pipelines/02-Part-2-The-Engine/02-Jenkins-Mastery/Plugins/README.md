# Jenkins Plugin Management

Essential plugins and management strategies for Jenkins automation and integration.

## Essential Plugins

### Core Build Plugins
```bash
# Git integration
Git Plugin
GitHub Plugin
GitLab Plugin
Bitbucket Plugin

# Build tools
Maven Integration Plugin
Gradle Plugin
Ant Plugin
NodeJS Plugin

# Pipeline plugins
Pipeline Plugin
Pipeline: Stage View
Blue Ocean
```

### Deployment Plugins
```bash
# Container deployment
Docker Plugin
Kubernetes Plugin
OpenShift Plugin

# Cloud deployment
AWS Steps Plugin
Azure CLI Plugin
Google Cloud Build Plugin

# Artifact management
Artifactory Plugin
Nexus Artifact Uploader
```

### Notification Plugins
```bash
# Communication
Slack Notification Plugin
Microsoft Teams Plugin
Email Extension Plugin
Telegram Bot Plugin

# Monitoring
Prometheus Plugin
Datadog Plugin
New Relic Plugin
```

## Plugin Installation

### Web Interface Installation
```bash
# Navigate to Manage Jenkins > Manage Plugins
1. Available tab - Browse available plugins
2. Search for desired plugin
3. Select plugin checkbox
4. Click "Install without restart" or "Download now and install after restart"
```

### CLI Installation
```bash
# Install single plugin
jenkins-cli install-plugin git

# Install multiple plugins
jenkins-cli install-plugin git maven-plugin docker-plugin

# Install from file
jenkins-cli install-plugin /path/to/plugin.hpi

# Install with dependencies
jenkins-cli install-plugin git -deploy
```

### Automated Installation Script
```bash
#!/bin/bash
# install-plugins.sh

JENKINS_CLI="java -jar jenkins-cli.jar -s http://localhost:8080"
PLUGINS=(
    "git"
    "workflow-aggregator"
    "docker-plugin"
    "kubernetes"
    "slack"
    "email-ext"
    "build-timeout"
    "credentials-binding"
    "timestamper"
    "ws-cleanup"
)

for plugin in "${PLUGINS[@]}"; do
    echo "Installing $plugin..."
    $JENKINS_CLI install-plugin "$plugin"
done

echo "Restarting Jenkins..."
$JENKINS_CLI safe-restart
```

## Plugin Configuration

### Git Plugin Configuration
```groovy
// Jenkinsfile
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'git-credentials',
                    url: 'https://github.com/user/repo.git'
            }
        }
    }
}
```

### Docker Plugin Configuration
```groovy
pipeline {
    agent {
        docker {
            image 'maven:3.8.1-openjdk-11'
            args '-v /root/.m2:/root/.m2'
        }
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
    }
}
```

### Slack Plugin Configuration
```groovy
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
        success {
            slackSend channel: '#deployments',
                     color: 'good',
                     message: "Build successful: ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
        }
        failure {
            slackSend channel: '#deployments',
                     color: 'danger',
                     message: "Build failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
        }
    }
}
```

## Plugin Management Best Practices

### Plugin Updates
```bash
# List outdated plugins
jenkins-cli list-plugins | grep -E '\)$'

# Update all plugins
jenkins-cli update-plugin $(jenkins-cli list-plugins | grep -E '\)$' | awk '{print $1}')

# Update specific plugin
jenkins-cli update-plugin git
```

### Plugin Security
```bash
# Check plugin vulnerabilities
# Use Jenkins Security Advisory database
# Regular security scans

# Disable unused plugins
jenkins-cli disable-plugin unused-plugin

# Remove plugins
jenkins-cli uninstall-plugin unused-plugin
```

This guide covers essential Jenkins plugin management for enterprise CI/CD environments.