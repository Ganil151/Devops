# 🛠️ Django Admin: High-Speed Operations
*Secure Backend Portals for Team Infrastructure Management*

---

## 📖 Overview
Django provides a fully functional administrative interface out of the box. For SREs, this means instantly having a UI to manage users, infrastructure metadata, or configuration flags without writing any frontend code.

---

## 🏗️ Technical Pillars

### 1. Registering Models
Make your models visible in the admin by registering them in `admin.py`.

### 2. Customizing List View
Control which columns are visible and searchable.
```python
@admin.register(Server)
class ServerAdmin(admin.ModelAdmin):
    list_display = ('hostname', 'ip', 'is_active')
    search_fields = ('hostname',)
```

### 3. Permissions & Groups
Use the built-in Group system to restrict access (e.g., Only "Junior SREs" can view servers, but "Senior SREs" can delete them).

---

## 🚀 Advanced Pattern: Log Entry Auditing
Django tracks every change made via the admin interface automatically in the `LogEntry` table. This provides a clear audit trail of who changed what and when.

---

## 🛡️ SRE Standard Checklist
- [ ] Is the `/admin` URL changed to a non-standard path for security through obscurity?
- [ ] Is Two-Factor Authentication (2FA) enforced for admin users?
- [ ] Are sensitive fields (like API keys) masked in the admin view?

---
**Next Step**: [04-Rest-Framework-DRF](../04-rest-framework-drf/readme.md)
