# Spring PetClinic - Ansible Configuration

This directory contains Ansible playbooks and roles for configuring infrastructure components that are not managed by Terraform, or for post-provisioning tasks.

## 📂 Directory Structure

```
ansible/
├── ansible.cfg       # Global Ansible configuration
├── inventory/        # Inventory files (dev/prod)
│   ├── dev.ini
│   └── prod.ini
├── playbooks/        # Playbooks to run
│   └── site.yml      # Main entry point
└── roles/            # Reusable roles
    └── install_tools/ # Role to install DevOps tools
```

## 🚀 Usage

### Prerequisites
- Ansible installed locally
- SSH access to correct target nodes
- Update `inventory/{env}.ini` with your target IP addresses

### Running the Playbook

To provision a development server (e.g., a bastion host or a manually managed build server):

1. **Update Inventory**:
   Edit `inventory/dev.ini` and add the IP address of your target server.

   ```ini
   [dev_servers]
   x.x.x.x ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/your-key.pem
   ```

2. **Run Playbook**:
   
   ```bash
   ansible-playbook -i inventory/dev.ini playbooks/site.yml
   ```

## 🛠️ Roles

### `install_tools`
Installs common DevOps tools on Amazon Linux 2 / 2023:
- **Java 17** (Amazon Corretto)
- **Maven 3.9.6**
- **Docker**
- **kubectl 1.29**
- **Helm 3.14**
- **AWS CLI v2**
- **Utilities**: `git`, `jq`, `unzip`

## 📝 Notes
- This setup assumes Amazon Linux 2/2023 based on `ec2-user` and `yum` usage.
- Adjust `roles/install_tools/vars/main.yml` if you need different versions.
