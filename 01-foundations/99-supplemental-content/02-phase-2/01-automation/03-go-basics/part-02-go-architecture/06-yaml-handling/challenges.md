# Working with YAML - DevOps Challenges

## Challenge 1: Kubernetes ConfigMap Parser
**Scenario**: Parse and validate Kubernetes ConfigMap YAML.

**Requirements:**
1. Parse ConfigMap YAML with metadata and data fields
2. Validate required fields (apiVersion, kind, metadata.name)
3. Extract all key-value pairs from data section

**Verification:**
```bash
go run configmap-parser.go configmap.yaml
# Expected: Lists all config keys and validates structure
```

---

## Challenge 2: Ansible Inventory Generator
**Scenario**: Generate Ansible inventory YAML from server list.

**Requirements:**
1. Create structs for Ansible inventory format
2. Group servers by environment (prod/staging)
3. Marshal to YAML with proper structure

**Verification:**
```bash
go run ansible-gen.go
# Expected: Outputs valid Ansible inventory YAML
```

---

## Challenge 3: CI/CD Pipeline Merger
**Scenario**: Merge multiple GitLab CI YAML files.

**Requirements:**
1. Parse multiple .gitlab-ci.yml files
2. Merge stages and jobs
3. Handle conflicts (later file wins)
4. Output merged pipeline

**Verification:**
```bash
go run pipeline-merger.go base.yml override.yml
# Expected: Merged pipeline configuration
```
