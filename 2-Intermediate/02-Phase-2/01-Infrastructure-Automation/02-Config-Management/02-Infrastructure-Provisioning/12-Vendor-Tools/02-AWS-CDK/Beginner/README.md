# 🔰 AWS CDK Beginner Level

## 📋 Learning Objectives
- ✅ Install and bootstrap a CDK environment
- ✅ Create a new CDK project
- ✅ Understand the difference between Apps, Stacks, and Constructs
- ✅ Deploy your first stack (S3 bucket or VPC)

---

## 🚀 Getting Started

### 1. Installation
The CDK CLI is installed via npm:
```bash
npm install -g aws-cdk
cdk --version
```

### 2. Bootstrapping
Before deploying, you must bootstrap your AWS environment (account/region). This creates resources for the CDK to manage assets.
```bash
cdk bootstrap aws://ACCOUNT-NUMBER/REGION
```

### 3. Project Initialization
Initialize a project in your preferred language:
```bash
mkdir hello-cdk
cd hello-cdk
cdk init app --language typescript
```

---

## 🏗️ Core Concepts

### Apps and Stacks
- **App**: The root of your CDK application. It can contain one or more stacks.
- **Stack**: The unit of deployment. Each stack maps 1:1 to a CloudFormation stack.

### Constructs (The Building Blocks)
Constructs are represented as classes in your code.
- **L1 (CfnResources)**: Direct mappings to CloudFormation resources. No defaults.
- **L2**: Curated by AWS. Include sensible defaults, boilerplate logic, and helper methods.
- **L3 (Patterns)**: High-level constructs designed to complete common tasks (e.g., `ApplicationLoadBalancedFargateService`).

---

## 💻 Example: Creating an S3 Bucket

```typescript
import * as cdk from 'aws-cdk-lib';
import * as s3 from 'aws-cdk-lib/aws-s3';

export class MyFirstStack extends cdk.Stack {
  constructor(scope: cdk.App, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    new s3.Bucket(this, 'MyFirstBucket', {
      versioned: true,
      removalPolicy: cdk.RemovalPolicy.DESTROY, // For dev only!
      autoDeleteObjects: true,
    });
  }
}
```

---

## 🛠️ Essential Commands
| Command | Purpose |
|---------|---------|
| `cdk init` | Start a new project |
| `cdk synth` | Generate the CloudFormation template |
| `cdk deploy` | Deploy the stack to AWS |
| `cdk diff` | Compare local code with deployed stack |
| `cdk destroy` | Delete the stack |
| `cdk list` | Show stacks in the app |
