# ⚡ FastAPI: Basic API Foundations
*Building Robust entry points for Automation*

---

## 📖 Overview
FastAPI is an ASGI framework, meaning it is designed for asynchronous operations. Its syntax is incredibly clean, allowing you to build an operational API with just a few lines.

---

## 🏗️ Technical Pillars

### 1. The `FastAPI` Instance
The main application object that coordinates routing and configuration.
```python
from fastapi import FastAPI
app = FastAPI()
```

### 2. Path Operators
Decorators like `@app.get()`, `@app.post()`, `@app.put()`, and `@app.delete()` that map URLs to Python functions.

### 3. Automatic JSON Conversion
FastAPI automatically converts Python `dict` and `list` objects into JSON responses, setting the correct `content-type` headers.

---

## 🧪 Quick Exercise
Create a `main.py` that:
1. Defines a root GET endpoint returning `{"message": "Ready"}`.
2. Defines a GET `/status` endpoint returning a dictionary of system stats.

---
**Next Step**: [02-Pydantic-Validation](../02-pydantic-validation/readme.md)
