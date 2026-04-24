# 🐎 Django MTV Architecture
*Mastering the Blueprint of Enterprise Python Apps*

---

## 📖 Overview
Django uses a variation of the MVC pattern called **MTV (Model, Template, View)**. This strict separation ensures that business logic, data structures, and the UI never overlap.

---

## 🏗️ Technical Pillars

### 1. Model (Data)
The single source of truth for your data types. Defined in `models.py`.

### 2. Template (UI)
HTML files enriched with **Django Template Language (DTL)**. Used for server-side rendering.

### 3. View (Logic)
The controller that processes incoming requests, talks to models, and renders templates or returns JSON.

### 4. URL Dispatcher
The `urls.py` file provides a clean, regex-based mapping for your views.

---

## 🧪 Quick Exercise
1. Create a `CloudNode` model with `hostname` and `region`.
2. Write a view that queries all nodes and passes them to a template.
3. Map the view to `/nodes/`.

---
**Next Step**: [02-Django-ORM](../02-django-orm/readme.md)
