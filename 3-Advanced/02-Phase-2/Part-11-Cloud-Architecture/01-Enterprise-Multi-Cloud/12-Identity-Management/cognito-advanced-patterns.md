# Advanced Cognito Patterns & Troubleshooting

A deep dive into customizing user workflows with Lambda triggers, federating identities with external providers, and resolving production-level issues.

## 1. Customizing Workflows with Lambda Triggers

Cognito allows you to trigger AWS Lambda functions at specific points in the user lifecycle.

### Common Use Cases
- **Pre-signup**: Add custom validation to check if a user is allowed to register (e.g., checking internal database).
- **Post-confirmation**: Trigger an welcome email or provision resources for the new user in a database.
- **Pre-token generation**: Add custom claims to the JWT ID token (e.g., user's internal ID or subscription tier).
- **Define Auth Challenge / Create Auth Challenge / Verify Auth Challenge Response**: Implement custom, passwordless authentication (e.g., Magic links or OTP via Email).

#### Example: Pre-Signup Lambda (Python)
```python
import json

def lambda_handler(event, context):
    # Only allow users from a specific domain
    user_email = event['request']['userAttributes'].get('email', '')
    if not user_email.endswith('@company.com'):
        raise Exception("Registration restricted to @company.com domains.")
    
    # Return to Cognito
    return event
```

## 2. Identity Federation (SAML & OIDC)

Instead of managing passwords, federate identities from enterprise directories or social providers.

### SAML Federation (e.g., Okta, Entra ID)
1. Configure Cognito as a Service Provider (SP) in the Identity Provider (IdP).
2. Upload the IdP metadata XML to Cognito.
3. Map SAML attributes (e.g., `NameID`) to Cognito User Pool attributes.

### Social Login (OIDC)
- Native integration for Google, Facebook, Amazon, and Apple.
- Cognito manages the OAuth 2.0 flow and returns a unified JWT to your application.

## 3. Advanced Security Features

### Adaptive Authentication
Cognito evaluates the risk of a login attempt based on:
- **New Device**: Is the user signing in from a known device?
- **New Location**: Is the login from an unusual IP range or country?
- **Risk Score**: Calculated based on multiple factors.
- **Action**: Based on risk, you can require MFA, allow, or block the session.

### Compromised Credential Protection
Cognito checks user credentials against a database of known leaked passwords from data breaches elsewhere on the internet.

## 4. Troubleshooting Guide

| Error Code | Probable Cause | Resolution |
| :--- | :--- | :--- |
| **InvalidParameterException** | Missing required attribute or malformed input. | Check User Pool schema; ensure all mandatory attributes are sent in `SignUp`. |
| **NotAuthorizedException** | Incorrect password or user is disabled. | Verify credentials. Check if user status is `CONFIRMED`. |
| **UserNotFoundException** | Typo in username or wrong User Pool ID. | Verify User Pool ID and Client ID match the region and account. |
| **AliasExistsException** | Email or phone matches another user. | Cognito enforces uniqueness for aliases. Ensure users sign in with unique identifiers. |
| **TokenExpiredError** | Access token has expired. | Use the **Refresh Token** to obtain a new Access/ID token silently. |

## 5. Cognito Architecture Hacks

### The "Admin Bypass" Hack
If you need to programmatically confirm a user's phone or email without sending a real SMS/Email during automated testing:
```bash
aws cognito-idp admin-update-user-attributes \
    --user-pool-id $USER_POOL_ID \
    --username $USERNAME \
    --user-attributes Name=email_verified,Value=true Name=phone_number_verified,Value=true
```

### Decoupling Client-side logic
Don't use AWS SDKs directly in your frontend if possible. Use **AWS Amplify** libraries. They handle the complex token refresh logic, storage, and secure transmission for you out-of-the-box.

## Summary Checklist
- [ ] Use Least Privilege for IAM roles associated with Identity Pools.
- [ ] Enable Advanced Security Features in production.
- [ ] Use Lambda triggers for critical business logic (like domain restrictions).
- [ ] Implement Token Revocation for sensitive applications.
- [ ] Monitor User Pool events with CloudWatch and CloudTrail.
