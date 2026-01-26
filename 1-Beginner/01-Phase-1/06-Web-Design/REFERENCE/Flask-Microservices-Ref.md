# 🧪 Flask Microservices: Minimalist API Development
*Version 1.0 | Lightweight Backend Logic with Python*

---

## 📖 Overview
Flask is a WSGI web application framework. It is designed to make getting started quick and easy, with the ability to scale up to complex applications. For SREs, Flask is the go-to for building small "Glue APIs," internal webhooks, or lightweight monitoring probes.

---

## 🗺️ Routing & Controllers

### Routes (`@app.route`)
**Definition**: Mappings between URL paths and Python functions.
**Example**:
```python
@app.route('/health')
def health():
    return {"status": "healthy"}, 200
```

### URL Variables
**Definition**: Dynamic segments in a URL that can be captured as arguments in the function.
**Example**: `@app.route('/node/<node_id>')`.

---

## 🏗️ Data Handling & Logic

### Request Object
**Definition**: A global object that contains data about the incoming HTTP request (headers, JSON body, query params).
**Example**: `request.get_json()`.

### Response & JSONify
**Definition**: Formatting Python dictionaries into JSON responses for consumption by frontends or other services.
**Example**: `return jsonify(items=[1,2,3])`.

### Blueprints
**Definition**: A way to organize a group of related views and other code into modules.
**SRE Impact**: Mandatory for keeping larger automation projects maintainable.

---

## 🚀 Advanced Flask Operations

### Middleware (Before/After Request)
**Definition**: Code that runs before every request or after every response.
**Use Case**: Centralized logging, Auth token validation.

### Extensions
**Definition**: Flask is "un-opinionated." You add functionality via extensions.
- **Flask-SQLAlchemy**: For Database ORM.
- **Flask-Migrate**: For DB schema changes.
- **Flask-CORS**: To allow cross-origin requests from a React frontend.

---

## 💡 SRE Pro-Tips
- **Development Server**: Never use `app.run()` in production. Always use a production-grade WSGI server like `Gunicorn` or `uWSGI`.
- **Environment Variables**: Configure your Flask app using `python-dotenv` to keep secrets out of your code.
- **Thread Safety**: Ensure your Flask routes are stateless, as the server will likely be handling requests concurrently across multiple worker processes.

---
**Next Step**: [Django Fullstack Framework →](./Django-Fullstack-Ref.md)
