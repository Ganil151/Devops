# Observability & Governance - Advanced

Move beyond basic logs and metrics to deep distributed tracing and automated compliance at scale.

---

## 1. Distributed Tracing with X-Ray

In a world of serverless and microservices, a single request can touch dozens of components. Traditional logging is insufficient to identify where failures or latency originate.

**AWS X-Ray** provides a visual map of requests, allowing you to "follow the thread" across:
- API Gateways
- Lambda Functions
- Managed Services (DynamoDB, SQS)
- External APIs

---

## 2. Core Guides

### 🔍 [AWS X-Ray Observability Guide](aws-xray-observability.md)
Master distributed tracing, Service Maps, and CloudWatch ServiceLens integration.

---

## 3. Governance at Scale

Use **AWS Config** to ensure your infrastructure stays compliant with enterprise standards automatically.
- **Detect Drift**: Know when someone manually changes a production setting.
- **Auto-Remediate**: Automatically fix non-compliant resources (e.g., closing an open S3 bucket).

---

## 4. Best Practices
- **Sampling Rules**: Optimize costs by only tracing a percentage of successful requests.
- **Instrumentation**: Use the AWS X-Ray SDK to wrap your database and HTTP client calls.
- **Dashboards**: Build unified CloudWatch ServiceLens dashboards for your entire application stack.

---
**Next Step**: Learn how these patterns apply across multiple clouds in the [Multi-Cloud Architecture Module](../01-multi-cloud-architecture/readme.md)
