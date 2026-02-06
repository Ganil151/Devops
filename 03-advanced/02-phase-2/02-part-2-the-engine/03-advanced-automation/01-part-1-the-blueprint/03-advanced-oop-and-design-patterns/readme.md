# Advanced OOP & Design Patterns
*Building Scalable and Modular Frameworks*

In enterprise DevOps, we don't just write scripts; we build **platforms**. To do this effectively, you must master Advanced Object-Oriented Programming (OOP) and common **Design Patterns**. This allows you to write code that is "Open for extension but closed for modification."

---

## 🏗️ Core Advanced OOP

### Abstract Base Classes (ABC)
Enforce a contract. Every "Cloud" class *must* have a `provision()` method.

```python
from abc import ABC, abstractmethod

class CloudProvider(ABC):
    @abstractmethod
    def provision(self, name):
        pass

class AWS(CloudProvider):
    def provision(self, name):
        print(f"Creating EC2: {name}")

class Azure(CloudProvider):
    def provision(self, name):
        print(f"Creating VM: {name}")
```

### Mixins & Composition
Reuse behavior without deep inheritance chains.

```python
class LoggingMixin:
    def log(self, message):
        print(f"[LOG] {message}")

class Deployer(LoggingMixin):
    def deploy(self):
        self.log("Starting deployment...")
```

---

## 📊 Design Patterns for DevOps

### 1. The Factory Pattern
Create objects without specifying the exact class. (Useful for Multi-Cloud)

```python
class ProviderFactory:
    @staticmethod
    def get_provider(cloud_type):
        if cloud_type == "aws": return AWS()
        if cloud_type == "azure": return Azure()
        raise ValueError("Unknown Cloud")
```

### 2. The Singleton Pattern
Ensure a resource (like a database connection or config) only exists once.

### 3. The Observer Pattern
Notify multiple components (Slack, PagerDuty, Logs) when a deployment fails.

---

## 🛠️ Hands-On Challenges

Master architectural design by building these modular systems.

| Challenge | Topic | Description | Starter Code | Solution |
| :--- | :--- | :--- | :--- | :--- |
| **01. Multi-Cloud Engine** | Factory Pattern | Build a unified CLI that provisions resources on AWS/GCP based on a YAML config. | [Link](./challenges/challenge-01-cloud-factory.py) | [Link](./challenges/solutions/solution-01-cloud-factory.py) |
| **02. Slack Monitor** | Observer Pattern | Create an alert system where different services "Subscribe" to deployment events. | [Link](./challenges/challenge-02-alert-observer.py) | [Link](./challenges/solutions/solution-02-alert-observer.py) |
| **03. Global Config** | Singleton | Implement a Thread-Safe Singleton that loads environment variables once for the whole app. | [Link](./challenges/challenge-03-singleton-config.py) | [Link](./challenges/solutions/solution-03-singleton-config.py) |

---

## ❓ Interview Questions

1. **What is 'Duck Typing' and why is it useful in Python automation?**
   * *Answer*: "If it walks like a duck and quacks like a duck, it's a duck." In Python, we care about what an object *does* (its methods) rather than what it *is*. This allows us to pass a Mock object into an Auditor function as long as it has the same method names as the real Boto3 client.
2. **Explain the difference between Inheritance and Composition.**
   * *Answer*: Inheritance is an "Is-A" relationship (A LinuxServer *is a* Server). Composition is a "Has-A" relationship (A Server *has a* Disk). Composition is generally preferred because it's more flexible and avoids deep, rigid hierarchy.
3. **Why use the Factory Pattern instead of simple `if/else`?**
   * *Answer*: Decoupling. The main script doesn't need to know how to instantiate AWS or GCP; it just asks the Factory for a "Provider". This makes it easy to add a third provider (DigitalOcean) without touching the main deployment logic.

---

**Next Step**: [Metaprogramming & Decorators →](../04-metaprogramming-and-decorators/readme.md)
