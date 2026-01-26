# Phase-2 Script Generation: Quick Reference

## 📊 At a Glance

**Modules**: 10  
**Scripts**: 30  
**Status**: ✅ Complete

---

## 🚀 Quick Commands

### Automation & API
```bash
# Audit System
python 01-Automation/scripts/audit-system-config.py

# Test API Endpoint
python 02-API-Basics/scripts/test-api-endpoint.py https://api.github.com
```

### Infrastructure (Nginx & Maven)
```bash
# Validate Nginx
sudo ./03-Nginx/scripts/nginx-config-validator.sh

# Wrap Maven Build
./04-Maven/scripts/mvn-build-wrapper.sh
```

### CI/CD & AI
```bash
# Simluate Pipeline
./05-Basic-CI-CD/scripts/local-pipeline-runner.sh

# Generate Commit Message
python 06-Prompt-Engineering/scripts/generate-commit-msg.py feat "added login"
```

### Operations (Observability & GitOps)
```bash
# Metrics
./07-Observability-Fundamentals/scripts/collect-node-metrics.sh

# Sync Check
./08-GitOps-Fundamentals/scripts/sync-repo-state.sh
```

### Security
```bash
# Compliance Scan
python 09-Compliance-as-Code-Foundations/scripts/scan-compliance.py

# Docker Scan
./10-Container-Security-Basics/scripts/scan-docker-image.sh my-app:latest
```

---

## 📂 File Structure

Every module has a `scripts/` directory containing the tools.

```text
02-Phase-2/
├── 01-Automation/scripts/
├── 02-API-Basics/scripts/
├── ...
└── 10-Container-Security-Basics/scripts/
```
