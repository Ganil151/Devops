# AWS CloudFront Architectural Patterns

This directory contains 20 common CloudFront patterns for Content Delivery Network (CDN) services using Terraform. CloudFront speeds up the distribution of your static and dynamic web content by delivering it through a worldwide network of data centers called edge locations.

## 📂 CloudFront Patterns Overview

| # | Type | Description | File |
|---|------|-------------|------|
| 1 | **Basic S3 Dist** | Standard global edge caching for an S3 bucket. | `01-basic-distribution.tf` |
| 2 | **OAC Security** | modern Origin Access Control for S3 origins. | `02-origin-access-control.tf` |
| 3 | **Custom Domain** | using ACM SSL certificates and branded domains. | `03-custom-domain-ssl.tf` |
| 4 | **Multi-Origin** | routing traffic to S3 (static) and ALB (dynamic). | `04-multiple-origins.tf` |
| 5 | **Cache Policy** | creating custom caching rules for edge nodes. | `05-cache-policy.tf` |
| 6 | **Request Policy** | Forwards specific headers/cookies to the origin. | `06-origin-request-policy.tf` |
| 7 | **Response Policy** | Injecting security headers (HSTS, CSP) at edge. | `07-response-headers-policy.tf` |
| 8 | **WAF Integration** | blocking malicious traffic via Web App Firewall. | `08-waf-integration.tf` |
| 9 | **Lambda@Edge** | complex edge logic using Node.js/Python functions. | `09-lambda-edge.tf` |
| 10 | **CF Functions** | High-scale URI/Header manipulations via JS. | `10-cloudfront-functions.tf` |
| 11 | **Signed URLs** | Protecting private content with signed tokens. | `11-signed-urls.tf` |
| 12 | **Geo Restriction** | whitelisting or blacklisting access by country. | `12-geo-restriction.tf` |
| 13 | **Error Pages** | Branded 404/5xx pages for better UX. | `13-custom-error-pages.tf` |
| 14 | **S3 Logging** | archiving access logs for audit and analysis. | `14-s3-logging.tf` |
| 15 | **Price Class** | optimized costs by limiting edge locations. | `15-price-class.tf` |
| 16 | **Real-time Logs** | Streaming logs to Kinesis for instant metrics. | `16-real-time-logs.tf` |
| 17 | **Field Encryption**| encrypting PII data fields at the edge. | `17-field-level-encryption.tf` |
| 18 | **Continuous CD** | Canary deployments for CloudFront configurations. | `18-continuous-deployment.tf` |
| 19 | **Managed Policy** | using AWS-standard caching optimizations. | `19-managed-cache-policy.tf` |
| 20 | **Minimalist** | Baseline distribution boilerplate. | `20-minimalist-cf.tf` |

## 🚀 Architectural Best Practices
1.  **Use OAC**: Never leave your S3 bucket public. Use **Origin Access Control (OAC)** to ensure only CloudFront can read your files.
2.  **Redirect to HTTPS**: Always enforce HTTPS using `viewer_protocol_policy = "redirect-to-https"`.
3.  **Modern TLS**: Use `minimum_protocol_version = "TLSv1.2_2021"` or higher for secure viewer connections.
4.  **Cache policies over forwarded_values**: Prefer modern **Cache Policies** and **Origin Request Policies** over the legacy `forwarded_values` block.
5.  **Global ACM**: Remember that SSL certificates for CloudFront must be created in the **us-east-1** region.

## 🛠 Prerequisites
CloudFront distributions require an origin (S3 bucket, Load Balancer, or HTTP server). Some configurations (like Custom Domains) require pre-validated ACM certificates.
