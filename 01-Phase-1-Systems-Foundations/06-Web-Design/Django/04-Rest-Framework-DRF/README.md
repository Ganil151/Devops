# 🔌 Django REST Framework (DRF)
*Modern APIs for High-Scale Enterprise Integration*

---

## 📖 Overview
DRF is the industry standard for building APIs on top of Django. It adds a powerful serialization layer, authentication policies, and a browsable API interface.

---

## 🏗️ Technical Pillars

### 1. Serializers
Convert complex data (Model instances) into native Python types that can then be easily rendered into JSON.

### 2. ViewSets & Routers
Automatically generate all standard CRUD endpoints (`/list/`, `/create/`, `/update/`) with a single class.
```python
class NodeViewSet(viewsets.ModelViewSet):
    queryset = Node.objects.all()
    serializer_class = NodeSerializer
```

### 3. Permissions
Highly granular access control.
- `AllowAny`
- `IsAuthenticated`
- `IsAdminUser`
- `IsOwnerOrReadOnly` (Custom logic)

---

## 🚀 DevOps Use Case
Exposing your infrastructure inventory database to a React dashboard or an automated monitoring bot.

---

## 🛡️ SRE Standard Checklist
- [ ] Are all API responses in JSON format?
- [ ] Is "Token Authentication" or "JWT" active?
- [ ] Is "Throttling" configured to prevent API abuse?
- [ ] Is "Filtering" enabled via `django-filter`?

---
**Back to Module**: [Django Main Guide](../README.md)
