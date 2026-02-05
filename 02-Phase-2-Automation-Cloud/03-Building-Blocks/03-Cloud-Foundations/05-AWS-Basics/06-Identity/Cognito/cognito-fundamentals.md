# Cognito Fundamentals & Concepts

Amazon Cognito provides authentication, authorization, and user management for your web and mobile apps. Your users can sign in directly with a user name and password, or through a third party such as Facebook, Amazon, Google or Apple.

## 1. Core Concepts

Cognito consists of two main components: **User Pools** and **Identity Pools**.

### User Pools (Authentication)
A User Pool is a user directory in Amazon Cognito. It provides:
- Sign-up and sign-in services.
- A built-in, customizable web UI to sign in users (Hosted UI).
- Social sign-in with Google, Facebook, Amazon, and Apple, as well as through SAML and OIDC identity providers.
- User profile management and custom attributes.
- Security features such as multi-factor authentication (MFA), checks for compromised credentials, account takeoff protection, and phone and email verification.

### Identity Pools (Authorization)
Identity Pools (Federated Identities) enable you to create unique identities for your users and federate them with identity providers. With an identity pool, you can obtain temporary, limited-privilege AWS credentials to access other AWS services.
- Controls access to AWS resources (like S3 buckets or DynamoDB tables).
- Supports both authenticated and unauthenticated (guest) users.

## 2. User Pools vs. Identity Pools

| Feature | User Pools | Identity Pools |
| :--- | :--- | :--- |
| **Primary Goal** | Authentication (Who are you?) | Authorization (What can you do?) |
| **Outcome** | Returns JWT tokens (Id, Access, Refresh) | Returns Temporary AWS Credentials |
| **Directory** | Contains its own user directory | Does not contain a directory |
| **Typical Use** | User registration and token-based auth | Accessing AWS services directly from client |

## 3. User Lifecycle Management

- **Sign-up**: Users can register themselves or be created by an administrator.
- **Verification**: Automatic verification of email addresses or phone numbers.
- **MFA**: Support for SMS-based and TOTP (Time-based One-Time Password) MFA.
- **Account Recovery**: Self-service password reset and recovery workflows.

## 4. Attributes

- **Standard Attributes**: OpenID Connect compliant attributes like `email`, `given_name`, `phone_number`.
- **Custom Attributes**: Up to 50 additional attributes specific to your application's needs.

## 5. Security Summary

- **Encryption**: Data is encrypted at rest and in transit.
- **Advanced Security Features**: Adaptive authentication based on risk (IP address, device, location).
- **Compliance**: PCI DSS, SOC, ISO/IEC, HIPAA, and more.

---
**Next Step**: Learn how to set up Cognito in the [Hands-on Cognito Guide](../../../../../../2-Intermediate/02-Phase-2/01-Infrastructure-Automation/03-Cloud-Platforms/03-Networking-and-Security/03-Identity-and-Access-Control/AWS-IAM-Cognito/cognito-hands-on.md)
