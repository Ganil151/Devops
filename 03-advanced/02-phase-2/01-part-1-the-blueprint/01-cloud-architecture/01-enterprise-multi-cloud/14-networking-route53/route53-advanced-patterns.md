# Advanced Route 53 Patterns & Troubleshooting

Master complex traffic routing, hybrid DNS integration, and resolving DNS resolution failures in production.

## 1. Advanced Routing Policies

Route 53 offers several policies to determine how it responds to queries.

| Policy | Use Case |
| :--- | :--- |
| **Simple** | Single resource that performs a given function for your domain (e.g., one web server). |
| **Weighted** | Route traffic to multiple resources in proportions that you specify (e.g., 80/20 for Blue/Green deployment). |
| **Latency** | Route traffic to the region that provides the lowest latency for the user. |
| **Failover** | Configure active-passive failover for Disaster Recovery. |
| **Geolocation** | Route traffic based on the geographic location of your users. |
| **Geoproximity** | Route traffic based on the geographic location of your resources and (optionally) shift traffic between them. |
| **Multi-value Answer** | Simple routing with health checks. Returns up to 8 healthy records. |

### Example: Weighted Routing (CLI)
```json
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "app.example.com",
        "Type": "A",
        "SetIdentifier": "BluePool",
        "Weight": 80,
        "ResourceRecords": [{ "Value": "1.2.3.4" }]
      }
    },
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "app.example.com",
        "Type": "A",
        "SetIdentifier": "GreenPool",
        "Weight": 20,
        "ResourceRecords": [{ "Value": "5.6.7.8" }]
      }
    }
  ]
}
```

## 2. Route 53 Resolver (Hybrid DNS)

The Route 53 Resolver enables recursive DNS queries between your VPC and on-premises networks.

- **Inbound Endpoints**: Allow on-premises DNS servers to resolve AWS-based domains (e.g., `db.us-east-1.aws.local`).
- **Outbound Endpoints**: Allow AWS resources to resolve on-premises domains (e.g., `corporate-ad.internal`).
- **Rules**: Define which domains should be forwarded to which DNS servers.

## 3. Security: DNSSEC

Domain Name System Security Extensions (DNSSEC) protects your domain from DNS spoofing and man-in-the-middle attacks.
1. Enable DNSSEC signing for your hosted zone.
2. Create a Key-Signing Key (KSK) in AWS KMS.
3. Establish a Chain of Trust by providing the DS record to your domain registrar.

## 4. Troubleshooting Guide

### Primary Tools
- `dig`: Best for detailed DNS investigation.
- `nslookup`: Quick checks.
- `host`: Human-readable DNS info.

### Common Issues
| Symptom | Probable Cause | Resolution |
| :--- | :--- | :--- |
| **DNS Not Resolving** | Registrar Name Servers not updated | Verify the NS records in Route 53 match what is configured at your registrar. |
| **Propagation Lag** | High TTL | Wait for the TTL to expire or use `dig @8.8.8.8` to check Google DNS. |
| **Failover Not Working** | Health Check misconfigured | Ensure the health check is correctly pointing to a public IP and the security groups allow Route 53 health checkers. |
| **Private Zone Not Working** | VPC DNS hostnames disabled | Ensure `enableDnsHostnames` and `enableDnsSupport` are set to `true` in your VPC. |

### The "Propagation Check" Hack
Use `dig +trace myapp.example.com` to see the full path of DNS resolution from the root servers down to Route 53. This helps identify where exactly the breakdown is occurring.

## 5. Performance Tips
- **TTL Balancing**: Use low TTL (60s) for resources that change often (like failover targets) and high TTL (172800s) for static records to reduce DNS query costs and latency.
- **EDNS Extensions**: Route 53 supports EDNS0 client subnet, allowing it to provide more geographically accurate results.

---

## Route 53 Best Practices Checklist
- [ ] Use **Alias Records** for all AWS resource mapping.
- [ ] Implement **Health Checks** for all public-facing application endpoints.
- [ ] Enable **CloudWatch Logs** for DNS query logging in critical environments.
- [ ] Use **Weighted Routing** for canary releases and testing.
- [ ] Protect critical domains with **DNSSEC**.
