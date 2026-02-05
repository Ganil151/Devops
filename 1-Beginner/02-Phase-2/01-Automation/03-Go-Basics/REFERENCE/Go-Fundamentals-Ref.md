# 🐹 Go Fundamentals Reference
*Version 1.0 | Mastering the Bedrock of Compiled Automation*

---

## 📖 Overview
Go (Golang) is an open-source programming language designed for simplicity, efficiency, and reliability. For SREs and DevOps engineers, Go is the language of choice for cloud-native infrastructure (Kubernetes, Docker, Terraform) due to its static typing, fast compilation, and single-binary deployment.

---

## 🏗️ Core Syntax & Variables

### 1. Variables and Type Inference
- **Explicit Declaration**: `var name string = "Go"`
- **Short Variable Declaration**: `name := "Go"` (Only inside functions).
- **Multiple Declaration**: `var x, y int = 1, 2`
- **Constants**: `const Pi = 3.14`

### 2. Basic Types
- **Integers**: `int`, `int8`, `int16`, `int32`, `int64` (and unsigned `uint` variants).
- **Floating Point**: `float32`, `float64`.
- **Strings**: Immutable sequences of bytes.
- **Booleans**: `bool` (`true`, `false`).

---

## ⚙️ Pointers & Memory Management

### 1. Pointers
Go has pointers but **no pointer arithmetic**.
- `&`: Address-of operator.
- `*`: Dereference operator.
```go
x := 10
p := &x         // p points to x
fmt.Println(*p) // output: 10
*p = 20         // x is now 20
```

### 2. `new` vs `make`
- **`new(T)`**: Allocates zeroed storage for a new item of type T and returns its address (`*T`).
- **`make(T, args)`**: Used only for **slices, maps, and channels**. It returns an initialized (not zeroed) value of type T (not `*T`).

---

## 🚀 SRE Standard Checklist
- [ ] **Type Safety**: Avoid `interface{}` (any) unless absolutely necessary to maintain type safety.
- [ ] **Formatting**: Always run `go fmt` or `goimports` to adhere to standard styling.
- [ ] **Zero Values**: Understand that variables are initialized to their "Zero Value" (`0`, `""`, `false`, `nil`) by default.
- [ ] **Shadowing**: Be careful not to "shadow" variables in inner scopes when using `:=`.

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain the difference between a `string` and a `[]byte` in Go. Which is more efficient for heavy modifications?**
2. **What is a "Pointer Receiver" in a method, and why is it preferred over a "Value Receiver" for large structs?**
3. **Describe the behavior of Go's Garbage Collector (GC). Is it a "Stop-the-World" collector?**
4. **Why does Go not support traditional class-based inheritance?**
5. **How does the Go compiler handle "Unused Variables" and "Unused Imports"?**

---
**Next Step**: [Go Data Modeling & Interfaces →](./Go-Data-Modeling-Ref.md)
