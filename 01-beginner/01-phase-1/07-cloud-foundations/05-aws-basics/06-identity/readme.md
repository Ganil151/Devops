# AWS Identity (IAM & Cognito)

Managing access to AWS resources and applications.

## Identity Architecture
```mermaid
graph TD
    User[Human User]
    App[Application Code]

subgraph IAM
        Key[Access Keys]
        Pass[Password + MFA]
        Role[IAM Role]
    end

subgraph Resources
        S3[S3 Bucket]
        EC2[EC2 Instance]
    end

User -->|Console| Pass
    User -->|CLI| Key
    App -->|AssumeRole| Role

Pass --> Resources
    Key --> Resources
    Role --> Resources

classDef sec fill:#e3f2fd,stroke:#0d47a1
    class IAM sec
```

## Real World Scenarios
### Scenario: Mobile App Login
**Context:** You are building a mobile game. You don't want to manage a database of usernames/passwords. You want users to sign in with Facebook or Google.
**Solution:**
- **Cognito User Pools:** Handle sign-up/sign-in and social federation (Google/FB).
- **Cognito Identity Pools:** Exchange the login token for temporary AWS credentials to allow the app to upload saves to S3 directly.
**Benefit:** Offloads security/auth complexity to AWS.

<b>1. IAM stands for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Identity and Access Management</b>
</details>


<b>2. An IAM Role is designed for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Machines/Services or Federated Users (Temporary credentials)</b>
</details>


<b>3. The "Root Account" should be:</b>
<details>
<summary>Show Answer</summary>
Answer: B) Locked away and protected with MFA, only used for billing/account setup</b>
</details>


<b>4. Which policy type is attached directly to a User/Role?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Identity-based policy (Inline or Managed)</b>
</details>


<b>5. Cognito User Pools are for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Authentication (Sign-up, Sign-in)</b>
</details>


<b>6. Cognito Identity Pools are for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Authorization (Exchanging tokens for AWS Credentials)</b>
</details>


<b>7. IAM Groups are:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Collections of Users (for permission management)</b>
</details>


<b>8. "Principle of Least Privilege" means:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Giving only the permissions needed for the task and no more</b>
</details>


<b>9. IAM is scoped to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Global</b>
</details>


<b>10. Service Control Policies (SCPs) are used in:</b>
<details>
<summary>Show Answer</summary>
Answer: A) AWS Organizations (Multi-account governance)</b>
</details>


<b>11. Can IAM Roles have long-term credentials (Access Keys)?</b>
<details>
<summary>Show Answer</summary>
Answer: A) No, they use temporary STS tokens</b>
</details>


<b>12. To allow cross-account access, you generally use:</b>
<details>
<summary>Show Answer</summary>
Answer: A) IAM Roles (AssumeRole)</b>
</details>


<b>13. AWS Directory Service is use for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Managed Microsoft Active Directory</b>
</details>


<b>14. IAM Access Analyzer helps:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Identify resources shared externally (public/cross-account)</b>
</details>


<b>15. Multi-Factor Authentication (MFA) adds:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Something you have (Token/Phone) to something you know (Password)</b>
</details>


<b>16. JSON Policy Structure: "Effect" can be:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Allow or Deny</b>
</details>


<b>17. Which takes precedence: Explicit Deny or Explicit Allow?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Explicit Deny (always wins)</b>
</details>


<b>18. Can you customize the login URL for IAM users?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes (using account alias)</b>
</details>


<b>19. IAM Credential Report:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Lists all users and the status of their credentials (MFA, password age)</b>
</details>


<b>20. Permission Boundaries:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Set the maximum permissions an entity can have (Guardrails)</b>
</details>


<b>21. Single Sign-On (SSO) / IAM Identity Center allows:</b>
<details>
<summary>Show Answer</summary>
Answer: A) One login for multiple AWS accounts and apps</b>
</details>


---
## 🧭 Additional Modules
- [Cognito](cognito/readme.md)
