# 🔐 Lab: Cross-Cloud Workload Identity Federation

> **Scenario**: You have an AWS Lambda function that needs to upload logs directly to a Google Cloud Storage (GCS) bucket.
> **Constraint**: You MUST NOT use static IAM service account keys (JSON keys). You must use short-lived, federated tokens.

---

## 🏗️ The Architecture (OIDC)

1.  **AWS Lambda** assumes an IAM Role.
2.  **Lambda** requests an OIDC ID Token from AWS STS.
3.  **Lambda** exchanges the AWS ID Token for a **GCP Federated Token** via the GCP Security Token Service (STS).
4.  **Lambda** impersonates a **GCP Service Account** to gain access to the GCS Bucket.

---

## 🛠️ Step 1: Configure Google Cloud (The Consumer)

First, we create a pool that trusts AWS as an Identity Provider.

### 1. Create the Workload Identity Pool
```bash
gcloud iam workload-identity-pools create "aws-pool" \
    --location="global" \
    --display-name="AWS Integration Pool"
```

### 2. Create the AWS OIDC Provider in GCP
```bash
gcloud iam workload-identity-pools providers create-aws "aws-provider" \
    --workload-identity-pool="aws-pool" \
    --account-id="YOUR_AWS_ACCOUNT_ID" \
    --location="global"
```

### 3. Bind a Service Account to the Pool
Allow any AWS role with a specific name to impersonate the GCP service account:
```bash
gcloud iam service-accounts add-iam-policy-binding "gcp-log-uploader@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/aws-pool/attribute.aws_role/arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/LambdaGCPLoggerRole"
```

---

## 🛠️ Step 2: Configure AWS (The Producer)

### 1. Create the Lambda IAM Role
The role only needs basic Lambda permissions, but its **ARN** must match the one used in the GCP binding above.
- **Name**: `LambdaGCPLoggerRole`
- **Policy**: `AWSLambdaBasicExecutionRole`

### 2. Lambda Execution Logic (Python/Boto3 & Google Auth)
The Lambda code uses the `google-auth` library to handle the token exchange automatically.

```python
import boto3
from google.auth import identity_pool
from google.cloud import storage

def lambda_handler(event, context):
    # 1. Define the OIDC Configuration
    audience = "//iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/aws-pool/providers/aws-provider"
    
    # 2. Use the local AWS credentials to exchange for GCP tokens
    # Note: 'google-auth' understands how to fetch the AWS token if running in Lambda/EC2
    credentials = identity_pool.Credentials.from_info({
        "type": "external_account",
        "audience": audience,
        "subject_token_type": "urn:ietf:params:oauth:token-type:id_token",
        "token_url": "https://sts.googleapis.com/v1/token",
        "service_account_impersonation_url": "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/gcp-log-uploader@PROJECT_ID.iam.gserviceaccount.com:generateAccessToken",
        "credential_source": {
            "environment_variable": "AWS_ROLE_ARN" # Handled by Google library
        }
    })

    # 3. Access GCS
    client = storage.Client(credentials=credentials)
    bucket = client.bucket("my-enterprise-logs")
    blob = bucket.blob("incoming/lambda-log.txt")
    blob.upload_from_string("Hello from AWS Lambda via federated identity!")
    
    return {"status": "success"}
```

---

## 🚨 Production Hazards (Senior Pro-Tips)

- **Audience Mismatch**: The `audience` string in GCP MUST exactly match the URL-encoded path of the provider. Even one extra slash will cause a 403.
- **Token Expiry**: STS tokens are short-lived. If your Lambda runs for a long time (rare, but possible), ensure the library refreshes the token.
- **Attribute Mapping**: You can map AWS tags (e.g., `Project`, `CostCenter`) into GCP attributes to enforce fine-grained access control on the GCP side.

---
**Module**: Multi-Cloud Security
**Next Lab**: [Cross-Cloud VPN Mesh](../connectivity/vpn-mesh-lab.md)
