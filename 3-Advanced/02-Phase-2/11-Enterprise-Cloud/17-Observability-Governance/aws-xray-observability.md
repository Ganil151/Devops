# AWS X-Ray Observability Guide

AWS X-Ray helps developers analyze and debug distributed applications, such as those built using a microservices architecture. With X-Ray, you can understand how your application and its underlying services are performing to identify and troubleshoot the root cause of performance issues and errors.

## 1. What is Distributed Tracing?

In a microservices environment, a single user request can pass through dozens of different services (API Gateway -> Lambda -> SQS -> DynamoDB). If a request is slow or fails, it's difficult to know which service is responsible.

X-Ray provides a end-to-end view of requests as they travel through your application, visualizing the connections between services in a **Service Map**.

### Benefits
- **Identify Bottlenecks**: See exactly which service is adding latency.
- **Troubleshoot Errors**: Pinpoint the specific microservice where an exception occurred.
- **Service Dependency Analysis**: View the relationships between all services in your architecture.

## 2. Core Concepts

- **Segments**: Data about the work performed by your application (e.g., total request time).
- **Subsegments**: Finer-grained data about calls made to other AWS services (e.g., DynamoDB query time).
- **Traces**: A collection of segments and subsegments that represent a single request.
- **Sampling Rules**: Define which requests should be traced to control costs and data volume.
- **Service Map**: A visual representation of the path requests take through your application.

## 3. Hands-on: Enabling X-Ray (CLI)

### For AWS Lambda
```bash
# Enable active tracing
aws lambda update-function-configuration \
    --function-name my-devops-function \
    --tracing-config Mode=Active
```

### Creating a Sampling Rule
```bash
aws xray create-sampling-rule \
    --sampling-rule '{
        "rule_name": "ProductionSampling",
        "priority": 1(Highest),
        "fixed_rate": 0.05,
        "reservoir_size": 1,
        "service_name": "*",
        "service_type": "*",
        "host": "*",
        "method": "*",
        "url_path": "*",
        "version": 1
    }'
```

## 4. X-Ray Insights & Analytics

X-Ray includes advanced features for automated anomaly detection.

- **Insights**: Automatically identifies anomalies in your service map, such as a sudden increase in error rates from a specific microservice.
- **Analytics**: Interactively explore your trace data to identify patterns (e.g., "Show me all slow requests for users in Europe").

## 5. Integrating with CloudWatch (ServiceLens)

**CloudWatch ServiceLens** integrates X-Ray traces with CloudWatch metrics and logs in a single view.
- Click on a node in the Service Map to see its corresponding CPU/RAM metrics and application logs.
- This "Unified Observability" is the gold standard for production operations.

## 6. Troubleshooting Guide

| Symptom | Probable Cause | Resolution |
| :--- | :--- | :--- |
| **No Traces Appearing** | X-Ray daemon not running (EC2/ECS) or tracing not active (Lambda) | Ensure the X-Ray daemon is installed and running; verify IAM permissions (`xray:PutTraceSegments`). |
| **Service Map is Incomplete** | Code not instrumented for specific SDK calls | Ensure you are using the X-Ray SDK (e.g., `aws_xray_sdk` in Python) to wrap AWS client calls. |
| **High Latency in Service Map** | Downstream service timeout or retry storm | Investigate the longest subsegment; check if circular dependencies exist. |
| **Segment size exceeded** | Large custom data in subsegments | Limit the amount of metadata added to subsegments or use X-Ray annotations for searching. |

---
**Next Step**: Complete the governance module with [AWS Config & Governance Guide](../../Intermediate-Level/16-Governance-Compliance/aws-config-governance.md)
