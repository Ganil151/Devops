# 🔄 Terraform CI/CD Pipeline with Security Scanning

## GitHub Actions Workflow

```yaml
# .github/workflows/terraform-security.yml
name: Terraform Security & Compliance

on:
  pull_request:
    branches: [main, develop]
    paths:
      - '**.tf'
      - '**.tfvars'
      - '.github/workflows/terraform-security.yml'
  push:
    branches: [main]
    paths:
      - '**.tf'
      - '**.tfvars'

env:
  TF_VERSION: '1.5.0'
  AWS_REGION: 'us-east-1'

jobs:
  # ============================================================================
  # Job 1: Terraform Validation & Formatting
  # ============================================================================
  validate:
    name: Validate & Format
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Terraform Format Check
        id: fmt
        run: terraform fmt -check -recursive
        continue-on-error: true
      
      - name: Terraform Init
        run: terraform init -backend=false
      
      - name: Terraform Validate
        id: validate
        run: terraform validate -no-color
      
      - name: Comment PR - Format Issues
        if: steps.fmt.outcome == 'failure' && github.event_name == 'pull_request'
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '❌ **Terraform Format Check Failed**\n\nRun `terraform fmt -recursive` to fix formatting issues.'
            })
      
      - name: Fail if Format Check Failed
        if: steps.fmt.outcome == 'failure'
        run: exit 1

  # ============================================================================
  # Job 2: Security Scanning with tfsec
  # ============================================================================
  tfsec:
    name: tfsec Security Scan
    runs-on: ubuntu-latest
    needs: validate
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      
      - name: Run tfsec
        uses: aquasecurity/tfsec-action@v1.0.3
        with:
          soft_fail: false
          format: sarif
          additional_args: --minimum-severity MEDIUM
      
      - name: Upload tfsec SARIF
        if: always()
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: tfsec.sarif
      
      - name: Generate tfsec Report
        if: always()
        run: |
          docker run --rm -v $(pwd):/src aquasec/tfsec:latest /src \
            --format json \
            --out /src/tfsec-report.json
      
      - name: Upload tfsec Report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: tfsec-report
          path: tfsec-report.json

  # ============================================================================
  # Job 3: Policy Scanning with Checkov
  # ============================================================================
  checkov:
    name: Checkov Policy Scan
    runs-on: ubuntu-latest
    needs: validate
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      
      - name: Run Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: .
          framework: terraform
          output_format: sarif
          output_file_path: checkov-report.sarif
          soft_fail: false
          skip_check: CKV_AWS_79,CKV_AWS_80  # Skip specific checks if needed
      
      - name: Upload Checkov SARIF
        if: always()
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: checkov-report.sarif
      
      - name: Generate Checkov JSON Report
        if: always()
        run: |
          docker run --rm -v $(pwd):/tf bridgecrew/checkov:latest \
            -d /tf \
            --framework terraform \
            --output json \
            --output-file-path /tf/checkov-report.json
      
      - name: Upload Checkov Report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: checkov-report
          path: checkov-report.json

  # ============================================================================
  # Job 4: Linting with TFLint
  # ============================================================================
  tflint:
    name: TFLint
    runs-on: ubuntu-latest
    needs: validate
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      
      - name: Setup TFLint
        uses: terraform-linters/setup-tflint@v3
        with:
          tflint_version: latest
      
      - name: Initialize TFLint
        run: tflint --init
      
      - name: Run TFLint
        run: tflint --recursive --format compact
      
      - name: Generate TFLint Report
        if: always()
        run: tflint --recursive --format json > tflint-report.json
      
      - name: Upload TFLint Report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: tflint-report
          path: tflint-report.json

  # ============================================================================
  # Job 5: Cost Estimation with Infracost
  # ============================================================================
  infracost:
    name: Cost Estimation
    runs-on: ubuntu-latest
    needs: validate
    if: github.event_name == 'pull_request'
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Setup Infracost
        uses: infracost/actions/setup@v2
        with:
          api-key: ${{ secrets.INFRACOST_API_KEY }}
      
      - name: Generate Infracost JSON
        run: |
          infracost breakdown --path . \
            --format json \
            --out-file infracost-base.json
      
      - name: Post Infracost Comment
        uses: infracost/actions/comment@v1
        with:
          path: infracost-base.json
          behavior: update

  # ============================================================================
  # Job 6: Terraform Plan
  # ============================================================================
  plan:
    name: Terraform Plan
    runs-on: ubuntu-latest
    needs: [tfsec, checkov, tflint]
    if: github.event_name == 'pull_request'
    
    permissions:
      id-token: write
      contents: read
      pull-requests: write
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Terraform Init
        run: terraform init
      
      - name: Terraform Plan
        id: plan
        run: |
          terraform plan -no-color -out=tfplan -lock-timeout=5m
        continue-on-error: true
      
      - name: Generate Plan Summary
        run: |
          terraform show -no-color tfplan > plan-output.txt
      
      - name: Comment PR with Plan
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const plan = fs.readFileSync('plan-output.txt', 'utf8');
            const truncatedPlan = plan.length > 65000 ? plan.substring(0, 65000) + '\n\n... (truncated)' : plan;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## Terraform Plan\n\`\`\`terraform\n${truncatedPlan}\n\`\`\``
            })
      
      - name: Upload Plan Artifact
        uses: actions/upload-artifact@v3
        with:
          name: terraform-plan
          path: tfplan

  # ============================================================================
  # Job 7: Terraform Apply (Production)
  # ============================================================================
  apply:
    name: Terraform Apply
    runs-on: ubuntu-latest
    needs: [tfsec, checkov, tflint]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    
    permissions:
      id-token: write
      contents: read
    
    environment:
      name: production
      url: https://console.aws.amazon.com/eks
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Terraform Init
        run: terraform init
      
      - name: Backup Current State
        run: |
          terraform state pull > state-backup-$(date +%Y%m%d-%H%M%S).json
          aws s3 cp state-backup-*.json s3://my-terraform-state-backup/
      
      - name: Terraform Apply
        id: apply
        run: terraform apply -auto-approve -lock-timeout=10m
        continue-on-error: true
      
      - name: Notify on Failure
        if: steps.apply.outcome == 'failure'
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.repos.createCommitStatus({
              owner: context.repo.owner,
              repo: context.repo.repo,
              sha: context.sha,
              state: 'failure',
              description: 'Terraform apply failed',
              context: 'terraform/apply'
            })
      
      - name: Fail Job if Apply Failed
        if: steps.apply.outcome == 'failure'
        run: exit 1

  # ============================================================================
  # Job 8: Generate Documentation
  # ============================================================================
  docs:
    name: Generate Documentation
    runs-on: ubuntu-latest
    needs: validate
    if: github.event_name == 'pull_request'
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      
      - name: Generate terraform-docs
        uses: terraform-docs/gh-actions@v1.0.0
        with:
          working-dir: .
          output-file: README.md
          output-method: inject
          git-push: false
      
      - name: Check for Documentation Changes
        id: docs-check
        run: |
          if git diff --quiet; then
            echo "No documentation changes"
          else
            echo "Documentation needs update"
            git diff
          fi

  # ============================================================================
  # Job 9: Compliance Report
  # ============================================================================
  compliance:
    name: Generate Compliance Report
    runs-on: ubuntu-latest
    needs: [tfsec, checkov, tflint]
    if: always()
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      
      - name: Download All Reports
        uses: actions/download-artifact@v3
      
      - name: Generate Compliance Summary
        run: |
          cat << EOF > compliance-report.md
          # Terraform Compliance Report
          
          **Date:** $(date)
          **Commit:** ${{ github.sha }}
          **Branch:** ${{ github.ref }}
          
          ## Security Scan Results
          
          ### tfsec
          $(cat tfsec-report/tfsec-report.json | jq -r '.results | length') issues found
          
          ### Checkov
          $(cat checkov-report/checkov-report.json | jq -r '.summary.failed') checks failed
          
          ### TFLint
          $(cat tflint-report/tflint-report.json | jq -r '.issues | length') issues found
          
          ## Recommendations
          - Review all HIGH and CRITICAL findings
          - Update security group rules
          - Enable encryption where missing
          - Implement least privilege IAM policies
          
          EOF
      
      - name: Upload Compliance Report
        uses: actions/upload-artifact@v3
        with:
          name: compliance-report
          path: compliance-report.md
      
      - name: Comment PR with Summary
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('compliance-report.md', 'utf8');
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: report
            })
```

---

## GitLab CI/CD Pipeline

```yaml
# .gitlab-ci.yml
stages:
  - validate
  - security
  - plan
  - apply

variables:
  TF_VERSION: "1.5.0"
  TF_ROOT: ${CI_PROJECT_DIR}

.terraform_base:
  image: hashicorp/terraform:${TF_VERSION}
  before_script:
    - cd ${TF_ROOT}
    - terraform --version

# ============================================================================
# Stage 1: Validation
# ============================================================================

validate:
  extends: .terraform_base
  stage: validate
  script:
    - terraform fmt -check -recursive
    - terraform init -backend=false
    - terraform validate
  only:
    - merge_requests
    - main

# ============================================================================
# Stage 2: Security Scanning
# ============================================================================

tfsec:
  stage: security
  image: aquasec/tfsec:latest
  script:
    - tfsec . --format json --out tfsec-report.json
    - tfsec . --format sarif --out tfsec-report.sarif
  artifacts:
    reports:
      sast: tfsec-report.sarif
    paths:
      - tfsec-report.json
  only:
    - merge_requests
    - main

checkov:
  stage: security
  image: bridgecrew/checkov:latest
  script:
    - checkov -d . --framework terraform --output json --output-file checkov-report.json
    - checkov -d . --framework terraform --output sarif --output-file checkov-report.sarif
  artifacts:
    reports:
      sast: checkov-report.sarif
    paths:
      - checkov-report.json
  only:
    - merge_requests
    - main

tflint:
  stage: security
  image: ghcr.io/terraform-linters/tflint:latest
  script:
    - tflint --init
    - tflint --recursive --format json > tflint-report.json
  artifacts:
    paths:
      - tflint-report.json
  only:
    - merge_requests
    - main

# ============================================================================
# Stage 3: Plan
# ============================================================================

plan:
  extends: .terraform_base
  stage: plan
  script:
    - terraform init
    - terraform plan -out=tfplan
    - terraform show -no-color tfplan > plan-output.txt
  artifacts:
    paths:
      - tfplan
      - plan-output.txt
  only:
    - merge_requests

# ============================================================================
# Stage 4: Apply
# ============================================================================

apply:
  extends: .terraform_base
  stage: apply
  script:
    - terraform init
    - terraform state pull > state-backup-$(date +%Y%m%d-%H%M%S).json
    - terraform apply -auto-approve
  artifacts:
    paths:
      - state-backup-*.json
  only:
    - main
  when: manual
  environment:
    name: production
```

---

## Pre-commit Hooks Configuration

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.0
    hooks:
      - id: terraform_fmt
        name: Terraform Format
        description: Rewrites all Terraform files to canonical format
      
      - id: terraform_validate
        name: Terraform Validate
        description: Validates all Terraform files
      
      - id: terraform_docs
        name: Terraform Docs
        description: Inserts terraform-docs output into README.md
        args:
          - --args=--lockfile=false
      
      - id: terraform_tflint
        name: TFLint
        description: Lints Terraform files
        args:
          - --args=--config=__GIT_WORKING_DIR__/.tflint.hcl
      
      - id: terraform_tfsec
        name: tfsec
        description: Security scanning with tfsec
        args:
          - --args=--minimum-severity=MEDIUM
      
      - id: terraform_checkov
        name: Checkov
        description: Policy scanning with Checkov
        args:
          - --args=--quiet
          - --args=--framework=terraform

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json
      - id: check-merge-conflict
      - id: detect-private-key
```

---

## Installation Instructions

### GitHub Actions
1. Copy workflow file to `.github/workflows/terraform-security.yml`
2. Configure AWS OIDC provider
3. Set secrets: `AWS_ROLE_ARN`, `INFRACOST_API_KEY`
4. Enable GitHub Advanced Security (for SARIF upload)

### GitLab CI/CD
1. Copy pipeline file to `.gitlab-ci.yml`
2. Configure AWS credentials in CI/CD variables
3. Enable SAST scanning in Security settings

### Pre-commit Hooks
```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

---

## Security Scanning Thresholds

### tfsec
- **CRITICAL**: Block merge
- **HIGH**: Block merge
- **MEDIUM**: Warning
- **LOW**: Info only

### Checkov
- **CRITICAL**: Block merge
- **HIGH**: Block merge
- **MEDIUM**: Warning
- **LOW**: Info only

### TFLint
- **Error**: Block merge
- **Warning**: Warning
- **Notice**: Info only

---

## Cost Estimation

Infracost provides:
- Monthly cost estimate
- Cost diff for changes
- Resource breakdown
- Comparison with baseline

---

## Compliance Reporting

Generated reports include:
- Security findings summary
- Policy violations
- Linting issues
- Cost impact
- Remediation recommendations

---

**Last Updated:** 2024  
**Pipeline Version:** 1.0
