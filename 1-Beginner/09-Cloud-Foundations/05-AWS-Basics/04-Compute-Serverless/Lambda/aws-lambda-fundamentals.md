# AWS Lambda Fundamentals & Concepts

AWS Lambda is a serverless, event-driven compute service that lets you run code for virtually any type of application or backend service without provisioning or managing servers.

## 1. What is AWS Lambda?

Lambda allows you to run code in response to events from over 200 AWS services and SaaS applications. You only pay for the compute time you consume—there is no charge when your code is not running.

### Key Benefits
- **No Servers to Manage**: You just upload your code; Lambda handles the rest.
- **Continuous Scaling**: Scales automatically by running code in response to each event.
- **Sub-second Metering**: Charged per request and for the duration (rounded to the nearest 1ms).

## 2. Core Concepts

### Lambda Function
The script or program that runs in AWS Lambda. It includes your code, its dependencies, and configuration.

### Triggers
AWS services or applications that invoke your Lambda function.
- **Synchronous**: API Gateway, Cognito, Alexa.
- **Asynchronous**: S3, SNS, EventBridge.
- **Polling/Batching**: SQS, Kinesis, DynamoDB Streams.

### Event Object
A JSON-formatted document that contains data for the function to process. The structure varies depending on the trigger.

### Execution Context (Environment)
A temporary environment that initializes your code's dependencies and logic. Lambda reuses this environment for subsequent invocations to improve performance (Cold Start vs. Warm Start).

## 3. Supported Runtimes
Lambda supports multiple languages natively:
- **Node.js**: Extremely popular for web backends and microservices.
- **Python**: Preferred for data processing, automation, and AI/ML.
- **Java/Go/C#/Ruby**: Supported for enterprise applications.
- **Custom Runtimes**: Use the Lambda Runtime API to run any language (e.g., Rust, PHP).

## 4. Resource Allocation
- **Memory**: You choose the amount of memory (128 MB to 10 GB). 
- **CPU**: Lambda allocates CPU power linearly in proportion to the memory.
- **Ephemeral Storage**: `/tmp` directory (512 MB to 10 GB) for temporary files.

## 5. Security & Permissions
- **Execution Role**: An IAM role that grants the function permission to access other AWS services.
- **Resource-based Policy**: Grants other AWS services permission to invoke your function.

---
**Next Step**: Learn how to deploy and test your first function in the [Hands-on Lambda Guide](../../Intermediate-Level/14-Serverless-Lambda/aws-lambda-hands-on.md)
