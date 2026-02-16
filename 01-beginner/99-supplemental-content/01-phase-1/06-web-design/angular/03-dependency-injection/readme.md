# 💉 Angular: Dependency Injection (DI)
*Service Architecture and Business Logic Separation*

---

## 📖 Overview
Dependency Injection is a design pattern where a class receives its dependencies from external sources rather than creating them itself.

---

## 🏗️ Technical Pillars

### 1. `@Injectable` Services
Classes intended to be used across components.
```typescript
@Injectable({
  providedIn: 'root'
})
export class StatusService {
  getStatus() { return 'Healthy'; }
}
```

### 2. Constructor Injection
The mechanism used to request a service.
```typescript
constructor(private status: StatusService) {}
```

### 3. Hierarchical Injectors
Control the lifetime of a service by where you provide it (Root, Module, or Component).

---
**Next Step**: [04-RxJS-and-Observables](../04-rxjs-and-observables/readme.md)
