# AWS IAM Security Guide for DevOps Engineers

## IAM Overview

AWS Identity and Access Management (IAM) is a web service that helps you securely control access to AWS resources. IAM enables you to manage users, groups, roles, and permissions to allow and deny access to AWS resources.

## IAM Core Components

### Users, Groups, and Roles
```bash
# Create IAM user
aws iam create-user \
    --user-name devops-engineer \
    --path /devops/ \
    --tags Key=Department,Value=Engineering Key=Team,Value=DevOps

# Create IAM group
aws iam create-group \
    --group-name DevOps-Engineers \
    --path /devops/

# Add user to group
aws iam add-user-to-group \
    --group-name DevOps-Engineers \
    --user-name devops-engineer

# Create IAM role
aws iam create-role \
    --role-name DevOps-EC2-Role \
    --assume-role-policy-document file://trust-policy.json \
    --path /devops/ \
    --description "Role for DevOps EC2 instances"

# List users, groups, and roles
aws iam list-users --path-prefix /devops/
aws iam list-groups --path-prefix /devops/
aws iam list-roles --path-prefix /devops/
```

### Trust Policies and Assume Role

```json
# trust-policy.json - EC2 service trust policy
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

```json
# cross-account-trust-policy.json - Cross-account access
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "unique-external-id"
        }
      }
    }
  ]
}
```

```bash
# Assume role
aws sts assume-role \
    --role-arn arn:aws:iam::123456789012:role/DevOps-EC2-Role \
    --role-session-name DevOps-Session \
    --duration-seconds 3600

# Assume role with MFA
aws sts assume-role \
    --role-arn arn:aws:iam::123456789012:role/DevOps-Admin-Role \
    --role-session-name DevOps-Admin-Session \
    --serial-number arn:aws:iam::123456789012:mfa/devops-engineer \
    --token-code 123456

# Get caller identity
aws sts get-caller-identity
```
___

## IAM Policies

### Policy Types

#### AWS Managed Policies
```bash
# List AWS managed policies
aws iam list-policies --scope AWS --max-items 50

# Common AWS managed policies for DevOps
aws iam attach-user-policy \
    --user-name devops-engineer \
    --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

aws iam attach-group-policy \
    --group-name DevOps-Engineers \
    --policy-arn arn:aws:iam::aws:policy/IAMReadOnlyAccess

# Useful AWS managed policies
# - PowerUserAccess: Full access except IAM
# - ReadOnlyAccess: Read-only access to all services
# - AmazonEC2FullAccess: Full EC2 access
# - AmazonS3FullAccess: Full S3 access
# - CloudWatchFullAccess: Full CloudWatch access
```

#### Customer Managed Policies
```json
# devops-policy.json - Custom DevOps policy
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EC2Management",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeImages",
        "ec2:DescribeSnapshots",
        "ec2:DescribeVolumes",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeKeyPairs",
        "ec2:RunInstances",
        "ec2:StopInstances",
        "ec2:StartInstances",
        "ec2:RebootInstances",
        "ec2:TerminateInstances"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/Environment": ["Development", "Staging"]
        }
      }
    },
    {
      "Sid": "S3Access",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::devops-*",
        "arn:aws:s3:::devops-*/*"
      ]
    },
    {
      "Sid": "CloudWatchLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Resource": "arn:aws:logs:*:*:log-group:/aws/devops/*"
    },
    {
      "Sid": "DenyProductionAccess",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-gov-west-1"
        }
      }
    }
  ]
}
```

```bash
# Create custom policy
aws iam create-policy \
    --policy-name DevOps-Policy \
    --policy-document file://devops-policy.json \
    --description "Custom policy for DevOps engineers"

# Attach custom policy
aws iam attach-group-policy \
    --group-name DevOps-Engineers \
    --policy-arn arn:aws:iam::123456789012:policy/DevOps-Policy

# List policy versions
aws iam list-policy-versions \
    --policy-arn arn:aws:iam::123456789012:policy/DevOps-Policy

# Create new policy version
aws iam create-policy-version \
    --policy-arn arn:aws:iam::123456789012:policy/DevOps-Policy \
    --policy-document file://devops-policy-v2.json \
    --set-as-default
```

#### Inline Policies
```bash
# Create inline policy for user
aws iam put-user-policy \
    --user-name devops-engineer \
    --policy-name S3-Specific-Access \
    --policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:GetObject",
                    "s3:PutObject"
                ],
                "Resource": "arn:aws:s3:::my-specific-bucket/*"
            }
        ]
    }'

# Create inline policy for role
aws iam put-role-policy \
    --role-name DevOps-EC2-Role \
    --policy-name CloudWatch-Metrics \
    --policy-document file://cloudwatch-policy.json
```

### Policy Conditions and Advanced Features
```json
# advanced-conditions-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TimeBasedAccess",
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*",
      "Condition": {
        "DateGreaterThan": {
          "aws:CurrentTime": "2024-01-01T00:00:00Z"
        },
        "DateLessThan": {
          "aws:CurrentTime": "2024-12-31T23:59:59Z"
        }
      }
    },
    {
      "Sid": "IPRestriction",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": ["203.0.113.0/24", "198.51.100.0/24"]
        }
      }
    },
    {
      "Sid": "MFARequired",
      "Effect": "Allow",
      "Action": [
        "ec2:TerminateInstances",
        "rds:DeleteDBInstance"
      ],
      "Resource": "*",
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": "true"
        },
        "NumericLessThan": {
          "aws:MultiFactorAuthAge": "3600"
        }
      }
    },
    {
      "Sid": "TagBasedAccess",
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/Owner": "${aws:username}"
        }
      }
    }
  ]
}
```
___

## Multi-Factor Authentication (MFA)

### Virtual MFA Setup
```bash
# Create virtual MFA device
aws iam create-virtual-mfa-device \
    --virtual-mfa-device-name devops-engineer-mfa \
    --outfile QRCode.png \
    --bootstrap-method QRCodePNG

# Enable MFA device for user
aws iam enable-mfa-device \
    --user-name devops-engineer \
    --serial-number arn:aws:iam::123456789012:mfa/devops-engineer-mfa \
    --authentication-code-1 123456 \
    --authentication-code-2 789012

# List MFA devices
aws iam list-mfa-devices --user-name devops-engineer

# Deactivate MFA device
aws iam deactivate-mfa-device \
    --user-name devops-engineer \
    --serial-number arn:aws:iam::123456789012:mfa/devops-engineer-mfa

# Delete virtual MFA device
aws iam delete-virtual-mfa-device \
    --serial-number arn:aws:iam::123456789012:mfa/devops-engineer-mfa
```

### Hardware MFA Setup
```bash
# Enable hardware MFA device
aws iam enable-mfa-device \
    --user-name devops-engineer \
    --serial-number GAHT12345678 \
    --authentication-code-1 123456 \
    --authentication-code-2 789012

# Resync MFA device if out of sync
aws iam resync-mfa-device \
    --user-name devops-engineer \
    --serial-number GAHT12345678 \
    --authentication-code-1 123456 \
    --authentication-code-2 789012
```
___

## Access Keys and Credentials Management

### Access Key Management
```bash
# Create access key
aws iam create-access-key --user-name devops-engineer

# List access keys
aws iam list-access-keys --user-name devops-engineer

# Get access key last used information
aws iam get-access-key-last-used \
    --access-key-id AKIAIOSFODNN7EXAMPLE

# Update access key status
aws iam update-access-key \
    --user-name devops-engineer \
    --access-key-id AKIAIOSFODNN7EXAMPLE \
    --status Inactive

# Delete access key
aws iam delete-access-key \
    --user-name devops-engineer \
    --access-key-id AKIAIOSFODNN7EXAMPLE

# Rotate access keys script
#!/bin/bash
USER_NAME="devops-engineer"

# Create new access key
NEW_KEY=$(aws iam create-access-key --user-name $USER_NAME --output json)
NEW_ACCESS_KEY=$(echo $NEW_KEY | jq -r '.AccessKey.AccessKeyId')
NEW_SECRET_KEY=$(echo $NEW_KEY | jq -r '.AccessKey.SecretAccessKey')

echo "New Access Key: $NEW_ACCESS_KEY"
echo "New Secret Key: $NEW_SECRET_KEY"

# Test new key (update your applications first)
# After testing, deactivate old key
# aws iam update-access-key --user-name $USER_NAME --access-key-id OLD_KEY --status Inactive
# After confirming everything works, delete old key
# aws iam delete-access-key --user-name $USER_NAME --access-key-id OLD_KEY
```

### Temporary Credentials
```bash
# Get session token with MFA
aws sts get-session-token \
    --serial-number arn:aws:iam::123456789012:mfa/devops-engineer \
    --token-code 123456 \
    --duration-seconds 3600

# Assume role for cross-account access
aws sts assume-role \
    --role-arn arn:aws:iam::987654321098:role/CrossAccountRole \
    --role-session-name CrossAccountSession \
    --external-id unique-external-id

# Get federation token
aws sts get-federation-token \
    --name DevOpsFederatedUser \
    --policy '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": "s3:ListBucket",
                "Resource": "*"
            }
        ]
    }' \
    --duration-seconds 3600
```
___

## IAM Best Practices for DevOps

### Principle of Least Privilege

```json
# least-privilege-policy.json - Granular permissions
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSpecificEC2Actions",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/Team": "DevOps"
        }
      }
    },
    {
      "Sid": "AllowS3AccessToSpecificBucket",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::devops-deployment-artifacts/*"
    },
    {
      "Sid": "AllowCloudWatchMetrics",
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "cloudwatch:namespace": "DevOps/*"
        }
      }
    }
  ]
}
```

### Service-Linked Roles
```bash
# Create service-linked role for Auto Scaling
aws iam create-service-linked-role \
    --aws-service-name autoscaling.amazonaws.com

# List service-linked roles
aws iam list-roles \
    --path-prefix /aws-service-role/

# Delete service-linked role
aws iam delete-service-linked-role \
    --role-name AWSServiceRoleForAutoScaling
```

### Cross-Account Access
```json
# cross-account-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCrossAccountAssumeRole",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::123456789012:user/devops-engineer",
          "arn:aws:iam::123456789012:role/DevOps-CI-Role"
        ]
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "unique-external-id"
        },
        "IpAddress": {
          "aws:SourceIp": "203.0.113.0/24"
        }
      }
    }
  ]
}
```

```bash
# Create cross-account role
aws iam create-role \
    --role-name CrossAccountDevOpsRole \
    --assume-role-policy-document file://cross-account-policy.json

# Attach permissions to cross-account role
aws iam attach-role-policy \
    --role-name CrossAccountDevOpsRole \
    --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess
```
___

## IAM Security Monitoring and Auditing

### Access Analyzer
```bash
# Create access analyzer
aws accessanalyzer create-analyzer \
    --analyzer-name DevOps-Access-Analyzer \
    --type ACCOUNT \
    --tags Key=Team,Value=DevOps

# List findings
aws accessanalyzer list-findings \
    --analyzer-arn arn:aws:access-analyzer:us-east-1:123456789012:analyzer/DevOps-Access-Analyzer

# Get finding details
aws accessanalyzer get-finding \
    --analyzer-arn arn:aws:access-analyzer:us-east-1:123456789012:analyzer/DevOps-Access-Analyzer \
    --id finding-id-12345
```

### Credential Reports
```bash
# Generate credential report
aws iam generate-credential-report

# Get credential report
aws iam get-credential-report --output text --query 'Content' | base64 -d > credential-report.csv

# Analyze credential report
awk -F',' '
NR>1 {
    if ($5 == "true" && $11 == "N/A") {
        print "User " $1 " has console access but no MFA: " $11
    }
    if ($9 != "N/A" && $9 != "no_information") {
        days_since_key_used = (systime() - mktime(substr($9,1,4) " " substr($9,6,2) " " substr($9,9,2) " 00 00 00")) / 86400
        if (days_since_key_used > 90) {
            print "User " $1 " has unused access key (last used " int(days_since_key_used) " days ago)"
        }
    }
}' credential-report.csv
```

### CloudTrail Integration
```bash
# Create CloudTrail for IAM monitoring
aws cloudtrail create-trail \
    --name DevOps-IAM-Audit-Trail \
    --s3-bucket-name devops-iam-audit-logs \
    --include-global-service-events \
    --is-multi-region-trail \
    --enable-log-file-validation

# Start logging
aws cloudtrail start-logging --name DevOps-IAM-Audit-Trail

# Query IAM events
aws logs start-query \
    --log-group-name CloudTrail/DevOpsIAMAuditTrail \
    --start-time 1642694400 \
    --end-time 1642780800 \
    --query-string 'fields @timestamp, eventName, sourceIPAddress, userIdentity.type, userIdentity.userName
    | filter eventName like /^(CreateUser|DeleteUser|AttachUserPolicy|DetachUserPolicy|CreateRole|DeleteRole)$/
    | sort @timestamp desc'
```
___

## IAM Automation and Infrastructure as Code

### CloudFormation Templates
```yaml
# iam-resources.yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'DevOps IAM Resources'

Parameters:
  TeamName:
    Type: String
    Default: DevOps
    Description: Name of the DevOps team

Resources:
  DevOpsGroup:
    Type: AWS::IAM::Group
    Properties:
      GroupName: !Sub '${TeamName}-Engineers'
      Path: !Sub '/${TeamName}/'
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/PowerUserAccess
        - arn:aws:iam::aws:policy/IAMReadOnlyAccess

  DevOpsRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: !Sub '${TeamName}-EC2-Role'
      Path: !Sub '/${TeamName}/'
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: ec2.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
        - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

  DevOpsInstanceProfile:
    Type: AWS::IAM::InstanceProfile
    Properties:
      InstanceProfileName: !Sub '${TeamName}-EC2-Profile'
      Path: !Sub '/${TeamName}/'
      Roles:
        - !Ref DevOpsRole

  DevOpsCustomPolicy:
    Type: AWS::IAM::ManagedPolicy
    Properties:
      ManagedPolicyName: !Sub '${TeamName}-Custom-Policy'
      Path: !Sub '/${TeamName}/'
      Description: 'Custom policy for DevOps team'
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Sid: S3Access
            Effect: Allow
            Action:
              - s3:GetObject
              - s3:PutObject
              - s3:DeleteObject
              - s3:ListBucket
            Resource:
              - !Sub 'arn:aws:s3:::${TeamName}-*'
              - !Sub 'arn:aws:s3:::${TeamName}-*/*'
      Groups:
        - !Ref DevOpsGroup

Outputs:
  DevOpsGroupArn:
    Description: 'ARN of the DevOps group'
    Value: !GetAtt DevOpsGroup.Arn
    Export:
      Name: !Sub '${AWS::StackName}-DevOpsGroup-Arn'

  DevOpsRoleArn:
    Description: 'ARN of the DevOps role'
    Value: !GetAtt DevOpsRole.Arn
    Export:
      Name: !Sub '${AWS::StackName}-DevOpsRole-Arn'
```

### Terraform IAM Configuration
```hcl
# iam.tf
variable "team_name" {
  description = "Name of the DevOps team"
  type        = string
  default     = "DevOps"
}

# IAM Group
resource "aws_iam_group" "devops_group" {
  name = "${var.team_name}-Engineers"
  path = "/${var.team_name}/"
}

# IAM Group Policy Attachments
resource "aws_iam_group_policy_attachment" "devops_power_user" {
  group      = aws_iam_group.devops_group.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_group_policy_attachment" "devops_iam_readonly" {
  group      = aws_iam_group.devops_group.name
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}

# IAM Role for EC2
resource "aws_iam_role" "devops_ec2_role" {
  name = "${var.team_name}-EC2-Role"
  path = "/${var.team_name}/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Team        = var.team_name
    Environment = "Production"
  }
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "devops_profile" {
  name = "${var.team_name}-EC2-Profile"
  path = "/${var.team_name}/"
  role = aws_iam_role.devops_ec2_role.name
}

# Custom IAM Policy
resource "aws_iam_policy" "devops_custom_policy" {
  name        = "${var.team_name}-Custom-Policy"
  path        = "/${var.team_name}/"
  description = "Custom policy for ${var.team_name} team"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${lower(var.team_name)}-*",
          "arn:aws:s3:::${lower(var.team_name)}-*/*"
        ]
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/aws/${lower(var.team_name)}/*"
      }
    ]
  })
}

# Attach custom policy to group
resource "aws_iam_group_policy_attachment" "devops_custom_policy" {
  group      = aws_iam_group.devops_group.name
  policy_arn = aws_iam_policy.devops_custom_policy.arn
}

# Outputs
output "devops_group_arn" {
  description = "ARN of the DevOps group"
  value       = aws_iam_group.devops_group.arn
}

output "devops_role_arn" {
  description = "ARN of the DevOps role"
  value       = aws_iam_role.devops_ec2_role.arn
}

output "devops_instance_profile_arn" {
  description = "ARN of the DevOps instance profile"
  value       = aws_iam_instance_profile.devops_profile.arn
}
```

This comprehensive IAM security guide provides DevOps engineers with the knowledge and tools needed to implement robust identity and access management practices in AWS environments, ensuring security while enabling efficient operations.