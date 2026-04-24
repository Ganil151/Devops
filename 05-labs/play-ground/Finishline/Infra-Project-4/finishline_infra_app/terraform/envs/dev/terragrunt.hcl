#============================================================
#  Terragrunt Configuration - Development Environment
#============================================================
#
# This file uses the run-all pattern to deploy all modules
# Run with: terragrunt run-all apply
#
# Module Order (handled by dependencies):
# 1. vpc      - Creates networking
# 2. iam      - Creates IAM roles (without OIDC initially)
# 3. sg       - Creates security groups
# 4. eks      - Creates EKS cluster
# 5. jumphost - Creates bastion host
# 6. alb      - Creates load balancer
# 7. bootstrap- Deploys K8s resources
#
#============================================================

include {
  path = find_in_parent_folders("root.hcl")
}
