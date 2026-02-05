# 🏆 GCP Deployment Manager Advanced Level

## 📋 Learning Objectives
- ✅ Use **Python templates** for complex logic
- ✅ Implement **Runtime Configurator** and **Wait Conditions**
- ✅ Manage **IAM Policies** and project-level resources
- ✅ Handle template **Composite Types**

---

## 🐍 Python Templates
For the most complex logic (e.g., calculating CIDR ranges dynamically), use Python instead of Jinja2.

```python
def GenerateConfig(context):
    resources = []
    # Dynamic logic here
    resources.append({
        'name': 'network-' + context.env['deployment'],
        'type': 'compute.v1.network',
        'properties': {
            'autoCreateSubnetworks': True
        }
    })
    return {'resources': resources}
```

---

## ⏳ Runtime Configurator & Wait Conditions
Used to coordinate resource creation with software installation inside a VM.

1. **Deploy resources** (e.g., a GCE instance).
2. **Create a Wait Condition**.
3. **VM Script** signals the Runtime Configurator when success is reached.
4. **Deployment Manager** proceeds only after the signal is received.

---

## 🏢 Enterprise Patterns: Composite Types
Composite types allow you to register a template as a custom resource type in your project, allowing other teams to use your infrastructure patterns as if they were native GCP types.

```bash
gcloud deployment-manager types create my-custom-vm-type \
    --template my-vm-template.jinja
```

---

## 🛡️ Security Best Practices
- **Least Privilege**: Deployment Manager uses a service account; ensure it only has the necessary IAM roles (e.g., `roles/compute.admin` vs `roles/editor`).
- **Policy Enforcement**: Use constraints and regular audits to ensure DM templates don't violate organizational policies.
