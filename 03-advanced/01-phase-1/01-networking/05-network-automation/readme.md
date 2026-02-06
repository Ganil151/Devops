# Network Automation for DevOps

Infrastructure as Code and network automation frameworks for scalable, reliable network management. This section covers GitOps, CI/CD for networks, and automated compliance.

## 🎯 Learning Objectives

- Implement Infrastructure as Code for networks
- Design GitOps workflows for network infrastructure
- Build CI/CD pipelines for network changes
- Automate network compliance and testing
- Develop self-healing network systems

## 🏗️ Infrastructure as Code for Networks

### Terraform Network Modules

**Reusable VPC Module:**
```hcl
# modules/vpc/main.tf
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.environment}-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.availability_zones)
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.environment}-public-${count.index + 1}"
    Type = "public"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.availability_zones)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "${var.environment}-private-${count.index + 1}"
    Type = "private"
  }
}

# Outputs
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
```

**Multi-Environment Configuration:**
```hcl
# environments/production/main.tf
module "vpc" {
  source = "../../modules/vpc"
  
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  environment        = "production"
}

module "security_groups" {
  source = "../../modules/security-groups"
  
  vpc_id      = module.vpc.vpc_id
  environment = "production"
}

module "load_balancer" {
  source = "../../modules/load-balancer"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
  
  depends_on = [module.security_groups]
}
```

### Ansible Network Automation

**Network Device Configuration:**
```yaml
# playbooks/network-config.yml
---
- name: Configure network infrastructure
  hosts: network_devices
  gather_facts: no
  connection: network_cli
  
  vars:
    vlans:
      - id: 10
        name: "Users"
      - id: 20
        name: "Servers"
      - id: 30
        name: "Management"
    
    interfaces:
      - name: "GigabitEthernet0/1"
        mode: "trunk"
        allowed_vlans: "10,20,30"
      - name: "GigabitEthernet0/2"
        mode: "access"
        access_vlan: 10
  
  tasks:
    - name: Configure VLANs
      cisco.ios.ios_vlans:
        config: "{{ vlans }}"
        state: merged
      when: ansible_network_os == 'ios'
    
    - name: Configure interfaces
      cisco.ios.ios_interfaces:
        config: "{{ interfaces }}"
        state: merged
      when: ansible_network_os == 'ios'
    
    - name: Configure Juniper VLANs
      junipernetworks.junos.junos_vlans:
        config: "{{ vlans }}"
        state: merged
      when: ansible_network_os == 'junos'
    
    - name: Validate configuration
      include_tasks: validate_config.yml
    
    - name: Generate compliance report
      template:
        src: compliance_report.j2
        dest: "/tmp/compliance_{{ inventory_hostname }}.html"
      delegate_to: localhost
```

**Dynamic Inventory:**
```python
#!/usr/bin/env python3
# inventory/dynamic_inventory.py
import json
import boto3
import sys

class NetworkInventory:
    def __init__(self):
        self.inventory = {
            '_meta': {
                'hostvars': {}
            }
        }
        self.ec2 = boto3.client('ec2')
    
    def get_inventory(self):
        # Get EC2 instances
        instances = self.ec2.describe_instances()
        
        for reservation in instances['Reservations']:
            for instance in reservation['Instances']:
                if instance['State']['Name'] != 'running':
                    continue
                
                # Extract instance information
                instance_id = instance['InstanceId']
                private_ip = instance.get('PrivateIpAddress', '')
                public_ip = instance.get('PublicIpAddress', '')
                
                # Get tags
                tags = {tag['Key']: tag['Value'] for tag in instance.get('Tags', [])}
                
                # Group by role
                role = tags.get('Role', 'ungrouped')
                if role not in self.inventory:
                    self.inventory[role] = {'hosts': []}
                
                self.inventory[role]['hosts'].append(instance_id)
                
                # Add host variables
                self.inventory['_meta']['hostvars'][instance_id] = {
                    'ansible_host': public_ip or private_ip,
                    'private_ip': private_ip,
                    'public_ip': public_ip,
                    'instance_type': instance['InstanceType'],
                    'tags': tags
                }
        
        return self.inventory

if __name__ == '__main__':
    inventory = NetworkInventory()
    print(json.dumps(inventory.get_inventory(), indent=2))
```

## 🔄 GitOps for Network Infrastructure

### GitOps Workflow

**Repository Structure:**
```
network-infrastructure/
├── environments/
│   ├── production/
│   │   ├── terraform/
│   │   ├── ansible/
│   │   └── kubernetes/
│   ├── staging/
│   └── development/
├── modules/
│   ├── vpc/
│   ├── security-groups/
│   └── load-balancer/
├── policies/
│   ├── security/
│   └── compliance/
├── .github/
│   └── workflows/
└── scripts/
```

**GitHub Actions Workflow:**
```yaml
# .github/workflows/network-deploy.yml
name: Network Infrastructure Deployment

on:
  push:
    branches: [main]
    paths: ['environments/**']
  pull_request:
    branches: [main]
    paths: ['environments/**']

env:
  TF_VERSION: '1.5.0'
  ANSIBLE_VERSION: '6.0.0'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Terraform Format Check
        run: terraform fmt -check -recursive
      
      - name: Terraform Validate
        run: |
          find environments -name "*.tf" -execdir terraform init -backend=false \;
          find environments -name "*.tf" -execdir terraform validate \;
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install Ansible
        run: |
          pip install ansible==${{ env.ANSIBLE_VERSION }}
          pip install ansible-lint
      
      - name: Ansible Lint
        run: ansible-lint playbooks/

  security-scan:
    runs-on: ubuntu-latest
    needs: validate
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: .
          framework: terraform
          output_format: sarif
          output_file_path: checkov-report.sarif
      
      - name: Upload SARIF file
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: checkov-report.sarif

  plan:
    runs-on: ubuntu-latest
    needs: [validate, security-scan]
    if: github.event_name == 'pull_request'
    strategy:
      matrix:
        environment: [development, staging]
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-west-2
      
      - name: Terraform Plan
        working-directory: environments/${{ matrix.environment }}
        run: |
          terraform init
          terraform plan -out=tfplan
      
      - name: Comment PR
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const plan = fs.readFileSync('environments/${{ matrix.environment }}/tfplan', 'utf8');
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## Terraform Plan - ${{ matrix.environment }}\n\`\`\`\n${plan}\n\`\`\``
            });

  deploy:
    runs-on: ubuntu-latest
    needs: validate
    if: github.ref == 'refs/heads/main'
    strategy:
      matrix:
        environment: [development, staging, production]
    
    environment: ${{ matrix.environment }}
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-west-2
      
      - name: Terraform Apply
        working-directory: environments/${{ matrix.environment }}
        run: |
          terraform init
          terraform apply -auto-approve
      
      - name: Run Ansible Playbook
        run: |
          pip install ansible
          ansible-playbook -i inventory/dynamic_inventory.py \
            playbooks/network-config.yml \
            --extra-vars "environment=${{ matrix.environment }}"
      
      - name: Network Validation Tests
        run: |
          python scripts/network_tests.py --environment ${{ matrix.environment }}
```

### ArgoCD for Network GitOps

**ArgoCD Application:**
```yaml
# argocd/network-infrastructure.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: network-infrastructure
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/company/network-infrastructure
    targetRevision: HEAD
    path: kubernetes/network-policies
  destination:
    server: https://kubernetes.default.svc
    namespace: network-system
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
---
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: network-project
  namespace: argocd
spec:
  description: Network infrastructure project
  sourceRepos:
  - 'https://github.com/company/network-infrastructure'
  destinations:
  - namespace: 'network-*'
    server: https://kubernetes.default.svc
  clusterResourceWhitelist:
  - group: 'networking.k8s.io'
    kind: NetworkPolicy
  - group: 'cilium.io'
    kind: CiliumNetworkPolicy
```

## 🧪 Network Testing and Validation

### Automated Network Tests

**Network Connectivity Tests:**
```python
#!/usr/bin/env python3
# scripts/network_tests.py
import subprocess
import json
import sys
import argparse
from concurrent.futures import ThreadPoolExecutor
import boto3

class NetworkTester:
    def __init__(self, environment):
        self.environment = environment
        self.ec2 = boto3.client('ec2')
        self.results = []
    
    def test_connectivity(self, source_ip, target_ip, port):
        """Test connectivity between two endpoints"""
        try:
            result = subprocess.run([
                'nc', '-z', '-v', '-w', '5', target_ip, str(port)
            ], capture_output=True, text=True, timeout=10)
            
            return {
                'source': source_ip,
                'target': target_ip,
                'port': port,
                'success': result.returncode == 0,
                'output': result.stderr
            }
        except subprocess.TimeoutExpired:
            return {
                'source': source_ip,
                'target': target_ip,
                'port': port,
                'success': False,
                'output': 'Connection timeout'
            }
    
    def test_dns_resolution(self, hostname):
        """Test DNS resolution"""
        try:
            result = subprocess.run([
                'nslookup', hostname
            ], capture_output=True, text=True, timeout=10)
            
            return {
                'hostname': hostname,
                'success': result.returncode == 0,
                'output': result.stdout
            }
        except subprocess.TimeoutExpired:
            return {
                'hostname': hostname,
                'success': False,
                'output': 'DNS timeout'
            }
    
    def test_security_groups(self):
        """Validate security group rules"""
        security_groups = self.ec2.describe_security_groups()
        violations = []
        
        for sg in security_groups['SecurityGroups']:
            # Check for overly permissive rules
            for rule in sg.get('IpPermissions', []):
                for ip_range in rule.get('IpRanges', []):
                    if ip_range.get('CidrIp') == '0.0.0.0/0':
                        if rule.get('FromPort') == 22:  # SSH
                            violations.append({
                                'type': 'security_violation',
                                'sg_id': sg['GroupId'],
                                'rule': 'SSH open to 0.0.0.0/0',
                                'severity': 'high'
                            })
        
        return violations
    
    def run_all_tests(self):
        """Run comprehensive network tests"""
        print(f"Running network tests for {self.environment} environment...")
        
        # Connectivity tests
        test_cases = [
            ('10.0.1.10', '10.0.2.10', 80),
            ('10.0.1.10', '10.0.2.10', 443),
            ('10.0.2.10', '10.0.3.10', 3306),
        ]
        
        with ThreadPoolExecutor(max_workers=10) as executor:
            connectivity_results = list(executor.map(
                lambda args: self.test_connectivity(*args), test_cases
            ))
        
        # DNS tests
        dns_tests = ['internal.example.com', 'api.example.com']
        dns_results = [self.test_dns_resolution(host) for host in dns_tests]
        
        # Security tests
        security_results = self.test_security_groups()
        
        # Compile results
        all_results = {
            'environment': self.environment,
            'connectivity_tests': connectivity_results,
            'dns_tests': dns_results,
            'security_tests': security_results,
            'summary': {
                'total_tests': len(connectivity_results) + len(dns_results),
                'passed': sum(1 for r in connectivity_results + dns_results if r['success']),
                'failed': sum(1 for r in connectivity_results + dns_results if not r['success']),
                'security_violations': len(security_results)
            }
        }
        
        return all_results
    
    def generate_report(self, results):
        """Generate test report"""
        print("\n" + "="*50)
        print(f"NETWORK TEST REPORT - {results['environment'].upper()}")
        print("="*50)
        
        summary = results['summary']
        print(f"Total Tests: {summary['total_tests']}")
        print(f"Passed: {summary['passed']}")
        print(f"Failed: {summary['failed']}")
        print(f"Security Violations: {summary['security_violations']}")
        
        if summary['failed'] > 0:
            print("\nFAILED TESTS:")
            for test in results['connectivity_tests'] + results['dns_tests']:
                if not test['success']:
                    print(f"  - {test}")
        
        if summary['security_violations'] > 0:
            print("\nSECURITY VIOLATIONS:")
            for violation in results['security_tests']:
                print(f"  - {violation}")
        
        # Return exit code
        return 0 if summary['failed'] == 0 and summary['security_violations'] == 0 else 1

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Network infrastructure tests')
    parser.add_argument('--environment', required=True, help='Environment to test')
    args = parser.parse_args()
    
    tester = NetworkTester(args.environment)
    results = tester.run_all_tests()
    exit_code = tester.generate_report(results)
    
    # Save results for CI/CD
    with open(f'test-results-{args.environment}.json', 'w') as f:
        json.dump(results, f, indent=2)
    
    sys.exit(exit_code)
```

### Chaos Engineering for Networks

**Network Chaos Testing:**
```python
#!/usr/bin/env python3
# scripts/network_chaos.py
import random
import time
import subprocess
import boto3
from datetime import datetime

class NetworkChaosEngine:
    def __init__(self, environment):
        self.environment = environment
        self.ec2 = boto3.client('ec2')
        self.experiments = []
    
    def simulate_network_partition(self, duration=300):
        """Simulate network partition between subnets"""
        print(f"Starting network partition simulation for {duration} seconds...")
        
        # Get security groups
        sgs = self.ec2.describe_security_groups(
            Filters=[
                {'Name': 'tag:Environment', 'Values': [self.environment]}
            ]
        )
        
        # Temporarily block inter-subnet communication
        for sg in sgs['SecurityGroups']:
            # Add deny rule
            try:
                self.ec2.authorize_security_group_ingress(
                    GroupId=sg['GroupId'],
                    IpPermissions=[{
                        'IpProtocol': '-1',
                        'IpRanges': [{'CidrIp': '10.0.0.0/8', 'Description': 'Chaos-Block'}]
                    }]
                )
                print(f"Added chaos rule to {sg['GroupId']}")
            except Exception as e:
                print(f"Failed to add chaos rule: {e}")
        
        # Wait for duration
        time.sleep(duration)
        
        # Remove deny rules
        for sg in sgs['SecurityGroups']:
            try:
                self.ec2.revoke_security_group_ingress(
                    GroupId=sg['GroupId'],
                    IpPermissions=[{
                        'IpProtocol': '-1',
                        'IpRanges': [{'CidrIp': '10.0.0.0/8', 'Description': 'Chaos-Block'}]
                    }]
                )
                print(f"Removed chaos rule from {sg['GroupId']}")
            except Exception as e:
                print(f"Failed to remove chaos rule: {e}")
    
    def simulate_latency(self, target_instances, latency_ms=100, duration=300):
        """Add artificial latency to network traffic"""
        print(f"Adding {latency_ms}ms latency for {duration} seconds...")
        
        for instance_id in target_instances:
            # Use tc (traffic control) to add latency
            command = f"""
            sudo tc qdisc add dev eth0 root netem delay {latency_ms}ms
            sleep {duration}
            sudo tc qdisc del dev eth0 root
            """
            
            # Execute via SSM
            ssm = boto3.client('ssm')
            try:
                response = ssm.send_command(
                    InstanceIds=[instance_id],
                    DocumentName='AWS-RunShellScript',
                    Parameters={'commands': [command]}
                )
                print(f"Applied latency to {instance_id}")
            except Exception as e:
                print(f"Failed to apply latency to {instance_id}: {e}")
    
    def simulate_packet_loss(self, target_instances, loss_percent=5, duration=300):
        """Simulate packet loss"""
        print(f"Simulating {loss_percent}% packet loss for {duration} seconds...")
        
        for instance_id in target_instances:
            command = f"""
            sudo tc qdisc add dev eth0 root netem loss {loss_percent}%
            sleep {duration}
            sudo tc qdisc del dev eth0 root
            """
            
            ssm = boto3.client('ssm')
            try:
                response = ssm.send_command(
                    InstanceIds=[instance_id],
                    DocumentName='AWS-RunShellScript',
                    Parameters={'commands': [command]}
                )
                print(f"Applied packet loss to {instance_id}")
            except Exception as e:
                print(f"Failed to apply packet loss to {instance_id}: {e}")
    
    def run_experiment(self, experiment_type, **kwargs):
        """Run chaos experiment"""
        experiment = {
            'type': experiment_type,
            'start_time': datetime.utcnow().isoformat(),
            'parameters': kwargs
        }
        
        try:
            if experiment_type == 'network_partition':
                self.simulate_network_partition(kwargs.get('duration', 300))
            elif experiment_type == 'latency':
                self.simulate_latency(
                    kwargs.get('target_instances', []),
                    kwargs.get('latency_ms', 100),
                    kwargs.get('duration', 300)
                )
            elif experiment_type == 'packet_loss':
                self.simulate_packet_loss(
                    kwargs.get('target_instances', []),
                    kwargs.get('loss_percent', 5),
                    kwargs.get('duration', 300)
                )
            
            experiment['status'] = 'completed'
            experiment['end_time'] = datetime.utcnow().isoformat()
            
        except Exception as e:
            experiment['status'] = 'failed'
            experiment['error'] = str(e)
            experiment['end_time'] = datetime.utcnow().isoformat()
        
        self.experiments.append(experiment)
        return experiment

# Usage
if __name__ == '__main__':
    chaos = NetworkChaosEngine('staging')
    
    # Run network partition experiment
    chaos.run_experiment('network_partition', duration=60)
    
    # Run latency experiment
    target_instances = ['i-1234567890abcdef0']
    chaos.run_experiment('latency', 
                        target_instances=target_instances,
                        latency_ms=200,
                        duration=120)
```

## 📊 Network Compliance Automation

### Policy as Code

**Open Policy Agent (OPA) Network Policies:**
```rego
# policies/network_security.rego
package network.security

# Deny SSH access from 0.0.0.0/0
deny[msg] {
    input.resource_type == "aws_security_group_rule"
    input.type == "ingress"
    input.from_port == 22
    input.to_port == 22
    input.cidr_blocks[_] == "0.0.0.0/0"
    msg := "SSH access should not be open to 0.0.0.0/0"
}

# Require encryption for database connections
deny[msg] {
    input.resource_type == "aws_db_instance"
    not input.storage_encrypted
    msg := "Database instances must have encryption enabled"
}

# Ensure VPC flow logs are enabled
deny[msg] {
    input.resource_type == "aws_vpc"
    not has_flow_logs
    msg := "VPC must have flow logs enabled"
}

has_flow_logs {
    input.flow_logs_enabled == true
}
```

**Compliance Scanning Script:**
```python
#!/usr/bin/env python3
# scripts/compliance_scan.py
import json
import subprocess
import boto3
from typing import List, Dict

class ComplianceScanner:
    def __init__(self):
        self.ec2 = boto3.client('ec2')
        self.violations = []
    
    def scan_security_groups(self) -> List[Dict]:
        """Scan security groups for compliance violations"""
        violations = []
        
        response = self.ec2.describe_security_groups()
        
        for sg in response['SecurityGroups']:
            # Check for overly permissive rules
            for rule in sg.get('IpPermissions', []):
                for ip_range in rule.get('IpRanges', []):
                    if ip_range.get('CidrIp') == '0.0.0.0/0':
                        # Check for dangerous ports
                        dangerous_ports = [22, 3389, 1433, 3306, 5432]
                        from_port = rule.get('FromPort', 0)
                        to_port = rule.get('ToPort', 65535)
                        
                        for port in dangerous_ports:
                            if from_port <= port <= to_port:
                                violations.append({
                                    'type': 'security_group_violation',
                                    'resource_id': sg['GroupId'],
                                    'violation': f'Port {port} open to 0.0.0.0/0',
                                    'severity': 'high',
                                    'remediation': f'Restrict access to port {port}'
                                })
        
        return violations
    
    def scan_vpc_flow_logs(self) -> List[Dict]:
        """Check if VPCs have flow logs enabled"""
        violations = []
        
        vpcs = self.ec2.describe_vpcs()
        flow_logs = self.ec2.describe_flow_logs()
        
        vpc_with_logs = {fl['ResourceId'] for fl in flow_logs['FlowLogs']}
        
        for vpc in vpcs['Vpcs']:
            if vpc['VpcId'] not in vpc_with_logs:
                violations.append({
                    'type': 'vpc_flow_logs',
                    'resource_id': vpc['VpcId'],
                    'violation': 'VPC flow logs not enabled',
                    'severity': 'medium',
                    'remediation': 'Enable VPC flow logs for monitoring'
                })
        
        return violations
    
    def scan_nacl_rules(self) -> List[Dict]:
        """Scan Network ACL rules for compliance"""
        violations = []
        
        nacls = self.ec2.describe_network_acls()
        
        for nacl in nacls['NetworkAcls']:
            for entry in nacl['Entries']:
                # Check for overly permissive ALLOW rules
                if (entry['RuleAction'] == 'allow' and 
                    entry.get('CidrBlock') == '0.0.0.0/0' and
                    entry.get('PortRange', {}).get('From', 0) <= 22 <= 
                    entry.get('PortRange', {}).get('To', 65535)):
                    
                    violations.append({
                        'type': 'nacl_violation',
                        'resource_id': nacl['NetworkAclId'],
                        'violation': 'NACL allows SSH from anywhere',
                        'severity': 'high',
                        'remediation': 'Restrict SSH access in NACL'
                    })
        
        return violations
    
    def run_opa_policies(self, terraform_plan: str) -> List[Dict]:
        """Run OPA policies against Terraform plan"""
        violations = []
        
        try:
            # Run OPA evaluation
            result = subprocess.run([
                'opa', 'eval', '-d', 'policies/', '-i', terraform_plan,
                'data.network.security.deny[x]'
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                opa_results = json.loads(result.stdout)
                for violation in opa_results.get('result', []):
                    violations.append({
                        'type': 'policy_violation',
                        'violation': violation,
                        'severity': 'high',
                        'source': 'opa'
                    })
        
        except Exception as e:
            print(f"OPA evaluation failed: {e}")
        
        return violations
    
    def generate_compliance_report(self) -> Dict:
        """Generate comprehensive compliance report"""
        print("Running compliance scan...")
        
        all_violations = []
        all_violations.extend(self.scan_security_groups())
        all_violations.extend(self.scan_vpc_flow_logs())
        all_violations.extend(self.scan_nacl_rules())
        
        # Categorize by severity
        high_severity = [v for v in all_violations if v['severity'] == 'high']
        medium_severity = [v for v in all_violations if v['severity'] == 'medium']
        low_severity = [v for v in all_violations if v['severity'] == 'low']
        
        report = {
            'scan_timestamp': datetime.utcnow().isoformat(),
            'total_violations': len(all_violations),
            'high_severity_count': len(high_severity),
            'medium_severity_count': len(medium_severity),
            'low_severity_count': len(low_severity),
            'violations': all_violations,
            'compliance_score': max(0, 100 - (len(high_severity) * 10 + 
                                            len(medium_severity) * 5 + 
                                            len(low_severity) * 1))
        }
        
        return report

# Usage
if __name__ == '__main__':
    scanner = ComplianceScanner()
    report = scanner.generate_compliance_report()
    
    print(f"Compliance Score: {report['compliance_score']}/100")
    print(f"Total Violations: {report['total_violations']}")
    
    if report['high_severity_count'] > 0:
        print(f"HIGH SEVERITY VIOLATIONS: {report['high_severity_count']}")
        sys.exit(1)
    
    # Save report
    with open('compliance-report.json', 'w') as f:
        json.dump(report, f, indent=2)
```

## ✅ Knowledge Check

- [ ] Implement Infrastructure as Code for networks
- [ ] Design GitOps workflows for network changes
- [ ] Build automated network testing pipelines
- [ ] Create network compliance automation
- [ ] Develop chaos engineering for networks
- [ ] Integrate network automation with CI/CD
- [ ] Monitor and alert on network changes

## 🔗 Next Steps

- [Performance Optimization](readme.md) - Automated performance tuning
- [Cloud Networking](readme.md) - Cloud automation integration
- [Service Mesh](readme.md) - Service mesh automation