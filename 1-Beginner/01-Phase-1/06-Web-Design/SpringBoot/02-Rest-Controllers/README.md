# 🔌 Spring Boot RESTful Controllers
*Building Performance-Driven Enterprise APIs*

---

## 📖 Overview
Spring Web allows you to build REST endpoints quickly using Annotations. It maps HTTP requests to specific methods in your Controller classes.

---

## 🏗️ Technical Pillars

### 1. `@RestController`
Combines `@Controller` and `@ResponseBody`, ensuring that the return value of every method is automatically serialized into JSON.

### 2. Mapping Annotations
- `@GetMapping`: Query data.
- `@PostMapping`: Trigger actions/Save data.
- `@DeleteMapping`: decommissioning resources.

### 3. Path Variables & Params
- `@PathVariable`: `/api/logs/{id}`
- `@RequestParam`: `/api/logs?status=error`

---

## 🧪 Quick Exercise
Create a `HealthController` that:
1. Returns a JSON status object at `/health`.
2. Returns a specific pod's status at `/status/{podName}`.

---
**Next Step**: [03-Data-JPA](../03-Data-JPA/README.md)
