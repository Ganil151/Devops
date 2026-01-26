# 🧪 Flask: Lightweight Python Microservices
*The SRE Tool for Building Glue APIs and Webhooks*

---

## 🗺️ Learning Roadmap

### [01-Routing](./01-Routing/)
- **Concepts**: App decorators, Variable paths, Methods (GET/POST).
- **Goal**: Map entry points to Python logic.

### [02-Request-and-Response](./02-Request-and-Response/)
- **Concepts**: `request` object, `jsonify`, Status codes.
- **Goal**: Handle JSON data incoming and outgoing.

### [03-Database-and-ORM](./03-Database-and-ORM/)
- **Concepts**: Flask-SQLAlchemy, SQLite, Migrations.
- **Goal**: Persist infrastructure state in a SQL database.

### [04-Production-Deployment](./04-Production-Deployment/)
- **Concepts**: Gunicorn, Nginx Proxy, Worker threads.
- **Goal**: Move from `app.run()` to a resilient server.

---

## 🛠️ Quick Start
```bash
pip install flask
# create app.py
flask run
```

---

## 🛡️ SRE Standards
- **Blueprints**: Always use Blueprints to keep your codebase modular.
- **Environment Context**: Use `python-dotenv` for config isolation.
- **Proxy Fix**: Always use `ProxyFix` when running behind Nginx or AWS ALB.