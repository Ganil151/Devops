# ✅ Quiz Solutions & Explanations

### 1. Which tool is primarily used to build "Golden Images"?
- **Answer**: B) **Packer**.
- **Reasoning**: While Terraform provisions the VM, Packer "bakes" the image beforehand so that the VM boots up pre-configured.

### 2. What does 'Idempotency' guarantee?
- **Answer**: B) **Only apply changes if needed**.
- **Reasoning**: This prevents redundant work and "Snowflake" configurations.

### 3. Which format does Ansible use?
- **Answer**: C) **YAML**.
- **Reasoning**: YAML (Yet Another Markup Language) is human-readable and standard for DevOps logic.

### 4. What is the role of 'Cloud-Init'?
- **Answer**: B) **Early-boot initialization**.
- **Reasoning**: It's the "Last Mile" of config, handling things like SSH keys and hostname on the first boot.

### 5. In Terraform, what does 'plan' do?
- **Answer**: C) **Preview changes**.
- **Reasoning**: This is the "Safety Catch" that prevents accidental mass-deletion of resources.
