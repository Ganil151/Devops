# Web Design & Frameworks

Welcome to the **Web Design** module. In modern DevOps, understanding how applications are built is as important as knowing how to deploy them.

## Overview
Web frameworks simplify development by providing tools for routing, database interaction, and security. We focus on the two most popular Python frameworks:

| Framework | Type | Best For |
|-----------|------|----------|
| **[Flask](./Flask/README.md)** | Micro-framework | Simple APIs, Microservices, Lightweight tools |
| **[Django](./Django/README.md)** | Full-stack | Large applications, E-commerce, Content management |

---

## Learning Path

1. **[Environment Setup](./Environment-Setup.md)**: Master Python Virtual Environments (`venv`) and dependency management. **(Start Here)**
2. **The Basics**: Understand how HTTP works (Requests, Responses).
2. **Framework Choice**: Decide based on project complexity.
3. **Application Logic**: Writing routes and handling data.
4. **DevOps Integration**: Dockerizing and deploying to production.

---

## Comparison: Flask vs Django

```mermaid
graph TB
    subgraph "Flask"
        F_Core[Core]
        F_Ext[Extensions]
        F_Core --- F_Ext
    end
    
    subgraph "Django"
        D_All[The Whole Kitchen Sink]
        D_ORM[ORM]
        D_Admin[Admin UI]
        D_Auth[Auth]
        D_All --- D_ORM & D_Admin & D_Auth
    end
```

---

## Resources
- [Flask Official Site](https://flask.palletsprojects.com/)
- [Django Project Site](https://www.djangoproject.com/)

---

**[← Back to Beginner Roadmap](../README.md)**
