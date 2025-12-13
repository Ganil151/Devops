# CI/CD for Serverless Applications

## Overview

Continuous Integration and Continuous Deployment (CI/CD) for serverless applications requires specialized approaches due to the event-driven, stateless nature of serverless functions and the need for rapid deployment cycles.

## Key Principles

### 1. Function-Level Deployment
- Deploy individual functions independently
- Version control for each function
- Rollback capabilities per function
- Blue-green deployments for functions

### 2. Infrastructure as Code (IaC)
- Define serverless resources in code
- Version control infrastructure changes
- Automated provisioning and updates
- Environment consistency

## CI/CD Pipeline Architecture

```yaml
# GitHub Actions Example
name: Serverless CI/CD
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install dependencies
        run: npm ci
      - name: Run tests
        run: npm test
      - name: Run security scan
        run: npm audit

  deploy-dev:
    needs: test
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Development
        run: |
          npm install -g serverless
          serverless deploy --stage dev
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

  deploy-prod:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Production
        run: |
          npm install -g serverless
          serverless deploy --stage prod
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## AWS CodePipeline for Serverless

```yaml
# buildspec.yml
version: 0.2
phases:
  install:
    runtime-versions:
      nodejs: 18
    commands:
      - npm install -g serverless
      - npm install
  pre_build:
    commands:
      - echo Running tests
      - npm test
      - echo Running security audit
      - npm audit --audit-level moderate
  build:
    commands:
      - echo Build started on `date`
      - serverless package --stage $STAGE
  post_build:
    commands:
      - echo Build completed on `date`
      - serverless deploy --stage $STAGE
artifacts:
  files:
    - '**/*'
```

## Azure DevOps Pipeline

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
      - develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  - group: serverless-variables

stages:
- stage: Test
  jobs:
  - job: RunTests
    steps:
    - task: NodeTool@0
      inputs:
        versionSpec: '18.x'
    - script: |
        npm ci
        npm test
        npm run lint
      displayName: 'Install and Test'

- stage: DeployDev
  condition: eq(variables['Build.SourceBranch'], 'refs/heads/develop')
  jobs:
  - deployment: DeployToDev
    environment: 'development'
    strategy:
      runOnce:
        deploy:
          steps:
          - script: |
              npm install -g @azure/functions-core-tools
              func azure functionapp publish $(DEV_FUNCTION_APP_NAME)
            displayName: 'Deploy to Development'

- stage: DeployProd
  condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')
  jobs:
  - deployment: DeployToProd
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - script: |
              npm install -g @azure/functions-core-tools
              func azure functionapp publish $(PROD_FUNCTION_APP_NAME)
            displayName: 'Deploy to Production'
```

## Testing Strategies

### Unit Testing
```javascript
// Example Jest test for AWS Lambda
const { handler } = require('../src/handler');

describe('Lambda Handler', () => {
  test('should return success response', async () => {
    const event = {
      body: JSON.stringify({ name: 'test' })
    };
    
    const result = await handler(event);
    
    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body)).toHaveProperty('message');
  });
});
```

### Integration Testing
```javascript
// Integration test example
const AWS = require('aws-sdk');
const lambda = new AWS.Lambda({ region: 'us-east-1' });

describe('Integration Tests', () => {
  test('should invoke function successfully', async () => {
    const params = {
      FunctionName: 'my-serverless-function',
      Payload: JSON.stringify({ test: 'data' })
    };
    
    const result = await lambda.invoke(params).promise();
    expect(result.StatusCode).toBe(200);
  });
});
```

## Deployment Strategies

### Canary Deployments
```yaml
# serverless.yml with canary deployment
service: my-serverless-app

provider:
  name: aws
  runtime: nodejs18.x
  deploymentBucket:
    name: my-deployment-bucket

functions:
  myFunction:
    handler: handler.main
    deploymentSettings:
      type: Canary10Percent5Minutes
      alias: Live
      preTrafficHook: preHook
      postTrafficHook: postHook
      alarms:
        - AliasErrorMetricGreaterThanZeroAlarm
        - LatestVersionErrorMetricGreaterThanZeroAlarm

plugins:
  - serverless-plugin-canary-deployments
```

### Blue-Green Deployments
```bash
#!/bin/bash
# Blue-Green deployment script

FUNCTION_NAME="my-function"
NEW_VERSION=$(aws lambda publish-version --function-name $FUNCTION_NAME --query 'Version' --output text)

# Update alias to point to new version
aws lambda update-alias \
  --function-name $FUNCTION_NAME \
  --name LIVE \
  --function-version $NEW_VERSION

# Monitor for errors
sleep 300

# Check CloudWatch metrics
ERROR_COUNT=$(aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Errors \
  --dimensions Name=FunctionName,Value=$FUNCTION_NAME \
  --start-time $(date -u -d '5 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum \
  --query 'Datapoints[0].Sum' \
  --output text)

if [ "$ERROR_COUNT" != "None" ] && [ "$ERROR_COUNT" -gt 0 ]; then
  echo "Errors detected, rolling back"
  # Rollback logic here
fi
```

## Environment Management

### Environment Configuration
```yaml
# serverless.yml
custom:
  stages:
    dev:
      memorySize: 128
      timeout: 30
      logLevel: DEBUG
    prod:
      memorySize: 256
      timeout: 10
      logLevel: ERROR

provider:
  environment:
    LOG_LEVEL: ${self:custom.stages.${opt:stage}.logLevel}
    
functions:
  myFunction:
    memorySize: ${self:custom.stages.${opt:stage}.memorySize}
    timeout: ${self:custom.stages.${opt:stage}.timeout}
```

## Security in CI/CD

### Secret Management
```yaml
# GitHub Actions with secrets
- name: Deploy with secrets
  run: |
    serverless deploy --stage prod
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

### IAM Roles for Deployment
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:*",
        "apigateway:*",
        "cloudformation:*",
        "s3:*",
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
```

## Monitoring and Rollback

### Automated Rollback
```javascript
// CloudWatch alarm for automatic rollback
const AWS = require('aws-sdk');
const cloudwatch = new AWS.CloudWatch();

const createAlarm = async () => {
  const params = {
    AlarmName: 'Lambda-Error-Rate-High',
    ComparisonOperator: 'GreaterThanThreshold',
    EvaluationPeriods: 2,
    MetricName: 'Errors',
    Namespace: 'AWS/Lambda',
    Period: 300,
    Statistic: 'Sum',
    Threshold: 5.0,
    ActionsEnabled: true,
    AlarmActions: [
      'arn:aws:sns:us-east-1:123456789012:rollback-topic'
    ],
    AlarmDescription: 'Alarm when lambda errors exceed threshold',
    Dimensions: [
      {
        Name: 'FunctionName',
        Value: 'my-function'
      }
    ]
  };
  
  return await cloudwatch.putMetricAlarm(params).promise();
};
```

## Best Practices

### 1. Pipeline Design
- Separate pipelines for different environments
- Automated testing at every stage
- Security scanning integration
- Performance testing inclusion

### 2. Deployment Practices
- Use infrastructure as code
- Implement proper versioning
- Enable rollback mechanisms
- Monitor deployment health

### 3. Security Practices
- Scan dependencies for vulnerabilities
- Use least privilege IAM roles
- Encrypt sensitive data
- Implement proper secret management

### 4. Performance Optimization
- Optimize function cold starts
- Monitor execution duration
- Implement proper caching
- Use appropriate memory allocation