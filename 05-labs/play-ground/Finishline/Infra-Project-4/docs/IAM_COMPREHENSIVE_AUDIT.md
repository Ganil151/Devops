# IAM Module - Comprehensive Audit Report

## Executive Summary

**Total Issues Found:** 12  
**Critical Issues:** 8  
**Medium Issues:** 3  
**Low Issues:** 1  
**Status:** ⚠️ Requires Immediate Fixes

---

## 🔴 CRITICAL ISSUES (8)

### 1. Duplicate OIDC Role Resource
**File:** `main.tf` (Lines 95-103)  
**Severity:** CRITICAL  
**Type:** Logic Error / Resource Duplication

**Problem:**
```hcl
resource "aws_iam_role" "eks_oidc_role" {
  count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0
  name  = "${local.cluster_name}-oidc-role-${random_integer.random_suffix.result}"
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy[0].json
  tags = local.iam_tags
}

resource "aws_iam_role" "eks_oidc" {  # DUPLICATE!
  count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy[0].json
  name = "${local.cluster_name}-oidc-role-${random_integer.random_suffix.result}"
  tags = local.iam_tags
}
```

**Impact:** 
- Two identical roles will be created
- Terraform will fail or create duplicate resources
- Resource naming conflicts

**Fix:** Remove the duplicate `aws_iam_role.eks_oidc` resource (lines 105-111)

---

### 2. Syntax Error: Missing Quotes in S3 Policy
**File:** `main.tf` (Line 135)  
**Severity:** CRITICAL  
**Type:** Syntax Error

**Problem:**
```hcl
Resource = var.s3_prefix != "" ? "${var.s3_bucket_arn}/${var.s3_prefix}*" : ${var.s3_bucket_arn}
                                                                              ↑ Missing quotes
```

**Correct Syntax:**
```hcl
Resource = var.s3_prefix != "" ? "${var.s3_bucket_arn}/${var.s3_prefix}*" : var.s3_bucket_arn
```

**Impact:** Terraform will fail to parse the file

---

### 3. Incorrect S3 Policy Action Syntax
**File:** `main.tf` (Line 130)  
**Severity:** CRITICAL  
**Type:** Syntax Error

**Problem:**
```hcl
Action = var.s3_access_type == "read" ? ["s3:GetObject"] : var.s3_access_type == "write" ? ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"] : ["s3:GetObject", "s3:PutObject"]
```

**Issue:** 
- Ternary operators are not properly nested
- Difficult to read and maintain
- Potential logic error

**Better Approach:**
```hcl
Action = (
  var.s3_access_type == "read" ? ["s3:GetObject"] :
  var.s3_access_type == "write" ? ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"] :
  ["s3:GetObject", "s3:PutObject"]
)
```

---

### 4. Duplicate S3 Policy Statement
**File:** `main.tf` (Lines 122-127 and 128-136)  
**Severity:** CRITICAL  
**Type:** Logic Error

**Problem:**
```hcl
Statement = [
  {
    Effect = "Allow"
    Action = ["s3:GetObject"]
    Resource = var.s3_bucket_arn
  },
  {
    Sid = "AllowObjectAccess"
    Action = var.s3_access_type == "read" ? ... : ...
    Effect = "Allow"
    Resource = var.s3_prefix != "" ? ... : ...
  }
]
```

**Issue:** 
- First statement is redundant
- Second statement already handles all cases
- Conflicting permissions

**Fix:** Remove the first statement (lines 122-127)

---

### 5. Missing S3 Prefix Variable
**File:** `variables.tf`  
**Severity:** CRITICAL  
**Type:** Missing Variable

**Problem:** Variable `s3_prefix` is used in `main.tf` (line 135) but not defined in `variables.tf`

**Fix:** Add variable:
```hcl
variable "s3_prefix" {
  description = "The prefix for S3 bucket objects"
  type        = string
  default     = ""
}
```

---

### 6. Incorrect Resource Reference in Policy Attachment
**File:** `main.tf` (Line 145)  
**Severity:** CRITICAL  
**Type:** Logic Error

**Problem:**
```hcl
resource "aws_iam_role_policy_attachment" "eks-oidc-policy-attachment" {
  count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" && var.s3_bucket_arn != "" ? 1 : 0
  policy_arn = aws_iam_policy.eks_oidc_policy[0].arn
  role       = aws_iam_role.eks_oidc[0].name  # References duplicate role!
}
```

**Issue:** References `aws_iam_role.eks_oidc` which is a duplicate resource

**Fix:** Should reference `aws_iam_role.eks_oidc_role[0].name`

---

### 7. Inconsistent Indentation in OIDC Role
**File:** `main.tf` (Lines 105-111)  
**Severity:** CRITICAL  
**Type:** Syntax/Style Error

**Problem:**
```hcl
resource "aws_iam_role" "eks_oidc" {
 count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0  # Wrong indentation
 assume_role_policy = ...  # Wrong indentation
 name = ...  # Wrong indentation
 tags = ...  # Wrong indentation
}
```

**Impact:** While Terraform may parse it, it violates HCL style conventions

---

### 8. Missing Condition Block in S3 Policy
**File:** `main.tf` (Line 128-136)  
**Severity:** CRITICAL  
**Type:** Logic Error

**Problem:** S3 policy statement is missing the `Condition` block that should restrict access to specific prefixes

**Current:**
```hcl
{
  Sid = "AllowObjectAccess"
  Action = [...]
  Effect = "Allow"
  Resource = var.s3_prefix != "" ? "${var.s3_bucket_arn}/${var.s3_prefix}*" : var.s3_bucket_arn
}
```

**Should Include:**
```hcl
{
  Sid = "AllowObjectAccess"
  Action = [...]
  Effect = "Allow"
  Resource = "${var.s3_bucket_arn}/*"
  Condition = {
    StringLike = {
      "s3:prefix" = var.s3_prefix != "" ? "${var.s3_prefix}*" : "*"
    }
  }
}
```

---

## 🟡 MEDIUM ISSUES (3)

### 9. Inconsistent Variable Naming
**File:** `variables.tf` (Line 88)  
**Severity:** MEDIUM  
**Type:** Style/Naming Convention

**Problem:**
```hcl
variable  "s3_access_type" {  # Extra space before variable name
  description = "The type of access to S3 bucket for OIDC"
  type        = string
  default     = "read"
}
```

**Fix:** Remove extra space:
```hcl
variable "s3_access_type" {
```

---

### 10. Missing S3 Bucket ARN Validation
**File:** `variables.tf`  
**Severity:** MEDIUM  
**Type:** Missing Validation

**Problem:** `s3_bucket_arn` variable has no validation to ensure it's a valid ARN format

**Fix:** Add validation:
```hcl
variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for OIDC"
  type        = string
  default     = ""

  validation {
    condition     = var.s3_bucket_arn == "" || can(regex("^arn:aws:s3:::[a-z0-9-]+$", var.s3_bucket_arn))
    error_message = "S3 bucket ARN must be empty or a valid ARN format (arn:aws:s3:::bucket-name)"
  }
}
```

---

### 11. Missing S3 Access Type Validation
**File:** `variables.tf`  
**Severity:** MEDIUM  
**Type:** Missing Validation

**Problem:** `s3_access_type` variable has no validation for allowed values

**Fix:** Add validation:
```hcl
variable "s3_access_type" {
  description = "The type of access to S3 bucket for OIDC"
  type        = string
  default     = "read"

  validation {
    condition     = contains(["read", "write", "readwrite"], var.s3_access_type)
    error_message = "S3 access type must be 'read', 'write', or 'readwrite'"
  }
}
```

---

## 🟢 LOW ISSUES (1)

### 12. Missing Output for S3 Policy
**File:** `outputs.tf`  
**Severity:** LOW  
**Type:** Missing Documentation

**Problem:** S3 policy ARN is not exported as output

**Fix:** Add output:
```hcl
output "oidc_s3_policy_arn" {
  description = "ARN of the OIDC S3 policy"
  value       = try(aws_iam_policy.eks_oidc_policy[0].arn, "")
}
```

---

## 📋 Summary Table

| Issue # | File | Line | Severity | Type | Status |
|---------|------|------|----------|------|--------|
| 1 | main.tf | 95-111 | CRITICAL | Duplicate Resource | ❌ Not Fixed |
| 2 | main.tf | 135 | CRITICAL | Syntax Error | ❌ Not Fixed |
| 3 | main.tf | 130 | CRITICAL | Syntax Error | ❌ Not Fixed |
| 4 | main.tf | 122-136 | CRITICAL | Logic Error | ❌ Not Fixed |
| 5 | variables.tf | - | CRITICAL | Missing Variable | ❌ Not Fixed |
| 6 | main.tf | 145 | CRITICAL | Logic Error | ❌ Not Fixed |
| 7 | main.tf | 105-111 | CRITICAL | Syntax Error | ❌ Not Fixed |
| 8 | main.tf | 128-136 | CRITICAL | Logic Error | ❌ Not Fixed |
| 9 | variables.tf | 88 | MEDIUM | Style Error | ❌ Not Fixed |
| 10 | variables.tf | - | MEDIUM | Missing Validation | ❌ Not Fixed |
| 11 | variables.tf | - | MEDIUM | Missing Validation | ❌ Not Fixed |
| 12 | outputs.tf | - | LOW | Missing Output | ❌ Not Fixed |

---

## 🔧 Recommended Fixes (Priority Order)

### Priority 1: Critical Syntax Errors (Must Fix)
1. Remove duplicate `aws_iam_role.eks_oidc` resource
2. Fix missing quotes in S3 policy Resource line
3. Add missing `s3_prefix` variable
4. Fix policy attachment to reference correct role

### Priority 2: Logic Errors (Must Fix)
1. Remove duplicate S3 policy statement
2. Simplify S3 access type ternary operator
3. Add proper S3 policy conditions

### Priority 3: Validation & Documentation (Should Fix)
1. Add S3 bucket ARN validation
2. Add S3 access type validation
3. Add S3 policy output
4. Fix variable naming style

---

## 🚨 Impact Assessment

**Current State:** Module will FAIL to deploy

**Blocking Issues:**
- Syntax error on line 135 (missing quotes)
- Duplicate resource definition
- Missing variable definition

**Deployment Status:** ❌ NOT READY

---

## 📝 Files Requiring Changes

1. **main.tf** - 6 critical fixes needed
2. **variables.tf** - 4 fixes needed (1 critical, 3 medium)
3. **outputs.tf** - 1 low priority addition

---

## ✅ Next Steps

1. Apply all critical fixes immediately
2. Add missing variables
3. Add validation rules
4. Test with `terraform validate`
5. Run `terraform plan` to verify
6. Update documentation

---

## 📚 Related Documentation

- AWS IAM Policy Best Practices
- Terraform HCL Style Guide
- S3 Bucket Policy Examples
- OIDC Provider Configuration
