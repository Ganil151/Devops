# Policy as Code

Complete guide to implementing policy as code in DevSecOps environments.

## Policy as Code Fundamentals

### Core Concepts
```bash
# Policy Definition
- Security policies written as code
- Version controlled policy management
- Automated policy enforcement
- Compliance validation
- Audit trail and reporting

# Benefits
- Consistency across environments
- Automated compliance checking
- Rapid policy deployment
- Version control and rollback
- Collaborative policy development
```

## Open Policy Agent (OPA)

### Rego Policy Language
```rego
# Basic policy structure
package kubernetes.admission

# Deny privileged containers
deny[msg] {
  input.request.kind.kind == "Pod"
  input.request.object.spec.containers[_].securityContext.privileged == true
  msg := "Privileged containers are not allowed"
}

# Require resource limits
deny[msg] {
  input.request.kind.kind == "Pod"
  container := input.request.object.spec.containers[_]
  not container.resources.limits.memory
  msg := sprintf("Container %v must have memory limits", [container.name])
}

# Enforce image registry
deny[msg] {
  input.request.kind.kind == "Pod"
  image := input.request.object.spec.containers[_].image
  not starts_with(image, "registry.company.com/")
  msg := sprintf("Image %v must come from approved registry", [image])
}
```

### Kubernetes Integration
```yaml
# OPA Gatekeeper ConstraintTemplate
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLabels
      validation:
        properties:
          labels:
            type: array
            items:
              type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredlabels
        
        violation[{"msg": msg}] {
          required := input.parameters.labels
          provided := input.review.object.metadata.labels
          missing := required[_]
          not provided[missing]
          msg := sprintf("Missing required label: %v", [missing])
        }

---
# Constraint using the template
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: must-have-environment
spec:
  match:
    kinds:
      - apiGroups: ["apps"]
        kinds: ["Deployment"]
  parameters:
    labels: ["environment", "team", "version"]
```

### OPA Testing
```rego
# Policy testing
package kubernetes.admission

test_deny_privileged_containers {
  deny[_] with input as {
    "request": {
      "kind": {"kind": "Pod"},
      "object": {
        "spec": {
          "containers": [{
            "name": "test",
            "securityContext": {"privileged": true}
          }]
        }
      }
    }
  }
}

test_allow_non_privileged_containers {
  count(deny) == 0 with input as {
    "request": {
      "kind": {"kind": "Pod"},
      "object": {
        "spec": {
          "containers": [{
            "name": "test",
            "securityContext": {"privileged": false}
          }]
        }
      }
    }
  }
}
```

## Infrastructure Policy

### Terraform Policy (Sentinel)
```hcl
# Sentinel policy for Terraform
import "tfplan/v2" as tfplan

# Require encryption for S3 buckets
main = rule {
  all tfplan.resource_changes as _, rc {
    rc.type is "aws_s3_bucket" and
    rc.change.actions contains "create"
    implies
    rc.change.after.server_side_encryption_configuration is not null
  }
}

# Enforce instance types
allowed_instance_types = ["t3.micro", "t3.small", "t3.medium"]

main = rule {
  all tfplan.resource_changes as _, rc {
    rc.type is "aws_instance" and
    rc.change.actions contains "create"
    implies
    rc.change.after.instance_type in allowed_instance_types
  }
}
```

### Checkov Custom Policies
```python
# Custom Checkov policy
from checkov.common.models.enums import TRUE_VALUES, FALSE_VALUES
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

class S3BucketEncryption(BaseResourceCheck):
    def __init__(self):
        name = "Ensure S3 bucket has encryption enabled"
        id = "CKV_AWS_141"
        supported_resources = ['aws_s3_bucket']
        categories = [CheckCategories.ENCRYPTION]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        """
        Looks for encryption configuration on S3 buckets
        """
        if 'server_side_encryption_configuration' in conf:
            encryption_conf = conf['server_side_encryption_configuration'][0]
            if isinstance(encryption_conf, dict) and 'rule' in encryption_conf:
                return CheckResult.PASSED
        return CheckResult.FAILED
```

## Cloud Security Policies

### AWS Config Rules
```json
{
  "ConfigRuleName": "s3-bucket-public-access-prohibited",
  "Description": "Checks that S3 buckets do not allow public access",
  "Source": {
    "Owner": "AWS",
    "SourceIdentifier": "S3_BUCKET_PUBLIC_ACCESS_PROHIBITED"
  },
  "Scope": {
    "ComplianceResourceTypes": [
      "AWS::S3::Bucket"
    ]
  }
}
```

### Azure Policy
```json
{
  "mode": "All",
  "policyRule": {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Storage/storageAccounts"
        },
        {
          "field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly",
          "notEquals": "true"
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  },
  "parameters": {},
  "displayName": "Secure transfer to storage accounts should be enabled",
  "description": "Audit requirement of Secure transfer in your storage account."
}
```

### GCP Organization Policies
```yaml
# Organization policy constraint
apiVersion: orgpolicy.googleapis.com/v1
kind: Policy
metadata:
  name: projects/PROJECT_ID/policies/compute.vmExternalIpAccess
spec:
  rules:
    - denyAll: true
  displayName: "Deny external IP access to VM instances"
  description: "Prevents VM instances from having external IP addresses"
```

## CI/CD Policy Integration

### Policy Validation Pipeline
```yaml
name: Policy Validation
on: [push, pull_request]

jobs:
  policy-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: OPA Policy Testing
        run: |
          opa fmt --diff policies/
          opa test policies/
      
      - name: Terraform Policy Check
        run: |
          terraform plan -out=tfplan
          terraform show -json tfplan > tfplan.json
          opa eval -d policies/ -i tfplan.json "data.terraform.deny[x]"
      
      - name: Kubernetes Policy Validation
        run: |
          conftest verify --policy policies/ k8s-manifests/
      
      - name: Container Policy Check
        run: |
          opa eval -d policies/ -i Dockerfile "data.docker.deny[x]"
```

### Policy Enforcement Gates
```bash
# Pre-commit hooks for policy validation
#!/bin/bash
# .git/hooks/pre-commit

echo "Running policy validation..."

# OPA policy testing
opa test policies/
if [ $? -ne 0 ]; then
    echo "Policy tests failed!"
    exit 1
fi

# Terraform policy check
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
violations=$(opa eval -d policies/ -i tfplan.json "data.terraform.deny[x]" --format raw)

if [ ! -z "$violations" ]; then
    echo "Policy violations found:"
    echo "$violations"
    exit 1
fi

echo "All policy checks passed!"
```

## Policy Monitoring and Compliance

### Compliance Dashboard
```python
# Policy compliance monitoring
import json
import requests
from datetime import datetime

class PolicyComplianceMonitor:
    def __init__(self, opa_url, k8s_api_url):
        self.opa_url = opa_url
        self.k8s_api_url = k8s_api_url
    
    def check_cluster_compliance(self):
        # Get all pods
        pods = self.get_kubernetes_resources('pods')
        
        compliance_results = []
        for pod in pods:
            # Check against policies
            policy_result = self.evaluate_policy(pod)
            compliance_results.append({
                'resource': pod['metadata']['name'],
                'namespace': pod['metadata']['namespace'],
                'compliant': len(policy_result.get('violations', [])) == 0,
                'violations': policy_result.get('violations', [])
            })
        
        return compliance_results
    
    def evaluate_policy(self, resource):
        policy_input = {
            'input': {
                'request': {
                    'object': resource
                }
            }
        }
        
        response = requests.post(
            f"{self.opa_url}/v1/data/kubernetes/admission/deny",
            json=policy_input
        )
        
        return response.json()
    
    def generate_compliance_report(self):
        results = self.check_cluster_compliance()
        
        total_resources = len(results)
        compliant_resources = len([r for r in results if r['compliant']])
        compliance_percentage = (compliant_resources / total_resources) * 100
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'total_resources': total_resources,
            'compliant_resources': compliant_resources,
            'compliance_percentage': compliance_percentage,
            'violations': [r for r in results if not r['compliant']]
        }
        
        return report
```

### Policy Violation Alerts
```yaml
# Alertmanager configuration for policy violations
groups:
- name: policy-violations
  rules:
  - alert: PolicyViolationDetected
    expr: increase(opa_policy_violations_total[5m]) > 0
    for: 0m
    labels:
      severity: warning
    annotations:
      summary: "Policy violation detected"
      description: "{{ $labels.policy }} policy has been violated {{ $value }} times in the last 5 minutes"
  
  - alert: ComplianceThresholdBreached
    expr: (opa_compliant_resources / opa_total_resources) * 100 < 95
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "Compliance threshold breached"
      description: "Compliance percentage is {{ $value }}%, below the 95% threshold"
```

## Policy Development Lifecycle

### Policy Development Process
```bash
# 1. Policy Design
- Identify compliance requirements
- Define policy objectives
- Create policy specifications
- Design policy rules

# 2. Policy Implementation
- Write policy code (Rego, Sentinel, etc.)
- Create test cases
- Validate policy logic
- Document policy behavior

# 3. Policy Testing
- Unit testing for policy rules
- Integration testing with systems
- Performance testing
- Security validation

# 4. Policy Deployment
- Version control integration
- Automated deployment pipelines
- Gradual rollout strategies
- Rollback procedures

# 5. Policy Monitoring
- Compliance tracking
- Violation monitoring
- Performance metrics
- Continuous improvement
```

### Policy Versioning
```bash
# Semantic versioning for policies
# policy-v1.2.3
# Major: Breaking changes
# Minor: New rules or features
# Patch: Bug fixes or clarifications

# Git-based policy management
git tag -a policy-v1.2.3 -m "Add container security policies"
git push origin policy-v1.2.3

# Policy rollback strategy
kubectl apply -f policies/v1.2.2/
kubectl rollout status deployment/opa-gatekeeper
```