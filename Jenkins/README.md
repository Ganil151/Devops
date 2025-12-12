# Jenkins CI/CD

Comprehensive guide to Jenkins installation, configuration, and CI/CD pipeline management for DevOps automation.

## Jenkins Overview

### What is Jenkins?
Jenkins is an open-source automation server that enables developers to build, test, and deploy applications through continuous integration and continuous delivery (CI/CD) pipelines.

### Key Features
- **Pipeline as Code**: Define build pipelines using Jenkinsfile
- **Plugin Ecosystem**: 1800+ plugins for integration
- **Distributed Builds**: Master-slave architecture for scalability
- **Multi-Platform**: Supports Windows, macOS, and Linux
- **Integration**: Git, Docker, Kubernetes, AWS, Azure, GCP
- **Notifications**: Email, Slack, Teams integration

## Directory Structure

```bash
Jenkins/
├── Installation/           # Setup and configuration
├── Pipelines/             # Pipeline examples and patterns
├── Plugins/               # Plugin management and configuration
├── Security/              # Authentication and authorization
├── Monitoring/            # Performance and health monitoring
├── Backup-Recovery/       # Data protection strategies
├── Scaling/               # Master-slave configuration
├── Integration/           # Third-party integrations
└── Best-Practices/        # Production guidelines
```

## Quick Start

### Installation (Amazon Linux)
```bash
# Install Java
sudo yum update -y
sudo yum install java-11-openjdk -y

# Add Jenkins repository
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# Install Jenkins
sudo yum install jenkins -y

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Basic Configuration
```bash
# Access Jenkins web interface
http://your-server:8080

# Complete setup wizard
1. Enter initial admin password
2. Install suggested plugins
3. Create admin user
4. Configure Jenkins URL
```

## Core Concepts

### Jobs and Builds
- **Freestyle Jobs**: Simple build configurations
- **Pipeline Jobs**: Code-based build definitions
- **Multi-branch Pipelines**: Automatic branch detection
- **Folder Organization**: Hierarchical job structure

### Pipeline Types
```groovy
// Declarative Pipeline
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'make build'
            }
        }
    }
}

// Scripted Pipeline
node {
    stage('Build') {
        sh 'make build'
    }
}
```

### Agents and Nodes
- **Master Node**: Jenkins controller
- **Agent Nodes**: Build executors
- **Labels**: Node categorization
- **Executors**: Concurrent build slots

## Essential Operations

### Job Management
```bash
# Create job from CLI
jenkins-cli create-job myproject < job-config.xml

# Build job
jenkins-cli build myproject

# Get build status
jenkins-cli get-build myproject 1

# List all jobs
jenkins-cli list-jobs
```

### Plugin Management
```bash
# Install plugin
jenkins-cli install-plugin git

# List plugins
jenkins-cli list-plugins

# Update plugins
jenkins-cli update-plugin git
```

### System Management
```bash
# Restart Jenkins safely
jenkins-cli safe-restart

# Reload configuration
jenkins-cli reload-configuration

# System information
jenkins-cli version
```

## Integration Examples

### Git Integration
```groovy
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/user/repo.git'
            }
        }
    }
}
```

### Docker Integration
```groovy
pipeline {
    agent {
        docker {
            image 'maven:3.8.1-adoptopenjdk-11'
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

### Kubernetes Deployment
```groovy
pipeline {
    agent any
    stages {
        stage('Deploy') {
            steps {
                kubernetesDeploy(
                    configs: 'k8s-deployment.yaml',
                    kubeconfigId: 'kubeconfig'
                )
            }
        }
    }
}
```

## Monitoring and Maintenance

### Health Monitoring
- System resource usage
- Build queue status
- Node availability
- Plugin health

### Performance Optimization
- Executor allocation
- Build parallelization
- Workspace cleanup
- Archive management

### Backup Strategy
- Configuration backup
- Job definitions
- Build artifacts
- Plugin data

This comprehensive Jenkins guide provides enterprise-ready CI/CD automation capabilities.