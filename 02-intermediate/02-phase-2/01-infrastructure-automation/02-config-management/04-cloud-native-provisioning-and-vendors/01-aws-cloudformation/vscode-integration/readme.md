# CloudFormation VS Code Integration Guide

This guide covers multiple methods to deploy and manage CloudFormation templates directly from VS Code, from basic CLI commands to advanced integrated workflows.

---

## 📋 Table of Contents

1. [Method 1: AWS CLI in Terminal](#method-1-aws-cli-in-terminal-most-common)
2. [Method 2: AWS Toolkit Extension](#method-2-aws-toolkit-extension)
3. [Method 3: VS Code Tasks Automation](#method-3-vs-code-tasks-automation)
4. [Method 4: Integrated Deployment Scripts](#method-4-integrated-deployment-scripts)
5. [Method 5: Change Sets for Safe Deployments](#method-5-change-sets-safe-deployments)
6. [Method 6: Advanced VS Code Configuration](#method-6-advanced-vs-code-configuration)
7. [Method 7: NPM Scripts](#method-7-npm-scripts)
8. [Method 8: PowerShell Scripts (Windows)](#method-8-powershell-scripts-windows)
9. [Quick Setup Checklist](#quick-setup-checklist)
10. [Best Practices](#best-practices-for-vs-code-cloudformation)
11. [Troubleshooting](#troubleshooting-common-issues)

---

## Method 1: AWS CLI in Terminal (Most Common)

### Basic CloudFormation Commands

Open VS Code terminal (Ctrl+`` ` ``) and use these commands:

```bash
# Validate template syntax
aws cloudformation validate-template --template-body file://template.yaml

# Create a new stack
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --parameters ParameterKey=Environment,ParameterValue=dev \
  --capabilities CAPABILITY_IAM

# Update existing stack
aws cloudformation update-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --parameters ParameterKey=Environment,ParameterValue=prod

# Delete stack
aws cloudformation delete-stack --stack-name my-stack

# Check stack status
aws cloudformation describe-stacks --stack-name my-stack

# List all stacks
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE

# Get stack outputs
aws cloudformation describe-stacks \
  --stack-name my-stack \
  --query 'Stacks[0].Outputs'
```

### Using Parameter Files

Create a `parameters.json` file:

```json
[
	{
		"ParameterKey": "Environment",
		"ParameterValue": "dev"
	},
	{
		"ParameterKey": "InstanceType",
		"ParameterValue": "t3.micro"
	}
]
```

Then deploy:

```bash
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_IAM
```

> **Note**: For templates using AWS transforms (like SAM), use `aws cloudformation deploy` instead of `create-stack`.

---

## Method 2: AWS Toolkit Extension

### Install AWS Toolkit Extension

1. Install "AWS Toolkit" extension in VS Code from the Extensions Marketplace
2. Press `Ctrl+Shift+P` and type "AWS: Create Credentials Profile"
3. Configure your AWS credentials

### Deploy via AWS Toolkit

1. Right-click on CloudFormation template
2. Select "Deploy CloudFormation Stack"
3. Choose region and provide parameters
4. Monitor deployment in AWS Explorer

### AWS Explorer Features

- View existing stacks
- Monitor stack events
- Delete stacks
- View stack resources
- Access stack outputs

---

## Method 3: VS Code Tasks (Automation)

Create `.vscode/tasks.json` for automated workflows:

```json
{
	"version": "2.0.0",
	"tasks": [
		{
			"label": "CloudFormation: Validate Template",
			"type": "shell",
			"command": "aws",
			"args": [
				"cloudformation",
				"validate-template",
				"--template-body",
				"file://${file}"
			],
			"group": "build",
			"presentation": {
				"echo": true,
				"reveal": "always",
				"focus": false,
				"panel": "shared"
			},
			"problemMatcher": []
		},
		{
			"label": "CloudFormation: Deploy Stack",
			"type": "shell",
			"command": "aws",
			"args": [
				"cloudformation",
				"deploy",
				"--template-file",
				"${file}",
				"--stack-name",
				"${input:stackName}",
				"--parameter-overrides",
				"${input:parameters}",
				"--capabilities",
				"CAPABILITY_IAM"
			],
			"group": "build",
			"presentation": {
				"echo": true,
				"reveal": "always",
				"focus": true,
				"panel": "shared"
			}
		},
		{
			"label": "CloudFormation: Delete Stack",
			"type": "shell",
			"command": "aws",
			"args": [
				"cloudformation",
				"delete-stack",
				"--stack-name",
				"${input:stackName}"
			],
			"group": "build"
		}
	],
	"inputs": [
		{
			"id": "stackName",
			"description": "Stack name",
			"default": "my-test-stack",
			"type": "promptString"
		},
		{
			"id": "parameters",
			"description": "Parameters (Key=Value Key2=Value2)",
			"default": "Environment=dev",
			"type": "promptString"
		}
	]
}
```

**Usage**: `Ctrl+Shift+P` → "Tasks: Run Task" → Select your CloudFormation task

---

## Method 4: Using Integrated Scripts

Create deployment scripts in your project:

### deploy.sh (Linux/Mac/Git Bash)

```bash
#!/bin/bash
set -e

STACK_NAME=${1:-"my-default-stack"}
TEMPLATE_FILE=${2:-"template.yaml"}
ENVIRONMENT=${3:-"dev"}

echo "Deploying CloudFormation stack: $STACK_NAME"
echo "Template: $TEMPLATE_FILE"
echo "Environment: $ENVIRONMENT"

# Validate template
echo "Validating template..."
aws cloudformation validate-template --template-body file://$TEMPLATE_FILE

# Deploy stack
echo "Deploying stack..."
aws cloudformation deploy \
  --template-file $TEMPLATE_FILE \
  --stack-name $STACK_NAME \
  --parameter-overrides Environment=$ENVIRONMENT \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --no-fail-on-empty-changeset

echo "Stack deployed successfully!"

# Show outputs
echo "Stack outputs:"
aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --query 'Stacks[0].Outputs' \
  --output table
```

**Package and run:**

```bash
chmod +x deploy.sh
./deploy.sh my-stack template.yaml prod
```

---

## Method 5: Change Sets (Safe Deployments)

Change sets allow you to preview changes before applying them to your stack.

```bash
# Create change set
aws cloudformation create-change-set \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --change-set-name my-change-set-$(date +%Y%m%d-%H%M%S) \
  --capabilities CAPABILITY_IAM

# Review changes
aws cloudformation describe-change-set \
  --stack-name my-stack \
  --change-set-name my-change-set \
  --query 'Changes[].{Action:Action,Resource:ResourceChange.LogicalResourceId,Type:ResourceChange.ResourceType}'

# Execute if satisfied
aws cloudformation execute-change-set \
  --stack-name my-stack \
  --change-set-name my-change-set
```

---

## Method 6: Advanced VS Code Configuration

### Launch Configuration (launch.json)

Create `.vscode/launch.json` for debugging CloudFormation deployments:

```json
{
	"version": "0.2.0",
	"configurations": [
		{
			"name": "Deploy CloudFormation Stack",
			"type": "node",
			"request": "launch",
			"program": "${workspaceFolder}/deploy.js",
			"args": ["${input:stackName}", "${input:environment}"],
			"console": "integratedTerminal",
			"env": {
				"AWS_REGION": "us-west-2"
			}
		}
	],
	"inputs": [
		{
			"id": "stackName",
			"description": "CloudFormation Stack Name",
			"default": "my-stack",
			"type": "promptString"
		},
		{
			"id": "environment",
			"description": "Environment",
			"default": "dev",
			"type": "pickString",
			"options": ["dev", "staging", "prod"]
		}
	]
}
```

### Settings for CloudFormation

Add to `.vscode/settings.json`:

```json
{
	"yaml.schemas": {
		"https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json": [
			"template.yaml",
			"*.cf.yaml",
			"*-template.yml"
		]
	},
	"files.associations": {
		"*.template": "yaml",
		"*.cf.yaml": "yaml"
	},
	"editor.quickSuggestions": {
		"strings": true
	}
}
```

---

## Method 7: Using NPM Scripts (if you have package.json)

Add to your `package.json`:

```json
{
	"scripts": {
		"cf:validate": "aws cloudformation validate-template --template-body file://template.yaml",
		"cf:deploy": "aws cloudformation deploy --template-file template.yaml --stack-name $npm_config_stack --capabilities CAPABILITY_IAM",
		"cf:delete": "aws cloudformation delete-stack --stack-name $npm_config_stack",
		"cf:status": "aws cloudformation describe-stacks --stack-name $npm_config_stack --query 'Stacks[0].StackStatus'"
	}
}
```

**Usage in VS Code terminal:**

```bash
npm run cf:validate
npm run cf:deploy --stack=my-stack
npm run cf:status --stack=my-stack
npm run cf:delete --stack=my-stack
```

---

## Method 8: PowerShell Scripts (Windows)

### deploy.ps1

```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$StackName,

    [Parameter(Mandatory=$false)]
    [string]$TemplateFile = "template.yaml",

    [Parameter(Mandatory=$false)]
    [string]$Environment = "dev"
)

Write-Host "Deploying CloudFormation stack: $StackName" -ForegroundColor Green

# Validate template
Write-Host "Validating template..." -ForegroundColor Yellow
aws cloudformation validate-template --template-body file://$TemplateFile

if ($LASTEXITCODE -eq 0) {
    Write-Host "Template is valid" -ForegroundColor Green

    # Deploy stack
    Write-Host "Deploying stack..." -ForegroundColor Yellow
    aws cloudformation deploy `
      --template-file $TemplateFile `
      --stack-name $StackName `
      --parameter-overrides Environment=$Environment `
      --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM `
      --no-fail-on-empty-changeset

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Stack deployed successfully!" -ForegroundColor Green

        # Show outputs
        Write-Host "Stack outputs:" -ForegroundColor Cyan
        aws cloudformation describe-stacks `
          --stack-name $StackName `
          --query 'Stacks[0].Outputs' `
          --output table
    }
} else {
    Write-Host "Template validation failed!" -ForegroundColor Red
}
```

**Run in PowerShell:**

```powershell
.\deploy.ps1 -StackName my-stack -TemplateFile template.yaml -Environment prod
```

---

## Quick Setup Checklist

### 1. Configure AWS Credentials

```bash
# Option 1: AWS CLI configure
aws configure

# Option 2: Environment variables
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-west-2

# Option 3: AWS credentials file
# ~/.aws/credentials
[default]
aws_access_key_id = your_access_key
aws_secret_access_key = your_secret_key
region = us-west-2
```

### 2. Install Required Extensions

- **AWS Toolkit**: Official AWS extension for VS Code
- **CloudFormation Linter (cfn-lint)**: Template validation
- **YAML**: Better YAML support and syntax highlighting

### 3. Workspace Setup

Create this folder structure:

```
your-project/
├── .vscode/
│   ├── tasks.json
│   ├── launch.json
│   └── settings.json
├── templates/
│   ├── template.yaml
│   └── parameters.json
├── scripts/
│   ├── deploy.sh
│   └── deploy.ps1
└── README.md
```

---

## Best Practices for VS Code CloudFormation

### 1. Use Workspace-Specific Settings

Create `.vscode/settings.json`:

```json
{
	"aws.region": "us-west-2",
	"aws.profile": "default",
	"cloudformation.templatePath": "templates/",
	"editor.formatOnSave": true,
	"yaml.format.enable": true
}
```

### 2. Create Template Snippets

Add CloudFormation snippets in VS Code: File → Preferences → Configure User Snippets → yaml.json

```json
{
	"CloudFormation Template": {
		"prefix": "cf-template",
		"body": [
			"AWSTemplateFormatVersion: '2010-09-09'",
			"Description: '${1:Template description}'",
			"",
			"Parameters:",
			"  ${2:ParameterName}:",
			"    Type: String",
			"    Default: ${3:DefaultValue}",
			"",
			"Resources:",
			"  ${4:ResourceName}:",
			"    Type: ${5:AWS::ResourceType}",
			"    Properties:",
			"      ${6:Property}: ${7:Value}",
			"",
			"Outputs:",
			"  ${8:OutputName}:",
			"    Description: ${9:Output description}",
			"    Value: !Ref ${4:ResourceName}"
		],
		"description": "Basic CloudFormation template structure"
	}
}
```

### 3. Error Handling and Validation

Always validate before deployment:

```bash
# Comprehensive validation script
validate_and_deploy() {
    local template_file=$1
    local stack_name=$2

    echo "Validating template..."
    if aws cloudformation validate-template --template-body file://$template_file; then
        echo "Template is valid. Proceeding with deployment..."

        # Use change set for safer deployment
        aws cloudformation deploy \
          --template-file $template_file \
          --stack-name $stack_name \
          --capabilities CAPABILITY_IAM \
          --no-fail-on-empty-changeset
    else
        echo "Template validation failed. Aborting deployment."
        exit 1
    fi
}
```

---

## Troubleshooting Common Issues

### Issue 1: AWS Credentials Not Found

**Solution**: Configure credentials using `aws configure` or set environment variables:

```bash
aws configure
# or
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_DEFAULT_REGION=us-east-1
```

### Issue 2: Template Validation Fails

**Solution**: Use the AWS CloudFormation Linter extension and check syntax:

```bash
# Install cfn-lint
pip install cfn-lint

# Lint your template
cfn-lint template.yaml
```

### Issue 3: Permission Denied

**Solution**: Ensure your AWS user/role has CloudFormation permissions:

- `cloudformation:*`
- Permissions for resources being created (e.g., `s3:*`, `ec2:*`, `iam:*`)

### Issue 4: Stack Already Exists

**Solution**: Use `update-stack` instead of `create-stack`, or delete the existing stack:

```bash
# Update instead of create
aws cloudformation update-stack \
  --stack-name my-stack \
  --template-body file://template.yaml

# Or delete first
aws cloudformation delete-stack --stack-name my-stack
```

### Issue 5: Capabilities Required

**Solution**: Add `--capabilities` flag to your commands:

```bash
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
```

---

## Example: Complete Workflow

Here's a complete example of deploying a CloudFormation template from VS Code:

1. **Create template** (`template.yaml`)
2. **Validate**: `aws cloudformation validate-template --template-body file://template.yaml`
3. **Deploy**: `aws cloudformation deploy --template-file template.yaml --stack-name my-stack --capabilities CAPABILITY_IAM`
4. **Monitor**: Use AWS Toolkit extension to watch deployment progress
5. **Test**: Verify resources in AWS Console or via CLI
6. **Clean up**: `aws cloudformation delete-stack --stack-name my-stack`

---

## 📚 Additional Resources

- [AWS CloudFormation User Guide](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/)
- [AWS Toolkit for VS Code](https://aws.amazon.com/visualstudiocode/)
- [cfn-lint Documentation](https://github.com/aws-cloudformation/cfn-lint)
- [CloudFormation Sample Templates](https://github.com/awslabs/aws-cloudformation-templates)

---

[⬅️ Back to CloudFormation Index](../readme.md)
