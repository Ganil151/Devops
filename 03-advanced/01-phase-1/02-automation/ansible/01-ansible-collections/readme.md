# 01-Ansible-Collections

Master the development, packaging, and distribution of Ansible Collections for enterprise-scale automation.

## 🎯 Module Objectives

By completing this module, you will:
- Understand Ansible Collections architecture and benefits
- Design and develop comprehensive Collections
- Implement collection testing and CI/CD pipelines
- Publish collections to Galaxy and private repositories
- Manage collection dependencies and versioning
- Create enterprise collection standards and governance
- Contribute to the Ansible ecosystem

## 📚 Topics Covered

### What are Ansible Collections?

Collections are a distribution format for Ansible content that can include:
- **Modules**: Custom automation units
- **Plugins**: Filters, lookups, callbacks, and more
- **Roles**: Reusable automation components
- **Playbooks**: Complete automation workflows
- **Documentation**: Comprehensive guides and examples

### Collections vs. Roles

| Aspect | Roles | Collections |
|--------|-------|-------------|
| **Scope** | Single automation component | Multiple related components |
| **Content** | Tasks, handlers, templates, files | Modules, plugins, roles, playbooks |
| **Distribution** | Galaxy, Git repositories | Galaxy, Automation Hub, private repos |
| **Versioning** | Git tags, Galaxy versions | Semantic versioning with dependencies |
| **Namespace** | Role name only | Namespace.collection.component |
| **Dependencies** | Role dependencies | Collection dependencies |

### Collection Benefits

#### Enterprise Advantages
- **Standardization**: Consistent automation patterns across organization
- **Governance**: Centralized control over automation content
- **Reusability**: Share automation across teams and projects
- **Versioning**: Semantic versioning with dependency management
- **Testing**: Comprehensive testing frameworks and CI/CD integration

#### Technical Benefits
- **Modularity**: Logical grouping of related automation content
- **Namespace Management**: Avoid naming conflicts
- **Dependency Resolution**: Automatic dependency management
- **Performance**: Optimized content loading and execution
- **Extensibility**: Plugin architecture for custom functionality

## 🏗️ Collection Structure

### Standard Collection Layout

```
my_namespace/
└── my_collection/
    ├── galaxy.yml                    # Collection metadata
    ├── README.md                     # Collection documentation
    ├── CHANGELOG.md                  # Version history
    ├── LICENSE                       # License information
    ├── requirements.txt              # Python dependencies
    ├── bindep.txt                    # System dependencies
    ├── meta/
    │   └── runtime.yml              # Runtime requirements
    ├── plugins/
    │   ├── modules/                 # Custom modules
    │   │   ├── __init__.py
    │   │   ├── my_module.py
    │   │   └── another_module.py
    │   ├── inventory/               # Inventory plugins
    │   ├── lookup/                  # Lookup plugins
    │   ├── filter/                  # Filter plugins
    │   ├── test/                    # Test plugins
    │   ├── callback/                # Callback plugins
    │   ├── connection/              # Connection plugins
    │   ├── httpapi/                 # HTTP API plugins
    │   ├── netconf/                 # NETCONF plugins
    │   ├── terminal/                # Terminal plugins
    │   ├── cliconf/                 # CLI configuration plugins
    │   ├── become/                  # Become plugins
    │   ├── cache/                   # Cache plugins
    │   ├── vars/                    # Variables plugins
    │   └── doc_fragments/           # Documentation fragments
    ├── roles/                       # Collection roles
    │   ├── role1/
    │   ├── role2/
    │   └── role3/
    ├── playbooks/                   # Collection playbooks
    │   ├── site.yml
    │   ├── deploy.yml
    │   └── maintenance.yml
    ├── tests/                       # Collection tests
    │   ├── integration/
    │   ├── unit/
    │   └── sanity/
    └── docs/                        # Additional documentation
        ├── guides/
        ├── examples/
        └── api/
```

### Collection Metadata (galaxy.yml)

```yaml
# galaxy.yml
---
namespace: my_namespace
name: my_collection
version: 1.0.0
readme: README.md
authors:
  - "Your Name <your.email@example.com>"
  - "Team Name <team@example.com>"

description: >-
  Comprehensive collection for enterprise infrastructure automation
  including cloud provisioning, configuration management, and monitoring.

license:
  - MIT

license_file: LICENSE

tags:
  - infrastructure
  - cloud
  - automation
  - monitoring
  - security

dependencies:
  "ansible.posix": ">=1.3.0"
  "community.general": ">=4.0.0"
  "community.crypto": ">=2.0.0"
  "amazon.aws": ">=3.0.0"

repository: https://github.com/my_namespace/ansible-collection-my_collection
documentation: https://my-collection-docs.example.com
homepage: https://my-collection.example.com
issues: https://github.com/my_namespace/ansible-collection-my_collection/issues

build_ignore:
  - "*.tar.gz"
  - ".git"
  - ".github"
  - "tests/output"
  - "*.pyc"
  - "__pycache__"
  - ".pytest_cache"
  - ".vscode"
  - ".idea"
```

### Runtime Requirements (meta/runtime.yml)

```yaml
# meta/runtime.yml
---
requires_ansible: ">=2.12.0"

plugin_routing:
  modules:
    # Redirect old module names to new ones
    old_module_name:
      redirect: my_namespace.my_collection.new_module_name
    deprecated_module:
      deprecation:
        removal_version: "2.0.0"
        warning_text: "This module is deprecated. Use new_module instead."

  inventory:
    old_inventory_plugin:
      redirect: my_namespace.my_collection.new_inventory_plugin

action_groups:
  # Group related modules for easier use
  cloud_management:
    - my_namespace.my_collection.ec2_instance
    - my_namespace.my_collection.s3_bucket
    - my_namespace.my_collection.rds_instance
  
  monitoring:
    - my_namespace.my_collection.prometheus_config
    - my_namespace.my_collection.grafana_dashboard
    - my_namespace.my_collection.alertmanager_rule
```

## 🛠️ Collection Development

### 1. Planning and Design

#### Collection Architecture
```yaml
# Collection design document
collection_name: enterprise_infrastructure
namespace: mycompany
purpose: Enterprise infrastructure automation and management

components:
  modules:
    - cloud_instance: Manage cloud instances across providers
    - load_balancer: Configure load balancers
    - database_cluster: Manage database clusters
    - monitoring_stack: Deploy monitoring solutions
  
  roles:
    - common: Base system configuration
    - webserver: Web server deployment
    - database: Database server setup
    - monitoring: Monitoring stack deployment
  
  plugins:
    - inventory: Dynamic inventory for multiple clouds
    - lookup: Custom data lookups
    - filter: Data transformation filters
    - callback: Custom reporting callbacks

target_platforms:
  - AWS
  - Azure
  - Google Cloud
  - VMware vSphere
  - OpenStack

integration_points:
  - CI/CD pipelines
  - Monitoring systems
  - Configuration management
  - Security tools
```

### 2. Collection Initialization

#### Using ansible-galaxy
```bash
# Create collection structure
ansible-galaxy collection init mycompany.enterprise_infrastructure

# Create in specific directory
ansible-galaxy collection init mycompany.enterprise_infrastructure --init-path ./collections/

# Verify structure
tree collections/ansible_collections/mycompany/enterprise_infrastructure/
```

#### Manual Setup
```bash
# Create collection directory structure
mkdir -p collections/ansible_collections/mycompany/enterprise_infrastructure
cd collections/ansible_collections/mycompany/enterprise_infrastructure

# Create basic structure
mkdir -p {plugins/{modules,inventory,lookup,filter,callback},roles,playbooks,tests/{unit,integration,sanity},docs}

# Create metadata files
touch galaxy.yml README.md CHANGELOG.md LICENSE
touch meta/runtime.yml
```

### 3. Module Development

#### Custom Module Example
```python
# plugins/modules/cloud_instance.py
#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2023, Your Name <your.email@example.com>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: cloud_instance
short_description: Manage cloud instances across multiple providers
version_added: "1.0.0"
description:
    - Create, modify, and delete cloud instances
    - Support for AWS, Azure, and Google Cloud
    - Unified interface across cloud providers
author:
    - "Your Name (@your_github_username)"
options:
    provider:
        description:
            - Cloud provider to use
        required: true
        type: str
        choices: ['aws', 'azure', 'gcp']
    name:
        description:
            - Name of the instance
        required: true
        type: str
    state:
        description:
            - Desired state of the instance
        type: str
        choices: ['present', 'absent', 'running', 'stopped']
        default: present
    instance_type:
        description:
            - Instance type/size
        type: str
        required: true
    image:
        description:
            - Image ID or name to use for the instance
        type: str
        required: true
    region:
        description:
            - Region where the instance should be created
        type: str
        required: true
    tags:
        description:
            - Tags to apply to the instance
        type: dict
        default: {}
    wait:
        description:
            - Wait for the instance to reach desired state
        type: bool
        default: true
    wait_timeout:
        description:
            - Maximum time to wait for state change
        type: int
        default: 600
requirements:
    - boto3 (for AWS)
    - azure-mgmt-compute (for Azure)
    - google-cloud-compute (for GCP)
notes:
    - Requires appropriate cloud provider credentials
    - Instance types vary by provider
extends_documentation_fragment:
    - mycompany.enterprise_infrastructure.cloud_auth
'''

EXAMPLES = r'''
# Create an AWS EC2 instance
- name: Create EC2 instance
  mycompany.enterprise_infrastructure.cloud_instance:
    provider: aws
    name: web-server-01
    instance_type: t3.medium
    image: ami-0c02fb55956c7d316
    region: us-east-1
    tags:
      Environment: production
      Role: webserver
    state: present

# Create an Azure VM
- name: Create Azure VM
  mycompany.enterprise_infrastructure.cloud_instance:
    provider: azure
    name: web-server-01
    instance_type: Standard_B2s
    image: UbuntuLTS
    region: eastus
    tags:
      Environment: production
      Role: webserver
    state: present

# Stop an instance
- name: Stop instance
  mycompany.enterprise_infrastructure.cloud_instance:
    provider: aws
    name: web-server-01
    state: stopped
'''

RETURN = r'''
instance:
    description: Instance information
    returned: always
    type: dict
    contains:
        id:
            description: Instance ID
            type: str
            sample: "i-1234567890abcdef0"
        name:
            description: Instance name
            type: str
            sample: "web-server-01"
        state:
            description: Current instance state
            type: str
            sample: "running"
        public_ip:
            description: Public IP address
            type: str
            sample: "203.0.113.1"
        private_ip:
            description: Private IP address
            type: str
            sample: "10.0.1.100"
        tags:
            description: Instance tags
            type: dict
            sample: {"Environment": "production", "Role": "webserver"}
changed:
    description: Whether the instance was changed
    returned: always
    type: bool
    sample: true
'''

from ansible.module_utils.basic import AnsibleModule
from ansible_collections.mycompany.enterprise_infrastructure.plugins.module_utils.cloud_base import CloudBase

def main():
    module_args = dict(
        provider=dict(type='str', required=True, choices=['aws', 'azure', 'gcp']),
        name=dict(type='str', required=True),
        state=dict(type='str', default='present', choices=['present', 'absent', 'running', 'stopped']),
        instance_type=dict(type='str', required=True),
        image=dict(type='str', required=True),
        region=dict(type='str', required=True),
        tags=dict(type='dict', default={}),
        wait=dict(type='bool', default=True),
        wait_timeout=dict(type='int', default=600)
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # Initialize cloud provider handler
    cloud = CloudBase(module)
    
    try:
        result = cloud.manage_instance()
        module.exit_json(**result)
    except Exception as e:
        module.fail_json(msg=str(e))

if __name__ == '__main__':
    main()
```

#### Module Utilities
```python
# plugins/module_utils/cloud_base.py
# -*- coding: utf-8 -*-

from __future__ import absolute_import, division, print_function
__metaclass__ = type

import time
from abc import ABC, abstractmethod

class CloudBase(ABC):
    """Base class for cloud provider implementations"""
    
    def __init__(self, module):
        self.module = module
        self.provider = module.params['provider']
        self.name = module.params['name']
        self.state = module.params['state']
        self.instance_type = module.params['instance_type']
        self.image = module.params['image']
        self.region = module.params['region']
        self.tags = module.params['tags']
        self.wait = module.params['wait']
        self.wait_timeout = module.params['wait_timeout']
        
        # Initialize provider-specific client
        self.client = self._get_client()
    
    def manage_instance(self):
        """Main method to manage instance lifecycle"""
        existing_instance = self._get_instance()
        
        if self.state == 'present':
            if existing_instance:
                return self._update_instance(existing_instance)
            else:
                return self._create_instance()
        
        elif self.state == 'absent':
            if existing_instance:
                return self._delete_instance(existing_instance)
            else:
                return {'changed': False, 'instance': None}
        
        elif self.state in ['running', 'stopped']:
            if existing_instance:
                return self._change_instance_state(existing_instance)
            else:
                self.module.fail_json(msg=f"Instance {self.name} not found")
    
    @abstractmethod
    def _get_client(self):
        """Get cloud provider client"""
        pass
    
    @abstractmethod
    def _get_instance(self):
        """Get existing instance"""
        pass
    
    @abstractmethod
    def _create_instance(self):
        """Create new instance"""
        pass
    
    @abstractmethod
    def _update_instance(self, instance):
        """Update existing instance"""
        pass
    
    @abstractmethod
    def _delete_instance(self, instance):
        """Delete instance"""
        pass
    
    @abstractmethod
    def _change_instance_state(self, instance):
        """Change instance state"""
        pass
```

### 4. Plugin Development

#### Custom Filter Plugin
```python
# plugins/filter/cloud_filters.py
# -*- coding: utf-8 -*-

from __future__ import absolute_import, division, print_function
__metaclass__ = type

import re
from ansible.errors import AnsibleFilterError

def cloud_instance_name(value, environment=None, role=None):
    """
    Generate standardized cloud instance name
    
    Args:
        value: Base name
        environment: Environment (dev, staging, prod)
        role: Instance role (web, db, cache)
    
    Returns:
        Standardized instance name
    """
    if not isinstance(value, str):
        raise AnsibleFilterError("cloud_instance_name requires string input")
    
    # Clean base name
    clean_name = re.sub(r'[^a-zA-Z0-9-]', '-', value.lower())
    
    # Build name components
    name_parts = [clean_name]
    
    if environment:
        name_parts.append(environment.lower())
    
    if role:
        name_parts.append(role.lower())
    
    return '-'.join(name_parts)

def cloud_tags_merge(base_tags, additional_tags=None):
    """
    Merge cloud tags with validation
    
    Args:
        base_tags: Base tag dictionary
        additional_tags: Additional tags to merge
    
    Returns:
        Merged tag dictionary
    """
    if not isinstance(base_tags, dict):
        raise AnsibleFilterError("base_tags must be a dictionary")
    
    result = base_tags.copy()
    
    if additional_tags:
        if not isinstance(additional_tags, dict):
            raise AnsibleFilterError("additional_tags must be a dictionary")
        result.update(additional_tags)
    
    # Validate tag values
    for key, value in result.items():
        if not isinstance(key, str) or not isinstance(value, str):
            raise AnsibleFilterError("Tag keys and values must be strings")
        if len(key) > 128 or len(value) > 256:
            raise AnsibleFilterError("Tag key/value length exceeds limits")
    
    return result

def cloud_region_az(region, az_suffix='a'):
    """
    Generate availability zone from region
    
    Args:
        region: Cloud region
        az_suffix: AZ suffix (a, b, c)
    
    Returns:
        Availability zone
    """
    if not isinstance(region, str):
        raise AnsibleFilterError("Region must be a string")
    
    return f"{region}{az_suffix}"

class FilterModule(object):
    """Ansible filter plugin for cloud operations"""
    
    def filters(self):
        return {
            'cloud_instance_name': cloud_instance_name,
            'cloud_tags_merge': cloud_tags_merge,
            'cloud_region_az': cloud_region_az,
        }
```

#### Custom Lookup Plugin
```python
# plugins/lookup/cloud_inventory.py
# -*- coding: utf-8 -*-

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r"""
name: cloud_inventory
author: Your Name <your.email@example.com>
version_added: "1.0.0"
short_description: Look up cloud instances across providers
description:
    - Retrieve instance information from multiple cloud providers
    - Support for AWS, Azure, and Google Cloud
    - Filter instances by tags, state, and other attributes
options:
    provider:
        description: Cloud provider
        type: str
        required: true
        choices: ['aws', 'azure', 'gcp']
    region:
        description: Cloud region to search
        type: str
        required: true
    filters:
        description: Filters to apply to instance search
        type: dict
        default: {}
    state:
        description: Instance state filter
        type: str
        choices: ['running', 'stopped', 'terminated']
        default: 'running'
requirements:
    - boto3 (for AWS)
    - azure-mgmt-compute (for Azure)
    - google-cloud-compute (for GCP)
"""

EXAMPLES = r"""
# Get all running instances in AWS us-east-1
- name: Get AWS instances
  debug:
    msg: "{{ lookup('mycompany.enterprise_infrastructure.cloud_inventory', 
                    provider='aws', region='us-east-1') }}"

# Get instances with specific tags
- name: Get production web servers
  debug:
    msg: "{{ lookup('mycompany.enterprise_infrastructure.cloud_inventory',
                    provider='aws', region='us-east-1',
                    filters={'tag:Environment': 'production', 'tag:Role': 'webserver'}) }}"

# Get stopped instances
- name: Get stopped instances
  debug:
    msg: "{{ lookup('mycompany.enterprise_infrastructure.cloud_inventory',
                    provider='aws', region='us-east-1', state='stopped') }}"
"""

RETURN = r"""
_list:
    description: List of cloud instances
    type: list
    elements: dict
    contains:
        id:
            description: Instance ID
            type: str
        name:
            description: Instance name
            type: str
        state:
            description: Instance state
            type: str
        public_ip:
            description: Public IP address
            type: str
        private_ip:
            description: Private IP address
            type: str
        tags:
            description: Instance tags
            type: dict
"""

from ansible.errors import AnsibleError
from ansible.plugins.lookup import LookupBase
from ansible.utils.display import Display

display = Display()

class LookupModule(LookupBase):
    
    def run(self, terms, variables=None, **kwargs):
        # Set default options
        self.set_options(var_options=variables, direct=kwargs)
        
        provider = self.get_option('provider')
        region = self.get_option('region')
        filters = self.get_option('filters')
        state = self.get_option('state')
        
        try:
            if provider == 'aws':
                return self._lookup_aws_instances(region, filters, state)
            elif provider == 'azure':
                return self._lookup_azure_instances(region, filters, state)
            elif provider == 'gcp':
                return self._lookup_gcp_instances(region, filters, state)
            else:
                raise AnsibleError(f"Unsupported provider: {provider}")
        
        except Exception as e:
            raise AnsibleError(f"Failed to lookup cloud instances: {str(e)}")
    
    def _lookup_aws_instances(self, region, filters, state):
        """Lookup AWS EC2 instances"""
        try:
            import boto3
        except ImportError:
            raise AnsibleError("boto3 is required for AWS lookups")
        
        ec2 = boto3.client('ec2', region_name=region)
        
        # Build EC2 filters
        ec2_filters = []
        if state:
            ec2_filters.append({'Name': 'instance-state-name', 'Values': [state]})
        
        for key, value in filters.items():
            if key.startswith('tag:'):
                ec2_filters.append({'Name': key, 'Values': [value]})
        
        response = ec2.describe_instances(Filters=ec2_filters)
        
        instances = []
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                instances.append(self._format_aws_instance(instance))
        
        return instances
    
    def _format_aws_instance(self, instance):
        """Format AWS instance data"""
        tags = {tag['Key']: tag['Value'] for tag in instance.get('Tags', [])}
        
        return {
            'id': instance['InstanceId'],
            'name': tags.get('Name', instance['InstanceId']),
            'state': instance['State']['Name'],
            'public_ip': instance.get('PublicIpAddress', ''),
            'private_ip': instance.get('PrivateIpAddress', ''),
            'tags': tags
        }
    
    def _lookup_azure_instances(self, region, filters, state):
        """Lookup Azure VMs"""
        # Implementation for Azure
        pass
    
    def _lookup_gcp_instances(self, region, filters, state):
        """Lookup GCP instances"""
        # Implementation for GCP
        pass
```

### 5. Collection Testing

#### Unit Tests
```python
# tests/unit/plugins/modules/test_cloud_instance.py
import pytest
from unittest.mock import Mock, patch
from ansible_collections.mycompany.enterprise_infrastructure.plugins.modules import cloud_instance

class TestCloudInstanceModule:
    
    def test_module_args(self):
        """Test module argument specification"""
        module_args = cloud_instance.main.__code__.co_names
        assert 'AnsibleModule' in module_args
    
    @patch('ansible_collections.mycompany.enterprise_infrastructure.plugins.modules.cloud_instance.CloudBase')
    def test_aws_instance_creation(self, mock_cloud_base):
        """Test AWS instance creation"""
        # Mock module
        mock_module = Mock()
        mock_module.params = {
            'provider': 'aws',
            'name': 'test-instance',
            'state': 'present',
            'instance_type': 't3.micro',
            'image': 'ami-12345',
            'region': 'us-east-1',
            'tags': {'Environment': 'test'},
            'wait': True,
            'wait_timeout': 600
        }
        
        # Mock cloud base
        mock_cloud = Mock()
        mock_cloud.manage_instance.return_value = {
            'changed': True,
            'instance': {
                'id': 'i-12345',
                'name': 'test-instance',
                'state': 'running'
            }
        }
        mock_cloud_base.return_value = mock_cloud
        
        # Test module execution
        with patch('ansible_collections.mycompany.enterprise_infrastructure.plugins.modules.cloud_instance.AnsibleModule', return_value=mock_module):
            cloud_instance.main()
        
        mock_module.exit_json.assert_called_once()
```

#### Integration Tests
```yaml
# tests/integration/targets/cloud_instance/tasks/main.yml
---
- name: Test cloud instance module
  block:
    - name: Create test instance
      mycompany.enterprise_infrastructure.cloud_instance:
        provider: "{{ test_provider }}"
        name: "{{ test_instance_name }}"
        instance_type: "{{ test_instance_type }}"
        image: "{{ test_image }}"
        region: "{{ test_region }}"
        tags:
          Environment: test
          CreatedBy: ansible-test
        state: present
      register: create_result
    
    - name: Verify instance creation
      assert:
        that:
          - create_result.changed
          - create_result.instance.name == test_instance_name
          - create_result.instance.state == "running"
    
    - name: Test instance idempotency
      mycompany.enterprise_infrastructure.cloud_instance:
        provider: "{{ test_provider }}"
        name: "{{ test_instance_name }}"
        instance_type: "{{ test_instance_type }}"
        image: "{{ test_image }}"
        region: "{{ test_region }}"
        tags:
          Environment: test
          CreatedBy: ansible-test
        state: present
      register: idempotent_result
    
    - name: Verify idempotency
      assert:
        that:
          - not idempotent_result.changed
    
    - name: Stop instance
      mycompany.enterprise_infrastructure.cloud_instance:
        provider: "{{ test_provider }}"
        name: "{{ test_instance_name }}"
        state: stopped
      register: stop_result
    
    - name: Verify instance stopped
      assert:
        that:
          - stop_result.changed
          - stop_result.instance.state == "stopped"
  
  always:
    - name: Clean up test instance
      mycompany.enterprise_infrastructure.cloud_instance:
        provider: "{{ test_provider }}"
        name: "{{ test_instance_name }}"
        state: absent
      ignore_errors: yes
```

#### Sanity Tests Configuration
```yaml
# tests/sanity/ignore-2.12.txt
plugins/modules/cloud_instance.py validate-modules:missing-gplv3-license
plugins/filter/cloud_filters.py import-3.6
plugins/lookup/cloud_inventory.py import-3.7
```

### 6. CI/CD Pipeline

#### GitHub Actions Workflow
```yaml
# .github/workflows/ci.yml
name: Collection CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  sanity:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        ansible-version: [2.12, 2.13, 2.14]
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        with:
          path: ansible_collections/mycompany/enterprise_infrastructure
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install ansible==${{ matrix.ansible-version }}.*
          pip install -r requirements.txt
        working-directory: ansible_collections/mycompany/enterprise_infrastructure
      
      - name: Run sanity tests
        run: ansible-test sanity --docker -v
        working-directory: ansible_collections/mycompany/enterprise_infrastructure

  unit:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8, 3.9, '3.10']
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        with:
          path: ansible_collections/mycompany/enterprise_infrastructure
      
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install ansible pytest pytest-ansible
          pip install -r requirements.txt
        working-directory: ansible_collections/mycompany/enterprise_infrastructure
      
      - name: Run unit tests
        run: ansible-test units --docker -v
        working-directory: ansible_collections/mycompany/enterprise_infrastructure

  integration:
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        with:
          path: ansible_collections/mycompany/enterprise_infrastructure
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install ansible
          pip install -r requirements.txt
        working-directory: ansible_collections/mycompany/enterprise_infrastructure
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Run integration tests
        run: ansible-test integration cloud_instance --docker -v
        working-directory: ansible_collections/mycompany/enterprise_infrastructure
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

  build:
    runs-on: ubuntu-latest
    needs: [sanity, unit]
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        with:
          path: ansible_collections/mycompany/enterprise_infrastructure
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install ansible
      
      - name: Build collection
        run: ansible-galaxy collection build
        working-directory: ansible_collections/mycompany/enterprise_infrastructure
      
      - name: Upload collection artifact
        uses: actions/upload-artifact@v3
        with:
          name: collection-tarball
          path: ansible_collections/mycompany/enterprise_infrastructure/*.tar.gz

  publish:
    runs-on: ubuntu-latest
    needs: [build, integration]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    
    steps:
      - name: Download collection artifact
        uses: actions/download-artifact@v3
        with:
          name: collection-tarball
      
      - name: Publish to Galaxy
        run: |
          ansible-galaxy collection publish *.tar.gz --api-key ${{ secrets.GALAXY_API_KEY }}
```

## 🛠️ Hands-On Labs

### Lab 1: Create Enterprise Infrastructure Collection
**Duration**: 6 hours

#### Objectives
- Design comprehensive collection architecture
- Implement custom modules and plugins
- Create collection documentation
- Set up testing framework

#### Tasks

1. **Initialize Collection Structure**
   ```bash
   # Create collection
   mkdir -p collections/ansible_collections/enterprise/infrastructure
   cd collections/ansible_collections/enterprise/infrastructure
   
   # Initialize with ansible-galaxy
   ansible-galaxy collection init enterprise.infrastructure --init-path ../../..
   ```

2. **Define Collection Metadata**
   ```yaml
   # galaxy.yml
   ---
   namespace: enterprise
   name: infrastructure
   version: 1.0.0
   readme: README.md
   authors:
     - "Enterprise DevOps Team <devops@enterprise.com>"
   
   description: >-
     Enterprise infrastructure automation collection providing
     unified cloud management, monitoring, and security automation.
   
   license:
     - Apache-2.0
   
   tags:
     - infrastructure
     - cloud
     - monitoring
     - security
     - automation
   
   dependencies:
     "ansible.posix": ">=1.3.0"
     "community.general": ">=4.0.0"
     "amazon.aws": ">=3.0.0"
   
   repository: https://github.com/enterprise/ansible-collection-infrastructure
   documentation: https://enterprise-infrastructure-docs.example.com
   homepage: https://enterprise-infrastructure.example.com
   issues: https://github.com/enterprise/ansible-collection-infrastructure/issues
   ```

3. **Create Custom Module**
   ```python
   # plugins/modules/server_deployment.py
   #!/usr/bin/python
   
   DOCUMENTATION = r'''
   ---
   module: server_deployment
   short_description: Deploy and manage enterprise servers
   version_added: "1.0.0"
   description:
       - Deploy servers with enterprise standards
       - Configure monitoring and security
       - Manage server lifecycle
   options:
       name:
           description: Server name
           required: true
           type: str
       environment:
           description: Deployment environment
           required: true
           type: str
           choices: ['dev', 'staging', 'prod']
       server_type:
           description: Type of server to deploy
           required: true
           type: str
           choices: ['web', 'app', 'db', 'cache']
       instance_size:
           description: Instance size
           type: str
           default: 'medium'
       monitoring_enabled:
           description: Enable monitoring
           type: bool
           default: true
       backup_enabled:
           description: Enable backups
           type: bool
           default: true
   '''
   
   EXAMPLES = r'''
   - name: Deploy web server
     enterprise.infrastructure.server_deployment:
       name: web-01
       environment: prod
       server_type: web
       instance_size: large
       monitoring_enabled: true
       backup_enabled: true
   '''
   
   from ansible.module_utils.basic import AnsibleModule
   
   def main():
       module_args = dict(
           name=dict(type='str', required=True),
           environment=dict(type='str', required=True, choices=['dev', 'staging', 'prod']),
           server_type=dict(type='str', required=True, choices=['web', 'app', 'db', 'cache']),
           instance_size=dict(type='str', default='medium'),
           monitoring_enabled=dict(type='bool', default=True),
           backup_enabled=dict(type='bool', default=True)
       )
   
       module = AnsibleModule(
           argument_spec=module_args,
           supports_check_mode=True
       )
   
       # Implementation logic here
       result = {
           'changed': True,
           'server': {
               'name': module.params['name'],
               'environment': module.params['environment'],
               'type': module.params['server_type'],
               'status': 'deployed'
           }
       }
   
       module.exit_json(**result)
   
   if __name__ == '__main__':
       main()
   ```

4. **Create Filter Plugin**
   ```python
   # plugins/filter/enterprise_filters.py
   
   def enterprise_server_name(name, environment, server_type):
       """Generate enterprise standard server name"""
       return f"{environment}-{server_type}-{name}"
   
   def enterprise_tags(base_tags, environment, cost_center=None):
       """Generate enterprise standard tags"""
       tags = base_tags.copy()
       tags.update({
           'Environment': environment,
           'ManagedBy': 'Ansible',
           'CreatedDate': '{{ ansible_date_time.date }}'
       })
       
       if cost_center:
           tags['CostCenter'] = cost_center
       
       return tags
   
   class FilterModule(object):
       def filters(self):
           return {
               'enterprise_server_name': enterprise_server_name,
               'enterprise_tags': enterprise_tags,
           }
   ```

5. **Create Collection Role**
   ```bash
   # Create monitoring role
   mkdir -p roles/monitoring
   cd roles/monitoring
   ansible-galaxy init . --offline
   ```

   ```yaml
   # roles/monitoring/tasks/main.yml
   ---
   - name: Install monitoring agent
     package:
       name: "{{ monitoring_agent_package }}"
       state: present
   
   - name: Configure monitoring agent
     template:
       src: agent.conf.j2
       dest: /etc/monitoring/agent.conf
       owner: root
       group: root
       mode: '0644'
     notify: restart monitoring agent
   
   - name: Start monitoring service
     service:
       name: "{{ monitoring_service_name }}"
       state: started
       enabled: yes
   ```

### Lab 2: Collection Testing and CI/CD
**Duration**: 4 hours

#### Objectives
- Implement comprehensive testing
- Set up CI/CD pipeline
- Validate collection quality

#### Tasks

1. **Create Unit Tests**
   ```python
   # tests/unit/plugins/modules/test_server_deployment.py
   import pytest
   from unittest.mock import Mock
   from ansible_collections.enterprise.infrastructure.plugins.modules import server_deployment
   
   def test_module_args():
       """Test module argument validation"""
       # Test implementation
       pass
   
   def test_server_deployment():
       """Test server deployment logic"""
       # Test implementation
       pass
   ```

2. **Create Integration Tests**
   ```yaml
   # tests/integration/targets/server_deployment/tasks/main.yml
   ---
   - name: Test server deployment
     enterprise.infrastructure.server_deployment:
       name: test-server
       environment: dev
       server_type: web
       instance_size: small
     register: deployment_result
   
   - name: Verify deployment
     assert:
       that:
         - deployment_result.changed
         - deployment_result.server.name == "test-server"
   ```

3. **Set Up GitHub Actions**
   ```yaml
   # .github/workflows/collection-ci.yml
   name: Collection CI/CD
   
   on:
     push:
       branches: [main]
     pull_request:
       branches: [main]
   
   jobs:
     test:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - name: Set up Python
           uses: actions/setup-python@v4
           with:
             python-version: '3.9'
         - name: Install Ansible
           run: pip install ansible
         - name: Run tests
           run: ansible-test sanity --docker
   ```

### Lab 3: Collection Distribution and Versioning
**Duration**: 3 hours

#### Objectives
- Build and package collection
- Publish to Galaxy
- Implement versioning strategy

#### Tasks

1. **Build Collection**
   ```bash
   # Build collection tarball
   ansible-galaxy collection build
   
   # Verify build
   tar -tzf enterprise-infrastructure-1.0.0.tar.gz
   ```

2. **Test Installation**
   ```bash
   # Install locally
   ansible-galaxy collection install enterprise-infrastructure-1.0.0.tar.gz
   
   # Test usage
   ansible-doc enterprise.infrastructure.server_deployment
   ```

3. **Publish to Galaxy**
   ```bash
   # Login to Galaxy
   ansible-galaxy login
   
   # Publish collection
   ansible-galaxy collection publish enterprise-infrastructure-1.0.0.tar.gz
   ```

## 📊 Assessment

### Practical Assessment (60%)

#### Collection Development Project
Create a comprehensive collection with the following components:

**Requirements**:
- 3+ custom modules
- 2+ filter plugins
- 1+ lookup plugin
- 2+ roles
- Comprehensive documentation
- Complete test suite
- CI/CD pipeline

**Evaluation Criteria**:
- Code quality and organization
- Documentation completeness
- Test coverage and quality
- CI/CD implementation
- Galaxy compatibility

### Technical Assessment (40%)

#### Architecture Design
Design collection architecture for:
- Multi-cloud infrastructure management
- Security and compliance automation
- Monitoring and observability
- Application deployment

#### Code Review
Review and improve existing collection:
- Identify issues and improvements
- Implement best practices
- Optimize performance
- Enhance documentation

## 🎯 Module Summary

### Key Concepts Learned
- ✅ Collection architecture and structure
- ✅ Custom module development
- ✅ Plugin development (filters, lookups, callbacks)
- ✅ Collection testing frameworks
- ✅ CI/CD pipeline implementation
- ✅ Distribution and versioning strategies
- ✅ Enterprise collection governance

### Skills Developed
- ✅ Design enterprise-scale collections
- ✅ Develop custom modules and plugins
- ✅ Implement comprehensive testing
- ✅ Set up automated CI/CD pipelines
- ✅ Publish and distribute collections
- ✅ Manage collection dependencies and versions
- ✅ Create collection documentation and standards

### Next Steps
- **Module 02**: Performance Optimization techniques
- **Practice**: Contribute to community collections
- **Advanced**: Explore collection governance patterns
- **Community**: Share collections with the ecosystem

## 📚 Additional Resources

### Documentation
- [Ansible Collections Guide](https://docs.ansible.com/ansible/latest/dev_guide/developing_collections.html)
- [Collection Structure](https://docs.ansible.com/ansible/latest/dev_guide/developing_collections_structure.html)
- [Testing Collections](https://docs.ansible.com/ansible/latest/dev_guide/testing_collections.html)

### Development Tools
- [ansible-test](https://docs.ansible.com/ansible/latest/dev_guide/testing.html)
- [Collection Template](https://github.com/ansible-collections/collection_template)
- [Galaxy CLI](https://docs.ansible.com/ansible/latest/cli/ansible-galaxy.html)

### Community Resources
- [Ansible Collections Repository](https://github.com/ansible-collections)
- [Collection Development Guidelines](https://github.com/ansible-collections/overview/blob/main/collection_requirements.rst)
- [Community Collections](https://galaxy.ansible.com/community)

---

**Outstanding achievement! You've mastered Ansible Collections development and are now equipped to create enterprise-grade automation content. Your collections can standardize automation across organizations and contribute to the broader Ansible ecosystem.**