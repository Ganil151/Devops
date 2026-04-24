# 🧪 Testing & Validation Reference

> **"Test in development, not in production. Your 3 AM self will thank you."**

## 🎯 Testing Philosophy

**The Testing Pyramid for Infrastructure:**
```
        /\
       /  \  E2E Tests (Slow, Expensive)
      /____\
     /      \  Integration Tests (Medium)
    /________\
   /          \  Unit Tests (Fast, Cheap)
  /__________\
```

---

## 🔬 Testing Tools Matrix

| Tool | Language | Best For | Speed | Complexity |
| :--- | :------- | :------- | :---- | :--------- |
| **Molecule** | Python | Ansible roles | Fast | Low |
| **Terratest** | Go | Terraform modules | Slow | Medium |
| **Kitchen** | Ruby | Chef/Ansible | Medium | High |
| **InSpec** | Ruby | Compliance testing | Fast | Low |
| **Serverspec** | Ruby | Server state | Fast | Low |

---

## 🧬 Molecule (Ansible Testing)

### Setup

```bash
# Install
pip install molecule molecule-docker

# Initialize in role
cd roles/nginx
molecule init scenario
```

### Directory Structure

```
roles/nginx/
├── molecule/
│   └── default/
│       ├── molecule.yml       # Configuration
│       ├── converge.yml       # Playbook to test
│       ├── verify.yml         # Verification playbook
│       └── tests/
│           └── test_default.py  # Python tests
```

### Configuration (molecule.yml)

```yaml
---
dependency:
  name: galaxy
driver:
  name: docker
platforms:
  - name: ubuntu-20
    image: geerlingguy/docker-ubuntu2004-ansible
    pre_build_image: true
  - name: centos-8
    image: geerlingguy/docker-centos8-ansible
    pre_build_image: true
provisioner:
  name: ansible
  playbooks:
    converge: converge.yml
verifier:
  name: testinfra
```

### Test Playbook (converge.yml)

```yaml
---
- name: Converge
  hosts: all
  become: yes
  roles:
    - role: nginx
      nginx_port: 8080
```

### Python Tests (tests/test_default.py)

```python
import os
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']
).get_hosts('all')

def test_nginx_installed(host):
    nginx = host.package("nginx")
    assert nginx.is_installed

def test_nginx_running(host):
    nginx = host.service("nginx")
    assert nginx.is_running
    assert nginx.is_enabled

def test_nginx_listening(host):
    socket = host.socket("tcp://0.0.0.0:8080")
    assert socket.is_listening

def test_nginx_config_valid(host):
    cmd = host.run("nginx -t")
    assert cmd.rc == 0

def test_http_response(host):
    cmd = host.run("curl -s http://localhost:8080")
    assert cmd.rc == 0
    assert "Welcome" in cmd.stdout
```

### Run Tests

```bash
# Full test cycle
molecule test

# Individual steps
molecule create    # Create container
molecule converge  # Run playbook
molecule verify    # Run tests
molecule destroy   # Clean up

# Debug mode
molecule --debug test

# Test specific platform
molecule test --platform-name ubuntu-20
```

---

## 🏗️ Terratest (Terraform Testing)

### Setup

```bash
# Install Go
brew install go

# Initialize Go module
cd test
go mod init github.com/myorg/terraform-tests
go get github.com/gruntwork-io/terratest/modules/terraform
```

### Test Structure

```
terraform-module/
├── main.tf
├── variables.tf
├── outputs.tf
└── test/
    ├── go.mod
    └── terraform_test.go
```

### Basic Test (terraform_test.go)

```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestTerraformVPC(t *testing.T) {
    t.Parallel()

    terraformOptions := &terraform.Options{
        TerraformDir: "../",
        Vars: map[string]interface{}{
            "vpc_cidr": "10.0.0.0/16",
            "environment": "test",
        },
    }

    // Clean up resources
    defer terraform.Destroy(t, terraformOptions)

    // Deploy infrastructure
    terraform.InitAndApply(t, terraformOptions)

    // Validate outputs
    vpcID := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcID)

    // Validate VPC exists
    vpc := aws.GetVpcById(t, vpcID, "us-east-1")
    assert.Equal(t, "10.0.0.0/16", *vpc.CidrBlock)
}
```

### Advanced Test with Retries

```go
func TestWebServerDeployment(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../",
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    instanceURL := terraform.Output(t, terraformOptions, "instance_url")

    // Retry HTTP request (server may take time to start)
    maxRetries := 30
    timeBetweenRetries := 10 * time.Second

    http_helper.HttpGetWithRetry(
        t,
        instanceURL,
        nil,
        200,
        "Welcome",
        maxRetries,
        timeBetweenRetries,
    )
}
```

### Run Tests

```bash
# Run all tests
cd test
go test -v -timeout 30m

# Run specific test
go test -v -run TestTerraformVPC

# Parallel execution
go test -v -parallel 10
```

---

## 🍳 Kitchen (Multi-Tool Testing)

### Setup

```bash
# Install
gem install test-kitchen kitchen-terraform kitchen-ansible
```

### Configuration (.kitchen.yml)

```yaml
---
driver:
  name: terraform

provisioner:
  name: ansible_playbook
  playbook: site.yml

platforms:
  - name: ubuntu-20

suites:
  - name: default
    verifier:
      name: inspec
      inspec_tests:
        - test/integration/default
```

### InSpec Tests (test/integration/default/default_test.rb)

```ruby
describe package('nginx') do
  it { should be_installed }
end

describe service('nginx') do
  it { should be_running }
  it { should be_enabled }
end

describe port(80) do
  it { should be_listening }
end

describe http('http://localhost') do
  its('status') { should eq 200 }
  its('body') { should match /Welcome/ }
end
```

### Run Tests

```bash
# Full cycle
kitchen test

# Individual steps
kitchen create
kitchen converge
kitchen verify
kitchen destroy

# List instances
kitchen list
```

---

## ✅ Pre-commit Hooks

### Setup

```bash
# Install
pip install pre-commit

# Initialize
pre-commit install
```

### Configuration (.pre-commit-config.yaml)

```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint
      - id: terraform_tfsec

  - repo: https://github.com/ansible/ansible-lint
    rev: v6.20.0
    hooks:
      - id: ansible-lint
        files: \.(yaml|yml)$

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: detect-private-key
```

### Run Manually

```bash
# Run on all files
pre-commit run --all-files

# Run specific hook
pre-commit run terraform-fmt --all-files
```

---

## 🔍 Linting Tools

### TFLint (Terraform)

```bash
# Install
brew install tflint

# Initialize
tflint --init

# Run
tflint

# Configuration (.tflint.hcl)
plugin "aws" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "terraform_naming_convention" {
  enabled = true
}
```

### Ansible-lint

```bash
# Install
pip install ansible-lint

# Run
ansible-lint site.yml

# Configuration (.ansible-lint)
skip_list:
  - '306'  # Shells that use pipes should set pipefail
  - '204'  # Lines should be no longer than 160 chars

exclude_paths:
  - .cache/
  - test/
```

### Checkov (Security)

```bash
# Install
pip install checkov

# Scan Terraform
checkov -d .

# Scan specific file
checkov -f main.tf

# Output formats
checkov -d . --output json
checkov -d . --output sarif
```

---

## 🎯 Testing Strategies

### Unit Tests (Fast)

**What:** Test individual modules in isolation
**When:** Every commit
**Tools:** Molecule (roles), Terratest (modules)

```python
# Test single role
def test_nginx_config_syntax(host):
    cmd = host.run("nginx -t")
    assert cmd.rc == 0
```

### Integration Tests (Medium)

**What:** Test multiple components together
**When:** Before merge
**Tools:** Kitchen, Terratest

```go
// Test VPC + EC2 + RDS together
func TestFullStack(t *testing.T) {
    terraform.InitAndApply(t, options)
    // Verify connectivity between components
}
```

### End-to-End Tests (Slow)

**What:** Test complete user workflows
**When:** Before release
**Tools:** Selenium, Cypress, custom scripts

```bash
# Deploy full environment
terraform apply
ansible-playbook site.yml

# Run E2E tests
./scripts/e2e-test.sh

# Cleanup
terraform destroy
```

---

## 📊 Test Coverage

### Terraform Module Checklist

- [ ] Syntax validation (`terraform validate`)
- [ ] Format check (`terraform fmt -check`)
- [ ] Security scan (`tfsec`, `checkov`)
- [ ] Linting (`tflint`)
- [ ] Unit tests (Terratest)
- [ ] Integration tests
- [ ] Documentation (`terraform-docs`)

### Ansible Role Checklist

- [ ] Syntax check (`ansible-playbook --syntax-check`)
- [ ] Linting (`ansible-lint`)
- [ ] Molecule tests (multiple platforms)
- [ ] Idempotency test (run twice, no changes)
- [ ] Integration tests
- [ ] Documentation (README.md)

---

## 🚨 Common Issues

### Issue: Molecule Docker Permission Denied

```bash
# Solution: Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Issue: Terratest Timeout

```go
// Solution: Increase timeout
terraformOptions := &terraform.Options{
    TerraformDir: "../",
    MaxRetries: 3,
    TimeBetweenRetries: 10 * time.Second,
}
```

### Issue: Kitchen Converge Fails

```bash
# Debug mode
kitchen converge --log-level=debug

# Check logs
kitchen login
journalctl -xe
```

---

[⬅️ Back to Reference Hub](./readme.md)
