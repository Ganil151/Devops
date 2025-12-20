# AWS CI/CD and DevOps Services Guide

## AWS DevOps Services Overview

AWS provides a comprehensive suite of DevOps services that enable continuous integration, continuous delivery, and infrastructure automation. These services integrate seamlessly to create end-to-end DevOps pipelines.

## CodeCommit - Source Control

### Repository Management
```bash
# Create CodeCommit repository
aws codecommit create-repository \
    --repository-name devops-application \
    --repository-description "DevOps application source code" \
    --tags Team=DevOps,Environment=Production

# Clone repository
git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/devops-application

# Configure Git credentials helper
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true

# List repositories
aws codecommit list-repositories --output table

# Get repository metadata
aws codecommit get-repository \
    --repository-name devops-application

# Create branch
aws codecommit create-branch \
    --repository-name devops-application \
    --branch-name feature/new-feature \
    --commit-id 12345678

# List branches
aws codecommit list-branches \
    --repository-name devops-application
```

### Repository Triggers and Notifications
```bash
# Create repository trigger for Lambda
aws codecommit put-repository-triggers \
    --repository-name devops-application \
    --triggers repositoryName=devops-application,triggerName=DevOps-Trigger,triggerEvents=all,destinationArn=arn:aws:lambda:us-east-1:123456789012:function:ProcessCommit

# Create SNS notification rule
aws codestar-notifications create-notification-rule \
    --name DevOps-CodeCommit-Notifications \
    --event-type-ids codecommit-repository-commits-on-main-branch \
    --resource arn:aws:codecommit:us-east-1:123456789012:devops-application \
    --targets targetType=SNS,targetAddress=arn:aws:sns:us-east-1:123456789012:devops-notifications \
    --detail-type FULL \
    --status ENABLED
```
___

## CodeBuild - Build Service

### Build Projects
```bash
# Create build project
aws codebuild create-project \
    --name devops-application-build \
    --description "Build project for DevOps application" \
    --source type=CODECOMMIT,location=https://git-codecommit.us-east-1.amazonaws.com/v1/repos/devops-application \
    --artifacts type=S3,location=devops-build-artifacts \
    --environment type=LINUX_CONTAINER,image=aws/codebuild/amazonlinux2-x86_64-standard:3.0,computeType=BUILD_GENERAL1_MEDIUM \
    --service-role arn:aws:iam::123456789012:role/CodeBuildServiceRole \
    --tags Key=Team,Value=DevOps Key=Environment,Value=Production

# Start build
aws codebuild start-build \
    --project-name devops-application-build \
    --source-version main

# List builds
aws codebuild list-builds-for-project \
    --project-name devops-application-build \
    --output table

# Get build details
aws codebuild batch-get-builds \
    --ids devops-application-build:12345678-1234-1234-1234-123456789012
```

### BuildSpec Configuration
```yaml
# buildspec.yml - Build specification file
version: 0.2

env:
  variables:
    NODE_ENV: production
  parameter-store:
    DATABASE_URL: /devops/database/url
    API_KEY: /devops/api/key
  secrets-manager:
    DB_PASSWORD: devops-secrets:password

phases:
  install:
    runtime-versions:
      nodejs: 14
      python: 3.8
    commands:
      - echo Installing dependencies
      - npm install
      - pip install -r requirements.txt
      
  pre_build:
    commands:
      - echo Logging in to Amazon ECR
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
      - REPOSITORY_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/devops-app
      - COMMIT_HASH=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
      - IMAGE_TAG=${COMMIT_HASH:=latest}
      
  build:
    commands:
      - echo Build started on `date`
      - echo Running tests
      - npm test
      - python -m pytest tests/
      - echo Running security scan
      - npm audit --audit-level moderate
      - echo Building Docker image
      - docker build -t $REPOSITORY_URI:latest .
      - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$IMAGE_TAG
      
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing Docker images
      - docker push $REPOSITORY_URI:latest
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      - echo Writing image definitions file
      - printf '[{"name":"devops-app","imageUri":"%s"}]' $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions.json

artifacts:
  files:
    - imagedefinitions.json
    - '**/*'
  base-directory: dist
  
cache:
  paths:
    - '/root/.npm/**/*'
    - 'node_modules/**/*'

reports:
  jest_reports:
    files:
      - 'coverage/clover.xml'
    file-format: 'CLOVERXML'
  pytest_reports:
    files:
      - 'pytest.xml'
    file-format: 'JUNITXML'
```

### Advanced Build Configuration
```bash
# Create build project with VPC configuration
aws codebuild create-project \
    --name devops-secure-build \
    --source type=CODECOMMIT,location=https://git-codecommit.us-east-1.amazonaws.com/v1/repos/devops-application \
    --artifacts type=S3,location=devops-build-artifacts \
    --environment type=LINUX_CONTAINER,image=aws/codebuild/amazonlinux2-x86_64-standard:3.0,computeType=BUILD_GENERAL1_MEDIUM,privilegedMode=true \
    --service-role arn:aws:iam::123456789012:role/CodeBuildServiceRole \
    --vpc-config vpcId=vpc-12345678,subnets=subnet-12345678,securityGroupIds=sg-12345678 \
    --logs-config cloudWatchLogs='{groupName=/aws/codebuild/devops-secure-build,status=ENABLED}'

# Create build project with multiple source inputs
aws codebuild create-project \
    --name devops-multi-source-build \
    --source type=CODECOMMIT,location=https://git-codecommit.us-east-1.amazonaws.com/v1/repos/devops-application \
    --secondary-sources '[
        {
            "type": "S3",
            "location": "devops-shared-libraries/libraries.zip",
            "sourceIdentifier": "SharedLibraries"
        },
        {
            "type": "CODECOMMIT",
            "location": "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/devops-config",
            "sourceIdentifier": "ConfigRepo"
        }
    ]' \
    --artifacts type=S3,location=devops-build-artifacts \
    --environment type=LINUX_CONTAINER,image=aws/codebuild/amazonlinux2-x86_64-standard:3.0,computeType=BUILD_GENERAL1_MEDIUM
```

## CodeDeploy - Deployment Service

### Application and Deployment Groups

```bash
# Create CodeDeploy application
aws deploy create-application \
    --application-name devops-application \
    --compute-platform Server

# Create deployment group for EC2/On-premises
aws deploy create-deployment-group \
    --application-name devops-application \
    --deployment-group-name production-servers \
    --service-role-arn arn:aws:iam::123456789012:role/CodeDeployServiceRole \
    --ec2-tag-filters Key=Environment,Value=Production,Type=KEY_AND_VALUE \
    --auto-rollback-configuration enabled=true,events=DEPLOYMENT_FAILURE,DEPLOYMENT_STOP_ON_ALARM \
    --deployment-config-name CodeDeployDefault.AllAtOneTime

# Create deployment group for Auto Scaling
aws deploy create-deployment-group \
    --application-name devops-application \
    --deployment-group-name auto-scaling-group \
    --service-role-arn arn:aws:iam::123456789012:role/CodeDeployServiceRole \
    --auto-scaling-groups devops-asg \
    --deployment-config-name CodeDeployDefault.AllAtOneTimeAutoScaling

# Create deployment group for ECS
aws deploy create-deployment-group \
    --application-name devops-ecs-app \
    --deployment-group-name ecs-service \
    --service-role-arn arn:aws:iam::123456789012:role/CodeDeployServiceRole \
    --ecs-services serviceName=devops-service,clusterName=devops-cluster \
    --deployment-config-name CodeDeployDefault.ECSAllAtOnceBlueGreen \
    --blue-green-deployment-configuration '{
        "terminateBlueInstancesOnDeploymentSuccess": {
            "action": "TERMINATE",
            "terminationWaitTimeInMinutes": 5
        },
        "deploymentReadyOption": {
            "actionOnTimeout": "CONTINUE_DEPLOYMENT"
        },
        "greenFleetProvisioningOption": {
            "action": "COPY_AUTO_SCALING_GROUP"
        }
    }'
```

### Deployment Configuration

```bash
# Create deployment
aws deploy create-deployment \
    --application-name devops-application \
    --deployment-group-name production-servers \
    --s3-location bucket=devops-deployments,key=app-v1.2.0.zip,bundleType=zip \
    --description "Deploy version 1.2.0 to production" \
    --ignore-application-stop-failures

# Monitor deployment
aws deploy get-deployment \
    --deployment-id d-12345678

# List deployments
aws deploy list-deployments \
    --application-name devops-application \
    --deployment-group-name production-servers \
    --include-only-statuses InProgress,Succeeded,Failed

# Stop deployment
aws deploy stop-deployment \
    --deployment-id d-12345678 \
    --auto-rollback-enabled
```

### AppSpec File Configuration

```yaml
# appspec.yml - Application specification file
version: 0.0
os: linux
files:
  - source: /
    destination: /var/www/html
    overwrite: yes
  - source: /config/
    destination: /etc/myapp/
    overwrite: yes
permissions:
  - object: /var/www/html
    owner: apache
    group: apache
    mode: 755
  - object: /etc/myapp
    owner: root
    group: root
    mode: 644
hooks:
  BeforeInstall:
    - location: scripts/install_dependencies.sh
      timeout: 300
      runas: root
  ApplicationStart:
    - location: scripts/start_server.sh
      timeout: 300
      runas: root
  ApplicationStop:
    - location: scripts/stop_server.sh
      timeout: 300
      runas: root
  ValidateService:
    - location: scripts/validate_service.sh
      timeout: 300
      runas: root
```

## CodePipeline - CI/CD Orchestration

### Pipeline Creation

```bash
# Create S3 bucket for pipeline artifacts
aws s3 mb s3://devops-pipeline-artifacts-$(date +%s)

# Create pipeline
aws codepipeline create-pipeline \
    --pipeline file://pipeline-definition.json

# Pipeline definition JSON structure
cat > pipeline-definition.json << 'EOF'
{
  "pipeline": {
    "name": "DevOps-Application-Pipeline",
    "roleArn": "arn:aws:iam::123456789012:role/CodePipelineServiceRole",
    "artifactStore": {
      "type": "S3",
      "location": "devops-pipeline-artifacts-1642694400"
    },
    "stages": [
      {
        "name": "Source",
        "actions": [
          {
            "name": "SourceAction",
            "actionTypeId": {
              "category": "Source",
              "owner": "AWS",
              "provider": "CodeCommit",
              "version": "1"
            },
            "configuration": {
              "RepositoryName": "devops-application",
              "BranchName": "main"
            },
            "outputArtifacts": [
              {
                "name": "SourceOutput"
              }
            ]
          }
        ]
      },
      {
        "name": "Build",
        "actions": [
          {
            "name": "BuildAction",
            "actionTypeId": {
              "category": "Build",
              "owner": "AWS",
              "provider": "CodeBuild",
              "version": "1"
            },
            "configuration": {
              "ProjectName": "devops-application-build"
            },
            "inputArtifacts": [
              {
                "name": "SourceOutput"
              }
            ],
            "outputArtifacts": [
              {
                "name": "BuildOutput"
              }
            ]
          }
        ]
      },
      {
        "name": "Deploy-Staging",
        "actions": [
          {
            "name": "DeployToStaging",
            "actionTypeId": {
              "category": "Deploy",
              "owner": "AWS",
              "provider": "CodeDeploy",
              "version": "1"
            },
            "configuration": {
              "ApplicationName": "devops-application",
              "DeploymentGroupName": "staging-servers"
            },
            "inputArtifacts": [
              {
                "name": "BuildOutput"
              }
            ]
          }
        ]
      },
      {
        "name": "Manual-Approval",
        "actions": [
          {
            "name": "ManualApproval",
            "actionTypeId": {
              "category": "Approval",
              "owner": "AWS",
              "provider": "Manual",
              "version": "1"
            },
            "configuration": {
              "CustomData": "Please review the staging deployment and approve for production deployment.",
              "NotificationArn": "arn:aws:sns:us-east-1:123456789012:devops-approvals"
            }
          }
        ]
      },
      {
        "name": "Deploy-Production",
        "actions": [
          {
            "name": "DeployToProduction",
            "actionTypeId": {
              "category": "Deploy",
              "owner": "AWS",
              "provider": "CodeDeploy",
              "version": "1"
            },
            "configuration": {
              "ApplicationName": "devops-application",
              "DeploymentGroupName": "production-servers"
            },
            "inputArtifacts": [
              {
                "name": "BuildOutput"
              }
            ]
          }
        ]
      }
    ]
  }
}
EOF
```

### Advanced Pipeline Features

```bash
# Create multi-branch pipeline with parallel execution
cat > advanced-pipeline.json << 'EOF'
{
  "pipeline": {
    "name": "DevOps-Advanced-Pipeline",
    "roleArn": "arn:aws:iam::123456789012:role/CodePipelineServiceRole",
    "artifactStore": {
      "type": "S3",
      "location": "devops-pipeline-artifacts-advanced"
    },
    "stages": [
      {
        "name": "Source",
        "actions": [
          {
            "name": "ApplicationSource",
            "actionTypeId": {
              "category": "Source",
              "owner": "AWS",
              "provider": "CodeCommit",
              "version": "1"
            },
            "configuration": {
              "RepositoryName": "devops-application",
              "BranchName": "main"
            },
            "outputArtifacts": [{"name": "AppSource"}]
          },
          {
            "name": "InfrastructureSource",
            "actionTypeId": {
              "category": "Source",
              "owner": "AWS",
              "provider": "CodeCommit",
              "version": "1"
            },
            "configuration": {
              "RepositoryName": "devops-infrastructure",
              "BranchName": "main"
            },
            "outputArtifacts": [{"name": "InfraSource"}]
          }
        ]
      },
      {
        "name": "Parallel-Build",
        "actions": [
          {
            "name": "BuildApplication",
            "actionTypeId": {
              "category": "Build",
              "owner": "AWS",
              "provider": "CodeBuild",
              "version": "1"
            },
            "configuration": {
              "ProjectName": "devops-application-build"
            },
            "inputArtifacts": [{"name": "AppSource"}],
            "outputArtifacts": [{"name": "AppBuild"}],
            "runOrder": 1
          },
          {
            "name": "SecurityScan",
            "actionTypeId": {
              "category": "Build",
              "owner": "AWS",
              "provider": "CodeBuild",
              "version": "1"
            },
            "configuration": {
              "ProjectName": "devops-security-scan"
            },
            "inputArtifacts": [{"name": "AppSource"}],
            "outputArtifacts": [{"name": "SecurityReport"}],
            "runOrder": 1
          },
          {
            "name": "InfrastructureValidation",
            "actionTypeId": {
              "category": "Build",
              "owner": "AWS",
              "provider": "CodeBuild",
              "version": "1"
            },
            "configuration": {
              "ProjectName": "devops-terraform-validate"
            },
            "inputArtifacts": [{"name": "InfraSource"}],
            "outputArtifacts": [{"name": "InfraValidated"}],
            "runOrder": 1
          }
        ]
      }
    ]
  }
}
EOF

aws codepipeline create-pipeline --pipeline file://advanced-pipeline.json
```

### Pipeline Management

```bash
# Start pipeline execution
aws codepipeline start-pipeline-execution \
    --name DevOps-Application-Pipeline

# Get pipeline state
aws codepipeline get-pipeline-state \
    --name DevOps-Application-Pipeline

# List pipeline executions
aws codepipeline list-pipeline-executions \
    --pipeline-name DevOps-Application-Pipeline \
    --max-results 10

# Stop pipeline execution
aws codepipeline stop-pipeline-execution \
    --pipeline-name DevOps-Application-Pipeline \
    --pipeline-execution-id 12345678-1234-1234-1234-123456789012 \
    --abandon

# Update pipeline
aws codepipeline update-pipeline \
    --pipeline file://updated-pipeline-definition.json
```

## AWS Systems Manager - Operations Management

### Parameter Store

```bash
# Store configuration parameters
aws ssm put-parameter \
    --name "/devops/application/database-url" \
    --value "postgresql://user:pass@db.example.com:5432/devops" \
    --type "SecureString" \
    --description "Database connection URL for DevOps application"

aws ssm put-parameter \
    --name "/devops/application/api-key" \
    --value "your-api-key-here" \
    --type "SecureString" \
    --key-id "alias/devops-parameters"

# Retrieve parameters
aws ssm get-parameter \
    --name "/devops/application/database-url" \
    --with-decryption

# Get multiple parameters
aws ssm get-parameters \
    --names "/devops/application/database-url" "/devops/application/api-key" \
    --with-decryption

# Get parameters by path
aws ssm get-parameters-by-path \
    --path "/devops/application" \
    --recursive \
    --with-decryption

# List parameters
aws ssm describe-parameters \
    --parameter-filters Key=Name,Values=/devops/application
```

### Session Manager

```bash
# Start session with EC2 instance
aws ssm start-session --target i-1234567890abcdef0

# Run command on multiple instances
aws ssm send-command \
    --document-name "AWS-RunShellScript" \
    --parameters 'commands=["sudo yum update -y","sudo systemctl restart httpd"]' \
    --targets "Key=tag:Environment,Values=Production" \
    --comment "Update and restart web servers"

# Get command execution results
aws ssm list-command-invocations \
    --command-id 12345678-1234-1234-1234-123456789012 \
    --details

# Create custom document
aws ssm create-document \
    --content file://deploy-application.json \
    --name "DevOps-Deploy-Application" \
    --document-type "Command" \
    --document-format JSON
```

### Patch Management

```bash
# Create patch baseline
aws ssm create-patch-baseline \
    --name "DevOps-Patch-Baseline" \
    --operating-system AMAZON_LINUX_2 \
    --approval-rules Rules='[{
        "PatchRules": [{
            "PatchFilterGroup": {
                "PatchFilters": [{
                    "Key": "CLASSIFICATION",
                    "Values": ["Security", "Bugfix", "Critical"]
                }]
            },
            "ApproveAfterDays": 7,
            "ComplianceLevel": "CRITICAL"
        }]
    }]' \
    --description "Patch baseline for DevOps infrastructure"

# Create maintenance window
aws ssm create-maintenance-window \
    --name "DevOps-Patching-Window" \
    --schedule "cron(0 2 ? * SUN *)" \
    --duration 4 \
    --cutoff 1 \
    --description "Weekly patching window for DevOps infrastructure" \
    --allow-unassociated-targets

# Register targets with maintenance window
aws ssm register-target-with-maintenance-window \
    --window-id mw-12345678 \
    --target-type "Instance" \
    --targets Key=tag:Environment,Values=Production \
    --resource-type INSTANCE

# Register patch task
aws ssm register-task-with-maintenance-window \
    --window-id mw-12345678 \
    --target-type "Instance" \
    --targets Key=WindowTargetIds,Values=12345678-1234-1234-1234-123456789012 \
    --task-arn "AWS-RunPatchBaseline" \
    --task-type "RUN_COMMAND" \
    --max-concurrency 50% \
    --max-errors 1 \
    --priority 1 \
    --task-parameters Operation='{Values=[Install]}'
```

This comprehensive CI/CD and DevOps services guide provides the foundation for implementing robust automation pipelines using AWS native services.