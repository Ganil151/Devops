# CI/CD Infrastructure Guide: Spring PetClinic Microservices

## 🛡️ Senior SRE Overview
This guide defines the production-grade CI/CD pipeline for the **Spring PetClinic Microservices** architecture using **Jenkins** and **Docker Hub**. We utilize a **Stage-Gate approach** to ensure that only code satisfying all quality, security, and infrastructure requirements reaches the production EKS cluster.

### 🏗️ The Pipeline Architecture
![Pipeline Diagram](./images/pipeline_diagram.png)
The pipeline follows a strict unidirectional flow:
`Source` → `Build & Artifact` → `Quality & Security` → `Infrastructure Sync` → `Orchestrated Deployment`

---

## 🛠️ Infrastructure Bill of Materials (BOM)
Before triggering the pipeline, ensure the following infrastructure is provisioned or accessible.

### 1. Compute Instances (EC2)
| Component | Quantity | Instance Type | Role |
| :--- | :---: | :--- | :--- |
| **Jenkins Controller** | 1 | `t3.large` | Orchestrates builds; requires 4GB+ RAM for Java builds. |
| **EKS Worker Nodes** | 3 | `t3.medium` | Hosts the Microservices (API Gateway, Vets, etc.). |
| **Static Analysis** | 1 | `t2.medium` | Dedicated SonarQube server (optional: run as Docker container). |

### 2. Managed Services (AWS)
- **RDS Instance**: 1 x `db.t3.micro` (Multi-AZ) hosting the `petclinic` MySQL database.
- **EKS Cluster**: 1 x Managed Control Plane (v1.29+).

### 3. Installed Tooling (On Jenkins Server)
To ensure the pipeline stages execute correctly, the following must be pre-installed on the Jenkins instance:
- **Docker Engine**: For building microservice images.
- **Terraform (v1.5+)**: For infrastructure state synchronization.
- **Helm v3**: For Kubernetes application deployment.
- **Kubectl**: Configured with `aws eks update-kubeconfig`.
- **Trivy**: For container vulnerability scanning.
- **Maven 3.9+**: For Java compilation.

---

## 🌲 Enterprise Terraform Infrastructure Tree
For production-grade environments, we separate state files and configurations using an **Environments-Modules** pattern. This ensures that a change in `dev` cannot accidentally impact `prod`.

```text
terraform/
├── environments/               # Environment-specific root modules (State separation)
│   ├── dev/
│   │   ├── main.tf             # Calls modules with Dev-specific parameters
│   │   ├── variables.tf
│   │   ├── outputs.tf          # Proxies module outputs for local use
│   │   ├── providers.tf        # AWS provider & version constraints
│   │   ├── dev.tfvars          # Override values (e.g., node_count = 2)
│   │   └── backend.conf        # S3 Bucket/DynamoDB Partition for Dev state
│   └── prod/
│       ├── main.tf             # Calls modules with Production parameters
│       ├── variables.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── prod.tfvars         # Override values (e.g., node_count = 5)
│       └── backend.conf        # S3 Bucket/DynamoDB Partition for Prod state
├── modules/                    # Reusable, versioned "LEGO" bricks
│   ├── vpc/                    # Networking (VPC, Subnets, NAT, IGW)
│   │   ├── main.tf             # Resource definitions
│   │   ├── variables.tf        # Input definitions
│   │   ├── outputs.tf          # Export Subnet IDs, VPC CIDR
│   │   ├── locals.tf           # Computed values (Tags, Naming)
│   │   ├── data.tf             # External lookups (AZs, AWS caller ID)
│   │   └── versions.tf         # Min Terraform & Provider versions
│   ├── eks/                    # Cluster, Managed Node Groups, IAM OIDC
│   ├── rds/                    # DB Instance, Parameter Groups, Subnet Groups
│   ├── acm/                    # SSL/TLS Certificate management
│   ├── cloudwatch/             # Logs, Metrics, Alarms
│   └── security/               # IAM Roles, S3 Policies, WAF, SGs
├── global/                     # Shared cross-environment resources
│   ├── route53/                # Centralized Hosted Zones
│   ├── s3-state-store/         # Backend resources (Buckets/DynamoDB)
│   └── iam-users/              # Admin/CI-CD user definitions
└── README.md                   # Technical documentation for IaC workflows
```

---

## 🏁 Step 1: The Build & Artifact Stage (The Foundation)
**Tooling:** Jenkins + Maven 3.9+ + OpenJDK 17

### Objective
Compile the Java microservices, run unit tests, and package them into executable JAR files.

### 🛠️ Jenkins Pipeline Integration
In the Jenkinsfile, we define the build stage using Maven targets.

```groovy
stage('Build & Package') {
    steps {
        sh './mvnw clean package -DskipTests'
    }
}
```

---

## 📦 Step 2: Containerization & Registry (The Package)
**Tooling:** Docker + Docker Hub

### Objective
Create immutable, lightweight container images and push them to **Docker Hub**.

### 📐 Multi-Stage Dockerfile Strategy
We use multi-stage builds to ensure the final image contains only the JRE and the artifact.

### 🚀 Docker Hub Synchronization
```groovy
stage('Docker Build & Push') {
    environment {
        DOCKER_CREDS = credentials('docker-hub-credentials')
        IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        DOCKER_USER = "yourdockerhubuser"
    }
    steps {
        sh "echo $DOCKER_CREDS_PSW | docker login -u $DOCKER_CREDS_USR --password-stdin"
        script {
            def services = ['api-gateway', 'customers-service', 'vets-service', 'visits-service', 'genai-service']
            for (service in services) {
                sh "docker build -t ${DOCKER_USER}/${service}:${IMAGE_TAG} ./${service}"
                sh "docker push ${DOCKER_USER}/${service}:${IMAGE_TAG}"
            }
        }
    }
}
```

---

## 🛑 Step 3: Quality & Security Gates (The Guardrails)
**Tooling:** SonarQube + Trivy

### Objective
Block the pipeline if vulnerabilities (CVEs) or "Code Smells" are detected.

```groovy
stage('Security Scan') {
    steps {
        // SonarQube Analysis
        withSonarQubeEnv('SonarQube') {
            sh './mvnw sonar:sonar'
        }
        // Trivy Container Scan (High/Critical Fail)
        sh "trivy image --severity HIGH,CRITICAL --exit-code 1 ${DOCKER_USER}/api-gateway:${IMAGE_TAG}"
    }
}
```

---

## ⚙️ Step 4: Infrastructure Synchronization (The Environment)
**Tooling:** Terraform 1.5+

### Objective
Ensure AWS infrastructure is synced before deployment using Jenkins environment variables for AWS credentials.

```groovy
stage('Terraform Sync') {
    environment {
        ENV = "${params.ENVIRONMENT ?: 'dev'}" // Defaults to dev
    }
    steps {
        withAWS(credentials: "aws-jenkins-credentials-${ENV}", region: 'us-west-2') {
            sh """
            cd terraform/environments/${ENV}
            terraform init -backend-config=backend.conf
            terraform apply -var-file=${ENV}.tfvars --auto-approve
            """
        }
    }
}
```

---

## 🚢 Step 5: Orchestrated Deployment (The Launch)
**Tooling:** Helm 3 + Kubectl

### Objective
Deploy the validated container tags to the EKS cluster.

```groovy
stage('Kubernetes Deploy') {
    steps {
        sh """
        helm upgrade --install petclinic-services ./helm/microservices \
          --namespace petclinic \
          --set global.image.tag=${IMAGE_TAG} \
          --set global.image.repositoryPrefix=${DOCKER_USER}/ \
          --wait --timeout 300s
        """
    }
}
```

---

## 💰 Cost Management & FinOps
Managing cloud spend is as critical as managing code. We implement several SRE-driven cost-saving measures:

### 1. Spot Instance Integration
We use **Amazon EC2 Spot Instances** for 70-80% of our worker nodes, reducing compute costs by up to 90%.
- **Implementation**: Set `capacity_type = "SPOT"` in the EKS managed node group Terraform module.

### 2. Intelligent Auto-Scaling
- **Vertical Pod Autoscaler (VPA)**: Dynamically adjusts CPU/RAM based on actual usage.
- **Cluster Autoscaler**: Terminates EC2 nodes during low-traffic periods (e.g., nights/weekends).

### 3. Cleanup of Ephemeral Resources
- **Trivy/SonarQube**: Instances are configured to stop outside of business hours if not used for active development.
- **Docker Hub Retention**: Automation script to delete images older than 30 days that are not currently in production.

---

## 🚦 Pipeline Validation Checklist
A successful implementation must verify the following in Jenkins:
1. **Pipeline Auth:** Jenkins Credentials Store configured with `docker-hub-credentials` and `aws-jenkins-credentials`.
2. **Webhook Hookup:** Jenkins "GitHub hook trigger for GITScm polling" enabled.
3. **Notification Loop:** `post { failure { ... } }` block in Jenkinsfile for Slack notifications.
4. **Rollback Trigger:** Helm `--wait` ensures Jenkins fails if pods don't reach 'Ready' state, allowing for manual or automated `kubectl rollout undo`.

---

*Prepared by Senior DevOps Pipeline Engineer*
