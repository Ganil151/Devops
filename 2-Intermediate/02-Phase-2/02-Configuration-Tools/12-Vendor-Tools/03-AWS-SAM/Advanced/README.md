# 🏆 AWS SAM Advanced Level

## 📋 Learning Objectives
- ✅ Safe deployments with **Canary and Linear Traffic Shifting**
- ✅ Implementing **SAM Pipelines** for enterprise CI/CD
- ✅ Managing **Nested Applications**
- ✅ Integrating with **AWS Step Functions**

---

## 🛡️ Safe Deployments
SAM integrates with **AWS CodeDeploy** to shift traffic gradually during updates.

```yaml
DeploymentPreference:
  Type: Canary10Percent5Minutes # Shifts 10% traffic for 5 mins, then shifts the rest
  Alarms:
    - !Ref MyErrorAlarm # If this triggers, CodeDeploy rolls back automatically
```

### Types of Shifting
- **Canary**: Shift a percentage, wait, shift the rest.
- **Linear**: Shift X% every Y minutes until 100%.

---

## 🚀 SAM Pipelines
A feature of the SAM CLI to generate CI/CD pipeline configurations for GitHub Actions, GitLab CI, AWS CodePipeline, etc.
```bash
sam pipeline init --bootstrap
```

---

## 🏗️ Nested Applications
Break down large applications into smaller, manageable templates using `AWS::Serverless::Application`.

```yaml
Resources:
  UserManagement:
    Type: AWS::Serverless::Application
    Properties:
      Location: user_app/template.yaml
      Parameters:
        DBName: !Ref MainDB
```

---

## ⛓️ Orchestration: Step Functions
SAM simplifies the definition of State Machines.
```yaml
Resources:
  MyWorkflow:
    Type: AWS::Serverless::StateMachine
    Properties:
      DefinitionUri: statemachine/workflow.asl.json
      Role: !GetAtt MyRole.Arn
      Events:
        Timer:
          Type: Schedule
          Properties:
            Schedule: rate(1 hour)
```
