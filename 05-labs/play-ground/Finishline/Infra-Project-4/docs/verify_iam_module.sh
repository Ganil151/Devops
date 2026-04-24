#!/bin/bash

################################################################################
# IAM Module Verification Script
# Purpose: Verify that the IAM module has been properly applied to AWS
# Usage: ./verify_iam_module.sh
################################################################################

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Functions
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Main verification
main() {
    print_header "IAM Module Verification"
    
    # Check AWS CLI
    print_header "1. Checking Prerequisites"
    
    if command -v aws &> /dev/null; then
        print_success "AWS CLI is installed"
    else
        print_error "AWS CLI is not installed"
        exit 1
    fi
    
    if command -v jq &> /dev/null; then
        print_success "jq is installed"
    else
        print_warning "jq is not installed (optional, for JSON parsing)"
    fi
    
    # Check AWS credentials
    if aws sts get-caller-identity &> /dev/null; then
        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
        print_success "AWS credentials are configured (Account: $ACCOUNT_ID)"
    else
        print_error "AWS credentials are not configured"
        exit 1
    fi
    
    # Check Terraform/Terragrunt
    print_header "2. Checking Terraform State"
    
    cd /home/ganil/Documents/finishline_infra_app/terraform/envs/dev 2>/dev/null || {
        print_error "Cannot access dev environment directory"
        exit 1
    }
    
    if command -v terragrunt &> /dev/null; then
        print_success "Terragrunt is installed"
    else
        print_warning "Terragrunt is not installed"
    fi
    
    # Check IAM Roles
    print_header "3. Verifying IAM Roles"
    
    CLUSTER_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'cluster-role')].RoleName" --output text 2>/dev/null || echo "")
    NODEGROUP_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'nodegroup-role')].RoleName" --output text 2>/dev/null || echo "")
    OIDC_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'oidc-role')].RoleName" --output text 2>/dev/null || echo "")
    
    if [ -n "$CLUSTER_ROLE" ] && [ "$CLUSTER_ROLE" != "None" ]; then
        print_success "Cluster Role found: $CLUSTER_ROLE"
    else
        print_error "Cluster Role NOT found"
    fi
    
    if [ -n "$NODEGROUP_ROLE" ] && [ "$NODEGROUP_ROLE" != "None" ]; then
        print_success "NodeGroup Role found: $NODEGROUP_ROLE"
    else
        print_error "NodeGroup Role NOT found"
    fi
    
    if [ -n "$OIDC_ROLE" ] && [ "$OIDC_ROLE" != "None" ]; then
        print_success "OIDC Role found: $OIDC_ROLE"
    else
        print_warning "OIDC Role NOT found (may be expected if OIDC not configured)"
    fi
    
    # Check Policy Attachments
    print_header "4. Verifying Policy Attachments"
    
    if [ -n "$CLUSTER_ROLE" ] && [ "$CLUSTER_ROLE" != "None" ]; then
        CLUSTER_POLICIES=$(aws iam list-attached-role-policies --role-name "$CLUSTER_ROLE" --query "AttachedPolicies[].PolicyName" --output text)
        
        if echo "$CLUSTER_POLICIES" | grep -q "AmazonEKSClusterPolicy"; then
            print_success "Cluster Role has AmazonEKSClusterPolicy"
        else
            print_error "Cluster Role missing AmazonEKSClusterPolicy"
        fi
        
        if echo "$CLUSTER_POLICIES" | grep -q "AmazonEKSWorkerNodePolicy"; then
            print_success "Cluster Role has AmazonEKSWorkerNodePolicy"
        else
            print_error "Cluster Role missing AmazonEKSWorkerNodePolicy"
        fi
    fi
    
    if [ -n "$NODEGROUP_ROLE" ] && [ "$NODEGROUP_ROLE" != "None" ]; then
        NODEGROUP_POLICIES=$(aws iam list-attached-role-policies --role-name "$NODEGROUP_ROLE" --query "AttachedPolicies[].PolicyName" --output text)
        
        if echo "$NODEGROUP_POLICIES" | grep -q "AmazonEKSWorkerNodePolicy"; then
            print_success "NodeGroup Role has AmazonEKSWorkerNodePolicy"
        else
            print_error "NodeGroup Role missing AmazonEKSWorkerNodePolicy"
        fi
        
        if echo "$NODEGROUP_POLICIES" | grep -q "AmazonEKS_CNI_Policy"; then
            print_success "NodeGroup Role has AmazonEKS_CNI_Policy"
        else
            print_error "NodeGroup Role missing AmazonEKS_CNI_Policy"
        fi
        
        if echo "$NODEGROUP_POLICIES" | grep -q "AmazonEC2ContainerRegistryReadOnly"; then
            print_success "NodeGroup Role has AmazonEC2ContainerRegistryReadOnly"
        else
            print_error "NodeGroup Role missing AmazonEC2ContainerRegistryReadOnly"
        fi
        
        if echo "$NODEGROUP_POLICIES" | grep -q "AmazonEBSCSIDriverPolicy"; then
            print_success "NodeGroup Role has AmazonEBSCSIDriverPolicy"
        else
            print_error "NodeGroup Role missing AmazonEBSCSIDriverPolicy"
        fi
    fi
    
    # Check OIDC Provider
    print_header "5. Verifying OIDC Provider"
    
    OIDC_PROVIDERS=$(aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[].Arn" --output text 2>/dev/null || echo "")
    
    if [ -n "$OIDC_PROVIDERS" ] && [ "$OIDC_PROVIDERS" != "None" ]; then
        print_success "OIDC Provider found: $OIDC_PROVIDERS"
    else
        print_warning "OIDC Provider NOT found (may be expected if OIDC not configured)"
    fi
    
    # Check S3 Policy
    print_header "6. Verifying S3 Policy"
    
    S3_POLICY=$(aws iam list-policies --scope Local --query "Policies[?contains(PolicyName, 'oidc-policy')].Arn" --output text 2>/dev/null || echo "")
    
    if [ -n "$S3_POLICY" ] && [ "$S3_POLICY" != "None" ]; then
        print_success "S3 Policy found: $S3_POLICY"
        
        if [ -n "$OIDC_ROLE" ] && [ "$OIDC_ROLE" != "None" ]; then
            OIDC_POLICIES=$(aws iam list-attached-role-policies --role-name "$OIDC_ROLE" --query "AttachedPolicies[].PolicyName" --output text)
            
            if echo "$OIDC_POLICIES" | grep -q "oidc-policy"; then
                print_success "S3 Policy is attached to OIDC Role"
            else
                print_error "S3 Policy is NOT attached to OIDC Role"
            fi
        fi
    else
        print_warning "S3 Policy NOT found (may be expected if S3 access not configured)"
    fi
    
    # Check Terraform Outputs
    print_header "7. Verifying Terraform Outputs"
    
    if terragrunt output eks_cluster_role_arn &>/dev/null; then
        CLUSTER_ARN=$(terragrunt output -raw eks_cluster_role_arn 2>/dev/null || echo "")
        if [ -n "$CLUSTER_ARN" ]; then
            print_success "Terraform output eks_cluster_role_arn: $CLUSTER_ARN"
        else
            print_error "Terraform output eks_cluster_role_arn is empty"
        fi
    else
        print_warning "Terraform output eks_cluster_role_arn not available"
    fi
    
    if terragrunt output eks_nodegroup_role_arn &>/dev/null; then
        NODEGROUP_ARN=$(terragrunt output -raw eks_nodegroup_role_arn 2>/dev/null || echo "")
        if [ -n "$NODEGROUP_ARN" ]; then
            print_success "Terraform output eks_nodegroup_role_arn: $NODEGROUP_ARN"
        else
            print_error "Terraform output eks_nodegroup_role_arn is empty"
        fi
    else
        print_warning "Terraform output eks_nodegroup_role_arn not available"
    fi
    
    if terragrunt output oidc_provider_arn &>/dev/null; then
        OIDC_ARN=$(terragrunt output -raw oidc_provider_arn 2>/dev/null || echo "")
        if [ -n "$OIDC_ARN" ] && [ "$OIDC_ARN" != "" ]; then
            print_success "Terraform output oidc_provider_arn: $OIDC_ARN"
        else
            print_warning "Terraform output oidc_provider_arn is empty (may be expected)"
        fi
    else
        print_warning "Terraform output oidc_provider_arn not available"
    fi
    
    # Check Tags
    print_header "8. Verifying Resource Tags"
    
    if [ -n "$CLUSTER_ROLE" ] && [ "$CLUSTER_ROLE" != "None" ]; then
        TAGS=$(aws iam list-role-tags --role-name "$CLUSTER_ROLE" --query "Tags[].Key" --output text 2>/dev/null || echo "")
        
        if echo "$TAGS" | grep -q "Environment"; then
            print_success "Cluster Role has Environment tag"
        else
            print_warning "Cluster Role missing Environment tag"
        fi
        
        if echo "$TAGS" | grep -q "Project"; then
            print_success "Cluster Role has Project tag"
        else
            print_warning "Cluster Role missing Project tag"
        fi
    fi
    
    # Summary
    print_header "Verification Summary"
    
    echo -e "${GREEN}Passed: $PASSED${NC}"
    echo -e "${RED}Failed: $FAILED${NC}"
    echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
    
    if [ $FAILED -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ IAM Module verification PASSED${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}✗ IAM Module verification FAILED${NC}"
        echo "Please check the errors above and review the IAM_VERIFICATION_GUIDE.md"
        return 1
    fi
}

# Run main function
main
