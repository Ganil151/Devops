# 🏆 Infrastructure Automation: Hard-Mode Challenges

Welcome to the Forge. These challenges are designed to push you beyond "coding" and into **System Reliability Engineering (SRE)**. To complete these, you must apply Idempotency, Atomicity, and Robust Error Handling.

---

## 🛠️ Challenge 1: The Self-Healing Daemon
**Goal:** Create a Python-based watchdog that ensures a mission-critical process stays alive.

### 📋 The Requirements:
1.  **Monitor:** Use `subprocess` or `psutil` to monitor a dummy process (e.g., `sleep 1000`).
2.  **Healing:** If the process dies, the script must restart it.
3.  **Backoff Logic:** Implement **Exponential Backoff**. If it fails repeatedly, wait 2s, 4s, 8s... up to 60s before retrying.
4.  **Logging:** Log every restart attempt with a timestamp and the current backoff delay in a JSON format.
5.  **Graceful Exit:** Handle `SIGTERM` to shut down both the watchdog and the monitored process.

**Visual Tag:** `![Complexity: Hard] ![Focus: Reliability]`
**Solution:** [self_healing_daemon.py](../../01-phase-1/03-runbooks-procedures/03-auto-remediation-patterns/reference/safety-governance-self-healing-ref.md)

---

## 🏗️ Challenge 2: The Multi-Cloud Resource Auditor
**Goal:** Build a script that identifies "Zombie" resources across your cloud provider.

### 📋 The Requirements:
1.  **API Discovery:** Use `boto3` (AWS) or `google-cloud-sdk` to list all unattached storage volumes (EBS/GCP Disks).
2.  **Idempotent Tagging:** Instead of deleting them, tag them with `Cleanup-Status: Candidate` and `Termination-Date: <7_days_from_now>`.
3.  **Safety Guard:** The script must skip any volume that already has a `Retention: Permanent` tag.
4.  **Reporting:** Generate a markdown report of all "Zombies" discovered and the cost savings realized.

**Visual Tag:** `![Complexity: Intermediate] ![Focus: Cost-Optimization]`
**Solution:** [cloud_zombie_hunter.py](./01-scripting-automation/challenges/labs/solutions/cloud-zombie-hunter.py)

---

## 🔄 Challenge 3: The JSON/YAML Transformer
**Goal:** Create a pipeline tool that validates and converts Kubernetes manifests.

### 📋 The Requirements:
1.  **Format Switch:** Use `PyYAML` and `json` to convert a directory of `.yaml` Kubernetes files into `.json`.
2.  **Validation:** Before converting, validate that the YAML contains `apiVersion`, `kind`, and `metadata`.
3.  **Atomicity:** The tool must write to a `.tmp` file first and only rename it to `.json` if the validation and conversion pass perfectly.
4.  **CLI Interface:** Use `argparse` to allow users to specify input/output directories and a `--validate-only` flag.

**Visual Tag:** `![Complexity: Hard] ![Focus: Pipeline-Tooling]`
**Solution:** [manifest_transformer.py](../../../01-beginner/02-phase-2/01-automation/02-python-basics/part-02-python-architecture/03-yaml-handling/challenges/challenge-01-manifest-gen.py)

---

## 🛡️ "Staff Level" Bonus: The Chaos Monkey
Add a feature to any of the scripts above that randomly injects a failure (e.g., kills the process or disconnects the network) to test the script's resilience.

---

### 📬 Submission
Once complete, save your scripts in the `/scripts` directory of this module and create a PR-style documentation entry in your personal log.
