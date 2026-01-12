# 🐷 TruffleHog: The Secret Sniffer

**TruffleHog** is a powerful, open-source security tool designed to find legitimate credentials (secrets) and high-entropy strings accidentally committed to your codebases. Unlike simple grep tools, TruffleHog specifically focuses on **verified** secrets by attempting to authenticate with the credentials it finds (where possible), significantly reducing false positives.

> "Secrets are the keys to the kingdom. Don't leave them under the doormat."

---

## 🚀 Key Features

*   **🔍 Deep History Scan**: Scans the entire commit history of git repositories, not just the current state.
*   **✅ Secret Verification**: Automatically checks if the found API keys are active by hitting their respective endpoints.
*   **🧩 800+ Detectors**: Built-in regex patterns for AWS, GCP, Azure, Slack, Stripe, and hundreds more.
*   **🛠️ Modular Architecture**: Supports scanning Git, Filesystem, S3, GCS, Syslog, CircleCI, etc.
*   **🧹 False Positive Management**: Easy suppression via `.trufflehogignore` or config files.

---

## 📦 Installation

### 1. Docker (Recommended for CI)
The Docker image is the easiest way to run TruffleHog in pipelines without managing Go dependencies.
```bash
docker run -it --rm trufflesecurity/trufflehog:latest git https://github.com/trufflesecurity/test_keys
```

### 2. Homebrew (macOS/Linux)
```bash
brew install trufflehog
```

### 3. Binary (Windows/Linux)
Download the latest release from the [GitHub Releases](https://github.com/trufflesecurity/trufflehog/releases) page.
For Windows (PowerShell):
```powershell
curr_dir > curl -L -o trufflehog.exe https://github.com/trufflesecurity/trufflehog/releases/download/v3.81.9/trufflehog_3.81.9_windows_amd64.tar.gz
curr_dir > tar -xvzf trufflehog.exe
```

---

## 🎮 Usage Guide

### 📂 Scan a Local Git Repository
Scan the current directory (including full history):
```bash
trufflehog git file://. 
```

### ☁️ Scan a Remote Repository
```bash
trufflehog git https://github.com/my-org/my-private-repo --only-verified
```
*   `--only-verified`: Only report secrets that were successfully proven to be active.

### 🗄️ Scan a Filesystem (No Git)
Useful for scanning S3 buckets, Docker containers, or unversioned folders.
```bash
trufflehog filesystem ./path/to/folder
```

### 🐳 Scan a Docker Image
```bash
trufflehog docker --image my-app:latest
```

---

## ⚙️ Configuration (`trufflehog.yaml`)

You can configure TruffleHog to ignore certain paths or define custom detectors.

```yaml
version: 1
# 🛑 Exclude specific paths or files
exclusions:
  - "**/*.lock"
  - "node_modules/"
  - "test_data/"

# 🔎 Define custom secret detectors
detectors:
  - name: MyCompanyInternalKey
    keywords:
      - "x-internal-key"
    regex:
      - "INT-[A-Z0-9]{16}"
```

### Suppressing False Positives
Create a `.trufflehogignore` file (excludes files from scan):
```text
test/*.json
mock_secrets.py
```

Or mark a line in code (v3+ feature dependent):
```python
api_key = "12345" # trufflehog:ignore
```

---

## ⛓️ CI/CD Integration

### GitHub Actions
Add this step to your `.github/workflows/security.yml`:

```yaml
name: TruffleHog Secrets Scan
on: [push, pull_request]
jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        with:
          fetch-depth: 0 # IMPORTANT: Fetch full history for deep scanning

      - name: TruffleHog OSS
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: "${{ github.event.repository.default_branch }}"
          head: HEAD
          extra_args: --debug --only-verified
```

### Jenkins Pipeline
```groovy
pipeline {
    agent { docker { image 'trufflesecurity/trufflehog:latest' } }
    stages {
        stage('Secret Scan') {
            steps {
                sh 'trufflehog git file://. --fail'
            }
        }
    }
}
```

---

## ❓ Interview Questions

**1. What is the difference between `trufflehog` and `git-secrets`?**
> **Answer**: `git-secrets` relies largely on simple regex patterns and runs locally (often as a pre-commit hook). **TruffleHog** is more advanced; it scans the entire commit history (not just the diff) and, most importantly, can **verify** secrets by testing them against the actual API endpoints to confirm they are active.

**2. Why do we need `fetch-depth: 0` in GitHub Actions when using TruffleHog?**
> **Answer**: By default, `checkout` only pulls the latest commit (depth 1). TruffleHog needs the full commit history to find secrets that were deleted/overwritten in previous commits but still exist in the `.git` folder history.

**3. If TruffleHog finds a secret in commit history (e.g., from 2 years ago), surely it's safe to ignore?**
> **Answer**: **FALSE**. Attackers often clone the entire repo and mine the history. If the key was never rotated, it is still valid. Even if it was "deleted" in the code, it lives forever in the git history unless you perform a BFG Repo-Cleaner or `git filter-branch` operation.

**4. How does TruffleHog reduce "Alert Fatigue"?**
> **Answer**: It uses the `--only-verified` flag. This feature attempts to use the credential to authenticate with the provider (e.g., validates an AWS key against STS). If it fails, it's either a false positive or an inactive key, so it suppresses the alert.

**5. Where should TruffleHog sit in the DevSecOps pipeline?**
> **Answer**: Ideally in two places:
> 1.  **Pre-Commit (Local)**: To prevent secrets from leaving the developer's machine.
> 2.  **CI/CD Pipeline (Build)**: As a mandatory gate that fails the build if verified secrets are found.

---

## 🏆 Assessment Quiz

1.  **What is the primary function of TruffleHog?**
    *   A) Static Code Analysis for bugs
    *   B) Secret/Credential Scanning
    *   C) Dynamic Application Testing (DAST)
    *   D) Infrastructure Provisioning
    *   <details><summary>Answer</summary>B</details>

2.  **Which command scans the entire history of the current git repo?**
    *   A) `trufflehog filesystem .`
    *   B) `trufflehog git file://.`
    *   C) `trufflehog check`
    *   D) `trufflehog history`
    *   <details><summary>Answer</summary>B</details>

3.  **Does TruffleHog only find secrets in the latest version of the code?**
    *   A) Yes
    *   B) No, it scans the entire commit history
    *   <details><summary>Answer</summary>B</details>

4.  **How can you tell TruffleHog to only report effectively *active* keys?**
    *   A) `--verified-only`
    *   B) `--only-verified`
    *   C) `--active`
    *   D) `--live`
    *   <details><summary>Answer</summary>B</details>

5.  **If TruffleHog finds a secret, what is the FIRST thing you should do?**
    *   A) Delete the git repo
    *   B) Rotate (revoke and issue new) the credential
    *   C) Edit the commit history
    *   D) Ignore it
    *   <details><summary>Answer</summary>B (Revocation is critical before cleanup)</details>
