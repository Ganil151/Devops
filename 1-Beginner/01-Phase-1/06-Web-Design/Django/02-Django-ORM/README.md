# 🗄️ Django ORM: Advanced Data Logic
*High-Performance Database Operations with Python*

---

## 📖 Overview
The Django ORM is one of the most powerful features of the framework. It abstracts away SQL, allowing you to perform complex joins and aggregations using standard Python syntax.

---

## 🏗️ Technical Pillars

### 1. QuerySets (Lazy Loading)
Queries aren't executed until you evaluate them (e.g., in a loop).
`Server.objects.filter(status='up')`

### 2. Relationships
- `ForeignKey`: One-to-Many (e.g., A Host has many Logs).
- `OneToOneField`: (e.g., A User has one Profile).
- `ManyToManyField`: (e.g., A Server belongs to many Security Groups).

### 3. Migrations (Versioned Schema)
Django tracks every change to your models.
`python manage.py makemigrations`
`python manage.py migrate`

---

## 🚀 Optimization Tips
- **`select_related()`**: Use for single relationships (ForeignKey) to avoid "N+1" SQL queries.
- **`prefetch_related()`**: Use for many-to-many relationships.

---

## 🛡️ SRE Standard Checklist
- [ ] Are all database queries optimized for large datasets?
- [ ] Are migration files commited to Git?
- [ ] Is there a "Dry Run" check for migrations in the CI pipeline?

---
**Next Step**: [03-Admin-and-Auditing](../03-Admin-and-Auditing/README.md)
