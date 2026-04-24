# Security Hacks & Troubleshooting

A collection of "street-smart" security techniques, rapid incident response tactics, and deep-dive troubleshooting for cloud security engineers.

## 1. Troubleshooting "Access Denied" (IAM)

The most common cloud error can be the hardest to solve because "Access Denied" usually doesn't tell you *why*.

### Hack: The STS Decode-Authorization-Message
When you get a long, encoded "Access Denied" message from the CLI, decode it to find the specific failing policy.
```bash
# Encoded message looks like: "...EncodedMessage: ABC123XYZ..."
aws sts decode-authorization-message \
    --encoded-message [PASTE_ENCODED_MESSAGE_HERE] \
    --query DecodedMessage \
    --output text | jq .
```
> [!TIP]
> This command requires the `sts:DecodeAuthorizationMessage` permission. It is common for "Admin" roles to have this, but not "Developer" roles.

### Diagnostic Flowchart
1. **Is there an Explicit Deny?** (Check SCPs, Resource Policies).
2. **Is there an Allow?** (Check Identity policies).
3. **Is there a Boundary?** (Check if permissions are clipped by a Permission Boundary).
4. **Is it a Session Context issue?** (e.g., MFA missing but required by policy).

## 2. Incident Response Hacks

### Hack: Rapid Key Deactivation (The "Kill Switch")
If you suspect an access key is leaked, don't just delete it immediately. Deactivate it first. This stops the attacker but allows for easier restoration if it turns out to be a critical service.
```bash
# Kill switch script
#!/bin/bash
USER_NAME=$1
KEY_ID=$(aws iam list-access-keys --user-name $USER_NAME --query 'AccessKeyMetadata[0].AccessKeyId' --output text)

echo "Disabling key $KEY_ID for user $USER_NAME..."
aws iam update-access-key --user-name $USER_NAME --access-key-id $KEY_ID --status Inactive
```

### Hack: Blocking an IP at the Edge
If your application is under attack from a specific IP, block it at the **VPC NACL** (stateless) or **WAF** (Web Application Firewall) level rather than the Security Group (stateful) to save processing power.

## 3. Network Security Troubleshooting

### Analyzing VPC Flow Logs (CloudWatch Logs Insights)
Use this query to find rejected traffic patterns.
```sql
fields @timestamp, srcAddr, dstAddr, dstPort, action
| filter action="REJECT"
| stats count(*) as totalRejections by srcAddr, dstAddr, dstPort
| sort totalRejections desc
| limit 20
```

### The "Security Group vs NACL" Rule of Thumb
- **Can connect but times out?** Check Security Groups (they are stateful; if it goes out, it comes back in. If it's blocking, it just drops the packet).
- **Connection Refused immediately?** Check NACLs or the application service itself listening on that port.

## 4. Cost-Saving Security Hacks

### Free-Tier Vulnerability Monitoring
- **IAM Access Analyzer**: Free. Tells you which resources are shared externally.
- **Trusted Advisor (Security Check)**: Includes some free checks (e.g., S3 buckets with global access, root account MFA).
- **VPC Flow Logs to Cloudwatch**: Can be expensive; route them to **S3** and use **Athena** for periodic analysis to save 90% of the cost.

### Hack: Auto-Tagging IAM Creators
Use CloudWatch Events + Lambda to automatically tag IAM Users with their creation date and creator email for easier auditing later.

## 5. Security Performance Tips

### Use IMDSv2
Force EC2 instances to use Instance Metadata Service Version 2. This prevents SSRF (Server-Side Request Forgery) attacks that aim to steal EC2 role credentials.
```bash
# Enforce IMDSv2 on an existing instance
aws ec2 modify-instance-metadata-options \
    --instance-id i-1234567890abcdef0 \
    --http-tokens required \
    --http-endpoint enabled
```

## Summary Checklist
- [ ] Practice decoding authorization messages before an emergency happens.
- [ ] Have a "kill switch" script ready for leaked credentials.
- [ ] Regularly run CloudWatch Insights queries to look for REJECT traffic.
- [ ] Transition all EC2 workloads to IMDSv2.
- [ ] Audit S3 public access using IAM Access Analyzer.
