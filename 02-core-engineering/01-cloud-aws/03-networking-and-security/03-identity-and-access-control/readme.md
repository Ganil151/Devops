# 🔑 Identity and Access Control (IAM)

IAM is the most critical security layer in the cloud. It manages "Who" (Principals) can do "What" (Actions) on "What" (Resources).

## 🛡️ The Zero-Trust Model
In IAM, we follow the **Principle of Least Privilege**:
- **Principals**: Users, Groups, or Roles (for services).
- **Policies**: JSON or YAML documents defining permissions.
- **MFA**: Multi-Factor Authentication for every human user.

## 🚀 The "DevOps Why": Service Roles
In professional DevOps, we never use long-lived Access Keys inside applications.
- **Identity Federation**: Using an external provider (like Okta or Azure AD) to sign into the cloud.
- **Service Roles**: Granting an EC2 instance or a Lambda function a "Role" that provides temporary, rotating credentials via an internal metadata service.

---

## 📂 Multi-Cloud Implementations
- [AWS-IAM-Cognito](./aws-iam-cognito): Resource-based and Identity-based policies.
- [Azure-AD](./azure-ad): Modern enterprise identity management.
- [GCP-IAM](./gcp-iam): Hierarchical permissions (Org -> Folder -> Project).
