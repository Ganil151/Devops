# 🎯 Virtual Environments: Isolated Workshop Challenges

> **"Infrastructure is code, and environments are part of that code. These challenges test your ability to build reproducible and isolated automation workspaces."**

---

## 🏆 Challenge 1: The Ephemeral Task Runner
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Simulate a CI/CD job that creates a temporary environment to run a task.

### Requirements
- Create a script (Bash or Python) that:
    1. Creates a `.venv_temp` directory.
    2. Installs the `tabulate` library.
    3. Runs a tiny Python script that prints a table of server names.
    4. Deactivates and deletes the `.venv_temp` folder.
- **Verification**: The system must be left exactly as it was found (no global libraries installed).

---

## 🏆 Challenge 2: The Production manifest
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 20 minutes

### Objective
Create a professional multi-stage dependency manifest.

### Requirements
- Create a `requirements.txt` containing only production essentials (`boto3`, `requests`).
- Create a `requirements-dev.txt` that includes **everything in production** PLUS development tools (`pytest`, `black`, `flake8`).
- **Hint**: Use the `-r requirements.txt` syntax inside the dev file to stay DRY.
- Verify you can install the dev environment with a single command.

---

## 🏆 Challenge 3: Path Investigator
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 30 minutes

### Objective
Build a script that identifies exactly *which* environment it is running in.

### Requirements
- Write a Python script `env_audit.py`.
- It must print:
    1.  The absolute path of the `sys.executable`.
    2.  Whether it is running inside a virtual environment (`True/False`) by checking `sys.prefix` vs `sys.base_prefix`.
    3.  A list of all installed packages (using `pkg_resources` or `importlib.metadata`).
- **Goal**: This script should be your "Diagnostic Tool" for when you aren't sure if a cron job is using the right environment.

---

## ✅ Completion Checklist
- [ ] Challenge 1: Ephemeral Task Runner
- [ ] Challenge 2: Production Manifest
- [ ] Challenge 3: Path Investigator
