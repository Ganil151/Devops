# Hands-on Cognito Guide: Console & CLI

This guide provides step-by-step instructions for setting up an Amazon Cognito User Pool and managing users using the AWS Management Console and the AWS CLI.

## 1. Creating a User Pool

### Using the Management Console
1. Navigate to the **Cognito Console**.
2. Click **Create user pool**.
3. **Step 1: Configure sign-in experience**: Choose **User name** and **Email**. Click **Next**.
4. **Step 2: Configure security requirements**: Choose **No MFA** (for testing) and leave other defaults. Click **Next**.
5. **Step 3: Configure sign-up experience**: Leave defaults. Click **Next**.
6. **Step 4: Configure message delivery**: Choose **Send email with Cognito**. Click **Next**.
7. **Step 5: Integrate your app**:
   - **User pool name**: `my-test-user-pool`.
   - **App client name**: `my-web-app`.
   - **Client secret**: Choose **Generate a client secret**.
8. **Step 6: Review and create**: Click **Create user pool**.

### Using the AWS CLI
```bash
# Create the user pool
USER_POOL_ID=$(aws cognito-idp create-user-pool \
    --pool-name my-test-user-pool \
    --policies '{"PasswordPolicy":{"MinimumLength":8,"RequireUppercase":true,"RequireLowercase":true,"RequireNumbers":true,"RequireSymbols":false}}' \
    --query 'UserPool.Id' --output text)

echo "User Pool ID: $USER_POOL_ID"

# Create an app client
CLIENT_ID=$(aws cognito-idp create-user-pool-client \
    --user-pool-id $USER_POOL_ID \
    --client-name my-web-app \
    --no-generate-secret \
    --query 'UserPoolClient.ClientId' --output text)

echo "Client ID: $CLIENT_ID"
```
___

## 2. Managing Users via CLI

### Create a User
```bash
aws cognito-idp admin-create-user \
    --user-pool-id $USER_POOL_ID \
    --username devops-user \
    --user-attributes Name=email,Value=devops@example.com \
    --temporary-password "TempPass123!"
```

### Confirm a User (Mark as Verified)
```bash
aws cognito-idp admin-confirm-sign-up \
    --user-pool-id $USER_POOL_ID \
    --username devops-user
```

### Set/Change User Password
```bash
aws cognito-idp admin-set-user-password \
    --user-pool-id $USER_POOL_ID \
    --username devops-user \
    --password "NewSecurePass!2024" \
    --permanent
```

### List Users
```bash
aws cognito-idp list-users --user-pool-id $USER_POOL_ID
```
___

## 3. Configuring the Hosted UI

The Hosted UI is a ready-to-use authentication page.

1. In the User Pool console, go to **App integration** -> **Domain**.
2. Click **Create Cognito domain** and enter a unique prefix.
3. Go to **App client settings** and configure:
   - **Callback URLs**: `https://example.com` (for testing).
   - **Allowed OAuth Flows**: `Authorization code grant`.
   - **Allowed OAuth Scopes**: `email`, `openid`, `profile`.
4. Click **View Hosted UI** to test the sign-in page.

## 4. Setting up MFA (CLI)

```bash
# Enable MFA for the User Pool
aws cognito-idp update-user-pool \
    --user-pool-id $USER_POOL_ID \
    --mfa-configuration ON \
    --sms-configuration '{"SnsCallerArn":"ARN_OF_IAM_ROLE","ExternalId":"EXT_ID"}'
```

## 5. Cleaning Up
```bash
# Delete the app client first
aws cognito-idp delete-user-pool-client \
    --user-pool-id $USER_POOL_ID \
    --client-id $CLIENT_ID

# Delete the user pool
aws cognito-idp delete-user-pool --user-pool-id $USER_POOL_ID
```

---
**Next Step**: Explore [Advanced Cognito Patterns & Troubleshooting](../../Advanced-Level/12-Identity-Management/cognito-advanced-patterns.md)
