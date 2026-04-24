# ❓ AWS CloudFormation - Interview Questions & Quiz

## 📋 Interview Questions (25+)

### 🔰 Beginner Level (1-10)

**Q1: What is AWS CloudFormation?**
**A:** AWS CloudFormation is an Infrastructure as Code (IaC) service that allows you to model and provision AWS resources using declarative templates in JSON or YAML format. It manages the lifecycle of infrastructure through stacks.

**Q2: What are the main components of a CloudFormation template?**
**A:** 
- **Resources** (required) - AWS resources to create
- **Parameters** - Input values
- **Outputs** - Values to export
- **Mappings** - Lookup tables
- **Conditions** - Conditional resource creation
- **Metadata** - Additional information

**Q3: What is a CloudFormation Stack?**
**A:** A stack is a collection of AWS resources managed as a single unit. All resources in a stack are created, updated, and deleted together based on the template.

**Q4: What's the difference between Ref and GetAtt?**
**A:** 
- **!Ref** returns the logical resource ID or parameter value
- **!GetAtt** retrieves specific attributes from resources (e.g., PublicIp, Arn)

**Q5: How do you pass parameters to a CloudFormation stack?**
**A:** Via AWS Console, CLI with `--parameters`, or parameter files:
```bash
aws cloudformation create-stack --parameters ParameterKey=Key,ParameterValue=Value
```

**Q6: What happens if stack creation fails?**
**A:** CloudFormation automatically rolls back, deleting all resources created during the failed attempt (unless `--on-failure DO_NOTHING` is specified).

**Q7: Can you update resources in an existing stack?**
**A:** Yes, using `update-stack`. Some updates require replacement, others can be updated in-place. Use Change Sets to preview changes.

**Q8: What is the purpose of Outputs in CloudFormation?**
**A:** Outputs display values after stack creation and can be exported for use by other stacks via `!ImportValue`.

**Q9: How do you delete a CloudFormation stack?**
**A:** Use `aws cloudformation delete-stack --stack-name <name>` or via Console. All resources are deleted unless DeletionPolicy is set.

**Q10: What are CloudFormation intrinsic functions?**
**A:** Built-in functions like !Ref, !GetAtt, !Sub, !Join, !FindInMap that provide dynamic values and logic in templates.

---

### 🚀 Intermediate Level (11-20)

**Q11: What are Change Sets and why use them?**
**A:** Change Sets preview changes before applying stack updates, showing which resources will be modified, replaced, or deleted. They prevent unintended infrastructure changes.

**Q12: Explain CloudFormation Drift Detection.**
**A:** Drift detection identifies when actual resource configuration differs from the template (e.g., manual changes). Use `detect-stack-drift` to find discrepancies.

**Q13: What are Nested Stacks?**
**A:** Stacks within stacks, allowing modular template design. Parent stacks reference child stack templates. Useful for reusable components.

**Q14: How do you create custom resources?**
**A:** Using AWS Lambda-backed custom resources:
```yaml
MyCustomResource:
  Type: Custom::MyResource
  Properties:
    ServiceToken: !GetAtt MyLambdaFunction.Arn
```

**Q15: What is a Stack Policy?**
**A:** JSON document that defines update permissions for stack resources, preventing accidental modifications or deletions of critical resources.

**Q16: Explain DeletionPolicy attribute.**
**A:** Controls what happens to resources when stack is deleted:
- **Delete** (default) - Delete resource
- **Retain** - Keep resource
- **Snapshot** - Create snapshot before deletion (RDS, EBS)

**Q17: What are CloudFormation Macros?**
**A:** Template processors that perform custom processing before deployment. Enable code generation, validation, or transformation.

**Q18: How do you handle secrets in CloudFormation?**
**A:** Use AWS Secrets Manager or Systems Manager Parameter Store with dynamic references:
```yaml
Password: '{{resolve:secretsmanager:MySecret:SecretString:password}}'
```

**Q19: What is the difference between DependsOn and implicit dependencies?**
**A:** 
- **Implicit**: CloudFormation detects dependencies via !Ref or !GetAtt
- **DependsOn**: Explicitly defines creation order when implicit detection fails

**Q20: How do you implement conditional resource creation?**
**A:** Using Conditions section:
```yaml
Conditions:
  CreateProdResources: !Equals [!Ref Environment, prod]
Resources:
  ProdBucket:
    Type: AWS::S3::Bucket
    Condition: CreateProdResources
```

---

### 🏆 Advanced Level (21-30)

**Q21: What are StackSets and when would you use them?**
**A:** StackSets deploy stacks across multiple AWS accounts and regions from a single template. Used for multi-account governance, organization-wide compliance, and centralized infrastructure management.

**Q22: Explain CloudFormation Registry and third-party resources.**
**A:** Registry allows registration of custom resource types and third-party extensions. Enables using non-AWS resources in templates (e.g., Datadog monitors, GitHub repos).

**Q23: How do you implement blue-green deployments with CloudFormation?**
**A:** Use separate stacks for blue/green environments, or leverage CodeDeploy integration with:
- Traffic shifting using Route53 weighted routing
- ALB with multiple target groups
- CloudFormation StackSets for parallel environments

**Q24: What are the limitations of CloudFormation?**
**A:** 
- 200 resources per template (use nested stacks)
- 60 parameters maximum
- Template size: 1 MB (S3), 51,200 bytes (direct upload)
- 200 stacks per account (can be increased)
- AWS-only (no multi-cloud)

**Q25: How do you implement CI/CD for CloudFormation?**
**A:** Using:
- AWS CodePipeline with CloudFormation action
- GitHub Actions with AWS CLI
- Jenkins with CloudFormation plugin
- Change Sets for validation stage
- Automated testing with TaskCat or cfn-lint

**Q26: Explain CloudFormation drift remediation strategies.**
**A:** 
1. Re-apply template to restore desired state
2. Update template to match actual state (import changes)
3. Use Stack import to bring external resources under management
4. Implement preventive controls (SCPs, IAM policies)

**Q27: How do you manage cross-stack references?**
**A:** Using Exports and ImportValue:
```yaml
# Stack A outputs
Outputs:
  VpcId:
    Export:
      Name: MyVPC
# Stack B imports
VpcId: !ImportValue MyVPC
```

**Q28: What is the Transform section used for?**
**A:** Declares macros or serverless transforms:
- `AWS::Serverless-2016-10-31` for SAM templates
- `AWS::Include` for template snippets
- Custom macros for template processing

**Q29: How do you optimize CloudFormation performance?**
**A:** 
- Minimize resource count per stack
- Use parallel resource creation (avoid unnecessary DependsOn)
- Implement nested stacks for modularity
- Cache template snippets with S3
- Use StackSets for multi-region (parallel deployment)

**Q30: Explain CloudFormation service role and its use cases.**
**A:** Service role is an IAM role CloudFormation assumes to create/update resources. Useful for:
- Least privilege (users don't need resource creation permissions)
- Consistent permissions across environments
- Audit trail (role-based actions)

---

## 📝 Quiz Questions (20+)

### Multiple Choice Questions

**Q1:** What is the maximum number of resources allowed in a CloudFormation template?
- A) 50
- B) 100
- C) 200 ✅
- D) Unlimited

**Q2:** Which section is REQUIRED in every CloudFormation template?
- A) Parameters
- B) Resources ✅
- C) Outputs
- D) Mappings

**Q3:** What does the !Ref function return when used with an AWS::S3::Bucket resource?
- A) Bucket ARN
- B) Bucket Name ✅
- C) Bucket Domain
- D) Bucket Region

**Q4:** Which deployment mode completely replaces all resources?
- A) Update
- B) Change Set
- C) Complete Replacement ✅
- D) Incremental Update

**Q5:** What is the default behavior when a stack creation fails?
- A) Leave resources as-is
- B) Rollback and delete all resources ✅
- C) Pause for manual intervention
- D) Retry automatically

**Q6:** Which intrinsic function performs string substitution?
- A) !Join
- B) !Sub ✅
- C) !GetAtt
- D) !FindInMap

**Q7:** What is a Change Set used for?
- A) Version control
- B) Preview changes before applying ✅
- C) Change template format
- D) Modify parameters

**Q8:** How are stack outputs shared across stacks?
- A) S3 bucket
- B) Parameter Store
- C) Export/ImportValue ✅
- D) Direct reference

**Q9:** Which CLI command creates a new stack?
- A) aws cloudformation deploy-stack
- B) aws cloudformation create-stack ✅
- C) aws cloudformation launch-stack
- D) aws cloudformation new-stack

**Q10:** What language are CloudFormation templates written in?
- A) JSON or YAML ✅
- B) Python
- C) HCL
- D) XML

**Q11:** What does DeletionPolicy: Retain do?
- A) Prevents stack deletion
- B) Keeps resource when stack is deleted ✅
- C) Creates a backup
- D) Retains stack history

**Q12:** Which is NOT a valid CloudFormation intrinsic function?
- A) !Ref
- B) !GetAtt
- C) !Loop ✅
- D) !Sub

**Q13:** What is drift detection used for?
- A) Monitoring costs
- B) Finding manual resource changes ✅
- C) Template validation
- D) Performance optimization

**Q14:** How many parameters can a template have?
- A) 20
- B) 60 ✅
- C) 100
- D) 200

**Q15:** What is a StackSet?
- A) Collection of stack templates
- B) Multi-account/region deployment tool ✅
- C) Stack backup
- D) Template repository

**Q16:** Which attribute explicitly defines resource creation order?
- A) OrderBy
- B) DependsOn ✅
- C) CreationOrder
- D) Sequence

**Q17:** What does !GetAtt MyEC2.PublicIp return?
- A) Instance ID
- B) Public IP address ✅
- C) Private IP
- D) DNS name

**Q18:** What is the maximum template size for direct upload?
- A) 10 KB
- B) 51,200 bytes ✅
- C) 1 MB
- D) 10 MB

**Q19:** Which resource type creates a custom resource?
- A) AWS::Custom::Resource
- B) Custom::ResourceType ✅
- C) AWS::Lambda::CustomResource
- D) AWS::CloudFormation::CustomResource

**Q20:** What handles template processing for SAM?
- A) Macro
- B) Transform ✅
- C) Processor
- D) Converter

**Q21:** What is a Stack Policy?
- A) IAM policy for stack access
- B) Document preventing resource updates ✅
- C) Security group rules
- D) Encryption policy

**Q22:** Which command validates template syntax?
- A) aws cloudformation validate-template ✅
- B) aws cloudformation check-template
- C) aws cloudformation test-template
- D) aws cloudformation verify-template

---

## 🎯 Scenario-Based Questions

**Scenario 1:** Your stack creation fails midway. What information would you check?
**Answer:** 
1. Stack Events for error messages
2. Resource status (CREATE_FAILED)
3. CloudWatch Logs for Lambda-backed resources
4. IAM permissions
5. Service quotas

**Scenario 2:** You need to update production database without deletion. Which attribute do you set?
**Answer:** Set `DeletionPolicy: Retain` and `UpdateReplacePolicy: Retain` on the database resource.

**Scenario 3:** How would you deploy the same infrastructure across 10 AWS accounts?
**Answer:** Use AWS CloudFormation StackSets with administrator account to deploy to target accounts.

**Scenario 4:** A resource was manually modified. How do you detect and fix it?
**Answer:** 
1. Run `aws cloudformation detect-stack-drift`
2. Review drift results
3. Either update template to match reality or re-deploy template to restore

**Scenario 5:** You need to reference a VPC created in another stack. How?
**Answer:** 
1. In VPC stack, export the VPC ID:
```yaml
Outputs:
  VpcId:
    Export:
      Name: MyVPCId
```
2. In dependent stack, import:
```yaml
VpcId: !ImportValue MyVPCId
```

---

## 📊 Answer Key Summary

**Interview Questions:** 30 comprehensive questions covering beginner to advanced topics

**Quiz Questions:** 22 multiple-choice questions with correct answers marked (✅)

**Scenario Questions:** 5 real-world scenarios with detailed solutions

