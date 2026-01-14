# AWS Lambda - Advanced

Master enterprise-grade serverless architectures and performance tuning.

## Guides

### [Advanced Lambda Patterns & Troubleshooting](aws-lambda-advanced-patterns.md)
Deep dive into:
- VPC Networking for Lambda.
- Concurrency and Scaling controls.
- Asynchronous failure handling (Destinations & DLQs).
- Cold start mitigation and performance optimization.
- Production troubleshooting guide.

## Best Practices Checklist
- [ ] Use **Provisioned Concurrency** for critical, latency-sensitive paths.
- [ ] Implement **IAM Execution Roles** with the principle of least privilege.
- [ ] Enable **X-Ray Tracing** to identify bottlenecks in distributed systems.
- [ ] Monitor **Concurrency** metrics to avoid silent failures at scale.
