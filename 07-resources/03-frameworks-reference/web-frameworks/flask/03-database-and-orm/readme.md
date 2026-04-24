# 🗄️ Flask: Persistence & SQLAlchemy
*Managing Infrastructure State with a SQL Backend*

---

## 📖 Overview
For automation tools to be "Stateful" (remembering previous deployments, tracking locks), they need a database. **Flask-SQLAlchemy** is the standard Object Relational Mapper (ORM).

---

## 🏗️ Technical Pillars

### 1. Database Configuration
```python
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///infra.db'
db = SQLAlchemy(app)
```

### 2. Defining Models
Class representations of your SQL tables.
```python
class Node(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    ip = db.Column(db.String(15), unique=True)
    status = db.Column(db.String(20))
```

### 3. Basic Queries
- `Node.query.all()`: Get all records.
- `Node.query.filter_by(status='online').first()`: Find specific record.

---

## 🚀 Managed Migrations
Use **Flask-Migrate** (powered by Alembic) to handle database schema changes without losing data.
- `flask db init`
- `flask db migrate -m "Added IP column"`
- `flask db upgrade`

---

## 🛡️ SRE Standard Checklist
- [ ] Is the database URI stored in an environment variable?
- [ ] Are indexes created for frequently searched columns (like Hostname or IP)?
- [ ] Is there a scheduled backup for the DB file/instance?

---
**Next Step**: [04-Production-Deployment](../04-production-deployment/readme.md)
