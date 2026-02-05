# 🐎 Django: Enterprise Python Reliability
*The High-Scale Fullstack Framework for Data-Heavy Dashboards*

---

## 🗺️ Learning Roadmap

### [01-The-MTV-Pattern](./01-The-MTV-Pattern/)
- **Concepts**: Models, Templates, Views, URL mapping.
- **Goal**: Master the "Source of Truth" for your application logic.

### [02-Django-ORM](./02-Django-ORM/)
- **Concepts**: QuerySets, Filters, Relationships (One-to-Many).
- **Goal**: Talk to databases (Postgres/MySQL) using Python classes.

### [03-Admin-and-Auditing](./03-Admin-and-Auditing/)
- **Concepts**: Custom Admin classes, Model Registration.
- **Goal**: Provide a secure portal for team management without custom UI code.

### [04-Rest-Framework-DRF](./04-Rest-Framework-DRF/)
- **Concepts**: Serializers, Viewsets, Auth tokens.
- **Goal**: Build powerful REST APIs for frontend integration.

---

## 🛠️ Quick Start
```bash
pip install django
django-admin startproject my_portal
cd my_portal
python manage.py runserver
```

---

## 🛡️ SRE Standards
- **Migrations First**: Never change a database schema manually. Always use `makemigrations`.
- **Secret Management**: Never commit `SECRET_KEY` to Git. Use `django-environ`.
- **Database Pooling**: Use `pouncer` or built-in pooling for high-concurrency workloads.