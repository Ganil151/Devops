# ❓ AWS CDK Interview & Quiz Questions

## 📋 Interview Questions

**Q1: What is the main difference between CloudFormation and CDK?**
**A:** CloudFormation is a declarative template-based service (YAML/JSON). CDK is a programming framework that generates CloudFormation templates. CDK allows for complex logic, reusability via classes, and higher-level abstractions.

**Q2: What are the three levels of Constructs?**
**A:** 
- **L1 (CfnResources)**: Direct mappings to CFN.
- **L2**: AWS-curated with sensible defaults and helper methods.
- **L3 (Patterns)**: Higher-level abstractions for common tasks (e.g., Load Balanced Fargate Service).

**Q3: What does 'cdk bootstrap' do?**
**A:** It prepares the AWS environment by creating an S3 bucket and other resources needed to store assets (Lambda code, Docker images) during deployment.

**Q4: Explain the 'cdk synth' command.**
**A:** It synthesizes your CDK code into a CloudFormation template without actually deploying anything.

**Q5: How do you handle environment-specific configurations in CDK?**
**A:** Using Context (`cdk.json` or `-c`), environment variables, or passing props to Stacks when instantiating them in the App file.

**Q6: What is a CDK Pipeline?**
**A:** A construct library for defining CI/CD pipelines in code. It supports self-mutation, meaning the pipeline updates itself.

---

## 📝 Quiz Section (20+ Questions)

1. **What command translates CDK code into a CloudFormation template?**
   - A) cdk deploy
   - B) cdk translate
   - C) cdk synth ✅
   - D) cdk init

2. **Which level of construct includes sensible defaults?**
   - A) L1
   - B) L2 ✅
   - C) L0
   - D) All of them

3. **In which language is the CDK core written?**
   - A) Python
   - B) Go
   - C) TypeScript ✅
   - D) Java

4. **What is the root of a CDK application called?**
   - A) Root
   - B) Stack
   - C) App ✅
   - D) Module

5. **Which command is used to see changes before deployment?**
   - A) cdk list
   - B) cdk check
   - C) cdk diff ✅
   - D) cdk log

6. **What is 'cdk-nag' used for?**
   - A) Speeding up deployments
   - B) Security and compliance auditing ✅
   - C) Renaming resources
   - D) Translating code

7. **How do you delete all resources created by a stack?**
   - A) cdk remove
   - B) cdk destroy ✅
   - C) cdk clean
   - D) cdk stop

8. **Which of these is NOT a supported CDK language?**
   - A) Ruby ✅
   - B) C#
   - C) Go
   - D) Java

9. **What is an 'Aspect' in CDK?**
   - A) A way to view the code
   - B) A design pattern for classes
   - C) A tool to apply operations to all nodes in a scope ✅
   - D) A type of Lambda function

10. **What is the unit of deployment in CDK?**
    - A) App
    - B) Stack ✅
    - C) Construct
    - D) Resource

11. **Where does CDK store its assets during deployment?**
    - A) Local machine
    - B) GitHub
    - C) S3 (Bootstrap bucket) ✅
    - D) AWS Lambda

12. **Can you import an existing CloudFormation template into a CDK stack?**
    - A) No
    - B) Yes, using `CfnInclude` ✅
    - C) Only if it's JSON
    - D) Only if it's less than 100 lines

13. **Which command initializes a new project?**
    - A) cdk start
    - B) cdk build
    - C) cdk init ✅
    - D) cdk create

14. **What does L3 construct typically represent?**
    - A) A single AWS resource
    - B) A low-level configuration
    - C) A common architectural pattern ✅
    - D) A deprecated resource

15. **Which file contains permanent context variables?**
    - A) settings.json
    - B) cdk.json ✅
    - C) env.yaml
    - D) package.json

16. **How do you define resource dependencies in CDK?**
    - A) Using `node.addDependency()` ✅
    - B) CDK handles everything automatically (it does, but this is the manual way)
    - C) In the `cdk.json` file
    - D) Using comments

17. **What is 'cdk watch' used for?**
    - A) Monitoring logs
    - B) Automatic synchronization of code changes to AWS during development ✅
    - C) Alerting on cost increases
    - D) Viewing the dashboard

18. **Which library provides testing utilities for CDK?**
    - A) cdk-test
    - B) aws-cdk-lib/assertions ✅
    - C) infrastructure-tester
    - D) jest-cdk

19. **What is the 'removalPolicy' usually set to in production?**
    - A) DESTROY
    - B) RETAIN ✅
    - C) SNAPSHOT
    - D) MOVE

20. **Can CDK manage resources in multiple accounts within one App?**
    - A) No
    - B) Yes, by defining the environment for each stack ✅
    - C) Only if they are in the same region
    - D) Only using AWS CLI

21. **What is jsii?**
    - A) A new language
    - B) The technology that allows CDK to work across multiple languages ✅
    - C) A database service
    - D) A security protocol
