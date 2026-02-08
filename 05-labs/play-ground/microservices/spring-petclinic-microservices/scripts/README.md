# 🛠️ Utility Scripts for PetClinic Deployment

This directory contains automation scripts to streamline deployment and management of the Spring PetClinic microservices application.

---

## 📋 Available Scripts

### 1. **deploy.sh**
**Purpose**: End-to-end infrastructure deployment

**Usage**:
```bash
./scripts/deploy.sh [dev|staging|prod]
```

**What it does**:
1. Validates prerequisites (Terraform, AWS CLI, kubectl)
2. Initializes Terraform for the specified environment
3. Creates and applies infrastructure plan
4. Configures kubectl for the new EKS cluster
5. Displays cluster information and next steps

**Example**:
```bash
# Deploy to dev environment
./scripts/deploy.sh dev

# Deploy to production (requires confirmation)
./scripts/deploy.sh prod
```

---

### 2. **build-and-push.sh**
**Purpose**: Build Docker images and push to ECR

**Usage**:
```bash
./scripts/build-and-push.sh [env] [account-id] [region]
```

**What it does**:
1. Logs into AWS ECR
2. Builds Docker images for all microservices
3. Tags images with environment and timestamp
4. Pushes images to ECR repositories

**Example**:
```bash
# Build and push for dev (auto-detects account ID)
./scripts/build-and-push.sh dev

# Build and push with explicit parameters
./scripts/build-and-push.sh prod 123456789012 us-east-1
```

**Microservices Built**:
- petclinic-api-gateway
- petclinic-customers-service
- petclinic-vets-service
- petclinic-visits-service
- petclinic-config-server
- petclinic-discovery-server

---

### 3. **health-check.sh**
**Purpose**: Comprehensive health validation

**Usage**:
```bash
./scripts/health-check.sh [env]
```

**What it does**:
1. **Node Health**: Checks if EKS nodes are Ready
2. **Pod Status**: Validates pods are Running
3. **Service Endpoints**: Tests LoadBalancer provisioning
4. **RDS Connectivity**: Verifies database reachability

**Example**:
```bash
# Check dev environment health
./scripts/health-check.sh dev
```

**Sample Output**:
```
✅ Nodes are healthy
✅ All pods are running (6/6)
✅ LoadBalancer URL: http://abc123.us-east-1.elb.amazonaws.com
✅ RDS is reachable from pods
```

---

### 4. **cleanup.sh**
**Purpose**: Complete infrastructure teardown

**Usage**:
```bash
./scripts/cleanup.sh [env]
```

**What it does**:
1. Deletes Kubernetes namespace and resources
2. Waits for LoadBalancers to be deleted (prevents orphaned resources)
3. Destroys Terraform infrastructure
4. Verifies cleanup completion

**Safety Features**:
- **Production Protection**: Requires typing `destroy-prod-infrastructure` for prod
- **Orphan Detection**: Checks for leftover Load Balancers and ENIs
- **Graceful Deletion**: Waits for Kubernetes resources before destroying VPC

**Example**:
```bash
# Cleanup dev environment
./scripts/cleanup.sh dev

# Cleanup production (with confirmation)
./scripts/cleanup.sh prod
```

---

## 🎯 Typical Workflow

### Initial Deployment

```bash
# 1. Deploy infrastructure
./scripts/deploy.sh dev

# 2. Build and push images
./scripts/build-and-push.sh dev

# 3. Deploy to Kubernetes
kubectl apply -f helm/petclinic/

# 4. Verify health
./scripts/health-check.sh dev
```

### Updates

```bash
# Rebuild specific service
docker build -t petclinic-api-gateway ../spring-petclinic-api-gateway
# ... (manual ECR push)

# Or rebuild all
./scripts/build-and-push.sh dev

# Apply Kubernetes updates
kubectl rollout restart deployment/api-gateway -n petclinic
```

### Teardown

```bash
# Complete cleanup
./scripts/cleanup.sh dev
```

---

## 🔧 Prerequisites

All scripts require:
- **Terraform** >= 1.5.0
- **AWS CLI** >= 2.x (configured with credentials)
- **kubectl** >= 1.29
- **Docker** (for build-and-push.sh)
- **jq** (for parsing JSON outputs)

Install missing tools:
```bash
# On Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y jq curl unzip

# On macOS
brew install jq kubectl terraform
```

---

## 🛡️ Safety Features

- **Environment Validation**: Scripts reject invalid environment names
- **Production Guards**: Extra confirmations required for prod operations
- **Prerequisite Checks**: Scripts fail fast if required tools are missing
- **Colored Output**: Easy-to-read status messages (✅ success, ❌ error, ⚠️ warning)
- **Error Handling**: `set -euo pipefail` ensures scripts stop on errors

---

## 📊 Script Execution Times

| Script | Dev | Staging | Prod |
|:---|:---|:---|:---|
| **deploy.sh** | ~25 min | ~25 min | ~30 min |
| **build-and-push.sh** | ~10 min | ~10 min | ~10 min |
| **health-check.sh** | ~1 min | ~1 min | ~1 min |
| **cleanup.sh** | ~15 min | ~15 min | ~20 min |

*Times are approximate and depend on AWS region and service load*

---

## 🐛 Troubleshooting

### Script Permission Denied

```bash
chmod +x scripts/*.sh
```

### AWS Credentials Not Found

```bash
aws configure
# Or use AWS SSO
aws sso login --profile your-profile
```

### kubectl Not Configured

```bash
# Manually configure
aws eks update-kubeconfig --region us-east-1 --name dev-petclinic-cluster
```

---

## 📚 Related Documentation

- [Infrastructure README](../terraform/README.md)
- [Deployment Runbook](../terraform/RUNBOOK_AWS_DEPLOY.md)
- [Main Project README](../readme.md)

---

**Status**: ✅ Production-Ready Automation
**Last Updated**: 2026-02-08
