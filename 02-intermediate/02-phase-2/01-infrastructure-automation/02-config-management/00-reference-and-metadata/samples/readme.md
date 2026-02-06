# 🏗️ Configuration Management Samples

This directory contains production-grade samples for infrastructure provisioning, image building, and server initialization.

## 📂 Samples Index

| Sample File | Use Case | Tool |
| :--- | :--- | :--- |
| [`modular_vpc.tf`](./modular_vpc.tf) | Clean, scalable network provisioning. | Terraform |
| [`golden_image.pkr.hcl`](./golden_image.pkr.hcl) | Baking security-hardened AMIs. | Packer |
| [`cloud_init_bootstrap.yaml`](./cloud_init_bootstrap.yaml) | Zero-day server initialization. | Cloud-Init |
| [`ha_web_stack.yml`](./ha_web_stack.yml) | Multi-node configuration with handlers. | Ansible |

---

### 🚀 Usage Instruction
*   **Terraform**: Use `terraform init && terraform plan` to validate.
*   **Packer**: Use `packer build .` inside the directory.
*   **Ansible**: Use `ansible-playbook -i inventory.ini ha_web_stack.yml`.
