# 🏗️ Spring Boot: Inversion of Control
*Mastering the Enterprise Lifecycle Engine*

---

## 📖 Overview
The core of Spring is Inversion of Control (IoC). Instead of you creating objects using `new`, the Spring Container instantiates and manages the lifecycle of your objects (Beans).

---

## 🏗️ Technical Pillars

### 1. Beans
Objects that are managed by the Spring IoC container. Marked with `@Component`, `@Service`, or `@Repository`.

### 2. Dependency Injection (DI)
The process of wiring these beans together. Spring "injects" the required objects into your class via the constructor.
```java
@Service
public class MetricService {
    private final NodeRepository repo;
    // Spring injects the repo automatically
    public MetricService(NodeRepository repo) { this.repo = repo; }
}
```

### 3. Application Context
The central interface for providing configuration to the application. It loads beans and resolves dependencies.

---

## 🚀 DevOps Advantage
Decoupling components makes your application extremely easy to unit test. You can "Mock" a database repository and test your business logic in isolation.

---
**Next Step**: [02-Rest-Controllers](../02-Rest-Controllers/README.md)
