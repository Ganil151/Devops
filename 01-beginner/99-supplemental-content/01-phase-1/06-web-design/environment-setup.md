## Python Virtual Environments (venv)
A **Virtual Environment** is a self-contained directory tree that contains a Python installation for a particular version of Python, plus a number of additional packages.

## Why use venv?
1.  **Isolation**: Prevents dependency conflicts between different projects.
2.  **Versioning**: Allows you to use different versions of the same library for different projects.
3.  **Cleanliness**: Keeps your global Python installation clean and lightweight.
4.  **DevOps Best Practice**: Essential for creating reproducible environments and generating `requirements.txt` files.

---

## 1. Getting Started

### Create the Environment
Navigate to your project directory and run:
```bash
python3 -m venv .venv
```
*(Note: `.venv` is the standard name for the environment folder, but you can name it anything.)*

### Activate the Environment
You must "enter" the environment to use it.

**On Linux/macOS:**
```bash
source .venv/bin/activate
```

**On Windows (Command Prompt):**
```cmd
.venv\Scripts\activate
```

Once activated, your terminal prompt will usually show `(.venv)` at the beginning.

### Deactivate
To leave the virtual environment and return to the global Python:
```bash
deactivate
```

---

## 2. Managing Dependencies
Once the environment is **activated**, you can install packages.
### Install Packages
```bash
pip install flask
```
### Save Dependencies (requirements.txt)
DevOps engineers use this file to ensure the application runs exactly the same way in production (e.g., inside Docker).
```bash
pip freeze > requirements.txt
```
### Install from a file
```bash
pip install -r requirements.txt
```

---
## 3. Best Practices for DevOps

### Git: Always Ignore
**NEVER** commit your `.venv` folder to Git. It is large, machine-specific, and can be recreated easily using `requirements.txt`.
Add this to your `.gitignore`:
```text
.venv/
__pycache__/
*.pyc
```
### Naming Conventions
- `.venv`: Visible but hidden by default in many explorers.
- `venv`: Common alternative.
- `env`: Sometimes used, but less common for Python 3.

---

## 4. Quiz: venv Basics
1. Which command creates a new virtual environment?
   - a) `python3 venv create`
   - b) `python3 -m venv .venv`
   - c) `pip install venv`
   - d) `source venv create`

2. How do you "enter" a virtual environment on Linux?
   - a) `cd .venv`
   - b) `source .venv/bin/activate`
   - c) `python active`
   - d) `.venv --start`

3. What file is used to list all project dependencies for others to install?
   - a) `dependencies.py`
   - b) `config.yaml`
   - c) `requirements.txt`
   - d) `package.json`

*(Answers: 1:b, 2:b, 3:c)*

---

---

## 🟢 Node.js Environment (npm)
Node.js is essential for modern frontend (React/Next.js) and backend (Express) development.

### Installation
- **Standard**: Download from [nodejs.org](https://nodejs.org).
- **Pro (Recommended)**: Use **NVM (Node Version Manager)** to switch between versions easily.

### Managing Packages
- `npm init -y`: Initialize a new project.
- `npm install <name>`: Install a library.
- `npm install`: Install everything from `package.json`.

---

## ☕ Java Environment (Maven/Gradle)
Spring Boot requires a Java Development Kit (JDK) and a build tool.

### Setup
- **JDK**: Use OpenJDK 17 or 21 (LTS).
- **Build Tool**: **Maven** is the enterprise standard.

### Core Commands (Maven)
- `mvn clean install`: Build the project and run tests.
- `mvn spring-boot:run`: Start the application locally.

---

## 🛡️ SRE Global Best Practices

1. **`.gitignore`**: Never commit `.venv/`, `node_modules/`, or `target/` folders.
2. **Dockerfile**: Always use these setup steps to build your "Multi-stage" Dockerfiles.
3. **Taskfiles**: Use a `Makefile` or `Taskfile.yml` to wrap these complex commands for your team.

---

**[← Back to Web Design Guide](./readme.md)**
