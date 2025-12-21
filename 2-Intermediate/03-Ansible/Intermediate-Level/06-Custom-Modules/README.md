# Ansible Custom Modules

Complete guide to creating, developing, and maintaining custom Ansible modules for specialized automation needs.

## Module Development Fundamentals

### What are Custom Modules?

Custom modules extend Ansible's functionality by providing specialized automation capabilities not available in core or community modules. They allow you to:
- Integrate with proprietary systems and APIs
- Implement complex business logic
- Create reusable automation components
- Standardize operations across teams

### Module Types
- **Python Modules**: Most common, full feature support
- **PowerShell Modules**: For Windows environments
- **Binary Modules**: Compiled executables
- **Script Modules**: Shell scripts with Ansible integration

## Python Module Development

### Basic Module Structure
```python
#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2024, Your Name <your.email@example.com>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_custom_module
short_description: Brief description of what the module does
description:
    - Longer description of the module's functionality
    - Can span multiple lines
version_added: "1.0.0"
author:
    - Your Name (@yourgithub)
options:
    name:
        description:
            - Name of the resource to manage
        required: true
        type: str
    state:
        description:
            - Desired state of the resource
        choices: ['present', 'absent']
        default: present
        type: str
    config:
        description:
            - Configuration parameters
        type: dict
        default: {}
requirements:
    - python >= 3.6
    - requests
notes:
    - This module requires specific permissions
    - Check the API documentation for rate limits
'''

EXAMPLES = r'''
# Create a resource
- name: Create resource
  my_custom_module:
    name: example-resource
    state: present
    config:
      setting1: value1
      setting2: value2

# Remove a resource
- name: Remove resource
  my_custom_module:
    name: example-resource
    state: absent
'''

RETURN = r'''
resource:
    description: Information about the managed resource
    returned: always
    type: dict
    sample: {
        "id": "12345",
        "name": "example-resource",
        "status": "active"
    }
changed:
    description: Whether the resource was modified
    returned: always
    type: bool
    sample: true
message:
    description: Human readable message about the operation
    returned: always
    type: str
    sample: "Resource created successfully"
'''

from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.urls import fetch_url
import json

def main():
    # Define module arguments
    module_args = dict(
        name=dict(type='str', required=True),
        state=dict(type='str', default='present', choices=['present', 'absent']),
        config=dict(type='dict', default={}),
        api_url=dict(type='str', required=True),
        api_token=dict(type='str', required=True, no_log=True)
    )

    # Create AnsibleModule instance
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # Extract parameters
    name = module.params['name']
    state = module.params['state']
    config = module.params['config']
    api_url = module.params['api_url']
    api_token = module.params['api_token']

    # Initialize result dictionary
    result = dict(
        changed=False,
        resource={},
        message=''
    )

    try:
        # Check if resource exists
        resource = get_resource(module, api_url, api_token, name)
        
        if state == 'present':
            if resource:
                # Update existing resource
                if needs_update(resource, config):
                    if not module.check_mode:
                        resource = update_resource(module, api_url, api_token, name, config)
                    result['changed'] = True
                    result['message'] = 'Resource updated'
                else:
                    result['message'] = 'Resource already exists with correct configuration'
            else:
                # Create new resource
                if not module.check_mode:
                    resource = create_resource(module, api_url, api_token, name, config)
                result['changed'] = True
                result['message'] = 'Resource created'
            
            result['resource'] = resource or {}
        
        elif state == 'absent':
            if resource:
                # Delete existing resource
                if not module.check_mode:
                    delete_resource(module, api_url, api_token, name)
                result['changed'] = True
                result['message'] = 'Resource deleted'
            else:
                result['message'] = 'Resource does not exist'

    except Exception as e:
        module.fail_json(msg=f"Module execution failed: {str(e)}", **result)

    # Return results
    module.exit_json(**result)

def get_resource(module, api_url, api_token, name):
    """Retrieve resource information from API"""
    url = f"{api_url}/resources/{name}"
    headers = {
        'Authorization': f'Bearer {api_token}',
        'Content-Type': 'application/json'
    }
    
    response, info = fetch_url(module, url, headers=headers, method='GET')
    
    if info['status'] == 200:
        return json.loads(response.read())
    elif info['status'] == 404:
        return None
    else:
        module.fail_json(msg=f"Failed to get resource: {info['msg']}")

def create_resource(module, api_url, api_token, name, config):
    """Create a new resource via API"""
    url = f"{api_url}/resources"
    headers = {
        'Authorization': f'Bearer {api_token}',
        'Content-Type': 'application/json'
    }
    
    data = {
        'name': name,
        'config': config
    }
    
    response, info = fetch_url(
        module, url, 
        headers=headers, 
        method='POST',
        data=json.dumps(data)
    )
    
    if info['status'] in [200, 201]:
        return json.loads(response.read())
    else:
        module.fail_json(msg=f"Failed to create resource: {info['msg']}")

def update_resource(module, api_url, api_token, name, config):
    """Update existing resource via API"""
    url = f"{api_url}/resources/{name}"
    headers = {
        'Authorization': f'Bearer {api_token}',
        'Content-Type': 'application/json'
    }
    
    data = {'config': config}
    
    response, info = fetch_url(
        module, url,
        headers=headers,
        method='PUT',
        data=json.dumps(data)
    )
    
    if info['status'] == 200:
        return json.loads(response.read())
    else:
        module.fail_json(msg=f"Failed to update resource: {info['msg']}")

def delete_resource(module, api_url, api_token, name):
    """Delete resource via API"""
    url = f"{api_url}/resources/{name}"
    headers = {
        'Authorization': f'Bearer {api_token}',
        'Content-Type': 'application/json'
    }
    
    response, info = fetch_url(module, url, headers=headers, method='DELETE')
    
    if info['status'] not in [200, 204]:
        module.fail_json(msg=f"Failed to delete resource: {info['msg']}")

def needs_update(current_resource, desired_config):
    """Check if resource needs updating"""
    current_config = current_resource.get('config', {})
    
    for key, value in desired_config.items():
        if current_config.get(key) != value:
            return True
    
    return False

if __name__ == '__main__':
    main()
```

### Advanced Module Features

#### Input Validation
```python
def validate_parameters(module):
    """Custom parameter validation"""
    name = module.params['name']
    config = module.params['config']
    
    # Validate name format
    if not re.match(r'^[a-zA-Z0-9-_]+$', name):
        module.fail_json(msg="Name must contain only alphanumeric characters, hyphens, and underscores")
    
    # Validate configuration
    required_config_keys = ['setting1', 'setting2']
    missing_keys = [key for key in required_config_keys if key not in config]
    if missing_keys:
        module.fail_json(msg=f"Missing required configuration keys: {missing_keys}")
    
    # Validate value ranges
    if 'port' in config:
        port = config['port']
        if not isinstance(port, int) or port < 1 or port > 65535:
            module.fail_json(msg="Port must be an integer between 1 and 65535")

# Add validation to main function
def main():
    module = AnsibleModule(argument_spec=module_args)
    validate_parameters(module)
    # ... rest of module logic
```

#### Error Handling and Logging
```python
import logging
from ansible.module_utils.basic import AnsibleModule

def setup_logging(module):
    """Setup module logging"""
    log_level = module.params.get('log_level', 'INFO')
    logging.basicConfig(
        level=getattr(logging, log_level.upper()),
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    return logging.getLogger(__name__)

def safe_api_call(module, func, *args, **kwargs):
    """Wrapper for safe API calls with error handling"""
    logger = logging.getLogger(__name__)
    
    try:
        return func(*args, **kwargs)
    except requests.exceptions.ConnectionError as e:
        logger.error(f"Connection error: {e}")
        module.fail_json(msg=f"Unable to connect to API: {e}")
    except requests.exceptions.Timeout as e:
        logger.error(f"Timeout error: {e}")
        module.fail_json(msg=f"API request timed out: {e}")
    except requests.exceptions.HTTPError as e:
        logger.error(f"HTTP error: {e}")
        module.fail_json(msg=f"API returned error: {e}")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        module.fail_json(msg=f"Unexpected error occurred: {e}")
```

#### Check Mode Support
```python
def main():
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )
    
    # ... parameter extraction ...
    
    if state == 'present':
        if resource:
            if needs_update(resource, config):
                if module.check_mode:
                    # In check mode, don't make changes
                    result['changed'] = True
                    result['message'] = 'Resource would be updated'
                    result['resource'] = simulate_update(resource, config)
                else:
                    # Make actual changes
                    resource = update_resource(module, api_url, api_token, name, config)
                    result['changed'] = True
                    result['message'] = 'Resource updated'
                    result['resource'] = resource
```

## Module Testing

### Unit Tests
```python
# tests/unit/test_my_custom_module.py
import unittest
from unittest.mock import Mock, patch
import sys
import os

# Add module path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'library'))

from my_custom_module import main, get_resource, create_resource

class TestMyCustomModule(unittest.TestCase):
    
    def setUp(self):
        self.mock_module = Mock()
        self.mock_module.params = {
            'name': 'test-resource',
            'state': 'present',
            'config': {'setting1': 'value1'},
            'api_url': 'https://api.example.com',
            'api_token': 'test-token'
        }
        self.mock_module.check_mode = False
    
    @patch('my_custom_module.fetch_url')
    def test_get_resource_exists(self, mock_fetch_url):
        # Mock successful API response
        mock_response = Mock()
        mock_response.read.return_value = '{"id": "123", "name": "test-resource"}'
        mock_info = {'status': 200}
        mock_fetch_url.return_value = (mock_response, mock_info)
        
        result = get_resource(self.mock_module, 'https://api.example.com', 'token', 'test-resource')
        
        self.assertEqual(result['id'], '123')
        self.assertEqual(result['name'], 'test-resource')
    
    @patch('my_custom_module.fetch_url')
    def test_get_resource_not_found(self, mock_fetch_url):
        # Mock 404 response
        mock_info = {'status': 404}
        mock_fetch_url.return_value = (None, mock_info)
        
        result = get_resource(self.mock_module, 'https://api.example.com', 'token', 'nonexistent')
        
        self.assertIsNone(result)
    
    @patch('my_custom_module.fetch_url')
    def test_create_resource(self, mock_fetch_url):
        # Mock successful creation
        mock_response = Mock()
        mock_response.read.return_value = '{"id": "456", "name": "new-resource"}'
        mock_info = {'status': 201}
        mock_fetch_url.return_value = (mock_response, mock_info)
        
        result = create_resource(
            self.mock_module, 
            'https://api.example.com', 
            'token', 
            'new-resource', 
            {'setting1': 'value1'}
        )
        
        self.assertEqual(result['id'], '456')
        self.assertEqual(result['name'], 'new-resource')

if __name__ == '__main__':
    unittest.main()
```

### Integration Tests
```yaml
# tests/integration/test_my_custom_module.yml
---
- name: Test custom module integration
  hosts: localhost
  gather_facts: no
  
  vars:
    test_api_url: "{{ lookup('env', 'TEST_API_URL') }}"
    test_api_token: "{{ lookup('env', 'TEST_API_TOKEN') }}"
  
  tasks:
    - name: Test resource creation
      my_custom_module:
        name: test-resource-{{ ansible_date_time.epoch }}
        state: present
        api_url: "{{ test_api_url }}"
        api_token: "{{ test_api_token }}"
        config:
          setting1: value1
          setting2: value2
      register: create_result
    
    - name: Verify resource was created
      assert:
        that:
          - create_result.changed
          - create_result.resource.name is defined
          - create_result.message == "Resource created"
    
    - name: Test idempotency
      my_custom_module:
        name: "{{ create_result.resource.name }}"
        state: present
        api_url: "{{ test_api_url }}"
        api_token: "{{ test_api_token }}"
        config:
          setting1: value1
          setting2: value2
      register: idempotent_result
    
    - name: Verify idempotency
      assert:
        that:
          - not idempotent_result.changed
          - idempotent_result.message == "Resource already exists with correct configuration"
    
    - name: Test resource update
      my_custom_module:
        name: "{{ create_result.resource.name }}"
        state: present
        api_url: "{{ test_api_url }}"
        api_token: "{{ test_api_token }}"
        config:
          setting1: updated_value1
          setting2: value2
      register: update_result
    
    - name: Verify resource was updated
      assert:
        that:
          - update_result.changed
          - update_result.message == "Resource updated"
    
    - name: Test resource deletion
      my_custom_module:
        name: "{{ create_result.resource.name }}"
        state: absent
        api_url: "{{ test_api_url }}"
        api_token: "{{ test_api_token }}"
      register: delete_result
    
    - name: Verify resource was deleted
      assert:
        that:
          - delete_result.changed
          - delete_result.message == "Resource deleted"
```

## Advanced Module Patterns

### Module with Multiple Operations
```python
#!/usr/bin/python

from ansible.module_utils.basic import AnsibleModule

def main():
    module_args = dict(
        operation=dict(type='str', required=True, choices=['create', 'update', 'delete', 'list', 'backup']),
        name=dict(type='str'),
        config=dict(type='dict', default={}),
        backup_path=dict(type='str'),
        filters=dict(type='dict', default={})
    )
    
    module = AnsibleModule(
        argument_spec=module_args,
        required_if=[
            ('operation', 'create', ['name']),
            ('operation', 'update', ['name']),
            ('operation', 'delete', ['name']),
            ('operation', 'backup', ['backup_path'])
        ]
    )
    
    operation = module.params['operation']
    
    # Route to appropriate handler
    handlers = {
        'create': handle_create,
        'update': handle_update,
        'delete': handle_delete,
        'list': handle_list,
        'backup': handle_backup
    }
    
    if operation in handlers:
        result = handlers[operation](module)
        module.exit_json(**result)
    else:
        module.fail_json(msg=f"Unsupported operation: {operation}")

def handle_create(module):
    # Implementation for create operation
    return {'changed': True, 'message': 'Resource created'}

def handle_update(module):
    # Implementation for update operation
    return {'changed': True, 'message': 'Resource updated'}

def handle_delete(module):
    # Implementation for delete operation
    return {'changed': True, 'message': 'Resource deleted'}

def handle_list(module):
    # Implementation for list operation
    resources = get_all_resources(module)
    return {'changed': False, 'resources': resources}

def handle_backup(module):
    # Implementation for backup operation
    backup_file = create_backup(module)
    return {'changed': True, 'backup_file': backup_file}
```

### Module with Configuration Management
```python
#!/usr/bin/python

import yaml
import json
from ansible.module_utils.basic import AnsibleModule

class ConfigurationManager:
    def __init__(self, module):
        self.module = module
        self.config_file = module.params['config_file']
        self.config_format = module.params['config_format']
    
    def load_config(self):
        """Load configuration from file"""
        try:
            with open(self.config_file, 'r') as f:
                if self.config_format == 'yaml':
                    return yaml.safe_load(f)
                elif self.config_format == 'json':
                    return json.load(f)
                else:
                    self.module.fail_json(msg=f"Unsupported config format: {self.config_format}")
        except FileNotFoundError:
            return {}
        except Exception as e:
            self.module.fail_json(msg=f"Failed to load config: {e}")
    
    def save_config(self, config):
        """Save configuration to file"""
        try:
            with open(self.config_file, 'w') as f:
                if self.config_format == 'yaml':
                    yaml.dump(config, f, default_flow_style=False)
                elif self.config_format == 'json':
                    json.dump(config, f, indent=2)
        except Exception as e:
            self.module.fail_json(msg=f"Failed to save config: {e}")
    
    def merge_config(self, current_config, new_config):
        """Merge new configuration with existing"""
        def deep_merge(dict1, dict2):
            result = dict1.copy()
            for key, value in dict2.items():
                if key in result and isinstance(result[key], dict) and isinstance(value, dict):
                    result[key] = deep_merge(result[key], value)
                else:
                    result[key] = value
            return result
        
        return deep_merge(current_config, new_config)

def main():
    module_args = dict(
        config_file=dict(type='str', required=True),
        config_format=dict(type='str', default='yaml', choices=['yaml', 'json']),
        config_data=dict(type='dict', required=True),
        merge_mode=dict(type='str', default='merge', choices=['merge', 'replace']),
        backup=dict(type='bool', default=False)
    )
    
    module = AnsibleModule(argument_spec=module_args)
    
    config_mgr = ConfigurationManager(module)
    
    # Load current configuration
    current_config = config_mgr.load_config()
    new_config = module.params['config_data']
    merge_mode = module.params['merge_mode']
    
    # Determine final configuration
    if merge_mode == 'merge':
        final_config = config_mgr.merge_config(current_config, new_config)
    else:
        final_config = new_config
    
    # Check if changes are needed
    changed = current_config != final_config
    
    result = {
        'changed': changed,
        'config': final_config
    }
    
    if changed and not module.check_mode:
        # Create backup if requested
        if module.params['backup']:
            backup_file = f"{module.params['config_file']}.backup"
            config_mgr.save_config(current_config)
            result['backup_file'] = backup_file
        
        # Save new configuration
        config_mgr.save_config(final_config)
    
    module.exit_json(**result)
```

## Module Distribution and Packaging

### Module Collection Structure
```bash
# Collection directory structure
my_collection/
├── galaxy.yml
├── plugins/
│   └── modules/
│       ├── my_custom_module.py
│       ├── another_module.py
│       └── __init__.py
├── tests/
│   ├── unit/
│   │   └── test_my_custom_module.py
│   └── integration/
│       └── test_my_custom_module.yml
├── docs/
│   └── my_custom_module.rst
└── README.md
```

### Galaxy Metadata
```yaml
# galaxy.yml
namespace: mycompany
name: custom_modules
version: 1.0.0
readme: README.md
authors:
  - Your Name <your.email@example.com>
description: Custom Ansible modules for company-specific automation
license:
  - GPL-3.0-or-later
tags:
  - api
  - automation
  - custom
dependencies: {}
repository: https://github.com/mycompany/ansible-custom-modules
documentation: https://docs.mycompany.com/ansible-modules
homepage: https://mycompany.com
issues: https://github.com/mycompany/ansible-custom-modules/issues
```

### Module Documentation
```python
DOCUMENTATION = r'''
---
module: my_custom_module
short_description: Manage custom resources via API
description:
    - This module provides management capabilities for custom resources
    - Supports create, read, update, and delete operations
    - Integrates with company API for resource management
version_added: "1.0.0"
author:
    - Your Name (@yourgithub)
options:
    name:
        description:
            - Unique name for the resource
            - Must follow naming conventions (alphanumeric, hyphens, underscores)
        required: true
        type: str
    state:
        description:
            - Desired state of the resource
        choices: ['present', 'absent']
        default: present
        type: str
    config:
        description:
            - Configuration parameters for the resource
        type: dict
        suboptions:
            setting1:
                description: First configuration setting
                type: str
                required: true
            setting2:
                description: Second configuration setting
                type: str
                default: default_value
            port:
                description: Port number for the service
                type: int
                default: 8080
    api_url:
        description:
            - Base URL for the API endpoint
        required: true
        type: str
    api_token:
        description:
            - Authentication token for API access
        required: true
        type: str
        no_log: true
requirements:
    - python >= 3.6
    - requests >= 2.20.0
notes:
    - Requires valid API credentials
    - API rate limiting may apply
    - Check API documentation for supported operations
seealso:
    - module: uri
    - module: get_url
'''
```

## Best Practices

### Module Design Principles
```python
# Follow Ansible module conventions
def main():
    # 1. Use AnsibleModule for consistent behavior
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True,
        required_if=[
            ('state', 'present', ['config']),
        ],
        mutually_exclusive=[
            ('config_file', 'config_data'),
        ]
    )
    
    # 2. Validate inputs early
    validate_parameters(module)
    
    # 3. Initialize result dictionary
    result = dict(
        changed=False,
        message='',
        resource={}
    )
    
    # 4. Implement idempotency
    current_state = get_current_state(module)
    desired_state = get_desired_state(module)
    
    if current_state != desired_state:
        if not module.check_mode:
            apply_changes(module, desired_state)
        result['changed'] = True
    
    # 5. Return consistent results
    module.exit_json(**result)

# Error handling best practices
def safe_operation(module, operation_func, *args, **kwargs):
    """Wrapper for safe operations with proper error handling"""
    try:
        return operation_func(*args, **kwargs)
    except APIException as e:
        module.fail_json(msg=f"API error: {e.message}", error_code=e.code)
    except ValidationError as e:
        module.fail_json(msg=f"Validation error: {e}")
    except Exception as e:
        module.fail_json(msg=f"Unexpected error: {e}")
```

### Performance Optimization
```python
# Efficient API interactions
class APIClient:
    def __init__(self, base_url, token):
        self.base_url = base_url
        self.token = token
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        })
    
    def batch_operation(self, operations):
        """Perform multiple operations in a single API call"""
        response = self.session.post(
            f"{self.base_url}/batch",
            json={'operations': operations}
        )
        return response.json()
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.session.close()

# Use context managers for resource cleanup
def main():
    module = AnsibleModule(argument_spec=module_args)
    
    with APIClient(module.params['api_url'], module.params['api_token']) as client:
        # Perform operations
        result = perform_operations(module, client)
    
    module.exit_json(**result)
```

This comprehensive guide covers all aspects of creating robust, maintainable custom Ansible modules for specialized automation needs.