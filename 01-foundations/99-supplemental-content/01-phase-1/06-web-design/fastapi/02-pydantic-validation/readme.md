# 🛡️ FastAPI & Pydantic: Data Integrity
*Zero-Trust Input Validation via Type Hints*

---

## 📖 Overview
The killer feature of FastAPI is its integration with Pydantic. By defining the shape of your data with Python classes, FastAPI automatically validates incoming POST/PUT request bodies.

---

## 🏗️ Technical Pillars

### 1. `BaseModel` Classes
Define your schema using standard Python type annotations.
```python
from pydantic import BaseModel

class DeployRequest(BaseModel):
    app_name: str
    replicas: int = 1
    image_tag: str = "latest"
```

### 2. Automatic Error 422
If a user sends an integer where a string is expected, or misses a required field, FastAPI returns a detailed **422 Unprocessable Entity** error automatically.

### 3. Nested Schemas
Pydantic allows for complex, nested data structures (e.g., a Deployment that contains a list of Env Vars).

---

## 🚀 DevOps Use Case
Validating a webhook from GitHub or GitLab. By defining the webhook payload as a Pydantic model, you ensure your automation script only processes valid events.

---

## 💡 SRE Pro-Tip
- **Field Constraints**: Use `Field(gt=0, le=100)` to ensure numbers are within a safe range (e.g., preventing a replica count of 1,000,000).
- **Sensitive Data**: Use Pydantic's `SecretStr` to prevent secrets from being accidentally printed in logs.

---
**Next Step**: [03-Async-Operations](../03-async-operations/readme.md)
