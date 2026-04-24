# AWS API Gateway Guide

Amazon API Gateway is a fully managed service that makes it easy for developers to create, publish, maintain, monitor, and secure APIs at any scale.

## 1. API Types: REST vs. HTTP vs. WebSocket

| Feature | HTTP API | REST API | WebSocket API |
| :--- | :--- | :--- | :--- |
| **Primary Goal** | Low-latency, cost-effective | Feature-rich (Edge-optimized) | Real-time, two-way |
| **Cost** | Up to 71% cheaper than REST | Standard pricing | Message-based pricing |
| **Features** | OIDC/OAuth2, auto-deployment | Usage plans, caching, WAF | Statefull connections |
| **Endpoint Types** | Regional | Edge-optimized, Regional, Private | Regional |

### Endpoint Explained
- **Edge-optimized**: Routes traffic through CloudFront edge locations (Best for global users).
- **Regional**: Deployed in a specific region (Best for same-region clients).
- **Private**: Accessible only within your VPC via VPC Endpoints.

## 2. Hands-on: Creating an HTTP API (CLI)

HTTP APIs are the modern, recommended choice for simple Lambda integrations.

```bash
# 1. Create the API
API_ID=$(aws apigatewayv2 create-api \
    --name "DevOps-Microservice" \
    --protocol-type HTTP \
    --query 'ApiId' --output text)

# 2. Create an Integration (connect to Lambda)
INTEGRATION_ID=$(aws apigatewayv2 create-integration \
    --api-id $API_ID \
    --integration-type AWS_PROXY \
    --integration-uri arn:aws:lambda:us-east-1:123456789012:function:my-function \
    --payload-format-version "2.0" \
    --query 'IntegrationId' --output text)

# 3. Create a Route
aws apigatewayv2 create-route \
    --api-id $API_ID \
    --route-key "GET /hello" \
    --target "integrations/$INTEGRATION_ID"

# 4. Create a Stage (Automatic deployment)
aws apigatewayv2 create-stage \
    --api-id $API_ID \
    --stage-name '$default' \
    --auto-deploy
```

## 3. Security: Authorizers
Protect your API using one of the following methods:
- **IAM Authorizers**: Fine-grained access using AWS credentials (best for internal apps).
- **Cognito User Pools**: Authenticate users via OIDC tokens (best for web/mobile apps).
- **Lambda Authorizers**: Custom logic to validate tokens or headers.
## 4. Usage Plans & Throttling (REST API Only)
Control how clients consume your API to prevent abuse and manage costs.
- **Throttling**: Limit the rate of requests (Requests Per Second).
- **Quota**: Limit the total number of requests per day/week/month.
- **API Keys**: Identify and authorize unique clients.
## 5. Troubleshooting Guide

| Symptom | Probable Cause | Resolution |
| :--- | :--- | :--- |
| **403 Forbidden** | WAF blocking request or IAM permission missing | Check WAF logs or ensure the execution role has `lambda:InvokeFunction`. |
| **429 Too Many Requests** | Throttling limits reached | Verify Usage Plan settings or check account-level API Gateway quotas. |
| **504 Gateway Timeout** | Backend (Lambda) exceeded 29s timeout | All API Gateway requests have a hard 29-second timeout. Optimize backend performance. |
| **502 Bad Gateway** | Incorrect payload format | Ensure Lambda returns the expected JSON structure (statusCode, body, headers). |

---
**Next Step**: Learn how to accelerate content with [AWS CloudFront CDN Guide](aws-cloudfront-cdn.md)
