# Database Operations

DevOps isn't just about files. Dealing with state (users, inventories, jobs) often requires a Database. Python's DB-API 2.0 provides a standard way to talk to SQL databases.

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `db_ops.py` (SQLite Context Managers).
- **[CHALLENGES](./CHALLENGES.md)**: CSV Importers, JSON Exporters.

---

## 🔑 Key Concepts

| Concept | Description |
| :--- | :--- |
| **Cursor** | The object used to execute queries and traverse results. |
| **Commit** | Saving changes. Forgot this? Data is lost on close. |
| **Context Manager** | `with connect(...)` ensures connection closes even if errors occur. |
| **ORM** | Object Relational Mapper (SQLAlchemy). Maps Classes to Tables. |

---

## 🏗️ Safety Patterns

### SQL Injection Prevention
NEVER use f-strings for queries.

```python
# CATASTROPHIC SECURITY FLAW
cursor.execute(f"SELECT * FROM users WHERE name = '{user_input}'")

# SAFE (Parameterized)
cursor.execute("SELECT * FROM users WHERE name = ?", (user_input,))
```

---

## 📖 Real-World Story: The "Little Bobby Tables"

**Problem**: An internal admin tool allowed engineers to reset passwords by typing a username.
**Crisis**: A QA engineer typed `admin'; DROP TABLE users; --` as a test.
**Result**: The users table was deleted. The tool used string concatenation.
**Solution**: Switched to parameterized queries (`?` or `%s`).

---

## ❓ Interview Questions

1.  **What is the Python DB-API?**
    - *Answer*: A specification (PEP 249) that defines common interfaces (connect, cursor, execute) so code works across different databases (MySQL, Postgres, SQLite) with minimal changes.
2.  **Why use an ORM (like SQLAlchemy)?**
    - *Answer*: It abstracts raw SQL, allowing you to switch database backends easily and work with Python objects instead of tuples.
3.  **What happens if you don't call `conn.commit()`?**
    - *Answer*: The transaction is rolled back when the connection closes. No data is saved.

---

[Next: Docker & Kubernetes](../11-Docker-and-Kubernetes-SDKs/README.md)
