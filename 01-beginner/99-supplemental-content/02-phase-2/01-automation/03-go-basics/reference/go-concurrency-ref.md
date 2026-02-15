# 📡 Go Concurrency: Goroutines & Channels
*Version 1.0 | High-Scale Parallelism for Systems Engineering*

---

## 📖 Overview
Concurrency is built into the heart of Go. Unlike traditional threading which is heavy and managed by the OS, **Goroutines** are ultra-lightweight threads managed by the Go runtime. This allows a single SRE tool to monitor thousands of endpoints simultaneously.

---

## 🏗️ Technical Pillars

### 1. Goroutines
**Definition**: A function running concurrently with other functions.
- **Syntax**: `go myFunction()`
- **Memory**: Tiny stack size (~2KB), which grows and shrinks as needed.

### 2. Channels (CSP Pattern)
"Do not communicate by sharing memory; instead, share memory by communicating."
- **Unbuffered**: Blocks sender until receiver is ready. `ch := make(chan int)`
- **Buffered**: Allows sender to continue until buffer is full. `ch := make(chan int, 100)`

---

## ⚙️ Concurrency Control

### 1. The `select` Statement
Allows a goroutine to wait on multiple communication operations.
```go
select {
case msg := <-ch1:
    fmt.Println("Received", msg)
case <-time.After(1 * time.Second):
    fmt.Println("Timeout reached")
}
```

### 2. Sync Package
- **WaitGroup**: Wait for a collection of goroutines to finish.
- **Mutex**: Mutual exclusion lock to prevent "Race Conditions" when multiple goroutines write to the same map/variable.

---

## 🚀 Advanced Concurrency Patterns

- **Worker Pool**: Managing a fixed number of goroutines to process a queue of work (e.g., Image processing).
- **Fan-out, Fan-in**: One goroutine sending work to many, and consolidating the results.
- **Context Package**: Used for cancellation and timeouts across entire branches of goroutines (Critical for API timeouts).

---

## 🛡️ SRE Standard Checklist
- [ ] **Leak Check**: Ensure every goroutine has a way to exit (Avoid zombie goroutines).
- [ ] **Race Detector**: Always run your tests with the `-race` flag (`go test -race ./...`).
- [ ] **Timeouts**: Never perform a networked operation without a `select` timeout or a `context`.

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain the difference between Concurrency and Parallelism.**
2. **What happens if you send to a closed channel? What if you receive from a closed channel?**
3. **Describe the "M:N Scheduler" in the Go runtime.**
4. **How do you detect a Deadlock in a Go application?**
5. **What is a "Data Race" and how does a Mutex solve it?**

---
**Next Step**: [Go Toolchain & SRE Tooling →](./go-toolchain-sre-ref.md)
