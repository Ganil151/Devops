# 💻 Scripts & Code Assets: The Automation Toolkit

> **"If you have to do it more than twice, script it. If you have to do it more than ten times, automate the script."**

This directory contains the core logic used to maintain, audit, and enhance the DevOps environment. These scripts are designed to be modular, readable, and production-safe.

---

## 📂 Toolkit Breakdown

### 🛠️ [Maintenance Scripts](./maintenance/)
The SRE primary toolkit for keeping the repository clean and standardized.
- `project-clean.py`: Automates the removal of junk files and temp data.
- `repository-audit.py`: Scans for broken links and missing documentation.
- `fix_links.py`: Automatically repairs relative paths during refactoring.

### 🔄 [Converter Tools](./converter/)
Utilities for data transformation and document processing.
- `docx-to-pdf.py`: Scripted conversion for technical requirements.

### 🔍 Diagnostic & Standalone Tools
- `link-auditor.py`: Real-time checking of external resource health.
- `pdf-scraper.py`: Extracts technical metadata from vendor documents.
- `update-reference.py`: Central logic for updating curriculum roadmaps.

---

## 🚀 The DevOps Why: Code as Maintenance
Manual maintenance of large-scale documentation and codebases leads to "Documentation Rot." By using Python and Shell for these tasks, we ensure:
1.  **Repeatability**: Audits run the same way every time.
2.  **Scalability**: Cleaning 1,000 files takes the same effort as cleaning 1.
3.  **Auditability**: Anyone can look at the script to see exactly how the "Cleanup" was performed.

---

## 💡 Senior SRE Tips
- **Dry Runs**: Always implement a `--dry-run` flag in your scripts. It's better to see what *would* happen than to regret what *did* happen.
- **Logging**: Don't just `print()`. Use a proper logging library to track errors and execution flow.
- **Shebangs**: Always include a proper shebang (e.g., `#!/usr/bin/env python3`) to ensure portability across different Linux/MacOS environments.

---
**Standard**: Follow PEP-8 for Python and ShellCheck for Bash scripts.
