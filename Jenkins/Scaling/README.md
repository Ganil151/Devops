# Jenkins Scaling

Master-slave architecture, distributed builds, and horizontal scaling strategies for Jenkins.

## Master-Slave Architecture

### Jenkins Master Configuration
```bash
# Master node responsibilities:
- Job scheduling and dispatching
- Build triggering and monitoring  
- Plugin management
- User interface
- API endpoints
```

### Slave Node Setup

#### SSH Slave Configuration
```bash
# Create Jenkins user on slave
sudo useradd -m -s /bin/bash jenkins
sudo mkdir -p /home/jenkins/.ssh
sudo chown jenkins:jenkins /home/jenkins/.ssh
sudo chmod 700 /home/jenkins/.ssh

# Copy master's public key
sudo cp master_key.pub /home/jenkins/.ssh/authorized_keys
sudo chown jenkins:jenkins /home/jenkins/.ssh/authorized_keys
sudo chmod 600 /home/jenkins/.ssh/authorized_keys

# Install Java on slave
sudo apt update
sudo apt install openjdk-11-jdk -y

# Create workspace directory
sudo mkdir -p /var/lib/jenkins
sudo chown jenkins:jenkins /var/lib/jenkins
```

#### JNLP Slave Configuration
```bash
# Download slave agent
wget http://jenkins-master:8080/jnlpJars/agent.jar

# Run JNLP agent
java -jar agent.jar -jnlpUrl http://jenkins-master:8080/computer/slave-node/slave-agent.jnlp -secret <secret>

# Create systemd service
sudo tee /etc/systemd/system/jenkins-slave.service << EOF
[Unit]
Description=Jenkins Slave
After=network.target

[Service]
Type=simple
User=jenkins
WorkingDirectory=/home/jenkins
ExecStart=/usr/bin/java -jar /home/jenkins/agent.jar -jnlpUrl http://jenkins-master:8080/computer/slave-node/slave-agent.jnlp -secret <secret>
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable jenkins-slave
sudo systemctl start jenkins-slave
```

## Dynamic Slave Provisioning

### Docker-based Slaves
```groovy
// Pipeline with Docker agent
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

### Kubernetes Plugin Configuration
```yaml
# kubernetes-pod-template.yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.8.1-openjdk-11
    command:
    - cat
    tty: true
    volumeMounts:
    - name: maven-cache
      mountPath: /root/.m2
  - name: docker
    image: docker:dind
    securityContext:
      privileged: true
  volumes:
  - name: maven-cache
    emptyDir: {}
```

```groovy
// Pipeline with Kubernetes agent
pipeline {
    agent {
        kubernetes {
            yaml libraryResource('kubernetes-pod-template.yaml')
        }
    }
    
    stages {
        stage('Build') {
            steps {
                container('maven') {
                    sh 'mvn clean package'
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                container('docker') {
                    sh 'docker build -t myapp .'
                }
            }
        }
    }
}
```

### AWS EC2 Plugin Configuration
```bash
# Install EC2 plugin
jenkins-cli install-plugin ec2

# Configure EC2 cloud in Jenkins
# Manage Jenkins > Manage Nodes and Clouds > Configure Clouds
# Add Amazon EC2 cloud with:
- AWS credentials
- Region
- AMI ID
- Instance type
- Security groups
- Key pair
```

## Load Balancing

### HAProxy Configuration
```bash
# /etc/haproxy/haproxy.cfg
global
    daemon
    maxconn 4096

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend jenkins_frontend
    bind *:80
    default_backend jenkins_backend

backend jenkins_backend
    balance roundrobin
    option httpchk GET /login
    server jenkins1 jenkins-master1:8080 check
    server jenkins2 jenkins-master2:8080 check backup
```

### Nginx Load Balancer
```nginx
upstream jenkins_backend {
    server jenkins-master1:8080 weight=3;
    server jenkins-master2:8080 weight=1 backup;
}

server {
    listen 80;
    server_name jenkins.example.com;
    
    location / {
        proxy_pass http://jenkins_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support for Jenkins CLI
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

## Auto-Scaling Scripts

### AWS Auto Scaling
```bash
#!/bin/bash
# jenkins-autoscale-aws.sh

JENKINS_URL="http://jenkins-master:8080"
QUEUE_THRESHOLD=5
MIN_SLAVES=2
MAX_SLAVES=10

# Get current queue size
QUEUE_SIZE=$(curl -s "$JENKINS_URL/queue/api/json" | jq '.items | length')

# Get current slave count
SLAVE_COUNT=$(curl -s "$JENKINS_URL/computer/api/json" | jq '.computer | length - 1')

echo "Queue size: $QUEUE_SIZE, Slave count: $SLAVE_COUNT"

if [[ "$QUEUE_SIZE" -gt "$QUEUE_THRESHOLD" && "$SLAVE_COUNT" -lt "$MAX_SLAVES" ]]; then
    echo "Scaling up: launching new slave instance"
    
    # Launch new EC2 instance
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id ami-12345678 \
        --instance-type t3.medium \
        --key-name jenkins-key \
        --security-group-ids sg-12345678 \
        --user-data file://slave-userdata.sh \
        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=jenkins-slave},{Key=AutoScale,Value=true}]' \
        --query 'Instances[0].InstanceId' \
        --output text)
    
    echo "Launched instance: $INSTANCE_ID"
    
elif [[ "$QUEUE_SIZE" -eq 0 && "$SLAVE_COUNT" -gt "$MIN_SLAVES" ]]; then
    echo "Scaling down: terminating idle slave"
    
    # Find auto-scaled instances
    INSTANCE_ID=$(aws ec2 describe-instances \
        --filters "Name=tag:AutoScale,Values=true" "Name=instance-state-name,Values=running" \
        --query 'Reservations[0].Instances[0].InstanceId' \
        --output text)
    
    if [[ "$INSTANCE_ID" != "None" ]]; then
        aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"
        echo "Terminated instance: $INSTANCE_ID"
    fi
fi
```

### Kubernetes Auto Scaling
```yaml
# jenkins-slave-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins-slave
spec:
  replicas: 2
  selector:
    matchLabels:
      app: jenkins-slave
  template:
    metadata:
      labels:
        app: jenkins-slave
    spec:
      containers:
      - name: jenkins-slave
        image: jenkins/inbound-agent:latest
        env:
        - name: JENKINS_URL
          value: "http://jenkins-master:8080"
        - name: JENKINS_SECRET
          valueFrom:
            secretKeyRef:
              name: jenkins-slave-secret
              key: secret
        - name: JENKINS_AGENT_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name

---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: jenkins-slave-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: jenkins-slave
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## Performance Optimization

### Master Node Optimization
```bash
# JVM tuning for Jenkins master
JAVA_OPTS="-Xms2g -Xmx4g -XX:+UseG1GC -XX:+UseStringDeduplication -Djava.awt.headless=true"

# System tuning
echo 'jenkins soft nofile 65536' >> /etc/security/limits.conf
echo 'jenkins hard nofile 65536' >> /etc/security/limits.conf

# Jenkins configuration optimization
# Manage Jenkins > Configure System
# - Set number of executors to 0 on master
# - Increase build record retention
# - Configure workspace cleanup
```

### Build Distribution Strategy
```groovy
// Pipeline with node selection
pipeline {
    agent none
    
    stages {
        stage('Build') {
            agent {
                label 'build-nodes'
            }
            steps {
                sh 'make build'
            }
        }
        
        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    agent {
                        label 'test-nodes'
                    }
                    steps {
                        sh 'make test-unit'
                    }
                }
                
                stage('Integration Tests') {
                    agent {
                        label 'integration-nodes'
                    }
                    steps {
                        sh 'make test-integration'
                    }
                }
            }
        }
        
        stage('Deploy') {
            agent {
                label 'deploy-nodes'
            }
            steps {
                sh 'make deploy'
            }
        }
    }
}
```

## Monitoring Scaled Infrastructure

### Multi-Master Monitoring
```bash
#!/bin/bash
# monitor-jenkins-cluster.sh

MASTERS=("jenkins-master1:8080" "jenkins-master2:8080")
ALERT_EMAIL="admin@example.com"

for master in "${MASTERS[@]}"; do
    echo "Checking $master..."
    
    if curl -s -f "http://$master/login" > /dev/null; then
        echo "✓ $master is healthy"
        
        # Check queue size
        QUEUE_SIZE=$(curl -s "http://$master/queue/api/json" | jq '.items | length')
        echo "  Queue size: $QUEUE_SIZE"
        
        # Check slave count
        SLAVE_COUNT=$(curl -s "http://$master/computer/api/json" | jq '.computer | length - 1')
        echo "  Slave count: $SLAVE_COUNT"
        
    else
        echo "✗ $master is unhealthy"
        echo "Jenkins master $master is down" | mail -s "Jenkins Alert" "$ALERT_EMAIL"
    fi
    
    echo "---"
done
```

This comprehensive Jenkins scaling guide provides enterprise-grade distributed build capabilities and horizontal scaling strategies.