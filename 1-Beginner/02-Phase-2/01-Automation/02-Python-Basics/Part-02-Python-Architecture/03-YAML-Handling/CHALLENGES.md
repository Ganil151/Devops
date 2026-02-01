# 🎯 YAML Handling: Config Blueprint Challenges

> **"If JSON is for machines, YAML is for humans. These challenges test your ability to build readable infrastructure blueprints."**

---

## 🏆 Challenge 1: The Inventory Parser
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Read a `docker-compose.yml` style file and list all service names.

### Requirements
- Create a sample YAML with 3 services (`web`, `db`, `redis`).
- Load the YAML and print the keys under the `services:` block.
- Print the `image:` version for each service.

---

## 🏆 Challenge 2: The Multi-Doc Splitter
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 30 minutes

### Objective
Handle a YAML file with multiple documents (common in Kubernetes).

### Requirements
- Create a YAML file with 3 documents separated by `---`.
- Document 1: Kind: Service. Document 2: Kind: Deployment. Document 3: Kind: ConfigMap.
- Use `yaml.safe_load_all()` to read them.
- Print the `Kind` of each document found in the file.

---

## 🏆 Challenge 3: The Safe-to-Unsafe Converter (YAML to JSON)
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 20 minutes

### Objective
Build a utility that converts any `.yaml` configuration to a `.json` format for a legacy API.

### Requirements
- Accept a filename as input.
- Load the YAML.
- Dump it to a JSON file with the same name (replace extension).

---

## ✅ Completion Checklist
- [ ] Challenge 1: Inventory Parser
- [ ] Challenge 2: Multi-Doc Splitter
- [ ] Challenge 3: YAML to JSON Converter
