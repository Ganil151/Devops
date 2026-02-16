# ☁️ Cloud Inventory Plugins Reference
*Version 1.0 | Automating Discovery with AWS, Azure, and GCP*

---

## 🏛️ Executive Summary
Cloud Dynamic Inventory Plugins allow Ansible to pull host information directly from cloud provider APIs. This enables "Tags-as-Targeting," where you run playbooks against instances tagged with specific values rather than static IP addresses.

---

## 🏗️ Multi-Cloud Plugin Standards

### 1. AWS (aws_ec2 plugin)
- **File**: Must end in `aws_ec2.yml` or `aws_ec2.yaml`.
- **Requirement**: `boto3` and `botocore` python packages.
- **Example targeting**:
```yaml
filters:
  tag:Role: 'database'
  instance-state-name: 'running'
```

### 2. Azure (azure_rm plugin)
- **File**: Must end in `azure_rm.yml`.
- **Requirement**: `azure-mgmt-compute` and `msrestazure` packages.
- **Key Feature**: Grouping by `location`, `resource_group`, or `provisioning_state`.

### 3. GCP (gcp_compute plugin)
- **File**: Must end in `gcp_compute.yml`.
- **Requirement**: `google-auth` and `requests`.
- **Key Feature**: Grouping by `zone`, `labels`, or `network`.

---

## ⚙️ SRE Advanced Patterns: Keyed Groups & Filters

Keyed groups create Ansible groups based on metadata.

| Provider | Key Metadata Path | Resulting Group |
| :--- | :--- | :--- |
| **AWS** | `tags.Name` | `tag_Name_Webserver` |
| **Azure** | `tags.department` | `tag_department_hr` |
| **GCP** | `labels.tier` | `label_tier_frontend` |

---

## 🛡️ SRE Security Checklist
- [ ] **Least Privilege**: The IAM user/service account used for inventory discovery should have `ReadOnly` access to compute resources only.
- [ ] **Private IP Default**: In VPC environments, always target instances via their `private_ip_address` to avoid egress costs and security exposure.
- [ ] **Cache Management**: Enable JSON caching to avoid API rate limits (Throttling) during large fleet operations.

---

## 🚀 Troubleshooting Scenario: "Missing Hosts"
**Scenario**: You run a playbook, but some newly launched EC2 instances are missing from the task run.
- **Root Cause 1**: **Filters**. The instance state might be `pending` instead of `running`.
- **Root Cause 2**: **Plugin Cache**. The inventory cache might be stale.
- **Root Cause 3**: **IAM Permissions**. The discovery service account lacks permission to view the specific region.
- **Solution**: Run `ansible-inventory -i aws_ec2.yml --graph --refresh-cache` to force a new API call.

---

## ❓ Interview "Deep-Cut" Questions
1. **How do you handle authentication for a dynamic plugin in a Jenkins CI pipeline?**
2. **Explain the impact of the `compose` feature in a dynamic inventory file.**
3. **Difference between `filters` and `keyed_groups` in an inventory config.**
4. **Compare using the `add_host` module vs a dynamic inventory plugin for ad-hoc scaling.**
5. **Describe how you would use "Instance Profiles" instead of hardcoded API keys for AWS discovery.**

---
**Next Step**: [Inventory Security & Secret Management →](./ansible-security-rbac-ref.md)
