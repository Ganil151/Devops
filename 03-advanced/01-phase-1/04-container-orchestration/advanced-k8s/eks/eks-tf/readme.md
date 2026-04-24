# AWS EKS Terraform Project

This project provisions a production-ready AWS EKS (Elastic Kubernetes Service) cluster using Terraform. It includes a modular VPC architecture, EKS cluster with managed node groups (On-Demand and Spot), and an EC2 Jump Server for secure management.

## 🏗️ Architecture Overview

The Terraform configuration deploys the following resources:
-   **VPC**: Custom VPC with public and private subnets across 3 Availability Zones.
-   **Networking**: Internet Gateway, NAT Gateway (for private subnets), and Route Tables.
-   **EKS Cluster**: Managed Kubernetes control plane.
-   **Node Groups**:
    -   **On-Demand**: For stable, critical workloads.
    -   **Spot**: For cost-effective, interruptible workloads.
-   **Jump Server (Bastion)**: An EC2 instance in a public subnet to manage the cluster securely.
-   **Add-ons**: VPC CNI, CoreDNS, Kube-Proxy, EBS CSI Driver.

## 📋 Prerequisites

Ensure you have the following tools installed:
-   [Terraform](https://www.terraform.io/downloads) (v1.0+)
-   [AWS CLI](https://aws.amazon.com/cli/) (Configured with `aws configure`)
-   [kubectl](https://kubernetes.io/docs/tasks/tools/)

## 📂 Project Structure

```
EKS-TF/
├── eks/                  # Main environment configuration (dev)
│   ├── main.tf           # Root module call
│   ├── dev.auto.tfvars   # Variable values (Customize this!)
│   ├── variables.tf      # Variable definitions
│   └── backend.tf        # Remote state configuration
├── modules/              # Reusable Terraform modules
│   ├── eks.tf            # EKS Cluster & Node Groups
│   ├── vpc.tf            # VPC, Subnets, Gateways
│   ├── ec2.tf            # Jump Server Resources
│   └── ...
└── script/
    └── setup.sh          # Helper script to install tools on Jump Server
```

## 🚀 Deployment Instructions

### 1. Configure Variables
Navigate to the `eks/` directory and open `dev.auto.tfvars`. Update the following critical variables:
-   `aws-region`: Target AWS region (e.g., `us-east-1`).

### 2. Initialize Terraform
Initialize the project to download providers and modules.
```bash
cd eks
terraform init
```

### 3. Plan Deployment
Review the resources that will be created.
```bash
terraform plan -var-file="dev.auto.tfvars" -out=tfplan
```

### 4. Apply Configuration
Provision the infrastructure.
```bash
terraform apply "tfplan"
```
*This process takes approximately 15-20 minutes.*

---

## 💻 Accessing the Cluster

### From Local Machine
Once the cluster is active, update your local `kubeconfig` to interact with it:

```bash
aws eks update-kubeconfig --region us-east-1 --name dev-ap-medium-eks-cluster
```
*(Replace names matches your variables found in `main.tf`)*

Verify connection:
```bash
kubectl get nodes
```

---

## 🖥️ Using the Jump Server

The Jump Server is an EC2 instance in the public subnet provided for secure administrative tasks.

### 1. SSH Key
The deployment **automatically generates** an SSH key pair named `eks`.
The private key is saved to: `modules/eks.pem`.

**Important**: Change permissions of the key file before use:
```bash
chmod 400 ../modules/eks.pem
```

### 2. Connect via SSH
```bash
ssh -i ../modules/eks.pem ubuntu@<Public-IP-of-Jump-Server>
```
*Find the Public IP in the AWS Console or Terraform outputs.*

### 2. Setup Tools
We have provided a script to automatically install `aws-cli`, `kubectl`, and other dependencies on the Jump Server.

After logging in, clone/copy the script or run the commands:
```bash
# Assuming you copied the script content to setup.sh
chmod +x setup.sh
./setup.sh
```

### 3. Manage Cluster
Authenticate AWS CLI and update kubeconfig on the Jump Server:
```bash
aws configure
aws eks update-kubeconfig --region us-east-1 --name dev-ap-medium-eks-cluster
kubectl get pods -A
```

---

## 🧹 Clean Up

To destroy all resources and avoid costs:
```bash
cd eks
terraform destroy -var-file="dev.auto.tfvars"
```
