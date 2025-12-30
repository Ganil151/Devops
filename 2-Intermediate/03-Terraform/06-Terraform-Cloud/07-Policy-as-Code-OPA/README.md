# Policy as Code (OPA)

Open Policy Agent (OPA) is the industry-standard general-purpose policy engine. HCP Terraform now supports OPA alongside Sentinel.

## Sentinel vs. OPA
| Feature | Sentinel | OPA |
| :--- | :--- | :--- |
| **Language** | Sentinel (Proprietary) | Rego (Open Standard) |
| **Ecosystem** | HashiCorp Only | Kubernetes, Envoy, Terraform, etc. |
| **HCP TFC Tier** | Premium/Enterprise | Available in many tiers |

## Writing OPA Policies for Terraform
OPA inspects the JSON version of a Terraform plan. You write rules in **Rego** to determine if a plan is "Approved."

```rego
# Example OPA Rule: Block public S3 buckets
package terraform

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    resource.change.after.acl == "public-read"
    msg := sprintf("S3 bucket %v must not be public.", [resource.address])
}
```

## Benefits of OPA
- **Single Source of Truth**: Use the same Rego policies for your Kubernetes clusters and your Terraform infrastructure.
- **Large Community**: Thousands of pre-written Rego policies are available on GitHub.

---

## 🏗️ Real-Life Scenario: The Multi-Tool Compliance
**Problem**: A company uses Kubernetes for apps and Terraform for cloud. They have two different security teams writing policies for the same requirements (e.g., "Always use encryption").
**Solution**: They switch to OPA. The security team writes one Rego policy.
**Result**: That same code is used to block unencrypted disks in AWS (via TFC) and unencrypted volumes in Kubernetes.

---

## ❓ Interview Questions
1.  **What language is used to write OPA policies?**
    *   *Answer*: Rego. 
2.  **Why would a company choose OPA over Sentinel?**
    *   *Answer*: If they already use OPA for other parts of their stack (like Kubernetes or Service Mesh) and want to standardize their policy language across the entire company.

---

## 🧠 Quiz Snippet (5/50+)
1.  **What does OPA stand for?** (Open Policy Agent)
2.  **True/False: OPA policies are proprietary to HashiCorp.** (False - it is an open-standard tool)
3.  **Which language is more common in the Kubernetes ecosystem?** (OPA/Rego)
4.  **Can OPA block a Resource Group deletion?** (Yes, by inspecting the `actions` in the JSON plan)
5.  **Does HCP Terraform support both OPA and Sentinel?** (Yes)
