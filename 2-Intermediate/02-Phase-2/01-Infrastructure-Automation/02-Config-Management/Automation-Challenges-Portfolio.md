# 🏆 Automation Challenges Portfolio

This portfolio contains tiered challenges designed to build your skills in Infrastructure as Code and Configuration Management. Complete these labs to build a professional-grade portfolio.

---

## 🟢 Level 1: Provisioning Fundamentals (Terraform)
### Challenge: The "Hello World" VPC
1.  **Objective**: Use Terraform to create a VPC in AWS with one public subnet.
2.  **Requirements**:
    - Use variables for region and CIDR block.
    - Output the VPC ID and Subnet ID.
    - Use a Local backend for simplicity.
3.  **Definition of Done**: `terraform apply` runs successfully and outputs the correct IDs.

---

## 🟡 Level 2: State & Scalability (Terraform + S3)
### Challenge: The "Production-Ready" Backend
1.  **Objective**: Re-configure your Level 1 VPC to use a Remote Backend.
2.  **Requirements**:
    - Create an S3 bucket for state storage and a DynamoDB table for locking.
    - Migrate your local state to the new remote backend.
    - Simulate a "collision": Open two terminals and try to run `apply` at the same time. Verify the lock works.
3.  **Definition of Done**: State is stored in S3 and locking is verified.

---

## 🟠 Level 3: Configuration & software (Terraform + Ansible)
### Challenge: The "Hybrid Pattern" Web Server
1.  **Objective**: Provision a VM and configure it as a web server.
2.  **Requirements**:
    - Use Terraform to launch an EC2 instance.
    - Use an Ansible Playbook to install Nginx and copy a custom `index.html`.
    - Use a Terraform `null_resource` and `local-exec` provisioner to trigger the Ansible run automatically after the VM is up.
3.  **Definition of Done**: Visiting the VM's public IP shows your custom web page.

---

## 🔴 Level 4: Immutable Infrastructure (Packer + Ansible)
### Challenge: The "Golden Image" Factory
1.  **Objective**: Build a hardened Amazon Linux AMI.
2.  **Requirements**:
    - Use **Packer** to define an HCL template.
    - Use an **Ansible provisioner** inside Packer to:
        - Uninstall unnecessary software.
        - Create a non-root user.
        - Set up basic firewall rules.
    - Output a resulting AMI ID.
3.  **Definition of Done**: You can launch a manual EC2 instance from your custom AMI without any additional configuration.

---

## 🟣 Level 5: Cloud-Native Complexity (Helm + K8s)
### Challenge: The "Zero-Downtime" Microservice
1.  **Objective**: Deploy a multi-environment app to Kubernetes.
2.  **Requirements**:
    - Create a Helm Chart for a simple Python API.
    - Use **Helm Dependencies** to include a PostgreSQL sub-chart.
    - Use `values-dev.yaml` and `values-prod.yaml` to change replica counts and resource limits.
    - Perform a `helm upgrade` and verify that the app stays online during the rollout.
3.  **Definition of Done**: Both Dev and Prod environments are running in separate K8s namespaces.
