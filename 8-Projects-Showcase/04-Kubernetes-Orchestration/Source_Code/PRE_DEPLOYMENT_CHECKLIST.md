# 📋 Pre-Deployment Checklist

Use this checklist to ensure you're ready to deploy the Global Microservices Mesh project.

---

## ✅ Prerequisites Verification

### Required Tools

- [ ] **Terraform** (v1.0+)
  ```bash
  terraform version
  ```

- [ ] **kubectl** (v1.24+)
  ```bash
  kubectl version --client
  ```

- [ ] **Helm** (v3.x+)
  ```bash
  helm version
  ```

- [ ] **AWS CLI** (v2.x+)
  ```bash
  aws --version
  ```

- [ ] **Docker** (for local testing)
  ```bash
  docker --version
  ```

- [ ] **ArgoCD CLI** (v2.x+) - Optional but recommended
  ```bash
  argocd version
  ```

---

## 🔐 AWS Configuration

- [ ] AWS credentials configured
  ```bash
  aws configure list
  ```

- [ ] Valid AWS access key and secret key set

- [ ] Default region configured (recommended: us-east-1)

- [ ] Verify AWS account access
  ```bash
  aws sts get-caller-identity
  ```

- [ ] Check AWS service quotas for:
  - [ ] VPC (at least 1 available)
  - [ ] EKS clusters (at least 1 available)
  - [ ] EC2 instances (at least 4 t3.medium instances)
  - [ ] Elastic IPs (at least 2 available)

---

## 📁 Repository Setup

- [ ] Clone or navigate to the DevOps repository
  ```bash
  cd C:\Users\Ganil\Documents\Devops\8-Porjects-Showcase\Global-Microservices-Mesh
  ```

- [ ] Verify all required files exist:
  - [ ] `README.md`
  - [ ] `DEPLOYMENT_GUIDE.md`
  - [ ] `deploy.ps1` (Windows)
  - [ ] `deploy.sh` (Linux/Mac)
  - [ ] `Jenkinsfile`
  - [ ] `infra/main.tf`
  - [ ] `infra/mesh.tf`
  - [ ] `infra/variables.tf`
  - [ ] `gitops/argocd-app.yaml`

---

## 🔧 Infrastructure Planning

- [ ] Review Terraform variables in `infra/variables.tf`

- [ ] Decide on cluster configuration:
  - [ ] Cluster name: `_________________`
  - [ ] AWS region: `_________________`
  - [ ] Node instance type: `_________________`
  - [ ] Desired node count: `_________________`

- [ ] Estimate costs using AWS Pricing Calculator

- [ ] Determine if using S3 backend for Terraform state
  - [ ] If yes, create S3 bucket: `_________________`
  - [ ] Enable versioning on S3 bucket
  - [ ] Create DynamoDB table for state locking

---

## 🛡️ Security Considerations

- [ ] Review IAM permissions required for deployment

- [ ] Ensure AWS credentials have permissions for:
  - [ ] VPC creation and management
  - [ ] EKS cluster creation and management
  - [ ] EC2 instance management
  - [ ] IAM role creation (for EKS)
  - [ ] Security group management

- [ ] Plan for secrets management:
  - [ ] Will you use HashiCorp Vault?
  - [ ] Will you use AWS Secrets Manager?
  - [ ] Will you use Kubernetes Secrets?

- [ ] Review security group rules in Terraform code

---

## 📊 Monitoring & Observability

- [ ] Decide on monitoring stack components:
  - [ ] Prometheus (recommended)
  - [ ] Grafana (recommended)
  - [ ] Kiali (recommended for Istio)
  - [ ] Jaeger (optional - distributed tracing)

- [ ] Plan for log aggregation:
  - [ ] CloudWatch Logs
  - [ ] ELK Stack
  - [ ] Loki

---

## 🔄 CI/CD Setup

- [ ] Jenkins server available and accessible

- [ ] Jenkins plugins installed:
  - [ ] Kubernetes Plugin
  - [ ] Docker Pipeline Plugin
  - [ ] AWS Steps Plugin
  - [ ] ArgoCD Plugin (if available)

- [ ] Jenkins credentials configured:
  - [ ] AWS credentials
  - [ ] Docker registry credentials
  - [ ] Git credentials
  - [ ] Kubernetes credentials

- [ ] Jenkins shared library configured

---

## 🌐 Network Planning

- [ ] VPC CIDR block decided: `_________________`

- [ ] Public subnet CIDRs: `_________________`

- [ ] Private subnet CIDRs: `_________________`

- [ ] Availability zones: `_________________`

- [ ] NAT Gateway strategy:
  - [ ] One NAT Gateway per AZ (high availability)
  - [ ] Single NAT Gateway (cost-effective)

---

## 📝 Documentation Review

- [ ] Read the complete [Deployment Guide](./DEPLOYMENT_GUIDE.md)

- [ ] Understand the architecture diagram

- [ ] Review the Jenkinsfile pipeline stages

- [ ] Understand the GitOps workflow with ArgoCD

- [ ] Review Istio service mesh configuration

---

## 🚀 Deployment Decision

- [ ] Choose deployment method:
  - [ ] Automated (using deploy.ps1 or deploy.sh)
  - [ ] Manual (following DEPLOYMENT_GUIDE.md)

- [ ] Decide on optional components:
  - [ ] Install ArgoCD? (Yes/No)
  - [ ] Install monitoring stack? (Yes/No)
  - [ ] Install Vault? (Yes/No)

- [ ] Set deployment time window: `_________________`

- [ ] Identify rollback plan if deployment fails

---

## 🧪 Testing Plan

- [ ] Plan for post-deployment verification:
  - [ ] Verify all pods are running
  - [ ] Test Istio sidecar injection
  - [ ] Verify service mesh connectivity
  - [ ] Test ingress gateway accessibility

- [ ] Prepare sample application for testing:
  - [ ] Spring PetClinic microservices
  - [ ] Custom test application
  - [ ] Other: `_________________`

---

## 📞 Support & Escalation

- [ ] Identify team members for support during deployment

- [ ] Document escalation contacts:
  - [ ] AWS support contact: `_________________`
  - [ ] Team lead: `_________________`
  - [ ] DevOps engineer: `_________________`

- [ ] Prepare communication channels:
  - [ ] Slack channel: `_________________`
  - [ ] Email distribution list: `_________________`

---

## 🧹 Cleanup Plan

- [ ] Understand how to destroy infrastructure:
  ```bash
  cd infra
  terraform destroy
  ```

- [ ] Document resources that need manual cleanup:
  - [ ] S3 buckets
  - [ ] CloudWatch log groups
  - [ ] ECR repositories
  - [ ] Route53 records (if any)

- [ ] Set reminder for cost review after deployment

---

## ✨ Final Checks

- [ ] All team members notified of deployment

- [ ] Backup of current state (if applicable)

- [ ] Deployment window approved

- [ ] All prerequisites verified

- [ ] Ready to proceed with deployment

---

## 🎯 Success Criteria

After deployment, verify:

- [ ] EKS cluster is running with desired node count
- [ ] All Istio components are healthy
- [ ] Istio ingress gateway has external IP
- [ ] ArgoCD is installed and accessible (if selected)
- [ ] Monitoring dashboards are accessible (if selected)
- [ ] No critical security vulnerabilities detected
- [ ] Application can be deployed via GitOps
- [ ] All pods are in Running state

---

**Ready to Deploy?** Proceed to the [Deployment Guide](./DEPLOYMENT_GUIDE.md) or run the automated deployment script!

```powershell
# Windows
.\deploy.ps1
```

```bash
# Linux/Mac
./deploy.sh
```

---

**Last Updated**: 2026-01-24
