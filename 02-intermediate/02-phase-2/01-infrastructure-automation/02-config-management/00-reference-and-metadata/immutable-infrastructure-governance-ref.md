# 🛡️ Immutable Infrastructure & Governance

> **"Cattle, not Pets. If a server is sick, you don't take it to the vet (Debug it). You shoot it and get a new one."**

This reference covers the tools and patterns for creating **Golden Images** and enforcing governance.

---

## 🍳 1. The Baking Process (Packer)

Packer creates identical machine images for multiple platforms (AMI, Docker, VMWare) from a single source config.

### The Template
```hcl
source "amazon-ebs" "ubuntu" {
  ami_name      = "golden-image-v{{timestamp}}"
  instance_type = "t3.micro"
  ssh_username  = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  # 1. Provision Logic (Ansible)
  provisioner "ansible" {
    playbook_file = "./playbooks/harden_os.yml"
  }

  # 2. Cleanup Logic (Shell)
  provisioner "shell" {
    inline = ["rm -rf /var/log/*", "history -c"]
  }
}
```

---

## 🖼️ 2. The Golden Image Lifecycle

You don't bake once. You bake continuously.

| Stage | Responsibility | Frequency |
| :--- | :--- | :--- |
| **Base OS** | Security Team. Hardened Kernel, CIS Benchmarks. | Monthly (or on CVE). |
| **Middleware** | Platform Team. Java, Python, Nginx, Splunk Agent. | Bi-Weekly. |
| **App Layer** | Product Team. The Application Artifact (.jar). | On every Code Commit. |

**Staff Tip**: Don't re-bake the OS for every App deploy. Use layered builds or Docker.

---

## 🧟 3. Drift Detection

Even in Immutable setups, manual changes happen.

### Terraform Drift
Running `terraform plan` on a schedule (Cron/CI).
- **No Changes**: Healthy.
- **Changes Detected**: Drift! Someone manually modified a Security Group.
- **Remediation**: `terraform apply` to overwrite the manual hack.

### Cloud Custodian (Governance)
A rules engine to enforce what Terraform misses.
- **Rule**: "If an S3 bucket is public, encrypt it and notify the owner."
- **Rule**: "If an EC2 instance is tagged 'Dev' and it's 8 PM, stop it."

```yaml
policies:
  - name: terminate-untagged-instances
    resource: ec2
    filters:
      - "tag:Owner": absent
    actions:
      - stop
      - type: notify
        transport:
          type: sns
          topic: arn:aws:sns:...
```

---

## 🔐 4. Secrets in Images

**NEVER** bake secrets (API Keys, DB Passwords) into an AMI.

| Method | Safety | Recommendation |
| :--- | :--- | :--- |
| **Hardcoded in Packer** | 💀 Critical Risk | Never. |
| **Environment Vars** | ⚠️ Moderate Risk | Visible in `ps aux` and Metadata. |
| **Parameter Store / Secrets Manager** | ✅ Safe | Fetch at runtime using IAM Role identity. |

**Runtime Pattern**:
1. Server Boots.
2. Systemd runs `bootstrap.sh`.
3. Script calls `aws ssm get-parameter --name /db/password`.
4. Script injects password into `app.conf`.
5. App starts.

---

[⬅️ Back to Reference Hub](./readme.md)
