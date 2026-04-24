# 🔰 AWS SAM Beginner Level

## 📋 Learning Objectives
- ✅ Install SAM CLI
- ✅ Understand the basic SAM template anatomy
- ✅ Define a simple Lambda function and API Gateway
- ✅ Deploy your first serverless application

---

## 🚀 Getting Started

### 1. Installation
The SAM CLI requires Docker for local testing.
```bash
# Verify installation
sam --version
```

### 2. Initialization
Create a new project from a template:
```bash
sam init
```
Choose a runtime (e.g., Python 3.9) and a template (e.g., Hello World).

---

## 📝 Template Anatomy
SAM templates start with the `Transform` line.

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Description: My first SAM app

Resources:
  HelloWorldFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: hello_world/
      Handler: app.lambda_handler
      Runtime: python3.9
      Events:
        HelloWorld:
          Type: Api
          Properties:
            Path: /hello
            Method: get
```

### Key Resource Types
- `AWS::Serverless::Function`: A Lambda function.
- `AWS::Serverless::Api`: An API Gateway.
- `AWS::Serverless::SimpleTable`: A DynamoDB table with a single primary key.

---

## 🛠️ Essential Commands
| Command | Purpose |
|---------|---------|
| `sam init` | Create a new project |
| `sam build` | Resolve dependencies and package the app |
| `sam deploy --guided` | Deploy the app to AWS (with prompt-based config) |
| `sam local invoke` | Run a Lambda function locally |
| `sam logs` | Fetch logs for your function |
