# 🔐 Security and Secrets Management

Protecting the integrity of your data and the confidentiality of your credentials.

## 🧱 Layered Defense
- **At the Edge**: WAF and Shield protect against web attacks and DDoS.
- **In the Data**: KMS (Key Management Service) handles encryption at rest.
- **In the App**: Secrets Manager stores DB passwords and API keys securely.

## 🚀 The "DevOps Why": Envelope Encryption
Why not just encrypt the data directly?
- **Envelope Encryption**: We encrypt data with a Data Key. We encrypt the Data Key with a Master Key.
- **Benefits**: Speed (Data key stays near the data) and Security (Master key never leaves the HSM of the cloud provider).

---

## 📂 Multi-Cloud Implementations
- [AWS-Shield-WAF-KMS](./aws-shield-waf-kms): Enterprise-grade encryption and defense.
- [Azure-Security-Center-KeyVault](./azure-security-center-keyvault): Integrated secret vault and security compliance.
- [GCP-Armor-SecretManager](./gcp-armor-secretmanager): Global edge protection and secret storage.
