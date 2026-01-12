# Programming Languages for DevOps

Complete guide to programming languages commonly used in DevOps practices, automation, and infrastructure management.

## Overview

DevOps professionals work with various programming languages for automation, infrastructure as code, monitoring, and application deployment. Each language has specific strengths and use cases.

## Shell Scripting (Bash/Zsh)

### Use Cases
```bash
# System administration
# CI/CD pipeline automation
# Infrastructure provisioning
# Log processing and analysis
# Deployment scripts

# Example: Deployment Script
#!/bin/bash
set -e

APP_NAME="myapp"
VERSION=${1:-latest}
ENVIRONMENT=${2:-staging}

echo "Deploying $APP_NAME:$VERSION to $ENVIRONMENT"

# Build and deploy
docker build -t $APP_NAME:$VERSION .
docker tag $APP_NAME:$VERSION registry.com/$APP_NAME:$VERSION
docker push registry.com/$APP_NAME:$VERSION

kubectl set image deployment/$APP_NAME $APP_NAME=registry.com/$APP_NAME:$VERSION
kubectl rollout status deployment/$APP_NAME
```

### Best Practices
```bash
# Error handling
set -euo pipefail

# Logging
exec > >(tee -a /var/log/deployment.log)
exec 2>&1

# Parameter validation
if [ $# -lt 2 ]; then
    echo "Usage: $0 <version> <environment>"
    exit 1
fi

# Configuration management
source /etc/deployment/config.sh
```

## Python

### DevOps Applications
```python
# Infrastructure automation
# API development and integration
# Data processing and analysis
# Monitoring and alerting
# Configuration management

# Example: AWS Resource Monitor
import boto3
import json
from datetime import datetime

def monitor_ec2_instances():
    ec2 = boto3.client('ec2')
    cloudwatch = boto3.client('cloudwatch')
    
    instances = ec2.describe_instances()
    
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            state = instance['State']['Name']
            
            # Send custom metric to CloudWatch
            cloudwatch.put_metric_data(
                Namespace='Custom/EC2',
                MetricData=[
                    {
                        'MetricName': 'InstanceState',
                        'Value': 1 if state == 'running' else 0,
                        'Unit': 'Count',
                        'Dimensions': [
                            {
                                'Name': 'InstanceId',
                                'Value': instance_id
                            }
                        ]
                    }
                ]
            )

if __name__ == "__main__":
    monitor_ec2_instances()
```

### Popular Libraries
```python
# Infrastructure and Cloud
import boto3          # AWS SDK
import azure.mgmt     # Azure SDK
import google.cloud   # Google Cloud SDK

# Automation and Configuration
import ansible_runner # Ansible automation
import fabric         # SSH automation
import paramiko       # SSH client

# Monitoring and Logging
import prometheus_client  # Metrics
import logging           # Logging
import requests          # HTTP requests

# Data Processing
import pandas        # Data analysis
import json          # JSON processing
import yaml          # YAML processing
```

## Go (Golang)

### DevOps Strengths
```go
// High performance
// Excellent concurrency
// Static compilation
// Cloud-native tools
// Container and Kubernetes ecosystem

// Example: Health Check Service
package main

import (
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "time"
)

type HealthStatus struct {
    Status    string    `json:"status"`
    Timestamp time.Time `json:"timestamp"`
    Services  map[string]bool `json:"services"`
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
    status := HealthStatus{
        Status:    "healthy",
        Timestamp: time.Now(),
        Services: map[string]bool{
            "database": checkDatabase(),
            "redis":    checkRedis(),
            "api":      checkAPI(),
        },
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(status)
}

func main() {
    http.HandleFunc("/health", healthHandler)
    log.Println("Health check service starting on :8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}
```

### Popular Tools Built with Go
```bash
# Container and Orchestration
- Docker
- Kubernetes
- containerd
- runc

# Infrastructure Tools
- Terraform
- Consul
- Vault
- Nomad

# Monitoring and Observability
- Prometheus
- Grafana
- Jaeger
- etcd

# CI/CD and DevOps
- GitLab Runner
- Drone CI
- Tekton
```

## JavaScript/Node.js

### DevOps Applications
```javascript
// API development and microservices
// Frontend build automation
// Serverless functions
// Monitoring dashboards
// CI/CD pipeline tools

// Example: Deployment Webhook Handler
const express = require('express');
const { exec } = require('child_process');
const crypto = require('crypto');

const app = express();
app.use(express.json());

// GitHub webhook handler
app.post('/webhook', (req, res) => {
    const signature = req.headers['x-hub-signature-256'];
    const payload = JSON.stringify(req.body);
    
    // Verify webhook signature
    const hmac = crypto.createHmac('sha256', process.env.WEBHOOK_SECRET);
    const digest = 'sha256=' + hmac.update(payload).digest('hex');
    
    if (signature !== digest) {
        return res.status(401).send('Unauthorized');
    }
    
    // Trigger deployment
    if (req.body.ref === 'refs/heads/main') {
        exec('npm run deploy', (error, stdout, stderr) => {
            if (error) {
                console.error(`Deployment failed: ${error}`);
                return res.status(500).send('Deployment failed');
            }
            console.log(`Deployment successful: ${stdout}`);
            res.status(200).send('Deployment triggered');
        });
    } else {
        res.status(200).send('No deployment needed');
    }
});

app.listen(3000, () => {
    console.log('Webhook server running on port 3000');
});
```

### DevOps Tools and Frameworks
```javascript
// Build Tools
- Webpack
- Gulp
- Grunt
- Rollup

// Testing Frameworks
- Jest
- Mocha
- Cypress
- Playwright

// Package Management
- npm
- Yarn
- pnpm

// Serverless Frameworks
- Serverless Framework
- AWS CDK (JavaScript)
- Pulumi (JavaScript)
```

## Java

### Enterprise DevOps
```java
// Enterprise application deployment
// Build automation (Maven/Gradle)
// Spring Boot microservices
// Jenkins plugins
// Monitoring and APM tools

// Example: Spring Boot Health Check
@RestController
@RequestMapping("/actuator")
public class HealthController {
    
    @Autowired
    private DatabaseHealthIndicator databaseHealth;
    
    @Autowired
    private RedisHealthIndicator redisHealth;
    
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> health = new HashMap<>();
        
        boolean isDatabaseHealthy = databaseHealth.isHealthy();
        boolean isRedisHealthy = redisHealth.isHealthy();
        
        health.put("status", isDatabaseHealthy && isRedisHealthy ? "UP" : "DOWN");
        health.put("database", isDatabaseHealthy ? "UP" : "DOWN");
        health.put("redis", isRedisHealthy ? "UP" : "DOWN");
        health.put("timestamp", Instant.now());
        
        HttpStatus status = (isDatabaseHealthy && isRedisHealthy) ? 
            HttpStatus.OK : HttpStatus.SERVICE_UNAVAILABLE;
            
        return ResponseEntity.status(status).body(health);
    }
}
```

### Build and Deployment Tools
```xml
<!-- Maven Build Configuration -->
<project>
    <groupId>com.example</groupId>
    <artifactId>devops-app</artifactId>
    <version>1.0.0</version>
    
    <properties>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
        <spring.boot.version>2.7.0</spring.boot.version>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
            <plugin>
                <groupId>com.spotify</groupId>
                <artifactId>dockerfile-maven-plugin</artifactId>
                <configuration>
                    <repository>${docker.image.prefix}/${project.artifactId}</repository>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

## Ruby

### DevOps Use Cases
```ruby
# Configuration management (Chef)
# Infrastructure testing (Test Kitchen)
# Deployment automation (Capistrano)
# Monitoring and alerting
# API automation and testing

# Example: Deployment Script with Capistrano
# config/deploy.rb
set :application, 'myapp'
set :repo_url, 'git@github.com:company/myapp.git'
set :deploy_to, '/var/www/myapp'
set :linked_files, %w{config/database.yml config/secrets.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle}

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart
  
  desc 'Run database migrations'
  task :migrate do
    on roles(:db) do
      within release_path do
        execute :rake, 'db:migrate RAILS_ENV=production'
      end
    end
  end
end
```

### Popular Ruby Tools
```ruby
# Configuration Management
- Chef
- Puppet (Ruby-based)

# Testing and Quality
- RSpec
- Cucumber
- RuboCop
- Brakeman

# Deployment
- Capistrano
- Mina

# Monitoring
- Sensu
- Flapjack
```

## PowerShell

### Windows DevOps
```powershell
# Windows infrastructure management
# Azure automation
# Active Directory management
# IIS deployment and configuration
# Windows container management

# Example: Azure Resource Deployment
param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$Location,
    
    [Parameter(Mandatory=$true)]
    [string]$TemplateFile
)

# Connect to Azure
Connect-AzAccount

# Create resource group if it doesn't exist
$resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $resourceGroup) {
    Write-Host "Creating resource group: $ResourceGroupName"
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
}

# Deploy ARM template
Write-Host "Deploying resources..."
$deployment = New-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $TemplateFile `
    -Verbose

if ($deployment.ProvisioningState -eq "Succeeded") {
    Write-Host "Deployment completed successfully" -ForegroundColor Green
} else {
    Write-Error "Deployment failed"
    exit 1
}
```

### PowerShell DSC (Desired State Configuration)
```powershell
# Infrastructure as Code for Windows
Configuration WebServerConfig {
    param(
        [string[]]$NodeName = 'localhost'
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    Node $NodeName {
        WindowsFeature IIS {
            Ensure = "Present"
            Name = "Web-Server"
        }
        
        WindowsFeature ASP {
            Ensure = "Present"
            Name = "Web-Asp-Net45"
        }
        
        File WebContent {
            Ensure = "Present"
            DestinationPath = "C:\inetpub\wwwroot\index.html"
            Contents = "<html><body><h1>Hello World!</h1></body></html>"
        }
    }
}

# Compile and apply configuration
WebServerConfig -NodeName "WebServer01"
Start-DscConfiguration -Path .\WebServerConfig -Wait -Verbose
```

## Language Selection Guidelines

### Choosing the Right Language
```bash
# Shell Scripting (Bash/PowerShell)
Use for:
- System administration tasks
- Simple automation scripts
- CI/CD pipeline steps
- Environment setup

# Python
Use for:
- Complex automation
- Data processing
- API development
- Cloud automation
- Machine learning ops

# Go
Use for:
- High-performance tools
- Container/Kubernetes tools
- Microservices
- System programming

# JavaScript/Node.js
Use for:
- Web applications
- Serverless functions
- Build tools
- Real-time applications

# Java
Use for:
- Enterprise applications
- Spring Boot microservices
- Android applications
- Big data processing

# Ruby
Use for:
- Configuration management
- Rapid prototyping
- Web applications
- Testing frameworks
```

### Performance Considerations
```bash
# Execution Speed (Fastest to Slowest)
1. Go, Rust, C/C++
2. Java, C#
<b>3. JavaScript</b>
<details>
<summary>Show Answer</summary>
Answer: V8
</details>

4. Python, Ruby
5. Shell scripts

# Development Speed (Fastest to Slowest)
1. Python, Ruby
2. JavaScript
3. Shell scripting
4. Java, C#
5. Go, Rust, C/C++

# Memory Usage (Lowest to Highest)
1. Go, Rust, C/C++
2. Java, C#
3. JavaScript
4. Python, Ruby
```

This comprehensive guide helps DevOps professionals choose and effectively use programming languages for various automation and infrastructure management tasks.