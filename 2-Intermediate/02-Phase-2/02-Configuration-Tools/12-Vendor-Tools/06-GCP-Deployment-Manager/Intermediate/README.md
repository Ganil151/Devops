# 🚀 GCP Deployment Manager Intermediate Level

## 📋 Learning Objectives
- ✅ Use **Jinja2** to create reusable templates
- ✅ Understand **Top-level properties** and **Imports**
- ✅ Pass variables using **Schema files**

---

## 🏗️ Templating: Jinja2
Jinja2 allows you to use logic (if/else, loops) and variables in your configurations.

### 1. The Template (network.jinja)
```jinja
resources:
- name: {{ properties["name"] }}
  type: compute.v1.network
  properties:
    autoCreateSubnetworks: {{ properties["autoCreate"] }}
```

### 2. The Main Config
You must import the template before using it.
```yaml
imports:
- path: network.jinja

resources:
- name: my-custom-network
  type: network.jinja
  properties:
    name: dev-network
    autoCreate: true
```

---

## ⚙️ Environment Variables
Deployment Manager provides built-in variables you can use in templates:
- `deployment`: The name of the deployment.
- `project`: The project ID.
- `name`: The name of the resource instance.

Example in Jinja:
```jinja
name: {{ env["deployment"] }}-network
```

---

## 🛡️ Schema Files
Schemas allow you to define rules for the properties passed to your templates, providing validation and defaults.

```yaml
# network.jinja.schema
properties:
  name:
    type: string
    default: my-network
  autoCreate:
    type: boolean
    default: true
```
