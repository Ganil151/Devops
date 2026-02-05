# 📤 Flask: Handling Data
*Input Processing and JSON Responses*

---

## 📖 Overview
Interaction with a Flask backend involves receiving data from users (Requests) and returning structured information (Responses).

---

## 🏗️ Technical Pillars

### 1. The `request` Object
A global proxy object provided by Flask to inspect the incoming signal.
- `request.args`: Query string parameters (`?id=123`).
- `request.json`: Parsed JSON body from a POST request.
- `request.headers`: Auth tokens, user-agents.

### 2. The `jsonify` Function
Properly formats Python lists/dicts into JSON and sets the `application/json` header.

### 3. Functional Status Codes
Always return unambiguous status codes.
- `200 OK`: Success.
- `201 Created`: Successfully created a resource.
- `400 Bad Request`: Validation error.
- `401 Unauthorized`: Missing or invalid keys.
- `500 Internal Server Error`: Logic crash.

---

## 🚀 DevOps Use Case
Building a "Log Collector" that receives JSON logs via POST and returns a `201 Created` if successful.

---
**Next Step**: [03-Database-and-ORM](../03-Database-and-ORM/README.md)
