# IAM Module Verification - Quick Reference

## Quick Commands

### 1. List All IAM Roles
```bash
aws iam list-roles --query "Roles[?contains(RoleName, 'finishline')]" --output table
```

### 2. Get Cluster Role Details
```bash
CLUSTER_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'cluster-role')].RoleName" --output text)
aws iam get-role --role-name $CLUSTER_ROLE
```

### 3. Get NodeGroup Role Details
```bash
NODEGROUP_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'nodegroup-role')].RoleName" --output text)
aws iam get-role --role-name $NODEGROUP_ROLE
```

### 4. Get OIDC Role Details
```bash
OIDC_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'oidc-role')].RoleName" --output text)
aws iam get-role --role-name $OIDC_ROLE
```

### 5. List Cluster Role Policies
```bash
CLUSTER_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'cluster-role')].RoleName" --output text)
aws iam list-attached-role-policies --role-name $CLUSTER_ROLE --output table
```

### 6. List NodeGroup Role Policies
```bash
NODEGROUP_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'nodegroup-role')].RoleName" --output text)
aws iam list-attached-role-policies --role-name $NODEGROUP_ROLE --output table
```

### 7. List OIDC Providers
```bash
aws iam list-open-id-connect-providers
```

### 8. List S3 Policies
```bash
aws iam list-policies --scope Local --query "Policies[?contains(PolicyName, 'oidc-policy')]" --output table
```

### 9. Get Terraform Outputs
```bash
cd /home/ganil/Documents/finishline_infra_app/terraform/envs/dev
terragrunt output
```

### 10. Check Terraform State
```bash
cd /home/ganil/Documents/finishline_infra_app/terraform/envs/dev
terragrunt state list | grep iam
```

---

## Expected Resources

### Roles (3 total)
- [ ] `finishline-infra-development-cluster-role-XXXX`
- [ ] `finishline-infra-development-nodegroup-role-XXXX`
- [ ] `finishline-infra-development-oidc-role-XXXX` (if OIDC enabled)

### Policies (1 total)
- [ ] `finishline-infra-development-oidc-policy-XXXX` (if S3 access configured)

### OIDC Provider (1 total)
- [ ] `arn:aws:iam::ACCOUNT:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLEID` (if OIDC enabled)

---

## Expected Policy Attachments

### Cluster Role Should Have
- [ ] AmazonEKSClusterPolicy
- [ ] AmazonEKSWorkerNodePolicy

### NodeGroup Role Should Have
- [ ] AmazonEKSWorkerNodePolicy
- [ ] AmazonEKS_CNI_Policy
- [ ] AmazonEC2ContainerRegistryReadOnly
- [ ] AmazonEBSCSIDriverPolicy

### OIDC Role Should Have
- [ ] finishline-infra-development-oidc-policy-XXXX (if S3 access configured)

---

## Automated Verification

Run the verification script:
```bash
chmod +x /home/ganil/Documents/finishline_infra_app/verify_iam_module.sh
/home/ganil/Documents/finishline_infra_app/verify_iam_module.sh
```

---

## Troubleshooting

### Roles Not Found
```bash
# Check if Terraform applied successfully
cd /home/ganil/Documents/finishline_infra_app/terraform/envs/dev
terragrunt show

# Check state
terragrunt state list
```

### Policies Not Attached
```bash
# Re-apply Terraform
terragrunt apply

# Check for errors
terragrunt plan
```

### OIDC Provider Not Found
```bash
# Check if OIDC variables are set
terragrunt output oidc_provider_url

# If empty, OIDC may not be configured
```

---

## Key Verification Points

1. **Roles Exist** - All 3 roles should be present in AWS IAM
2. **Policies Attached** - Each role should have correct policies
3. **Trust Relationships** - Roles should have correct assume role policies
4. **Tags Applied** - All resources should have proper tags
5. **Terraform Outputs** - Outputs should match AWS resources
6. **OIDC Provider** - Should exist if OIDC is configured
7. **S3 Policy** - Should exist if S3 access is configured

---

## Common Issues

| Issue | Solution |
|-------|----------|
| Roles not found | Run `terragrunt apply` |
| Policies not attached | Check `terragrunt plan` for errors |
| OIDC not found | Verify `eks_oidc_url` variable is set |
| S3 policy not found | Verify `s3_bucket_arn` variable is set |
| Outputs empty | Run `terragrunt refresh` |

---

## Documentation

- **Full Guide:** `IAM_VERIFICATION_GUIDE.md`
- **Audit Report:** `IAM_COMPREHENSIVE_AUDIT.md`
- **Fixes Applied:** `IAM_FIXES_APPLIED.md`
- **Module Location:** `/terraform/modules/iam/`
