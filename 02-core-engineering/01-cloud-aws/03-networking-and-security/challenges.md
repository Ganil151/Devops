# 🧪 Networking & Security Labs

## Lab 1: "The Private Link Bridge"
**Objective**: Architecture a secure, private connection between two VPCs in different accounts without exposing traffic to the public internet.

### Scenario
Account A (Frontend) needs to access a REST API running in a private subnet in Account B (Backend). Company policy forbids VPC Peering due to overlapping CIDR ranges and security concerns.

### The Solution: PrivateLink (VPC Endpoints)
1. **Account B**: Create an **NLB** (Network Load Balancer) in front of the API.
2. **Account B**: Create an **Endpoint Service** associated with the NLB.
3. **Account A**: Create an **Interface VPC Endpoint** pointing to the service in Account B.

### Your Tasks
- [ ] Provision the VPCs and subnets with non-overlapping and overlapping ranges to simulate the constraint.
- [ ] Configure the NLB and Endpoint Service in the Backend account.
- [ ] Whitelist the Frontend account ID.
- [ ] Create the Endpoint in the Frontend account and verify connectivity via `curl` to the endpoint DNS.

---

## Lab 2: "The Secrets Rotation Automaton"
**Objective**: Implement a zero-trust model where application code never sees a hardcoded password.

### Scenario
An RDS PostgreSQL database requires credentials. You must store them in AWS Secrets Manager and rotate them every 30 days without application downtime.

### Implementation
1. **Vault**: Store the JSON credentials in Secrets Manager.
2. **Rotation**: Enable rotation using a managed Lambda function (or custom Bicep/Terraform logic).
3. **Access**: Grant the EC2/ECS instance an **IAM Role** with `secretsmanager:GetSecretValue` permission.
4. **App**: The application code calls the Secrets Manager API at startup/periodically to retrieve current credentials.

### Your Tasks
- [ ] Create an RDS instance.
- [ ] Store credentials in Secrets Manager via Terraform.
- [ ] Configure the Lambda rotation function.
- [ ] Write a simple script (Python/Node) that demonstrates fetching the secret using the SDK.
- [ ] Verify that when the secret is manually rotated, the app can still connect.

---

## 🏁 Final Project: The Hardened Edge
Combine all concepts:
- Deploy a static site on **S3/CloudFront**.
- Attach an **AWS WAF** with managed rules for SQLi and Bot protection.
- Configure **Route 53** with a health check failover to a maintenance page.
- Use **Certificate Manager** (ACM) for end-to-end SSL/TLS.
