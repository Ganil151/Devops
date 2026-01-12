# Cloud DevOps Monitoring

Complete guide to monitoring cloud DevOps pipelines, infrastructure, and applications.

## Pipeline Monitoring
```bash
# CI/CD Pipeline Metrics
- Build success rate
- Deployment frequency
- Lead time for changes
- Mean time to recovery (MTTR)
- Change failure rate

# Jenkins Pipeline Monitoring
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    def startTime = System.currentTimeMillis()
                    // Build steps
                    def duration = System.currentTimeMillis() - startTime
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'reports',
                        reportFiles: 'build-metrics.html',
                        reportName: 'Build Metrics'
                    ])
                }
            }
        }
    }
}
```

## Infrastructure Monitoring
```bash
# Terraform State Monitoring
# Infrastructure drift detection
# Resource compliance checking

# Terraform Cloud Monitoring
terraform {
  cloud {
    organization = "my-org"
    workspaces {
      name = "production"
    }
  }
}

# Drift Detection Script
#!/bin/bash
terraform plan -detailed-exitcode
if [ $? -eq 2 ]; then
    echo "Infrastructure drift detected!"
    # Send alert
    curl -X POST -H 'Content-type: application/json' \
        --data '{"text":"Infrastructure drift detected in production"}' \
        $SLACK_WEBHOOK_URL
fi
```

## Application Performance Monitoring
```bash
# APM Integration
# Distributed tracing
# Performance metrics

# New Relic Integration
version: '3'
services:
  app:
    image: myapp:latest
    environment:
      - NEW_RELIC_LICENSE_KEY=${NEW_RELIC_LICENSE_KEY}
      - NEW_RELIC_APP_NAME=MyApp
    volumes:
      - ./newrelic.ini:/app/newrelic.ini

# Datadog APM
DD_AGENT_HOST=datadog-agent \
DD_TRACE_ENABLED=true \
DD_SERVICE=myapp \
DD_ENV=production \
python app.py
```

## Log Aggregation
```bash
# Centralized logging
# Log analysis and alerting
# Compliance and audit trails

# ELK Stack Configuration
version: '3'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.15.0
    environment:
      - discovery.type=single-node
  
  logstash:
    image: docker.elastic.co/logstash/logstash:7.15.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
  
  kibana:
    image: docker.elastic.co/kibana/kibana:7.15.0
    ports:
      - "5601:5601"
```