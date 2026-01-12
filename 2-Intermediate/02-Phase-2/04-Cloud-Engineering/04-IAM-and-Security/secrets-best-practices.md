# Secrets Management Best Practices

A guide to securely storing, rotating, and consuming sensitive information like API keys, database passwords, and TLS certificates in cloud-native workloads.

## 1. Secrets Manager vs. Parameter Store (SSM)

Choosing the right tool for the job.

| Feature | AWS Secrets Manager | SSM Parameter Store (SecureString) |
| :--- | :--- | :--- |
| **Cost** | $0.40 per secret/month | Free (Standard), $0.05 per 10k API calls |
| **Rotation** | Native support with Lambda templates | Manual or custom logic required |
| **Max Size** | 64 KB | 4 KB (Standard), 8 KB (Advanced) |
| **Cross-Account** | Easy sharing via Resource Policies | Difficult (requires custom proxy or RAM) |

> [!TIP]
> **Use Secrets Manager** for complex secrets that require rotation (like RDS passwords).
> **Use SSM Parameter Store** for static secrets with high volume calls (like third-party API keys) to save costs.

## 2. Automated Secret Rotation
Leaving a secret unchanged for years is a high risk. Automated rotation mitigates the impact of a compromised key.

### Rotation Strategy: The "Single-User" vs "Multi-User"
- **Single-User**: Changes the password on the original resource. Can cause brief downtime during rotation.
- **Multi-User**: Uses two sets of credentials. Rotates the inactive one, updates the application, then rotates the previous one. Zero downtime.

#### Example: Enlisting Secret Rotation (CLI)
```bash
aws secretsmanager rotate-secret \
    --secret-id MyDatabaseSecret \
    --rotation-lambda-arn arn:aws:lambda:us-east-1:123456789012:function:RotationFunc
```

## 3. Injecting Secrets into Workloads

### ECS (Task Definitions)
Reference secrets directly in your task definition environment variables. The ECS agent injects them at container startup.
```json
"secrets": [
  {
    "name": "DB_PASSWORD",
    "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789012:secret:db-pass-xyz"
  }
]
```

### EKS (Kubernetes)
Use the **AWS Secrets Store CSI Driver**. This mounts secrets as volumes or synchronizes them as K8s native secrets.
- **Why?** It's more secure than standard K8s secrets (which are just base64 encoded) and easier for developers to consume.

## 4. Cross-Account Secret Access

Sharing a secret from a "Security" account to a "Production" account.

### Step 1: Resource-based Policy on the Secret
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::PROD_ACCOUNT_ID:root"
      },
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "*"
    }
  ]
}
```

### Step 2: KMS Key Policy
If the secret is encrypted with a CMK, the Prod Account must also have `kms:Decrypt` permission on that key.

## 5. Security Hacks & Pro-Tips

### The "Environment Variable" Trap
**NEVER** log environment variables in your application code. Use `unset` in your entrypoint script after the application has loaded the secrets into memory if possible.

### Hack: Scanning for Leaked Secrets
Use **Git Secrets** or **TruffleHog** as a pre-commit hook to prevent secrets from ever reaching your repository.
```bash
# Install git-secrets
git secrets --install
git secrets --register-aws
```

### Pro-Tip: Secret Versioning
Secrets Manager keeps versions of your secrets. If a rotation fails, you can quickly roll back to the `AWSPREVIOUS` version label.

## Summary Checklist
- [ ] Determine cost/feature trade-off between Secrets Manager and SSM.
- [ ] Implement automated rotation for all high-risk credentials.
- [ ] Use CSI Drivers or native integrations for container secrets.
- [ ] Secure the KMS keys used for secret encryption.
- [ ] Audit secret access logs via CloudTrail.
