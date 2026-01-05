# ❓ AWS SAM Interview & Quiz Questions

## 📋 Interview Questions

**Q1: What is the relationship between SAM and CloudFormation?**
**A:** SAM is an extension of CloudFormation. SAM templates include the `Transform: AWS::Serverless-2016-10-31` line, which instructs CloudFormation to expand the shorthand SAM syntax into standard CloudFormation resources during deployment.

**Q2: How do you perform Canary deployments with SAM?**
**A:** By using the `DeploymentPreference` property in the function resource. You specify the type (e.g., `Canary10Percent5Minutes`) and CloudWatch Alarms for rollback.

**Q3: What are the benefits of 'sam local start-api'?**
**A:** It allows developers to run and test their API endpoints locally on their machine, mimicking the API Gateway behavior, which speeds up development and reduces costs.

**Q4: Explain the purpose of the 'sam build' command.**
**A:** It prepares the application for deployment by gathering dependencies (like requirements.txt or package.json), copying code to a build directory, and resolving template references.

**Q5: What is a Lambda Layer and how does SAM support it?**
**A:** A layer is a distribution mechanism for shared code/libraries. SAM supports layers through the `AWS::Serverless::LayerVersion` resource type.

---

## 📝 Quiz Section (20+ Questions)

1. **Which line is mandatory to make a template a SAM template?**
   - A) AWSTemplateFormatVersion: '2010-09-09'
   - B) Transform: AWS::Serverless-2016-10-31 ✅
   - C) Scope: Serverless
   - D) Type: AWS::SAM

2. **Which command is used to run a Lambda function once locally?**
   - A) sam run
   - B) sam start-lambda
   - C) sam local invoke ✅
   - D) sam build

3. **What is 'AWS::Serverless::SimpleTable'?**
   - A) An S3 Bucket
   - B) A single-primary-key DynamoDB table ✅
   - C) A simple CSV file
   - D) A relational database

4. **Which command starts a guided deployment?**
   - A) sam deploy --guided ✅
   - B) sam start
   - C) sam setup
   - D) sam publish

5. **In the 'Globals' section, properties apply to:**
   - A) Only Lambda functions
   - B) All resources defined in the template ✅
   - C) Only API Gateways
   - D) Resources in other stacks

6. **Traffic shifting in SAM is managed by which service?**
   - A) AWS CloudWatch
   - B) AWS CloudFront
   - C) AWS CodeDeploy ✅
   - D) AWS Lambda

7. **The 'sam build' command puts build artifacts in which directory?**
   - A) /bin
   - B) .aws-sam ✅
   - C) /dist
   - D) /build

8. **Which event type is used for a standard REST API?**
   - A) HttpApi
   - B) Api ✅
   - C) RestFunction
   - D) Gateway

9. **What does 'sam local start-lambda' do?**
   - A) Starts a local endpoint that emulates the Lambda service ✅
   - B) Deploys the function to AWS
   - C) Starts an API Gateway
   - D) Checks for updates

10. **Can you use standard CloudFormation resources in a SAM template?**
    - A) No
    - B) Yes ✅
    - C) Only S3 buckets
    - D) Only if they are in the Globals section

11. **What is 'sam sync' used for?**
    - A) Downloading code from AWS
    - B) Quickly updating Lambda code and configurations in real-time during development ✅
    - C) Formatting the YAML file
    - D) Updating the CLI version

12. **Which property defines the gradual shift of traffic to a new version?**
    - A) TrafficPolicy
    - B) DeploymentPreference ✅
    - C) VersionUpdate
    - D) CanaryShift

13. **SAM templates must be in which format?**
    - A) JSON only
    - B) YAML only
    - C) JSON or YAML ✅
    - D) XML

14. **Which command produces logs from a deployed function?**
    - A) sam logs ✅
    - B) sam tail
    - C) sam report
    - D) sam watch

15. **What is 'sam init' used for?**
    - A) Building the code
    - B) Initializing a new project from a starter template ✅
    - C) Setting up AWS credentials
    - D) Starting a local API

16. **How do you define an S3 trigger for a function?**
    - A) Using the `Trigger` property
    - B) Using the `Events` property with type `S3` ✅
    - C) In the S3 bucket properties
    - D) Using a Lambda Layer

17. **Which command is used to generate CI/CD pipeline configs?**
    - A) sam build-pipeline
    - B) sam pipeline init ✅
    - C) sam ci
    - D) sam automate

18. **What does 'CodeUri' specify?**
    - A) The URL of the code in S3
    - B) The local path to the function's code ✅
    - C) The Git repository URL
    - D) The ARN of the function

19. **What is the default timeout for a SAM Lambda function if not specified?**
    - A) 1 second
    - B) 3 seconds ✅
    - C) 30 seconds
    - D) 15 minutes

20. **Can you debug a local SAM API with a debugger like VS Code?**
    - A) No
    - B) Yes, by passing debug ports to the `sam local` command ✅
    - C) Only if using Python
    - D) Only via console logs

21. **What is 'sam package' (legacy) equivalent to in the modern CLI?**
    - A) sam deploy
    - B) sam cloudformation package ✅
    - C) sam build
    - D) sam zip
