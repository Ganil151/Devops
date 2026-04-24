# 🏗️ Go Data Modeling & Interfaces
*Version 1.0 | Architectural Depth in Structural Composition*

---

## 📖 Overview
Go abandons traditional class-based inheritance in favor of **Composition** and **Interfaces**. This approach creates highly decoupled and modular systems, which are essential for complex infrastructure automation agents.

---

## ⚙️ Structs & Composition

### 1. Structs
The primary building block for custom data types.
```go
type Server struct {
    Hostname string
    IP       string
    Port     int
    IsActive bool
}
```

### 2. Struct Embedding (Composition)
Go uses embedding to share behavior between types. It is NOT inheritance.
```go
type LoadBalancer struct {
    Server // Embedded struct
    Region string
}
// Now LoadBalancer has access to Server.Hostname
```

---

## ⚓ Methods & Receivers

Methods are functions bounded to a specific type.
- **Value Receiver**: `func (s Server) Ping() {}` (Operates on a copy).
- **Pointer Receiver**: `func (s *Server) UpdateIP(ip string) {}` (Allows modification of the original struct).

---

## 🔌 Interfaces: Implicit Abstraction

### 1. Concept
An Interface defines a **set of method signatures**. A type implements an interface by simply implementing its methods. There is no `implements` keyword.

### 2. SRE Use Case: The "CloudProvider" Interface
```go
type CloudProvider interface {
    DeployInstance(name string) error
    DeleteInstance(id string) error
}

// Any struct (AWS, Azure, GCP) that has these two methods
// automatically satisfies the CloudProvider interface.
```

### 3. The Empty Interface (`any` / `interface{}`)
Matches anything. Use with caution as it bypasses Go's type-safety.

---

## 🚀 Advanced Composition Patterns

- **Functional Options**: A pattern for handling structural configuration without massive constructor functions.
- **Dependency Injection**: Passing interfaces to functions to allow for easy mocking in tests.

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain "Implicit Satisfaction" of interfaces and how it differs from Java/C# interfaces.**
2. **What happens during a "Type Assertion" in Go? How do you safely check if a type implements an interface?**
3. **What is "Field Tagging" in structs (e.g., `` json:"id" ``) and how is it used by the reflection engine?**
4. **Why would you choose struct embedding over defining a field of that type?**
5. **Describe the performance impact of using interfaces (virtual method tables) vs concrete types.**

---
**Next Step**: [Go Control Flow & Error Handling →](./go-control-flow-errors-ref.md)
