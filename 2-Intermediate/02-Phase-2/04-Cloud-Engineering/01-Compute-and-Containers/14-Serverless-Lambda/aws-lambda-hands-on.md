# Hands-on Lambda Guide: Console & CLI

This guide provides practical instructions for creating your first Lambda function, configuring its execution role, and invoking it using the AWS CLI.

## 1. Creating a Lambda Function

### Using the Management Console
1. Navigate to the **Lambda Console**.
2. Click **Create function**.
3. **Author from scratch**.
4. **Name**: `hello-world-devops`.
5. **Runtime**: Select **Python 3.12** or **Node.js 20.x**.
6. **Execution Role**: Choose **Create a new role with basic Lambda permissions**.
7. Click **Create function**.
8. In the **Code** tab, edit the handler and click **Deploy**.

### Using the AWS CLI

#### Step 1: Create the Execution Role
```bash
# Create the trust policy
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "lambda.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create the IAM Role
ROLE_ARN=$(aws iam create-role \
    --role-name lambda-ex-role \
    --assume-role-policy-document file://trust-policy.json \
    --query 'Role.Arn' --output text)

# Attach Basic Execution Policy
aws iam attach-role-policy \
    --role-name lambda-ex-role \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

#### Step 2: Prepare the Function Code
```python
# lambda_function.py
import json

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event))
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from DevOps Lambda!')
    }
```
Compress the file:
```bash
zip function.zip lambda_function.py
```

#### Step 3: Create the Lambda Function
```bash
aws lambda create-function \
    --function-name my-devops-function \
    --runtime python3.12 \
    --role $ROLE_ARN \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://function.zip
```

## 2. Invoking the Function

### Synchronous Invocation (CLI)
```bash
aws lambda invoke \
    --function-name my-devops-function \
    --payload '{"key": "value"}' \
    response.json

cat response.json
```

## 3. Configuring Environment Variables

```bash
aws lambda update-function-configuration \
    --function-name my-devops-function \
    --environment "Variables={DB_HOST=db.example.com,DB_USER=admin}"
```

## 4. Monitoring Logs

Lambda automatically sends logs to CloudWatch.
```bash
# Get the log group name
LOG_GROUP="/aws/lambda/my-devops-function"

# Tail logs (requires AWS CLI v2)
aws logs tail $LOG_GROUP --follow
```

## 5. Cleaning Up
```bash
# Delete the function
aws lambda delete-function --function-name my-devops-function

# Delete the IAM Role
aws iam detach-role-policy --role-name lambda-ex-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam delete-role --role-name lambda-ex-role
```

---
**Next Step**: Explore [Advanced Lambda Patterns & Troubleshooting](../../../../../3-Advanced/02-Phase-2/11-Enterprise-Cloud/15-Serverless-Lambda/aws-lambda-advanced-patterns.md)
