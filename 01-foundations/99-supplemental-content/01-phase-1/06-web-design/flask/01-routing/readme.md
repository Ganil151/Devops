# 🧪 Flask Routing & Parameters
*Mapping URL Entry Points to Python Operations*

---

## 📖 Overview
Flask uses a strictly synchronous routing model (unless using 2.0+ async extensions). It is highly predictable and ideal for internal scripts.

---

## 🏗️ Technical Pillars

### 1. Route Patterns
```python
@app.route('/deploy/<service_name>')
def deploy(service_name):
    # logic using service_name
    return f"Deploying {service_name}"
```

### 2. HTTP Methods
Flask routes are GET by default. Specify POST for operations that change state.
```python
@app.route('/restart', methods=['POST'])
def restart():
    ...
```

### 3. URL Converters
Ensure parameters are the correct type.
- `<int:id>`
- `<float:price>`
- `<path:file_path>`

---

## 🧪 Exercise
Create a Flask app that:
1. Accepts a POST to `/api/v1/log`.
2. Accepts a GET to `/api/v1/node/<int:node_id>`.

---
**Next Step**: [02-Request-and-Response](../02-request-and-response/readme.md)
