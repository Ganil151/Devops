# ❓ Technical Interview: Config Management & IaC

### 1. Explain 'Infrastructure as Code' vs 'Infrastructure as a Service'.
**Answer**: IaaS is the "What" (the cloud providing you a VM). IaC is the "How" (the code files you write to tell that cloud to give you the VM). IaC brings software engineering practices (Git, CI, testing) to hardware management.

### 2. What is 'Configuration Drift' and how do you prevent it?
**Answer**: Drift occurs when the actual system state deviates from the code state. You prevent it by:
- Using **Idempotent** tools (Terraform/Ansible).
- Running **Periodic Checks** (Terraform Plan).
- Implementing **GitOps** (automated reconciliation).
- Disabling manual access to the cloud console.

### 3. Difference between 'Immutable' and 'Mutable' infrastructure?
**Answer**: 
- **Mutable**: You patch existing servers (e.g., using Ansible to update a library).
- **Immutable**: You build a new image (Packer) and replace the server (Terraform). 
In modern Cloud-Native environments, Immutable is preferred for predictability and scaling speed.

### 4. What is 'State' in IaC, and why is it dangerous?
**Answer**: State is the "Map" between your code and the real world. It's dangerous because if it's lost, the tool doesn't know what it owns. If it's leaked, it may contain secrets. It must be versioned, locked, and encrypted.

### 5. When would you use Helm over Kustomize?
**Answer**: Use **Helm** when you're building a generic package to be shared by many people or projects (e.g., "Install a database cluster"). Use **Kustomize** for local environments where you just need to tweak a few settings (like environment variables) between Dev and Prod without the complexity of templates.
