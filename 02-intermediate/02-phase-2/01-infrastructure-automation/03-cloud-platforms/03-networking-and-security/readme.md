# Multi-Cloud Networking & Security Architect Framework

## 🌐 The Multi-Cloud Pillar
This framework provides a unified approach to architecting secure, high-performance network foundations across AWS, Azure, and GCP. In a cloud-native world, "Networking is the Security Perimeter." We focus on Zero-Trust principles, global traffic management, and identity-centric access control.

### The "DevOps Why": The Software-Defined Perimeter
Traditional networking relied on "Castles and Moats." Cloud networking uses "Software-Defined Perimeters."
- **Isolation**: Prevent lateral movement via micro-segmentation.
- **Performance**: Use content delivery networks (CDNs) to move data closer to the edge.
- **Scalability**: Programmatic network provisioning (Infrastructure as Code) to support rapid application scaling.
- **Compliance**: Enforce encryption in transit and at rest at the infrastructure level.

---

## 📊 Cross-Cloud Comparison Matrix

| Technical Function | AWS | Azure | GCP |
| :--- | :--- | :--- | :--- |
| **Virtual Network** | VPC | Virtual Network (VNet) | VPC / Cloud Network |
| **Private Connectivity** | Direct Connect | ExpressRoute | Cloud Interconnect |
| **Global DNS** | Route 53 | Azure DNS | Cloud DNS |
| **Edge CDN** | CloudFront | Front Door / CDN | Cloud CDN |
| **Web Firewall** | AWS WAF | Azure WAF | Cloud Armor |
| **Identity Service** | IAM | Microsoft Entra ID (AD) | Cloud IAM |
| **Secrets Management** | Secrets Manager | Key Vault | Secret Manager |
| **Key Management** | KMS | Key Vault (Keys) | Cloud KMS |
| **DDoS Protection** | Shield | DDoS Protection | Cloud Armor |

---

## 📂 Framework Structure

### [01-Network-Infrastructure](./01-network-infrastructure)
The foundational connectivity layer.
- **AWS-VPC**: Subnets, IGW, NAT, and Peering.
- **Azure-VNet**: Hub-and-Spoke architectures.
- **GCP-Virtual-Network**: Global VPCs and VPC Service Controls.

### [02-DNS-and-Content-Delivery](./02-dns-and-content-delivery)
Global traffic steering and performance.
- **AWS-Route53-CloudFront**: High-availability DNS and global caching.
- **Azure-DNS-FrontDoor**: Modern CDN with integrated security.
- **GCP-Cloud-DNS-CDN**: Fast, global edge infrastructure.

### [03-Identity-and-Access-Control](./03-identity-and-access-control)
Who can do what, and from where?
- **AWS-IAM-Cognito**: Roles, Policies, and Consumer identity.
- **Azure-AD**: Enterprise identity and B2C.
- **GCP-IAM**: Resource-based hierarchy and service accounts.

### [04-Security-and-Secrets-Management](./04-security-and-secrets-management)
Defending the perimeter and protecting data.
- **AWS-Shield-WAF-KMS**: Encryption and DDoS defense.
- **Azure-Security-Center-KeyVault**: Unified security management.
- **GCP-Armor-SecretManager**: Enterprise-grade API security.

---

## 🚀 Industry Asset: "The Global Banking Perimeter"
**Scenario**: A financial institution needs to serve low-latency traffic globally while strictly complying with data residency laws and preventing SQL injection.
**The Challenge**: Managing disparate security policies across 3 continents.
**The Architecture Solution**:
1. **Edge Defense**: Use **AWS WAF** (or GCP Armor) at the CDN level to block top 10 OWASP threats before they reach the data center.
2. **Transit Security**: Implement **PrivateLink** (or Azure Private Link) so that communication between the frontend and database never traverses the public internet.
3. **Identity Consolidation**: Use **SAML Federation** to allow employees to use one identity across all cloud environments, centrally managed via Azure AD.
4. **Secrets Rotation**: Enforce 30-day rotation for all DB credentials using **AWS Secrets Manager**, integrated with the application via IAM Roles.

---

## 🎓 Interview Preparation (Senior Level)

1. **How does a 'Global VPC' in GCP differ from AWS VPC Peering?**
   *Answer*: GCP VPCs are global resources; a single VPC can span multiple regions. In AWS, VPCs are regional, and you must use "VPC Peering" or "Transit Gateway" to connect them. GCP's architecture simplifies global routing but requires careful subnet CIDR management.

2. **Explain 'Envelope Encryption' using KMS.**
   *Answer*: It is the practice of encrypting data with a Data Key, and then encrypting that Data Key with a Master Key (CMK) within the KMS. This allows for high-performance encryption of large data while keeping the master keys securely stored in an HSM.

3. **What is 'Zero Trust' in the context of VPC Security Groups?**
   *Answer*: Zero Trust assumes the network is compromised. It means configuring Security Groups with "Default Deny" and only allowing specific ports/IPs for known services (Micro-segmentation), and using Identity-Aware Proxies (IAP) instead of traditional VPNs.

4. **Difference between AWS WAF and AWS Shield?**
   *Answer*: WAF protects at Layer 7 (Application) against SQLi, XSS, etc. Shield (Standard/Advanced) protects at Layer 3/4 against DDoS attacks (SYN floods, UDP blasts).

5. **When would you use a 'Transit Gateway' over 'VPC Peering'?**
   *Answer*: Use Transit Gateway when you have a complex "Hub-and-Spoke" network (e.g., more than 10 VPCs). Peering is point-to-point and does not support transitive routing; Transit Gateway centralizes management and simplifies network topology.

---

## 🧠 Knowledge Check: Networking & Security

1. **Which DNS record type is used to map a domain to a CloudFront distribution?** (ALIAS or CNAME)
2. **True/False: A NAT Gateway is required for an instance in a public subnet to reach the internet.** (False, IGW is needed. NAT is for private subnets)
3. **What is the purpose of a VPC Endpoint?** (To access cloud services privately without using an IGW)
4. **Define 'Least Privilege' in IAM.** (Granting only the minimum permissions required for a task)
5. **What is the difference between a NACL and a Security Group?** (NACL is stateless/subnet level; SG is stateful/instance level)
