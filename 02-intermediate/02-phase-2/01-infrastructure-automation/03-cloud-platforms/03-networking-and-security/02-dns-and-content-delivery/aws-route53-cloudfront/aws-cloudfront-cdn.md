# AWS CloudFront CDN Guide

Amazon CloudFront is a fast content delivery network (CDN) service that securely delivers data, videos, applications, and APIs to customers globally with low latency and high transfer speeds.

## 1. Core Components

- **Origins**: The source of your content (S3 buckets, ALBs, EC2 instances, or custom HTTP servers).
- **Distributions**: The configuration settings that tell CloudFront where to fetch content and how to deliver it.
- **Edge Locations**: Global network of data centers that cache content closer to users.
- **Behaviors**: Rules that define how CloudFront handles requests (e.g., caching TTL, protocol redirection, allowed methods).

## 2. Hands-on: Creating a CloudFront Distribution (CLI)

Typically, you use CloudFront to serve static content from an S3 bucket or to front-end an API.

```bash
# 1. Create a CloudFront Distribution for an S3 Origin
# Note: You need a distribution configuration JSON file
cat > cf-config.json << EOF
{
  "CallerReference": "my-distribution-$(date +%s)",
  "Origins": {
    "Items": [
      {
        "Id": "S3-Origin",
        "DomainName": "my-bucket.s3.amazonaws.com",
        "S3OriginConfig": {
          "OriginAccessIdentity": ""
        }
      }
    ],
    "Quantity": 1
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-Origin",
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": { "Forward": "none" }
    },
    "TrustedSigners": { "Enabled": false, "Quantity": 0 },
    "ViewerProtocolPolicy": "redirect-to-https",
    "MinTTL": 0
  },
  "Enabled": true,
  "Comment": "My DevOps Static Content Distribution"
}
EOF

aws cloudfront create-distribution \
    --distribution-config file://cf-config.json
```

## 3. High Availability & Security

- **Origin Failover**: Automatically switch to a secondary origin (e.g., S3 in another region) if the primary origin fails.
- **SSL/TLS (HTTPS)**: Use **AWS Certificate Manager (ACM)** to provide custom SSL certificates. Certificates must be in `us-east-1` to be used with CloudFront.
- **AWS WAF Integration**: Protect your distribution from common web exploits (SQLi, XSS) and bots.
- **Geo-Blocking**: Prevent users in specific countries from accessing your content.

## 4. Lambda@Edge & CloudFront Functions

Run code at the edge to customize content for each user with ultra-low latency.

| Feature | CloudFront Functions | Lambda@Edge |
| :--- | :--- | :--- |
| **Runtime** | Lightweight JavaScript | Node.js or Python |
| **Execution Location** | Viewer Request / Response | Viewer/Origin Request/Response |
| **Complexity** | Simple headers, redirects | Heavy logic, DB calls, network access |
| **Performance** | Sub-millisecond | 10ms - 100ms |

## 5. Troubleshooting Guide

| Symptom | Probable Cause | Resolution |
| :--- | :--- | :--- |
| **403 Access Denied** | S3 bucket policy or OAI/OAC missing | Ensure the S3 bucket policy allows `cloudfront.amazonaws.com` access. |
| **Stale Content** | High TTL or caching issue | Use **Invalidations** to clear the cache manually or reduce TTL in Behaviors. |
| **SSL Handshake Failed** | Mismatch between Client and CloudFront or Origin certificate | Verify the ACM certificate is valid and assigned; check Origin protocol policy. |
| **Slow Propagation** | Distribution is "In Progress" | CloudFront distributions can take 15-20 minutes to fully deploy globally. |

---
**Next Step**: Master container orchestration with [AWS ECS Deep Dive](../../../02-compute-and-scale/01-compute-services/aws-ec2-ecs/aws-ecs-fargate-guide.md)
