# IAM Module Audit Report

## Summary
**Total Issues Found:** 8  
**Severity:** 7 Critical, 1 Medium  
**Status:** ✅ All Fixed

---

## Issues Found and Fixed

### 1. **Syntax Error: Missing Variable Prefix** ❌ → ✅
**File:** `main.tf` (Line 56)  
**Severity:** Critical

**Problem:**
```hcl
for_each = var_is_eks_nodegroup_role_enabled ? toset([...]) : []
```

**Issue:** Used `var_is_eks_nodegroup_role_enabled` instead of `var.is_eks_nodegroup_role_enabled` (underscore instead of dot)

**Fix:**
```hcl
for_each = var.is_eks_nodegroup_role_enabled ? toset([...]) : toset([])
```

---

### 2. **Missing Variable Definition** ❌ → ✅
**File:** `variables.tf`  
**Severity:** Critical

**Problem:** Variable `is_eks_nodegroup_role_enabled` was referenced but never declared

**Fix:** Added to `variables.tf`:
```hcl
variable "is_eks_nodegroup_role_enabled" {
  description = "A flag to enable or disable EKS nodegroup role creation"
  type        = bool
}
```

---

### 3. **Incorrect Ternary Operator Syntax** ❌ → ✅
**File:** `main.tf` (Line 56)  
**Severity:** Critical

**Problem:**
```hcl
for_each = var.is_eks_nodegroup_role_enabled ? toset([...]) : []
```

**Issue:** Ternary operator returns `[]` (list) but `for_each` requires a set. Inconsistent types.

**Fix:**
```hcl
for_each = var.is_eks_nodegroup_role_enabled ? toset([...]) : toset([])
```

---

### 4. **Invalid Condition Logic in Data Source** ❌ → ✅
**File:** `data.tf` (Line 2)  
**Severity:** Critical

**Problem:**
```hcl
count = var.is_eks_cluster_enabled ? 1 : 0 && var.eks_oidc_url != "" ? 1 : 0
```

**Issue:** Operator precedence error. This evaluates as:
```
(var.is_eks_cluster_enabled ? 1 : 0) && (var.eks_oidc_url != "" ? 1 : 0)
```
Which is incorrect logic.

**Fix:**
```hcl
count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0
```

---

### 5. **Incorrect Policy Document Structure** ❌ → ✅
**File:** `data.tf` (Lines 8-18)  
**Severity:** Critical

**Problem:**
```hcl
statement {
  actions = ["sts:AssumeRoleWithWebIdentity"]
  effect = "Allow" 
}

condition {
  test = "StringEquals"
  variable = "..."
  values = [...]
}

principal {
  identifiers = [...]
  type = "Federated"
}
```

**Issue:** 
- `condition` and `principal` blocks are outside `statement` block
- `principal` block syntax is incorrect (should be inside statement)
- Missing `principals` block (plural)

**Fix:**
```hcl
statement {
  actions = ["sts:AssumeRoleWithWebIdentity"]
  effect  = "Allow"

  principals {
    type        = "Federated"
    identifiers = [aws_iam_openid_connect_provider.eks-oidc-provider[0].arn]
  }

  condition {
    test     = "StringEquals"
    variable = "..."
    values   = [...]
  }
}
```

---

### 6. **Missing OIDC Provider Resource** ❌ → ✅
**File:** `main.tf`  
**Severity:** Critical

**Problem:** Data source referenced `aws_iam_openid_connect_provider.eks-oidc-provider[0]` but the resource was never created

**Fix:** Added resource:
```hcl
resource "aws_iam_openid_connect_provider" "eks-oidc-provider" {
  count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.oidc_thumbprint]
  url             = var.eks_oidc_url

  tags = local.iam_tags
}
```

---

### 7. **Missing OIDC IAM Role Resource** ❌ → ✅
**File:** `main.tf`  
**Severity:** Critical

**Problem:** Data source created assume role policy but no role used it

**Fix:** Added resource:
```hcl
resource "aws_iam_role" "eks_oidc_role" {
  count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0

  name               = "${local.cluster_name}-oidc-role-${random_integer.random_suffix.result}"
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy[0].json

  tags = local.iam_tags
}
```

---

### 8. **Empty Outputs File** ❌ → ✅
**File:** `outputs.tf`  
**Severity:** Medium

**Problem:** File was completely empty, no outputs defined

**Fix:** Added comprehensive outputs:
```hcl
output "eks_cluster_role_arn" { ... }
output "eks_cluster_role_name" { ... }
output "eks_nodegroup_role_arn" { ... }
output "eks_nodegroup_role_name" { ... }
output "oidc_provider_arn" { ... }
output "oidc_provider_url" { ... }
output "oidc_role_arn" { ... }
output "oidc_role_name" { ... }
```

---

### 9. **Missing Variable Definitions** ❌ → ✅
**File:** `variables.tf`  
**Severity:** Critical

**Problem:** Variables referenced in data.tf were not defined:
- `eks_oidc_namespace`
- `eks_oidc_service_account_name`

**Fix:** Added variables:
```hcl
variable "eks_oidc_namespace" {
  description = "The Kubernetes namespace for OIDC service account"
  type        = string
  default     = "kube-system"
}

variable "eks_oidc_service_account_name" {
  description = "The Kubernetes service account name for OIDC"
  type        = string
  default     = "aws-node"
}
```

---

### 10. **Inconsistent Role Creation Logic** ❌ → ✅
**File:** `main.tf` (Line 47)  
**Severity:** Medium

**Problem:** Nodegroup role was created with `is_eks_role_enabled` but policies used `is_eks_nodegroup_role_enabled`

**Fix:** Changed nodegroup role creation to use `is_eks_nodegroup_role_enabled`:
```hcl
resource "aws_iam_role" "eks-nodegroup-role" {
  count = var.is_eks_nodegroup_role_enabled ? 1 : 0
  ...
}
```

---

## Module Structure After Fixes

```
iam/
├── main.tf
│   ├── Random suffix generator
│   ├── EKS Cluster Role
│   ├── EKS Cluster Role Policies
│   ├── EKS NodeGroup Role
│   ├── EKS NodeGroup Role Policies
│   ├── OIDC Provider
│   └── OIDC IAM Role
├── variables.tf
│   ├── Project variables
│   ├── IAM/Cluster variables
│   ├── OIDC variables
│   └── Kubernetes service account variables
├── data.tf
│   └── OIDC assume role policy document
├── locals.tf
│   ├── Cluster name
│   ├── Common tags
│   └── IAM tags
└── outputs.tf
    ├── Cluster role outputs
    ├── NodeGroup role outputs
    ├── OIDC provider outputs
    └── OIDC role outputs
```

---

## Variables Reference

### Required Variables
| Variable | Type | Description |
|----------|------|-------------|
| `project_name` | string | Project identifier |
| `environment` | string | Environment name |
| `cluster_name` | string | EKS cluster name |
| `is_eks_role_enabled` | bool | Enable EKS cluster role |
| `is_eks_nodegroup_role_enabled` | bool | Enable nodegroup role |
| `is_role_enabled` | bool | Enable IAM role creation |

### Optional Variables
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `eks_oidc_url` | string | "" | OIDC provider URL |
| `oidc_thumbprint` | string | "" | OIDC thumbprint |
| `eks_oidc_namespace` | string | "kube-system" | Kubernetes namespace |
| `eks_oidc_service_account_name` | string | "aws-node" | Service account name |

---

## Outputs Available

- `eks_cluster_role_arn` - EKS cluster role ARN
- `eks_cluster_role_name` - EKS cluster role name
- `eks_nodegroup_role_arn` - NodeGroup role ARN
- `eks_nodegroup_role_name` - NodeGroup role name
- `oidc_provider_arn` - OIDC provider ARN
- `oidc_provider_url` - OIDC provider URL
- `oidc_role_arn` - OIDC role ARN
- `oidc_role_name` - OIDC role name

---

## Testing Recommendations

1. **Validate Terraform:**
   ```bash
   terraform validate
   ```

2. **Plan with IAM enabled:**
   ```bash
   terraform plan -var="is_eks_role_enabled=true" \
                  -var="is_eks_nodegroup_role_enabled=true"
   ```

3. **Verify role policies:**
   ```bash
   aws iam list-attached-role-policies --role-name <role-name>
   ```

4. **Check OIDC provider:**
   ```bash
   aws iam list-open-id-connect-providers
   ```

---

## Security Notes

1. **Role Separation:** Cluster role and nodegroup role are properly separated
2. **OIDC Integration:** Supports IRSA (IAM Roles for Service Accounts)
3. **Least Privilege:** Uses AWS managed policies with specific permissions
4. **Tagging:** All resources properly tagged for tracking and cost allocation

---

## Next Steps

1. Update dev environment terragrunt.hcl with IAM variables
2. Run `terragrunt plan` to validate
3. Run `terragrunt apply` to create IAM roles
4. Verify roles in AWS IAM console
