# AWS GuardDuty: Intelligent Threat Detection

AWS GuardDuty is a continuous security monitoring service that analyzes and processes foundational data sources to identify unexpected and potentially unauthorized and malicious activity within your AWS environment.

---

## 1. Data Sources
GuardDuty is powerful because it analyzes log data **without you needing to enable logging** (it pulls from the service backends):
- **CloudTrail Management Events**: Detecting unusual API calls.
- **VPC Flow Logs**: Identifying suspicious network traffic (e.g., crypto-mining, C2 communication).
- **DNS Logs**: Detecting domain name queries to known malicious domains.
- **S3 Data Events**: Monitoring object-level access patterns.

---

## 2. Finding Types
GuardDuty categorizes findings into several types:
- **Recon**: Unusual API activity suggesting reconnaissance (e.g., `DescribeSubnets` from a new IP).
- **InstanceCredentialExfiltration**: Detecting that credentials assigned to an EC2 instance are being used from outside the AWS network.
- **CryptoCurrency**: Detecting communication with known mining pools.

---

## 3. Automation & Response
GuardDuty is most effective when integrated with **AWS EventBridge** and **AWS Lambda** for automated response.

**Example**:
1. GuardDuty detects a compromised EC2 instance.
2. EventBridge triggers a Lambda function.
3. Lambda isolates the instance by swapping its Security Group and attaching a restrictive IAM policy.

---

**Next Step**: Return to the **[Identity & Governance Overview](../readme.md)** to see how these tools work together.
