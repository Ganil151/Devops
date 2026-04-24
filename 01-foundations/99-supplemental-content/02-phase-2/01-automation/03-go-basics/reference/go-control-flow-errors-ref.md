# 🚦 Go Control Flow & Error Handling
*Version 1.0 | Logic Gates and the "Errors as Values" Philosophy*

---

## 📖 Overview
Go significantly simplifies control flow by having only one looping construct (`for`) and treating errors as explicit return values. This design forces developers to address failures immediately, leading to more resilient automation scripts.

---

## ⚙️ Control Flow Mechanics

### 1. The Only Loop: `for`
Go has no `while` or `until`.
- **Standard**: `for i := 0; i < 10; i++ {}`
- **Infinite**: `for {}`
- **Condition-only (While)**: `for x < 10 {}`
- **Range (Arrays/Maps)**: `for index, value := range data {}`

### 2. Switch Statements
More powerful than other languages.
- No `break` needed (implicit).
- Supports expressions and multiple values: `switch status { case "starting", "running": ... }`
- **Switch on Type**: `switch v := i.(type) { case int: ... }`

---

## 🛡️ Error Handling: The Go Way

### 1. Errors as Values
In Go, an `error` is just a standard interface. Functions typically return two values: the result and an error.
```go
data, err := os.ReadFile("config.yml")
if err != nil {
    log.Fatalf("Critical Failure: %v", err)
}
```

### 2. Custom Errors
```go
func QueryDB() error {
    return fmt.Errorf("network timeout on %s", clusterID)
}
```

### 3. Defer, Panic, and Recover
- **`defer`**: Schedules a function call to run immediately before the function returns. (Critical for closing files/sockets).
- **`panic`**: Stops normal execution and starts "panicking." Use only for unrecoverable errors (e.g., config file missing).
- **`recover`**: A built-in function that regains control of a panicking goroutine.

---

## 🚀 SRE Standard Checklist
- [ ] **Immediate Check**: Always check `if err != nil` immediately after the call.
- [ ] **Cleanups**: Always use `defer file.Close()` immediately after checking for errors in file opening.
- [ ] **Contextual Errors**: Use `fmt.Errorf("failed to process node %s: %w", nodeID, err)` to wrap errors with context without losing the original error.

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain the behavior of `defer` when a panic occurs.**
2. **What is the difference between `errors.Is()` and `errors.As()` in the Go standard library?**
3. **Describe a scenario where using `panic` is preferred over returning an `error`.**
4. **How do you handle a "Fallthrough" in a Switch statement?**
5. **What is a "Sentinel Error"? Give an example.**

---
**Next Step**: [Go Concurrency & Goroutines →](./go-concurrency-ref.md)
