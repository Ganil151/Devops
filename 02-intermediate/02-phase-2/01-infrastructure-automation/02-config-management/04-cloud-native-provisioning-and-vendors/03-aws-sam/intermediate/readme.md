# 🚀 AWS SAM Intermediate Level

## 📋 Learning Objectives
- ✅ Debug Lambda functions locally
- ✅ Use Globals to simplify templates
- ✅ Integrate with event sources (S3, DynamoDB)
- ✅ Manage application layers

---

## 🛠️ Local Testing and Debugging

### Invoke with Payload
Test functions with specific event triggers.
```bash
sam local invoke HelloWorldFunction -e events/event.json
```

### Start API Locally
Run a local version of API Gateway.
```bash
sam local start-api
# Access via http://localhost:3000/hello
```

---

## 🌎 Global Configurations
Use the `Globals` section to define common properties for all resources (e.g., Timeout, MemorySize).

```yaml
Globals:
  Function:
    Timeout: 5
    MemorySize: 128
    Runtime: python3.9
```

---

## ⛓️ Event Source Mappings
SAM simplifies complex triggers.

### S3 Trigger
```yaml
Events:
  FileUpload:
    Type: S3
    Properties:
      Bucket: !Ref SourceBucket
      Events: s3:ObjectCreated:*
```

### DynamoDB Stream
```yaml
Events:
  DataChange:
    Type: DynamoDB
    Properties:
      Stream: !GetAtt MyTable.StreamArn
      StartingPosition: TRIM_HORIZON
```

---

## 📦 Lambda Layers
Shared libraries used by multiple functions.
```yaml
MyLayer:
  Type: AWS::Serverless::LayerVersion
  Properties:
    ContentUri: common_libs/
    CompatibleRuntimes:
      - python3.9
```
Then reference it in the function:
```yaml
Layers:
  - !Ref MyLayer
```
