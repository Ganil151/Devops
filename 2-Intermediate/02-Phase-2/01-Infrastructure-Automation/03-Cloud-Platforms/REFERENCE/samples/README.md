# 📊 Cloud Architecture Samples

This directory contains production-grade infrastructure blueprints for building resilient and secure cloud platforms.

## 📂 Samples Index

| Sample File | Use Case | Implementation |
| :--- | :--- | :--- |
| [`iam_policy_example.json`](./iam_policy_example.json) | Least-privileged access with IP-based guardrails. | JSON (IAM) |
| [`asg_ha_example.tf`](./asg_ha_example.tf) | Multi-AZ auto-scaling with Load Balancing. | Terraform |
| [`s3_bucket_policy.json`](./s3_bucket_policy.json) | Enforcing SSL and private access at the bucket level. | JSON (Policy) |

---

### 🚀 Usage Instruction
1. **IAM Samples**: Use the AWS Console or `aws iam create-policy` to validate the JSON logic.
2. **Terraform Samples**: Ensure you have valid `subnet_id` and `security_group_id` variables defined before running `terraform plan`.
3. **Best Practice**: Always test these configurations in a "Sandbox" account before applying to production.
