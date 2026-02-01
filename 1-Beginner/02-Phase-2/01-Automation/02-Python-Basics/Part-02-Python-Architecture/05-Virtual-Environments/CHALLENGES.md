# 🎯 Virtual Environments: Isolated Workshop Challenges

> **"A clean environment is a predictable environment. These challenges test your ability to containerize your Python dependencies."**

---

## 🏆 Challenge 1: The One-Minute Environment
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 10 minutes

### Objective
Create, Activate, and Destroy an environment manually.

### Requirements
- Create an environment named `.venv_test`.
- Activate it and verify the path using `which python` (Linux/Mac) or `where python` (Windows).
- Deactivate it and delete the directory.

---

## 🏆 Challenge 2: The Dependency Freeze
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Capture an environment's state for another engineer.

### Requirements
- Create a new environment.
- Install `requests` and `PyYAML`.
- Create a `requirements.txt` file using `pip freeze`.
- Verify the contents of the file.

---

## 🏆 Challenge 3: Environment Drift Detection
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 25 minutes

### Objective
Write a script that checks if the current environment has all the required packages installed.

### Requirements
- Create a `requirements.txt` with `requests` and `flask`.
- Write a Python script (outside the env or in it) that reads the file.
- Try to import each package.
- Print "Package X is missing!" for any that fail.

---

## ✅ Completion Checklist
- [ ] Challenge 1: One-Minute Env
- [ ] Challenge 2: Dependency Freeze
- [ ] Challenge 3: Drift Detection
