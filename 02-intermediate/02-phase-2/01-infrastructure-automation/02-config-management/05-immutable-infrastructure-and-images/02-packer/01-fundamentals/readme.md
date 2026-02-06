# Packer: Automated Machine Image Building

Packer handles the creation of machine images for multiple platforms (AWS, Azure, GCP, VMware, VirtualBox) using a single configuration file. It implements the "Immutable Infrastructure" pattern.

## 📚 Module Structure
- **[Boilerplates](readme.md)**: `aws-ubuntu.pkr.hcl` (AMI buildup).
- **[CHALLENGES](../../../03-server-configuration-and-ansible/01-ansible/learning-modules/01-fundamentals/challenges.md)**: Multi-provisioning and post-processing manifests.

---

## 🏗️ Architecture: The Build Pipeline

Packer creates a temporary VM, runs your scripts, and then saves the result as an image.

```mermaid
graph LR
    Source[Source Template] --> Build[Temp VM Launched]
    Build --> Prov[Provision: Run Shell/Ansible]
    Prov --> Clear[Cleanup: Remove temporary files]
    Clear --> Image[Save: AMI / VMDK]
```

---

## 🔑 Key Concepts

| Keyword | Description |
| :--- | :--- |
| **Builder** | The component that creates the machine image (e.g., `amazon-ebs`). |
| **Provisioner** | The tools used to install software (Shell, Ansible, Chef). |
| **Post-Processor** | Actions taken after the image is built (e.g., tagging, manifest generation). |
| **HCL2** | The official configuration language for Packer (same as Terraform). |

---

## 🛡️ Robust Pattern: The Golden Image
Instead of installing software *every time* a server scales up, use Packer to create a **Golden Image** with:
1.  OS Hardening (Security patches).
2.  Monitoring agents (Datadog, CloudWatch).
3.  Pre-downloaded application binaries.
**Benefit**: Boot time drops from 10 minutes to 60 seconds.

---

## 📖 Real-World Story: The "Autoscaling Lag"
**Scenario**: A streaming service used an EC2 Autoscaling group. New servers took 12 minutes to install their heavy libraries. 
**Crisis**: During a viral event, traffic spiked in 3 minutes. The servers couldn't scale fast enough, and the site crashed.
**Solution**: Switched to **Packer-built AMIs**.
**Result**: Scale-out time dropped to 2 minutes. The site survived the next spike easily.

---

## ❓ Interview Questions

1. **Why use Packer if we have Ansible/Chef?**
   - *Answer*: We use them together. Packer uses Ansible/Chef to *build* the image. Once the image is built, we don't need Ansible/Chef to run at boot time, making scaling much faster.
2. **What is 'Immutable Infrastructure'?**
   - *Answer*: A philosophy where you never "patch" a server. If you need a change, you build a NEW image with Packer and replace the old servers with new ones using Terraform.
3. **What does the `packer validate` command do?**
   - *Answer*: It checks the syntax and configuration of your Packer template before you spend time and money launching a build VM.

---

[Next: Vagrant](../../../../../readme.md)
