# Enterprise Security: Interview Questions, Quiz & Scenarios

Master the art of high-level security governance and DevSecOps patterns.

---

## ❓ Interview Questions (Advanced)

1.  **What is the "Shared Responsibility Model" in the cloud?**
    *   *Answer*: The Cloud Provider is responsible for the security *of* the cloud (hardware, regions). The Customer is responsible for security *in* the cloud (data, OS configuration, IAM).
2.  **Explain the "Shift Left" security philosophy.**
    *   *Answer*: Integrating security testing (SAST/DAST) early in the development lifecycle (i.e., in the CI pipeline) rather than waiting for a final production audit.
3.  **How do you secure secrets in a containerized environment?**
    *   *Answer*: Use a dedicated secret store (AWS Secrets Manager, HashiCorp Vault), mount secrets as volumes (not env vars), and restrict Pod-to-Pod communication via NetworkPolicies.
4.  **What is "Zero Trust" architecture?**
    *   *Answer*: A security model based on the principle of "Never Trust, Always Verify." It assumes that threats exist both inside and outside the network.

---

## 🧠 Security Knowledge Quiz (20+ Questions)

<b>1. What does 'SAST' stand for?</b>
<details>
<summary>Show Answer</summary>
Answer: Static Application Security Testing
</details>

<b>2. What does 'DAST' stand for?</b>
<details>
<summary>Show Answer</summary>
Answer: Dynamic Application Security Testing
</details>

<b>3. What is a 'WAF'?</b>
<details>
<summary>Show Answer</summary>
Answer: Web Application Firewall
</details>

<b>4. Which tool is used for container image scanning?</b>
<details>
<summary>Show Answer</summary>
Answer: e.g., Trivy, Snyk, Clair
</details>

<b>5. True/False: IAM Role is more secure than IAM User for EC2.</b>
<details>
<summary>Show Answer</summary>
Answer: True
</details>

<b>6. What is 'Least Privilege'?</b>
<details>
<summary>Show Answer</summary>
Answer: Granting only the bare minimum permissions needed for a task
</details>

<b>7. What is 'Encryption at Rest'?</b>
<details>
<summary>Show Answer</summary>
Answer: Protecting data stored on disks using cryptographic keys
</details>

<b>8. What is 'Encryption in Transit'?</b>
<details>
<summary>Show Answer</summary>
Answer: Protecting data moving over the network, e.g., TLS
</details>

<b>9. What is a 'CVE'?</b>
<details>
<summary>Show Answer</summary>
Answer: Common Vulnerabilities and Exposures
</details>

<b>10. What is 'Penetration Testing'?</b>
<details>
<summary>Show Answer</summary>
Answer: Simulated cyber-attack to find vulnerabilities
</details>

<b>11. What is 'Multi-Factor Authentication'</b>
<details>
<summary>Show Answer</summary>
Answer: MFA)?** (Requiring two or more verification methods
</details>

<b>12. What is 'VPC Flow Logs'?</b>
<details>
<summary>Show Answer</summary>
Answer: Captures information about IP traffic going to and from network interfaces
</details>

<b>13. What is 'Cloud Custodian'?</b>
<details>
<summary>Show Answer</summary>
Answer: An open-source tool for managing cloud resources and policies
</details>

<b>14. What is 'AWS GuardDuty'?</b>
<details>
<summary>Show Answer</summary>
Answer: Managed threat detection service
</details>

<b>15. What is 'OIDC'?</b>
<details>
<summary>Show Answer</summary>
Answer: OpenID Connect - an authentication layer on top of OAuth 2.0
</details>

<b>16. What is 'RBAC'?</b>
<details>
<summary>Show Answer</summary>
Answer: Role-Based Access Control
</details>

<b>17. What is 'Network Policy' in Kubernetes?</b>
<details>
<summary>Show Answer</summary>
Answer: Controls traffic flow between Pods
</details>

<b>18. What is 'Secure Coding'?</b>
<details>
<summary>Show Answer</summary>
Answer: Writing code that is resistant to common security vulnerabilities
</details>

<b>19. What is 'Vulnerability Management'?</b>
<details>
<summary>Show Answer</summary>
Answer: The process of identifying, evaluating, and remediating security weaknesses
</details>

<b>20. What is 'Identity Federation'?</b>
<details>
<summary>Show Answer</summary>
Answer: Linking a user's identity across multiple independent systems
</details>

<b>21. What is 'Security Group' primarily used for?</b>
<details>
<summary>Show Answer</summary>
Answer: Acts as a virtual firewall for your EC2 instance
</details>


---

## 🏗️ Real-Life Scenarios

### Scenario 1: The Accidental Public S3 Bucket
**Problem**: An admin accidentally made a production S3 bucket public, exposing sensitive client data.
**Solution**: **AWS Config** detected the change in real-time and triggered a **Lambda function** to automatically revert the bucket to "Private" and notify the security team.

### Scenario 2: The Compromised Developer Key
**Problem**: A developer's IAM credentials were leaked on GitHub.
**Solution**: **AWS GuardDuty** detected "Unauthorized Access" from an unusual IP. The security team disabled the user and rotated all keys within 5 minutes.

### Scenario 3: The Vulnerable Base Image
**Problem**: A critical security vulnerability was found in the base `alpine` image used across production.
**Solution**: The **Snyk** scan in the CI pipeline blocked all new builds. The team updated the parent Dockerfile and propagated the fix to 100+ services via GitOps in under an hour.