#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_custom_status
short_description: A simple module to demonstrate custom Ansible module development.
description:
    - This module checks if a specific file exists and returns a custom status message.
options:
    path:
        description:
            - Path to the file to check.
        required: true
        type: str
author:
    - Your Name (@yourgithub)
'''

EXAMPLES = r'''
- name: Check system flag
  my_custom_status:
    path: /tmp/ready.txt
'''

RETURN = r'''
message:
    description: The status message returned by the module.
    returned: always
    type: str
    sample: "File /tmp/ready.txt exists!"
'''

from ansible.module_utils.basic import AnsibleModule
import os

def run_module():
    # Define available arguments/options
    module_args = dict(
        path=dict(type='str', required=True)
    )

    # Seed the result dict
    result = dict(
        changed=False,
        message=''
    )

    # Create the object
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    path = module.params['path']

    # Check Mode handling (Dry Run)
    if module.check_mode:
        module.exit_json(**result)

    # Business Logic
    if os.path.exists(path):
        result['message'] = f"File {path} exists!"
        result['changed'] = False
    else:
        # Let's say we create the file if it's missing (making it an actual config change)
        try:
            with open(path, 'w') as f:
                f.write('created by custom module')
            result['message'] = f"File {path} was missing and has been created."
            result['changed'] = True
        except Exception as e:
            module.fail_json(msg=f"Failed to create file: {str(e)}", **result)

    # Successful Exit
    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()
