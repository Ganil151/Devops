# 🚀 AWS CDK Intermediate Level

## 📋 Learning Objectives
- ✅ Create and share **Custom Constructs** (L3)
- ✅ Manage **Context and Environment** specific configurations
- ✅ Handle **Assets** (Code, Docker images)
- ✅ Implement **Testing** for infrastructure code

---

## 🏗️ Advanced Construct Design

### Creating Custom Constructs
Custom constructs allow you to bundle multiple resources into a single, reusable component.

```typescript
import { Construct } from 'constructs';
import * as s3 from 'aws-cdk-lib/aws-s3';

export class SecureBucket extends Construct {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    new s3.Bucket(this, 'MyBucket', {
      encryption: s3.BucketEncryption.S3_MANAGED,
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
      enforceSSL: true,
    });
  }
}
```

---

## ⚙️ Configuration Management

### Context Variables
Context allows you to pass variables to your app without hardcoding.
- **cdk.json**: Permanent context.
- **-c flag**: CLI-driven context (e.g., `cdk deploy -c env=prod`).

---

## 🧪 Testing Your Infrastructure

### 1. Fine-grained Assertions
Verify that specific resources are created with specific properties.
```typescript
import { Template } from 'aws-cdk-lib/assertions';

test('S3 Bucket Created', () => {
  const app = new cdk.App();
  const stack = new MyStack(app, 'TestStack');
  const template = Template.fromStack(stack);

  template.hasResourceProperties('AWS::S3::Bucket', {
    VersioningConfiguration: { Status: 'Enabled' }
  });
});
```

### 2. Snapshot Testing
Capture the synthesized template and ensure no unexpected changes occur in future runs.

---

## 📦 Handling Assets
CDK handles the process of zipping your Lambda code or building your Docker images, uploading them to S3 or ECR, and referencing them in your CloudFormation template automatically.
