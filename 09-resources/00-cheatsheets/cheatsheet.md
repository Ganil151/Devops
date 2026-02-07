# 05-terraform-iac
# 08-cicd-pipelines

## 🛡️ Best Practices (Junior to Senior)
- **Build Once, Deploy Many**: Build a single artifact (JAR, Docker Image) and promote it through environments. Don't rebuild for Prod.
- **Fail Fast**: Run unit tests, linting, and security scans in the first stage.
- **Immutable Artifacts**: Tag artifacts with the Git SHA (e.g., `app:a1b2c3d`), never just `latest`.
- **Infrastructure as Code**: Define pipelines in code (`Jenkinsfile`, `.github/workflows`) stored in the repo.

- **Remote State**: Never store `terraform.tfstate` locally. Use S3 + DynamoDB (locking).
- **Pin Versions**: Explicitly pin provider and module versions to avoid breaking changes.
- **Small State Files**: Break infrastructure into layers (Networking, Data, App) to reduce "blast radius."
- **Format & Validate**: Always run `terraform fmt` and `terraform validate` in CI pipelines.

---

## 🏗️ Modules & Dynamic Blocks
## 🤵 Jenkinsfile (Declarative)

### Calling a Reusable Module
### Standard Pipeline Structure
```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'my-registry.com'
        IMAGE_NAME = "myapp:${GIT_COMMIT.take(7)}"
    }

Don't reinvent the wheel; use modules for VPCs, Clusters, etc.

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "production-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
}
```

### Dynamic Blocks (DRY Security Groups)

Iterate over a list of ports instead of writing multiple `ingress` blocks.

```hcl
variable "ingress_ports" {
  type    = list(number)
  default = [80, 443, 22]
}

resource "aws_security_group" "web" {
  name = "web-sg"

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    stages {
        stage('Build & Test') {
            steps {
                sh 'mvn clean verify'
            }
        }
        
        stage('Docker Build') {
            steps {
                sh "docker build -t $IMAGE_NAME ."
            }
        }
        
        stage('Deploy Dev') {
            when { branch 'develop' }
            steps {
                sh './deploy.sh dev'
            }
        }
    }
  }
    
    post {
        always {
            junit 'target/surefire-reports/*.xml'
        }
        failure {
            mail to: 'team@example.com', subject: 'Build Failed'
        }
    }
}
```

---

## 🔄 State Management
## 🐙 GitHub Actions

### Inspecting State
### Workflow Syntax
File: `.github/workflows/ci.yaml`

List all resources currently tracked by Terraform.
```yaml
name: CI Pipeline

```bash
terraform state list
```
on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

### Moving Resources (Refactoring)

Move a resource into a module (or rename it) without destroying/recreating it.

```bash
terraform state mv aws_instance.web module.web_server.aws_instance.this
jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: 'maven'
        
    - name: Build with Maven
      run: mvn -B package --file pom.xml
      
    - name: Upload Artifact
      uses: actions/upload-artifact@v3
      with:
        name: app-jar
        path: target/*.jar
```

### Importing Existing Infrastructure

Bring a manually created S3 bucket under Terraform management.

```bash
# 1. Define empty resource in main.tf
# resource "aws_s3_bucket" "legacy" {}

# 2. Import
terraform import aws_s3_bucket.legacy my-existing-bucket-name
```

---

## ⚡ Lifecycle Hooks

### Create Before Destroy

Essential for zero-downtime replacements (e.g., Launch Templates, ASGs).

```hcl
resource "aws_launch_template" "app" {
  name_prefix   = "app-v1-"
  image_id      = "ami-0123456789abcdef0"
  instance_type = "t3.micro"

  lifecycle {
    create_before_destroy = true
  }
}
```

### Prevent Destruction

Safety lock for critical stateful resources (Databases, S3 Buckets).

```hcl
resource "aws_db_instance" "production" {
  allocated_storage = 100
  engine            = "postgres"

  lifecycle {
    prevent_destroy = true
  }
}
```
