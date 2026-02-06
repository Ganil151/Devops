# 🌐 Global Cloud Image Catalog (AMI, VM, GCE)
## 🛡️ Senior SRE Infrastructure Reference
This catalog provides a centralized list of verified, stable, and production-ready machine images across the three major cloud providers: **AWS (ECR/AMI)**, **Azure (Marketplace)**, and **GCP (compute-images)**.

---

## 🏗️ 1. Amazon Web Services (AWS) - AMI Catalog
*Region: us-east-1 (N. Virginia)*

| Distribution | Architecture | AMI ID (Current) | Owner Aliases |
| :--- | :---: | :--- | :--- |
| **Amazon Linux 2023** | x86_64 | `ami-0440d3b780d96b29d` | `amazon` |
| **Ubuntu 24.04 LTS (Noble)** | x86_64 | `ami-04b70fa74e45c3917` | `099720109477` (Canonical) |
| **Red Hat Enterprise Linux 9** | x86_64 | `ami-0fe630c1e196144e1` | `309956199498` (RedHat) |
| **Windows Server 2022 Base** | x86_64 | `ami-0069e23e208b53df4` | `amazon` |

---

## 🟦 2. Microsoft Azure - VM Image Catalog
*Reference Pattern: `Publisher : Offer : SKU : Version`*

| Distribution | Publisher | Offer | SKU |
| :--- | :--- | :--- | :--- |
| **Ubuntu 24.04 LTS** | `Canonical` | `ubuntu-24_04-lts` | `server` |
| **Debian 12 (Bookworm)** | `debian` | `debian-12` | `12-gen2` |
| **Windows Server 2022** | `MicrosoftWindowsServer` | `WindowsServer` | `2022-datacenter-g2` |
| **RHEL 9.3** | `RedHat` | `RHEL` | `9-lvm-gen2` |

---

## 🟩 3. Google Cloud Platform (GCP) - GCE Images
*Reference Pattern: `projects/[PROJECT_ID]/global/images/family/[FAMILY]`*

| Distribution | Project ID | Image Family |
| :--- | :--- | :--- |
| **Debian 12** | `debian-cloud` | `debian-12` |
| **Ubuntu 24.04 LTS** | `ubuntu-os-cloud` | `ubuntu-2404-lts-amd64` |
| **Rocky Linux 9** | `rocky-linux-cloud` | `rocky-linux-9` |
| **Windows 2022** | `windows-cloud` | `windows-2022` |

---

## 🛠️ Usage in Infrastructure as Code (IaC)

### Terraform (AWS Example)
```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}
```

### Terraform (Azure Example)
```hcl
resource "azurerm_linux_virtual_machine" "main" {
  # ...
  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}
```

---
*Last Verified: 2026-02-06*
