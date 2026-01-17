# Boilerplates: Searching in Files
Log analysis and security scanning scripts demonstrating grep mastery for DevOps.

## Available Boilerplates

### 1. Error Aggregator
**File**: `boilerplate_error_aggregator.sh`
**Purpose**: Analyzes application logs and categorizes errors
**DevOps Use Case**: Incident response and troubleshooting

**Usage**:
```bash
./boilerplate_error_aggregator.sh /var/log/app/application.log
```
**Features**:
- Error categorization (FATAL, ERROR, WARN)
- Statistical summaries
- Top error patterns
- Formatted reports

---
### 2. Security Audit Scanner
**File**: `boilerplate_security_audit.sh`
**Purpose**: Scans for hardcoded secrets in codebase
**DevOps Use Case**: Pre-commit security validation

**Usage**:
```bash
./boilerplate_security_audit.sh ./src
```

**Detects**:
- AWS access keys
- API keys
- Passwords
- Private keys
- JWT tokens

---

### 3. Config Drift Detector
**File**: `boilerplate_config_drift_detector.sh`

**Purpose**: Compares active vs baseline configuration

**DevOps Use Case**: Compliance and drift detection

**Usage**:
```bash
./boilerplate_config_drift_detector.sh baseline.conf active.conf
```

**Features**:
- Unified diff output
- Drift reporting
- Compliance validation

---

## Quick Start

```bash
chmod +x boilerplate_*.sh

# Analyze logs
./boilerplate_error_aggregator.sh /var/log/app.log

# Security scan
./boilerplate_security_audit.sh .

# Check drift
./boilerplate_config_drift_detector.sh baseline.yml current.yml
```

---

## Learning Objectives

- ✅ Advanced grep patterns
- ✅ Regular expressions
- ✅  Diff and comparison
- ✅ Security scanning
- ✅ Log analysis

---

## Related Resources

- [Parent Module](../../../README.md)
- [Challenges](../../../1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/01-Introduction/CHALLENGES.md)
