# GCP VPC & Cloud Interconnect Reference

GCP VPCs are global resources, not regional, allowing subnets to be distributed across different regions while sharing a single network.

## 🌉 Key Features
- **Global Scope**: A single VPC can have subnets in multiple regions worldwide.
- **Shared VPC**: Connecting multiple projects to a common VPC network.
- **Cloud Interconnect**: High-speed physical links to Google's edge.

## 🛡️ Security
- **Firewall Rules**: Global rules that can be applied using Tags or Service Accounts.
- **VPC Service Controls**: Defining a security perimeter around Google-managed services.

## 🛠️ IaC (Terraform)
```hcl
resource "google_compute_network" "vpc_network" {
  name                    = "vpc-global-prod"
  auto_create_subnetworks = false
}
```
