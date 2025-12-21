# Advanced Authentication & Authorization Strategies

Deep dive into industrial-grade authentication (AuthN) and authorization (AuthZ) strategies for cloud native applications and infrastructure.

## 1. Multi-Account Identity Strategy

In production environments, a single AWS account is a security risk. Organizations use **AWS Organizations** to manage multiple accounts.

### Centralized Identity (Identity Account)
Instead of creating IAM users in every account, use a central "Identity" account.
- **SAML/OIDC Federation**: Integrate with Azure AD (Entra ID), Okta, or Google Workspace.
- **Cross-Account Roles**: Users sign into the Identity account and assume roles in Workload accounts.

#### Example: Cross-Account Trust Policy (in Prod Account)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::IDENTITY_ACCOUNT_ID:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "Bool": { "aws:MultiFactorAuthPresent": "true" }
      }
    }
  ]
}
```

## 2. IAM Policy Evaluation Logic (The "Mental Model")
Understanding how AWS decides to `Allow` or `Deny` is critical for troubleshooting "Access Denied" errors.

> [!IMPORTANT]
> **Evaluation Order:**
> 1. Explicit Deny (Wins always)
> 2. Organization SCPs
> 3. Resource-based Policies (S3 Bucket policies, etc.)
> 4. IAM Permissions Boundaries
> 5. Session Policies
> 6. Identity-based Policies (IAM User/Role policies)
> 7. Default Deny (Final result if no Allow exists)

### Permission Boundaries
Used to delegate permission creation to developers without letting them escalate their own privileges.
```bash
# Create a user with a mandatory boundary
aws iam create-user --user-name dev-user \
    --permissions-boundary arn:aws:iam::123456789012:policy/Dev-Boundary
```

## 3. Application Security: Cognito vs. Entra ID
![Cognito vs Entra ID](../../Images/congitoVsEntra.png)

### Cognito Authentication Flow
1. User Logs in via Hosted UI -> Receives JWT (IdToken, AccessToken, RefreshToken).
2. App sends IdToken to API Gateway.
3. API Gateway uses **Cognito Authorizer** to validate JWT signature and expiration.
___

## 4. Service-to-Service Security

### Workload Identity (OIDC)
Avoid long-lived IAM keys in CI/CD (GitHub Actions, GitLab). Use OIDC.
- GitHub Actions assumes an IAM Role directly via short-lived OIDC tokens.

#### Trust Policy for GitHub Actions
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:my-org/my-repo:*"
        }
      }
    }
  ]
}
```

### Mutual TLS (mTLS)
Used for highly secure internal communication.
- Both Client and Server present certificates.
- Common in Service Meshes (Istio, Linkerd).
___

## 5. Security Hacks & Pro-Tips

### The "Dry-Run" Hack
Before applying complex IAM policies, use the **IAM Policy Simulator** CLI.
```bash
aws iam simulate-principal-policy \
    --policy-source-arn arn:aws:iam::123456789012:role/MyRole \
    --action-names s3:GetObject \
    --resource-arns arn:aws:s3:::my-bucket/secret.txt
```

### Zero Trust Architecture (ZTA) Principles
- **Never Trust, Always Verify**: Don't rely on being "inside the VPC".
- **Assume Breach**: Segment networks and encrypt everything.
- **Least Privilege Access**: Use dynamic, just-in-time (JIT) credentials.

## Summary Checklist
- [ ] Centralize identity management.
- [ ] Enforce MFA for all human users and cross-account access.
- [ ] Use Permission Boundaries to prevent privilege escalation.
- [ ] Move away from long-lived access keys to OIDC for CI/CD.
- [ ] Audit IAM roles regularly with Access Analyzer.
