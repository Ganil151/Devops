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

## Quiz
<details>
<summary><b>1. IAM stands for:</b></summary>
A) Identity and Access Management<br>
B) Internet Access Mode<br>
C) Internal Account Manager<br>
D) Instant Access Method<br>
<br>
<b>Answer: A) Identity and Access Management</b>
</details>

<details>
<summary><b>2. An IAM Role is designed for:</b></summary>
A) Machines/Services or Federated Users (Temporary credentials)<br>
B) A single immutable person<br>
C) Hardcoded passwords<br>
D) Storage<br>
<br>
<b>Answer: A) Machines/Services or Federated Users (Temporary credentials)</b>
</details>

<details>
<summary><b>3. The "Root Account" should be:</b></summary>
A) Used for everything<br>
B) Locked away and protected with MFA, only used for billing/account setup<br>
C) Shared with the team<br>
D) Deleted<br>
<br>
<b>Answer: B) Locked away and protected with MFA, only used for billing/account setup</b>
</details>

<details>
<summary><b>4. Which policy type is attached directly to a User/Role?</b></summary>
A) Identity-based policy (Inline or Managed)<br>
B) Resource-based policy (Bucket policy)<br>
C) SCP<br>
D) ACL<br>
<br>
<b>Answer: A) Identity-based policy (Inline or Managed)</b>
</details>

<details>
<summary><b>5. Cognito User Pools are for:</b></summary>
A) Authentication (Sign-up, Sign-in)<br>
B) Authorization (Access AWS resources)<br>
C) Database hosting<br>
D) EC2 management<br>
<br>
<b>Answer: A) Authentication (Sign-up, Sign-in)</b>
</details>

<details>
<summary><b>6. Cognito Identity Pools are for:</b></summary>
A) Authorization (Exchanging tokens for AWS Credentials)<br>
B) Authentication<br>
C) Storing files<br>
D) Sending emails<br>
<br>
<b>Answer: A) Authorization (Exchanging tokens for AWS Credentials)</b>
</details>

<details>
<summary><b>7. IAM Groups are:</b></summary>
A) Collections of Users (for permission management)<br>
B) Collections of Roles<br>
C) Collections of Resources<br>
D) Social networks<br>
<br>
<b>Answer: A) Collections of Users (for permission management)</b>
</details>

<details>
<summary><b>8. "Principle of Least Privilege" means:</b></summary>
A) Giving only the permissions needed for the task and no more<br>
B) Giving Admin access to everyone<br>
C) Giving no access<br>
D) Sharing passwords<br>
<br>
<b>Answer: A) Giving only the permissions needed for the task and no more</b>
</details>

<details>
<summary><b>9. IAM is scoped to:</b></summary>
A) Global<br>
B) Region<br>
C) VPC<br>
D) AZ<br>
<br>
<b>Answer: A) Global</b>
</details>

<details>
<summary><b>10. Service Control Policies (SCPs) are used in:</b></summary>
A) AWS Organizations (Multi-account governance)<br>
B) Single accounts<br>
C) S3<br>
D) EC2<br>
<br>
<b>Answer: A) AWS Organizations (Multi-account governance)</b>
</details>

<details>
<summary><b>11. Can IAM Roles have long-term credentials (Access Keys)?</b></summary>
A) No, they use temporary STS tokens<br>
B) Yes<br>
<br>
<b>Answer: A) No, they use temporary STS tokens</b>
</details>

<details>
<summary><b>12. To allow cross-account access, you generally use:</b></summary>
A) IAM Roles (AssumeRole)<br>
B) Sharing passwords<br>
C) Copying data<br>
D) VPC Peering (for network, not identity)<br>
<br>
<b>Answer: A) IAM Roles (AssumeRole)</b>
</details>

<details>
<summary><b>13. AWS Directory Service is use for:</b></summary>
A) Managed Microsoft Active Directory<br>
B) S3 file listings<br>
C) Phone book<br>
D) DNS<br>
<br>
<b>Answer: A) Managed Microsoft Active Directory</b>
</details>

<details>
<summary><b>14. IAM Access Analyzer helps:</b></summary>
A) Identify resources shared externally (public/cross-account)<br>
B) Reset passwords<br>
C) Create users<br>
D) Analyze costs<br>
<br>
<b>Answer: A) Identify resources shared externally (public/cross-account)</b>
</details>

<details>
<summary><b>15. Multi-Factor Authentication (MFA) adds:</b></summary>
A) Something you have (Token/Phone) to something you know (Password)<br>
B) Complexity only<br>
C) Cost<br>
D) Biometrics only<br>
<br>
<b>Answer: A) Something you have (Token/Phone) to something you know (Password)</b>
</details>

<details>
<summary><b>16. JSON Policy Structure: "Effect" can be:</b></summary>
A) Allow or Deny<br>
B) Yes or No<br>
C) Start or Stop<br>
D) Open or Close<br>
<br>
<b>Answer: A) Allow or Deny</b>
</details>

<details>
<summary><b>17. Which takes precedence: Explicit Deny or Explicit Allow?</b></summary>
A) Explicit Deny (always wins)<br>
B) Explicit Allow<br>
C) Neither<br>
D) The newest one<br>
<br>
<b>Answer: A) Explicit Deny (always wins)</b>
</details>

<details>
<summary><b>18. Can you customize the login URL for IAM users?</b></summary>
A) Yes (using account alias)<br>
B) No<br>
<br>
<b>Answer: A) Yes (using account alias)</b>
</details>

<details>
<summary><b>19. IAM Credential Report:</b></summary>
A) Lists all users and the status of their credentials (MFA, password age)<br>
B) Lists costs<br>
C) Lists logins<br>
D) Lists errors<br>
<br>
<b>Answer: A) Lists all users and the status of their credentials (MFA, password age)</b>
</details>

<details>
<summary><b>20. Permission Boundaries:</b></summary>
A) Set the maximum permissions an entity can have (Guardrails)<br>
B) Grant permissions<br>
C) Are firewalls<br>
D) Are optional<br>
<br>
<b>Answer: A) Set the maximum permissions an entity can have (Guardrails)</b>
</details>

<details>
<summary><b>21. Single Sign-On (SSO) / IAM Identity Center allows:</b></summary>
A) One login for multiple AWS accounts and apps<br>
B) One login for one account<br>
C) No login<br>
D) Social login only<br>
<br>
<b>Answer: A) One login for multiple AWS accounts and apps</b>
</details>
