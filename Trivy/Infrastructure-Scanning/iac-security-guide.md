# Infrastructure as Code Security with Trivy

## Terraform Scanning

### Basic Terraform Scanning
```bash
# Scan Terraform files
trivy config terraform/

# Scan specific file
trivy config main.tf

# Scan with severity filter
trivy config --severity HIGH,CRITICAL terraform/
```

### Terraform Security Issues
```hcl
# Example insecure Terraform code
resource "aws_s3_bucket" "example" {
  bucket = "my-bucket"
  
  # ISSUE: Public read access
  acl = "public-read"
}

resource "aws_security_group" "web" {
  # ISSUE: SSH open to world
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ISSUE: Unencrypted EBS volume
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t3.micro"
  
  root_block_device {
    encrypted = false
  }
}
```

### Secure Terraform Patterns
```hcl
# Secure S3 bucket
resource "aws_s3_bucket" "secure_example" {
  bucket = "my-secure-bucket-${random_string.suffix.result}"
}

resource "aws_s3_bucket_public_access_block" "secure_example" {
  bucket = aws_s3_bucket.secure_example.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure_example" {
  bucket = aws_s3_bucket.secure_example.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Secure security group
resource "aws_security_group" "secure_web" {
  name_prefix = "secure-web-"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]  # Restricted access
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Encrypted EBS volume
resource "aws_instance" "secure_web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  
  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }
}
```

## Kubernetes Scanning

### Kubernetes Manifest Scanning
```bash
# Scan Kubernetes manifests
trivy config k8s/

# Scan specific manifest
trivy config deployment.yaml

# Scan Helm charts
trivy config --file-patterns helm:Chart.yaml charts/
```

### Kubernetes Security Issues
```yaml
# Insecure Kubernetes deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: insecure-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: insecure-app
  template:
    metadata:
      labels:
        app: insecure-app
    spec:
      containers:
      - name: app
        image: nginx:latest  # ISSUE: Using latest tag
        ports:
        - containerPort: 80
        securityContext:
          runAsUser: 0       # ISSUE: Running as root
          privileged: true   # ISSUE: Privileged container
        # ISSUE: No resource limits
        # ISSUE: No health checks
```

### Secure Kubernetes Patterns
```yaml
# Secure Kubernetes deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 2000
      containers:
      - name: app
        image: nginx:1.21-alpine  # Specific version
        ports:
        - containerPort: 8080
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
          capabilities:
            drop:
            - ALL
        resources:
          limits:
            cpu: 500m
            memory: 512Mi
          requests:
            cpu: 250m
            memory: 256Mi
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: tmp
          mountPath: /tmp
      volumes:
      - name: tmp
        emptyDir: {}
```

## Docker Compose Scanning

### Docker Compose Security
```bash
# Scan Docker Compose files
trivy config docker-compose.yml

# Scan with custom patterns
trivy config --file-patterns compose:docker-compose*.yml .
```

### Secure Docker Compose
```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    image: nginx:1.21-alpine
    ports:
      - "80:80"
    user: "1000:1000"
    read_only: true
    tmpfs:
      - /tmp
      - /var/cache/nginx
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - SETGID
      - SETUID
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M

  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB_FILE: /run/secrets/postgres_db
      POSTGRES_USER_FILE: /run/secrets/postgres_user
      POSTGRES_PASSWORD_FILE: /run/secrets/postgres_password
    secrets:
      - postgres_db
      - postgres_user
      - postgres_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    user: "999:999"
    read_only: true
    tmpfs:
      - /tmp
      - /var/run/postgresql

secrets:
  postgres_db:
    file: ./secrets/postgres_db.txt
  postgres_user:
    file: ./secrets/postgres_user.txt
  postgres_password:
    file: ./secrets/postgres_password.txt

volumes:
  postgres_data:
```

## Cloud Formation Scanning

### AWS CloudFormation
```bash
# Scan CloudFormation templates
trivy config --file-patterns cloudformation:*.yaml cloudformation/
trivy config --file-patterns cloudformation:*.json cloudformation/
```

### Secure CloudFormation Template
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Secure S3 bucket with encryption and access controls'

Resources:
  SecureS3Bucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${AWS::StackName}-secure-bucket-${AWS::AccountId}'
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: AES256
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true
      VersioningConfiguration:
        Status: Enabled
      LoggingConfiguration:
        DestinationBucketName: !Ref LoggingBucket
        LogFilePrefix: access-logs/
      NotificationConfiguration:
        CloudWatchConfigurations:
          - Event: s3:ObjectCreated:*
            CloudWatchConfiguration:
              LogGroupName: !Ref S3LogGroup

  LoggingBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${AWS::StackName}-logging-${AWS::AccountId}'
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: AES256

  S3LogGroup:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: !Sub '/aws/s3/${AWS::StackName}'
      RetentionInDays: 30
```

## Policy as Code

### Custom Security Policies
```yaml
# security-policy.yaml
package trivy

# Deny containers running as root
deny[msg] {
  input.kind == "Deployment"
  input.spec.template.spec.containers[_].securityContext.runAsUser == 0
  msg := "Container should not run as root user"
}

# Require resource limits
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.resources.limits
  msg := "Container must have resource limits defined"
}

# Require health checks
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.livenessProbe
  msg := "Container must have liveness probe defined"
}
```

### Policy Enforcement
```bash
# Use custom policies
trivy config --policy security-policy.yaml k8s/

# Multiple policy files
trivy config --policy policies/ k8s/

# Combine with built-in checks
trivy config --policy policies/ --compliance k8s-cis k8s/
```