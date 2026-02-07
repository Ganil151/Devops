# Ansible Subfolder Structure Plan

## Enhanced Directory Organization

```
03-server-configuration-and-ansible/01-ansible/
├── learning-modules/
│   ├── 01-fundamentals/
│   │   ├── 01-control-node/
│   │   │   └── readme.md (Setup and configuration)
│   │   ├── 02-inventory-architecture/
│   │   │   ├── readme.md (Static vs Dynamic)
│   │   │   ├── static-hosts.ini
│   │   │   └── aws_ec2.yml (Dynamic inventory example)
│   │   ├── 03-transport-protocols/
│   │   │   └── readme.md (SSH, WinRM)
│   │   └── 04-module-architecture/
│   │       └── readme.md (How modules work)
│   │
│   ├── 02-inventory-management/
│   │   ├── 01-static-inventory/
│   │   │   ├── readme.md
│   │   │   └── hosts.ini
│   │   ├── 02-patterns-and-targeting/
│   │   │   └── readme.md (Host patterns, groups)
│   │   ├── 03-inventory-variables/
│   │   │   ├── readme.md
│   │   │   ├── group_vars/
│   │   │   └── host_vars/
│   │   └── 04-dynamic-plugins/
│   │       ├── readme.md (AWS, Azure, GCP)
│   │       ├── aws_ec2.yml
│   │       └── azure_rm.yml
│   │
│   ├── 03-basic-playbooks/
│   │   ├── 01-playbook-structure/
│   │   │   ├── readme.md
│   │   │   └── simple-playbook.yml
│   │   ├── 02-yaml-syntax/
│   │   │   └── readme.md (YAML best practices)
│   │   └── 03-task-execution-flow/
│   │       ├── readme.md
│   │       └── execution-order.yml
│   │
│   ├── 04-core-modules/
│   │   ├── 01-file-management/
│   │   │   ├── readme.md (copy, file, template, lineinfile)
│   │   │   └── examples.yml
│   │   ├── 02-package-management/
│   │   │   ├── readme.md (apt, yum, package)
│   │   │   └── examples.yml
│   │   ├── 03-system-modules/
│   │   │   ├── readme.md (service, systemd, user, group)
│   │   │   └── examples.yml
│   │   └── 04-utility-modules/
│   │       ├── readme.md (debug, assert, wait_for)
│   │       └── examples.yml
│   │
│   ├── 05-variables-and-facts/
│   │   ├── 01-variable-hierarchy/
│   │   │   ├── readme.md (Precedence order)
│   │   │   └── examples.yml
│   │   ├── 02-ansible-facts/
│   │   │   ├── readme.md (Gathering and using facts)
│   │   │   └── fact-examples.yml
│   │   ├── 03-magic-variables/
│   │   │   ├── readme.md (hostvars, groups, inventory_hostname)
│   │   │   └── examples.yml
│   │   └── 04-dynamic-data/
│   │       ├── readme.md (Registered variables, set_fact)
│   │       └── examples.yml
│   │
│   ├── 06-templates-and-files/
│   │   ├── 01-jinja2-basics/
│   │   │   ├── readme.md (Variables, filters, tests)
│   │   │   ├── nginx.conf.j2
│   │   │   └── index.html.j2
│   │   ├── 02-jinja2-advanced-logic/
│   │   │   ├── readme.md (Loops, conditionals, macros)
│   │   │   └── advanced-template.j2
│   │   ├── 03-deployment-strategies/
│   │   │   ├── readme.md (Blue-green, canary)
│   │   │   └── deploy-playbook.yml
│   │   └── 04-safe-deploy-validation/
│   │       ├── readme.md (Validation, rollback)
│   │       └── validated-deploy.yml
│   │
│   ├── 07-ansible-roles/
│   │   ├── 01-role-standard-structure/
│   │   │   ├── readme.md (tasks, handlers, templates, vars, defaults, meta)
│   │   │   └── example-role/
│   │   ├── 02-advanced-role-usage/
│   │   │   ├── readme.md (Dependencies, includes, imports)
│   │   │   └── complex-role/
│   │   ├── 03-galaxy-and-collections/
│   │   │   ├── readme.md (Using Ansible Galaxy)
│   │   │   └── requirements.yml
│   │   └── 04-testing-with-molecule/
│   │       ├── readme.md (Molecule setup and usage)
│   │       ├── molecule.yml
│   │       └── tests/
│   │
│   ├── 08-conditionals-and-loops/
│   │   ├── 01-conditional-execution/
│   │   │   ├── readme.md (when, changed_when, failed_when)
│   │   │   └── conditionals.yml
│   │   ├── 02-looping-mechanics/
│   │   │   ├── readme.md (loop, with_items, with_dict)
│   │   │   └── loops.yml
│   │   ├── 03-error-handling-blocks/
│   │   │   ├── readme.md (block, rescue, always)
│   │   │   └── error-handling.yml
│   │   └── 04-advanced-logic-control/
│   │       ├── readme.md (until, retries, delay)
│   │       └── advanced-control.yml
│   │
│   ├── 09-error-handling/
│   │   ├── 01-failure-strategies/
│   │   │   ├── readme.md (ignore_errors, any_errors_fatal)
│   │   │   └── strategies.yml
│   │   ├── 02-debugging-tools/
│   │   │   ├── readme.md (debug module, -vvv, strategy plugins)
│   │   │   └── debugging.yml
│   │   ├── 03-handler-management/
│   │   │   ├── readme.md (notify, handlers, flush_handlers)
│   │   │   └── handlers.yml
│   │   └── 04-validation-and-abortion/
│   │       ├── readme.md (assert, fail, meta: end_play)
│   │       └── validation.yml
│   │
│   ├── 10-ansible-vault/
│   │   ├── 01-vault-cli-operations/
│   │   │   ├── readme.md (create, encrypt, decrypt, edit, view)
│   │   │   └── vault-commands.sh
│   │   ├── 02-automation-workflow/
│   │   │   ├── readme.md (Password files, environment variables)
│   │   │   └── vault-automation.yml
│   │   ├── 03-vault-in-ci-cd/
│   │   │   ├── readme.md (Jenkins, GitLab CI integration)
│   │   │   └── .gitlab-ci.yml
│   │   └── 04-security-best-practices/
│   │       ├── readme.md (Key rotation, access control)
│   │       └── security-checklist.md
│   │
│   └── 11-custom-modules/
│       ├── 01-module-development-basics/
│       │   ├── readme.md (Python module structure)
│       │   └── simple_module.py
│       ├── 02-ansiblemodule-utility/
│       │   ├── readme.md (Using AnsibleModule class)
│       │   └── advanced_module.py
│       ├── 03-returns-and-idempotency/
│       │   ├── readme.md (Return values, changed status)
│       │   └── idempotent_module.py
│       └── 04-testing-and-distribution/
│           ├── readme.md (Unit tests, integration tests)
│           └── tests/
│
├── roles/
│   ├── common/
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── defaults/main.yml
│   │   └── README.md
│   ├── nginx/
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── templates/
│   │   │   ├── nginx.conf.j2
│   │   │   └── site.conf.j2
│   │   ├── defaults/main.yml
│   │   ├── vars/main.yml
│   │   └── README.md
│   ├── mysql/
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── templates/my.cnf.j2
│   │   ├── defaults/main.yml
│   │   └── README.md
│   ├── firewall/
│   │   ├── tasks/main.yml
│   │   ├── defaults/main.yml
│   │   └── README.md
│   └── ssl-certs/
│       ├── tasks/main.yml
│       ├── handlers/main.yml
│       ├── files/
│       └── README.md
│
├── group_vars/
│   ├── all.yml (Variables for all hosts)
│   ├── webservers.yml
│   ├── databases.yml
│   └── production/
│       ├── vars.yml
│       └── vault.yml (Encrypted secrets)
│
├── host_vars/
│   ├── web01.yml
│   └── db01.yml
│
├── playbooks/
│   ├── site.yml (Master playbook)
│   ├── webservers.yml
│   ├── databases.yml
│   ├── deploy-app.yml
│   └── security-hardening.yml
│
├── inventory/
│   ├── production/
│   │   ├── hosts.ini
│   │   └── aws_ec2.yml
│   ├── staging/
│   │   ├── hosts.ini
│   │   └── aws_ec2.yml
│   └── development/
│       └── hosts.ini
│
├── templates/
│   └── (Shared templates not in roles)
│
├── files/
│   └── (Shared static files)
│
├── ansible.cfg (Ansible configuration)
├── requirements.yml (Galaxy roles/collections)
├── README.md (Main documentation)
└── STRUCTURE.md (This file)
```

## Key Enhancements

### 1. Learning Modules Expansion

**Added Modules:**
- **Dynamic Inventory (02-inventory-management/04)**: AWS, Azure, GCP plugins
- **Jinja2 Advanced (06-templates-and-files/02)**: Loops, conditionals, macros
- **Molecule Testing (07-ansible-roles/04)**: Complete testing workflow
- **Error Handling (09)**: Comprehensive error management strategies
- **Ansible Vault (10)**: Security and secrets management
- **Custom Modules (11)**: Python module development

### 2. Role Structure

**Standard Role Template:**
```
roles/role-name/
├── tasks/
│   └── main.yml
├── handlers/
│   └── main.yml
├── templates/
│   └── config.j2
├── files/
│   └── static-file
├── vars/
│   └── main.yml
├── defaults/
│   └── main.yml
├── meta/
│   └── main.yml
└── README.md
```

### 3. Inventory Organization

**Multi-Environment Support:**
```
inventory/
├── production/
│   ├── hosts.ini (Static)
│   └── aws_ec2.yml (Dynamic)
├── staging/
└── development/
```

### 4. Variable Hierarchy

**Precedence (lowest to highest):**
1. role defaults
2. inventory file/script group vars
3. inventory group_vars/all
4. playbook group_vars/all
5. inventory group_vars/*
6. playbook group_vars/*
7. inventory file/script host vars
8. inventory host_vars/*
9. playbook host_vars/*
10. host facts
11. play vars
12. play vars_prompt
13. play vars_files
14. role vars
15. block vars
16. task vars
17. include_vars
18. set_facts
19. registered vars
20. extra vars (always win)

### 5. Security Structure

**Vault Organization:**
```
group_vars/
├── production/
│   ├── vars.yml (Non-sensitive)
│   └── vault.yml (Encrypted)
└── staging/
    ├── vars.yml
    └── vault.yml
```

**Naming Convention:**
- Encrypted variables: `vault_variable_name`
- Reference in playbooks: `{{ vault_db_password }}`

### 6. Testing Structure

**Molecule Integration:**
```
roles/nginx/
├── molecule/
│   └── default/
│       ├── molecule.yml
│       ├── converge.yml
│       ├── verify.yml
│       └── tests/
│           └── test_default.py
```

## Implementation Priority

### Phase 1: Core Structure (Week 1)
- [ ] Set up learning-modules/01-fundamentals
- [ ] Create basic roles (common, nginx)
- [ ] Configure inventory structure
- [ ] Set up ansible.cfg

### Phase 2: Advanced Concepts (Week 2)
- [ ] Add dynamic inventory examples
- [ ] Implement Ansible Vault
- [ ] Create Jinja2 templates
- [ ] Add error handling examples

### Phase 3: Testing & CI/CD (Week 3)
- [ ] Set up Molecule testing
- [ ] Create CI/CD integration examples
- [ ] Add custom module examples
- [ ] Document best practices

### Phase 4: Documentation (Week 4)
- [ ] Complete all README files
- [ ] Add code examples
- [ ] Create troubleshooting guides
- [ ] Add interview questions

## Best Practices Enforced

1. **Idempotency**: All examples use declarative modules
2. **Security**: Vault for all secrets, no hardcoded credentials
3. **Modularity**: Roles for reusability
4. **Testing**: Molecule tests for all roles
5. **Documentation**: README in every directory
6. **Version Control**: .gitignore for sensitive files
7. **Standards**: Consistent naming conventions

## Quick Start Commands

```bash
# Initialize new role
ansible-galaxy init roles/new-role

# Test role with Molecule
cd roles/nginx && molecule test

# Run playbook with vault
ansible-playbook site.yml --ask-vault-pass

# Check syntax
ansible-playbook site.yml --syntax-check

# Dry run
ansible-playbook site.yml --check --diff

# List inventory
ansible-inventory -i inventory/production --graph
```

---

**Last Updated:** 2024  
**Structure Version:** 2.0  
**Maintainer:** Platform Engineering Team
