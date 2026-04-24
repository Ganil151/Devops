# Advanced Lambda Patterns & Troubleshooting

Master production-grade Lambda architectures with VPC networking, concurrency control, and optimized performance.

## 1. Lambda Networking (VPC vs. Non-VPC)

By default, Lambda functions run in a secure, AWS-managed network with full internet access but no access to your private VPC resources (like RDS or internal ALBs).

### Connecting Lambda to your VPC
To access private resources, you must configure the function to connect to your VPC.
- **ENI (Elastic Network Interface)**: Lambda creates ENIs in your subnets.
- **Security Groups**: You must allow outbound traffic from Lambda and inbound traffic into your VPC resource.

```bash
# Update function to use VPC
aws lambda update-function-configuration \
    --function-name my-devops-function \
    --vpc-config SubnetIds=subnet-123,subnet-456,SecurityGroupIds=sg-789
```

## 2. Concurrency Management

Lambda scales automatically, but you must manage concurrency to protect downstream systems (like databases).

- **Reserved Concurrency**: Guarantees a minimum number of instances for a function and limits its maximum scale.
- **Provisioned Concurrency**: Keeps a specified number of execution environments "warm" to eliminate cold starts for latency-sensitive apps.

```bash
# Set reserved concurrency
aws lambda put-function-concurrency \
    --function-name my-devops-function \
    --reserved-concurrent-executions 50

# Set provisioned concurrency (for a specific version/alias)
aws lambda put-provisioned-concurrency-config \
    --function-name my-devops-function \
    --qualifier PROD_ALIAS \
    --provisioned-concurrent-executions 10
```

## 3. Lambda Destinations & Dead Letter Queues (DLQ)

Manage asynchronous failures gracefully.
- **DLQ**: Send failed events to an SQS queue or SNS topic for manual retry.
- **Destinations**: (Recommended) A more flexible way to route execution results (Success/Failure) to SQS, SNS, Lambda, or EventBridge.

## 4. Performance Optimization (Cold Starts)

Cold starts occur when Lambda initializes a new execution environment.
- **Language Choice**: Node.js/Python have faster cold starts than Java/C#.
- **Package Size**: Keep your deployment zip small.
- **Memory**: Increasing memory often reduces execution time, even if CPU demand is low.

## 5. Troubleshooting Guide

| Symptom | Probable Cause | Resolution |
| :--- | :--- | :--- |
| **Timeout Errors** | Function logic taking longer than configured timeout | Increase the timeout setting (max 15 mins). |
| **Out of Memory** | Data exceeds memory limit | Increase the memory allocation. |
| **VPC Connection Failure** | Incorrect Subnets/SGs or missing NAT Gateway | Verify SGs allow traffic; ensure subnets have a route to a NAT Gateway for internet access. |
| **Throttling (429)** | Exceeded account or reserved concurrency limits | Request a quota increase or check `ConcurrentExecutions` metric. |
| **Permission Denied** | Execution role missing specific permissions | Audit the IAM role's policy attached to the Lambda. |

---

## Lambda Best Practices Checklist
- [ ] Implement **Least Privilege** in the IAM Execution Role.
- [ ] Use **Environment Variables** for secrets or config (avoid hardcoding).
- [ ] Externalize dependencies into **Lambda Layers** for modularity.
- [ ] Monitor **Duration** and **Error Count** continuously in CloudWatch.
- [ ] Use **X-Ray** for tracing distributed microservices.
