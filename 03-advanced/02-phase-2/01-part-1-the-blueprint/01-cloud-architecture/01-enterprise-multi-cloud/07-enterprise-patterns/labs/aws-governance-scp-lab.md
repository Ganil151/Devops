# 🛡️ Lab: SRE-Grade Service Control Policies (SCPs)

> **"Identity allows you to do things. SCPs ensure you CAN'T do things you shouldn't, even if you are the Admin."**

In an enterprise AWS Organization, SCPs are the "Hard Guardrails." This lab demonstrates how to implement three critical enterprise patterns using JSON policies.

---

## 🏛️ Pattern 1: The "Region Lock"
**Objective**: Prevent any resource creation outside of approved regions (e.g., `us-east-1` and `eu-west-1`) to ensure data residency and cost control.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyAllOutsideApprovedRegions",
      "Effect": "Deny",
      "NotAction": [
        "iam:*",
        "organizations:*",
        "route53:*",
        "budgets:*",
        "cloudfront:*",
        "waf:*"
      ],
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": ["us-east-1", "eu-west-1"]
        }
      }
    }
  ]
}
```
*   **Why `NotAction`?**: Global services (IAM, Route53, CloudFront) must be excluded, or you will lock yourself out of basic management.

---

## 🏛️ Pattern 2: The "Protect the SRE Tooling"
**Objective**: Prevent anyone—including Account Admins—from deleting the "CloudWatch Log Groups" or "IAM Roles" used by the security team.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ProtectSecurityRoles",
      "Effect": "Deny",
      "Action": [
        "iam:DeleteRole",
        "iam:UpdateRoleDescription",
        "iam:UpdateAssumeRolePolicy"
      ],
      "Resource": [
        "arn:aws:iam::*:role/SRE-Admin-Role",
        "arn:aws:iam::*:role/Security-Audit-Role"
      ]
    },
    {
      "Sid": "ProtectLogs",
      "Effect": "Deny",
      "Action": ["logs:DeleteLogGroup"],
      "Resource": ["arn:aws:logs:*:*:log-group:/aws/security-hub/*"]
    }
  ]
}
```

---

## 🏛️ Pattern 3: The "Anti-Shadow-IT" (Block Expensive Services)
**Objective**: Block services that your organization hasn't approved for use yet (e.g., SageMaker or Bedrock) to prevent surprise $10k bills.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BlockUnapprovedAIServices",
      "Effect": "Deny",
      "Action": [
        "sagemaker:*",
        "bedrock:*",
        "lex:*"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## 🛠️ Step 4: Implementation Workflow (Principal Method)

1.  **Policy Staging**: Define the policy in Terraform using the `aws_organizations_policy` resource.
2.  **Simulation**: Use the **IAM Policy Simulator** with the SCP attached to verify it doesn't break production.
3.  **Targeting**: Attach the policy to an **Organizational Unit (OU)** rather than a single account to ensure all future accounts in that OU inherit the guardrail.

```hcl
resource "aws_organizations_policy" "region_lock" {
  name    = "RegionLockPolicy"
  content = data.aws_iam_policy_document.region_lock.json
}

resource "aws_organizations_policy_attachment" "prod_ou" {
  policy_id = aws_organizations_policy.region_lock.id
  target_id = aws_organizations_organization.main.roots[0].id # Or specific OU ID
}
```

---

## 🚨 Principal Architect Insights

- **The "FullAWSAccess" Inheritance**: For an SCP to work, the `FullAWSAccess` policy must also be attached. The SCP acts as a **filter**; it cannot grant permissions, it can only restrict the intersection of permissions.
- **Root User Vulnerability**: Unlike IAM policies, SCPs **DO affect the Root user** of the member accounts.
- **Quota Limits**: You are limited to 5 SCPs per OU/Account. **Design for density**: combine multiple Deny statements into a single policy document.

---
**Module**: Enterprise Patterns & Governance
**Next Lab**: [Designing a Multi-Account Landing Zone with Control Tower](./control-tower-lab.md)
