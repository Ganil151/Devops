# Virtual Environments
*Isolating Python Dependencies*

Virtual environments prevent dependency conflicts between projects and ensure reproducible automation scripts.

---

## 🎯 Learning Objectives

- Create and manage virtual environments
- Understand dependency isolation
- Best practices for Python projects

---

## 📊 Virtual Environment Isolation

```mermaid
flowchart TD
    A[System Python] --> B[venv 1: Project A]
    A --> C[venv 2: Project B]
    A --> D[venv 3: Project C]
    
    B --> B1[requests 2.28]
    C --> C1[requests 2.31]
    D --> D1[requests 3.0]
    
    style A fill:#306998,stroke:#ffe873,color:#fff
```

---

## 📚 Core Concepts

### 1. Creating Virtual Environments

```bash
# Create venv
python -m venv myenv

# Activate (Linux/Mac)
source myenv/bin/activate

# Activate (Windows)
myenv\Scripts\activate

# Deactivate
deactivate
```

### 2. Python Commands

```python
import venv
import subprocess

# Create programmatically
venv.create("automation-env", with_pip=True)

# Or via subprocess
subprocess.run(["python", "-m", "venv", "myenv"])
```

### 3. Best Practices

```ini
# .gitignore - Never commit venv!
venv/
env/
.venv/
```

```bash
# Requirements workflow
pip freeze > requirements.txt
pip install -r requirements.txt
```

---

## 🛠️ Hands-On Exercise

```bash
# Create project structure
mkdir my-automation
cd my-automation
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install requests pyyaml
pip freeze > requirements.txt
```

---

## 🧠 Quiz

1. Why use virtual environments?
   - a) Faster Python
   - b) Dependency isolation ✅
   - c) Security

2. Which folder should be gitignored?
   - a) `src/`
   - b) `venv/` ✅
   - c) `lib/`

---

**Next Step**: [Package Management →](../16-Package-Management/README.md)
