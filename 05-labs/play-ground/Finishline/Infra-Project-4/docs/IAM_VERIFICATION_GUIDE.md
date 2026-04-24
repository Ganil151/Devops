# IAM Module Verification Guide

## Overview
This guide provides step-by-step instructions to verify that the IAM module has been properly applied to your AWS infrastructure.

---

## 1. Terraform State Verification

### Check Terraform State File
```bash
# Navigate to the dev environment
cd /home/ganil/Documents/finishline_infra_app/terraform/envs/dev

# Show all resources in state
terragrunt state list

# Expected output should include:
# module.key_pair.aws_key_pair.finishline_public_key
# module.key_pair.local_file.finishline_private_key
# aws_vpc.finishline_vpc
# aws_iam_role.eks-cluster-role[0]
# aws_iam_role.eks-nodegroup-role[0]
# aws_iam_openid_connect_provider.eks-oidc-provider[0]
# aws_iam_role.eks_oidc_role[0]
# aws_iam_policy.eks_oidc_policy[0]
```

### Show Specific IAM Resources
```bash
# Show all IAM roles
terragrunt state list | grep iam_role

# Show all IAM policies
terragrunt state list | grep iam_policy

# Show all IAM providers
terragrunt state list | grep iam_openid
```

### Inspect Resource Details
```bash
# Get details of cluster role
terragrunt state show 'aws_iam_role.eks-cluster-role[0]'

# Get details of nodegroup role
terragrunt state show 'aws_iam_role.eks-nodegroup-role[0]'

# Get details of OIDC role
terragrunt state show 'aws_iam_role.eks_oidc_role[0]'

# Get details of OIDC provider
terragrunt state show 'aws_iam_openid_connect_provider.eks-oidc-provider[0]'

# Get details of S3 policy
terragrunt state show 'aws_iam_policy.eks_oidc_policy[0]'
```

---

## 2. AWS CLI Verification

### List All Created Roles
```bash
# List all roles with 'finishline' in the name
aws iam list-roles --query "Roles[?contains(RoleName, 'finishline')]" --output table

# Expected output:
# RoleName                                    | Arn
# finishline-infra-development-cluster-role-XXXX | arn:aws:iam::ACCOUNT:role/finishline-infra-development-cluster-role-XXXX
# finishline-infra-development-nodegroup-role-XXXX | arn:aws:iam::ACCOUNT:role/finishline-infra-development-nodegroup-role-XXXX
# finishline-infra-development-oidc-role-XXXX | arn:aws:iam::ACCOUNT:role/finishline-infra-development-oidc-role-XXXX
```

### Verify Cluster Role
```bash
# Get cluster role details
CLUSTER_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'cluster-role')].RoleName" --output text)

# Show role details
aws iam get-role --role-name $CLUSTER_ROLE

# Show assume role policy
aws iam get-role-policy --role-name $CLUSTER_ROLE --policy-name AssumeRolePolicy

# List attached policies
aws iam list-attached-role-policies --role-name $CLUSTER_ROLE

# Expected policies:
# - AmazonEKSClusterPolicy
# - AmazonEKSWorkerNodePolicy
```

### Verify NodeGroup Role
```bash
# Get nodegroup role details
NODEGROUP_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'nodegroup-role')].RoleName" --output text)

# Show role details
aws iam get-role --role-name $NODEGROUP_ROLE

# List attached policies
aws iam list-attached-role-policies --role-name $NODEGROUP_ROLE

# Expected policies:
# - AmazonEKSWorkerNodePolicy
# - AmazonEKS_CNI_Policy
# - AmazonEC2ContainerRegistryReadOnly
# - AmazonEBSCSIDriverPolicy
```

### Verify OIDC Provider
```bash
# List OIDC providers
aws iam list-open-id-connect-providers

# Expected output:
# {
#   "OpenIDConnectProviderList": [
#     {
#       "Arn": "arn:aws:iam::ACCOUNT:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLEID"
#     }
#   ]
# }

# Get OIDC provider details
OIDC_ARN=$(aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[0].Arn" --output text)
aws iam get-open-id-connect-provider --open-id-connect-provider-arn $OIDC_ARN
```

### Verify OIDC Role
```bash
# Get OIDC role details
OIDC_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'oidc-role')].RoleName" --output text)

# Show role details
aws iam get-role --role-name $OIDC_ROLE

# Show assume role policy
aws iam get-role --role-name $OIDC_ROLE --query 'Role.AssumeRolePolicyDocument'

# List attached policies
aws iam list-attached-role-policies --role-name $OIDC_ROLE
```

### Verify S3 Policy
```bash
# List all policies with 'finishline' in the name
aws iam list-policies --scope Local --query "Policies[?contains(PolicyName, 'finishline')]" --output table

# Get S3 policy details
S3_POLICY=$(aws iam list-policies --scope Local --query "Policies[?contains(PolicyName, 'oidc-policy')].Arn" --output text)

# Show policy details
aws iam get-policy --policy-arn $S3_POLICY

# Show policy document
aws iam get-policy-version --policy-arn $S3_POLICY --version-id $(aws iam get-policy --policy-arn $S3_POLICY --query 'Policy.DefaultVersionId' --output text)
```

---

## 3. Terraform Output Verification

### Get Module Outputs
```bash
# Navigate to dev environment
cd /home/ganil/Documents/finishline_infra_app/terraform/envs/dev

# Show all outputs
terragrunt output

# Show specific outputs
terragrunt output eks_cluster_role_arn
terragrunt output eks_nodegroup_role_arn
terragrunt output oidc_provider_arn
terragrunt output oidc_role_arn
terragrunt output oidc_s3_policy_arn
```

### Expected Outputs
```
eks_cluster_role_arn = "arn:aws:iam::ACCOUNT:role/finishline-infra-development-cluster-role-XXXX"
eks_cluster_role_name = "finishline-infra-development-cluster-role-XXXX"
eks_nodegroup_role_arn = "arn:aws:iam::ACCOUNT:role/finishline-infra-development-nodegroup-role-XXXX"
eks_nodegroup_role_name = "finishline-infra-development-nodegroup-role-XXXX"
oidc_provider_arn = "arn:aws:iam::ACCOUNT:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLEID"
oidc_provider_url = "https://oidc.eks.us-east-1.amazonaws.com/id/EXAMPLEID"
oidc_role_arn = "arn:aws:iam::ACCOUNT:role/finishline-infra-development-oidc-role-XXXX"
oidc_role_name = "finishline-infra-development-oidc-role-XXXX"
oidc_s3_policy_arn = "arn:aws:iam::ACCOUNT:policy/finishline-infra-development-oidc-policy-XXXX"
oidc_s3_policy_name = "finishline-infra-development-oidc-policy-XXXX"
```

---

## 4. Policy Attachment Verification

### Verify Cluster Role Policies
```bash
CLUSTER_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'cluster-role')].RoleName" --output text)

# List attached policies
aws iam list-attached-role-policies --role-name $CLUSTER_ROLE --output table

# Verify each policy
aws iam get-attached-role-policy --role-name $CLUSTER_ROLE --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam get-attached-role-policy --role-name $CLUSTER_ROLE --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
```

### Verify NodeGroup Role Policies
```bash
NODEGROUP_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'nodegroup-role')].RoleName" --output text)

# List attached policies
aws iam list-attached-role-policies --role-name $NODEGROUP_ROLE --output table

# Verify each policy
aws iam get-attached-role-policy --role-name $NODEGROUP_ROLE --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam get-attached-role-policy --role-name $NODEGROUP_ROLE --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
aws iam get-attached-role-policy --role-name $NODEGROUP_ROLE --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
aws iam get-attached-role-policy --role-name $NODEGROUP_ROLE --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
```

### Verify S3 Policy Attachment
```bash
OIDC_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'oidc-role')].RoleName" --output text)

# List attached policies
aws iam list-attached-role-policies --role-name $OIDC_ROLE --output table

# Get S3 policy ARN
S3_POLICY_ARN=$(aws iam list-policies --scope Local --query "Policies[?contains(PolicyName, 'oidc-policy')].Arn" --output text)

# Verify attachment
aws iam get-attached-role-policy --role-name $OIDC_ROLE --policy-arn $S3_POLICY_ARN
```

---

## 5. Assume Role Policy Verification

### Check Cluster Role Trust Relationship
```bash
CLUSTER_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'cluster-role')].RoleName" --output text)

# Get assume role policy
aws iam get-role --role-name $CLUSTER_ROLE --query 'Role.AssumeRolePolicyDocument' | jq .

# Should show:
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "eks.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
```

### Check NodeGroup Role Trust Relationship
```bash
NODEGROUP_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'nodegroup-role')].RoleName" --output text)

# Get assume role policy
aws iam get-role --role-name $NODEGROUP_ROLE --query 'Role.AssumeRolePolicyDocument' | jq .

# Should show:
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
```

### Check OIDC Role Trust Relationship
```bash
OIDC_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'oidc-role')].RoleName" --output text)

# Get assume role policy
aws iam get-role --role-name $OIDC_ROLE --query 'Role.AssumeRolePolicyDocument' | jq .

# Should show Federated principal with OIDC provider ARN
# and condition for specific service account
```

---

## 6. S3 Policy Content Verification

### View S3 Policy Document
```bash
# Get S3 policy ARN
S3_POLICY_ARN=$(aws iam list-policies --scope Local --query "Policies[?contains(PolicyName, 'oidc-policy')].Arn" --output text)

# Get policy version
VERSION=$(aws iam get-policy --policy-arn $S3_POLICY_ARN --query 'Policy.DefaultVersionId' --output text)

# Get policy document
aws iam get-policy-version --policy-arn $S3_POLICY_ARN --version-id $VERSION --query 'PolicyVersion.Document' | jq .

# Should show S3 permissions based on s3_access_type variable
```

---

## 7. Tags Verification

### Check Role Tags
```bash
# Get cluster role
CLUSTER_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'cluster-role')].RoleName" --output text)

# List tags
aws iam list-role-tags --role-name $CLUSTER_ROLE

# Expected tags:
# - Cluster: finishline-eks-cluster
# - Environment: development
# - Project: finishline-infra
# - ManagedBy: true
# - Terraform: true
```

### Check Policy Tags
```bash
# Get S3 policy ARN
S3_POLICY_ARN=$(aws iam list-policies --scope Local --query "Policies[?contains(PolicyName, 'oidc-policy')].Arn" --output text)

# List tags
aws iam list-policy-tags --policy-arn $S3_POLICY_ARN

# Expected tags:
# - Cluster: finishline-eks-cluster
# - Environment: development
# - Project: finishline-infra
# - ManagedBy: true
# - Terraform: true
```

---

## 8. Comprehensive Verification Script

Create a verification script:

```bash
#!/bin/bash

echo "=========================================="
echo "IAM Module Verification Script"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if resource exists
check_resource() {
    local resource_name=$1
    local resource_type=$2
    
    case $resource_type in
        "role")
            if aws iam get-role --role-name "$resource_name" &>/dev/null; then
                echo -e "${GREEN}✓${NC} Role found: $resource_name"
                return 0
            else
                echo -e "${RED}✗${NC} Role NOT found: $resource_name"
                return 1
            fi
            ;;
        "policy")
            if aws iam get-policy --policy-arn "$resource_name" &>/dev/null; then
                echo -e "${GREEN}✓${NC} Policy found: $resource_name"
                return 0
            else
                echo -e "${RED}✗${NC} Policy NOT found: $resource_name"
                return 1
            fi
            ;;
        "oidc")
            if aws iam get-open-id-connect-provider --open-id-connect-provider-arn "$resource_name" &>/dev/null; then
                echo -e "${GREEN}✓${NC} OIDC Provider found: $resource_name"
                return 0
            else
                echo -e "${RED}✗${NC} OIDC Provider NOT found: $resource_name"
                return 1
            fi
            ;;
    esac
}

echo ""
echo "1. Checking IAM Roles..."
echo "========================"

CLUSTER_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'cluster-role')].RoleName" --output text)
NODEGROUP_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'nodegroup-role')].RoleName" --output text)
OIDC_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'oidc-role')].RoleName" --output text)

check_resource "$CLUSTER_ROLE" "role"
check_resource "$NODEGROUP_ROLE" "role"
check_resource "$OIDC_ROLE" "role"

echo ""
echo "2. Checking OIDC Provider..."
echo "============================="

OIDC_ARN=$(aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[0].Arn" --output text)
if [ "$OIDC_ARN" != "None" ] && [ -n "$OIDC_ARN" ]; then
    check_resource "$OIDC_ARN" "oidc"
else
    echo -e "${YELLOW}⚠${NC} No OIDC Provider found (may be expected if not configured)"
fi

echo ""
echo "3. Checking IAM Policies..."
echo "============================"

S3_POLICY=$(aws iam list-policies --scope Local --query "Policies[?contains(PolicyName, 'oidc-policy')].Arn" --output text)
if [ "$S3_POLICY" != "None" ] && [ -n "$S3_POLICY" ]; then
    check_resource "$S3_POLICY" "policy"
else
    echo -e "${YELLOW}⚠${NC} No S3 Policy found (may be expected if not configured)"
fi

echo ""
echo "4. Checking Policy Attachments..."
echo "=================================="

if [ -n "$CLUSTER_ROLE" ]; then
    CLUSTER_POLICIES=$(aws iam list-attached-role-policies --role-name "$CLUSTER_ROLE" --query "AttachedPolicies[].PolicyName" --output text)
    echo "Cluster Role Policies: $CLUSTER_POLICIES"
fi

if [ -n "$NODEGROUP_ROLE" ]; then
    NODEGROUP_POLICIES=$(aws iam list-attached-role-policies --role-name "$NODEGROUP_ROLE" --query "AttachedPolicies[].PolicyName" --output text)
    echo "NodeGroup Role Policies: $NODEGROUP_POLICIES"
fi

echo ""
echo "5. Checking Terraform Outputs..."
echo "================================="

cd /home/ganil/Documents/finishline_infra_app/terraform/envs/dev

if terragrunt output eks_cluster_role_arn &>/dev/null; then
    echo -e "${GREEN}✓${NC} Terraform outputs available"
    echo "Cluster Role ARN: $(terragrunt output -raw eks_cluster_role_arn)"
    echo "NodeGroup Role ARN: $(terragrunt output -raw eks_nodegroup_role_arn)"
else
    echo -e "${RED}✗${NC} Terraform outputs NOT available"
fi

echo ""
echo "=========================================="
echo "Verification Complete"
echo "=========================================="
```

Save as `verify_iam.sh` and run:
```bash
chmod +x verify_iam.sh
./verify_iam.sh
```

---

## 9. Troubleshooting Verification Failures

### If Roles Not Found
```bash
# Check if any roles exist
aws iam list-roles --query "Roles[].RoleName" --output table

# Check Terraform state
cd /home/ganil/Documents/finishline_infra_app/terraform/envs/dev
terragrunt state list | grep iam_role

# Check for errors
terragrunt show
```

### If Policies Not Attached
```bash
# List all attached policies for a role
aws iam list-attached-role-policies --role-name <role-name>

# Check policy attachment status
aws iam get-attached-role-policy --role-name <role-name> --policy-arn <policy-arn>
```

### If OIDC Provider Not Found
```bash
# List all OIDC providers
aws iam list-open-id-connect-providers

# Check if OIDC variables were provided
cd /home/ganil/Documents/finishline_infra_app/terraform/envs/dev
terragrunt output oidc_provider_url
```

---

## 10. Quick Verification Checklist

- [ ] Cluster role exists and has correct name
- [ ] NodeGroup role exists and has correct name
- [ ] OIDC role exists (if OIDC enabled)
- [ ] OIDC provider exists (if OIDC enabled)
- [ ] S3 policy exists (if S3 access configured)
- [ ] Cluster role has AmazonEKSClusterPolicy attached
- [ ] Cluster role has AmazonEKSWorkerNodePolicy attached
- [ ] NodeGroup role has AmazonEKSWorkerNodePolicy attached
- [ ] NodeGroup role has AmazonEKS_CNI_Policy attached
- [ ] NodeGroup role has AmazonEC2ContainerRegistryReadOnly attached
- [ ] NodeGroup role has AmazonEBSCSIDriverPolicy attached
- [ ] OIDC role has S3 policy attached (if configured)
- [ ] All roles have correct assume role policies
- [ ] All resources have proper tags
- [ ] Terraform outputs match AWS resources

---

## Summary

To verify IAM module deployment:

1. **Check Terraform State** - Verify resources are in state
2. **List AWS Resources** - Confirm roles/policies exist in AWS
3. **Verify Attachments** - Check policies are attached to roles
4. **Validate Policies** - Review policy documents and permissions
5. **Check Tags** - Verify resource tagging
6. **Review Outputs** - Confirm Terraform outputs match resources
7. **Test Trust Relationships** - Verify assume role policies
8. **Run Verification Script** - Use automated checks

All verification commands are provided above for comprehensive validation.
