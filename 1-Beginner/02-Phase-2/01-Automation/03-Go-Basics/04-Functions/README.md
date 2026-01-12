# Functions
*The Building Blocks of Go Programs*

Functions in Go are first-class citizens. They can be passed as arguments, returned from other functions, and assigned to variables.

---

## 🎯 Learning Objectives

- Define functions with multiple returns
- Use named return values
- Understand closures and anonymous functions
- Apply defer for cleanup

---

## 📊 Function Anatomy

```mermaid
flowchart LR
    A[func] --> B[name]
    B --> C[parameters]
    C --> D[return types]
    D --> E[body]
    
    style A fill:#00ADD8,stroke:#00758D,color:#fff
```

---

## 📚 Core Concepts

### 1. Basic Functions

```go
// Single return
func checkHealth(server string) bool {
    // health check logic
    return true
}

// Multiple returns (idiomatic Go)
func getServerInfo(name string) (string, int, error) {
    return "10.0.0.1", 8080, nil
}

// Named returns
func divide(a, b float64) (result float64, err error) {
    if b == 0 {
        err = errors.New("division by zero")
        return  // naked return
    }
    result = a / b
    return
}
```

### 2. Variadic Functions

```go
func sum(numbers ...int) int {
    total := 0
    for _, n := range numbers {
        total += n
    }
    return total
}

// Usage
sum(1, 2, 3)
sum(1, 2, 3, 4, 5)

// Expand slice
nums := []int{1, 2, 3}
sum(nums...)
```

### 3. Closures

```go
func counter() func() int {
    count := 0
    return func() int {
        count++
        return count
    }
}

c := counter()
fmt.Println(c())  // 1
fmt.Println(c())  // 2
fmt.Println(c())  // 3
```

### 4. Defer

```go
func processFile(path string) error {
    file, err := os.Open(path)
    if err != nil {
        return err
    }
    defer file.Close()  // Runs when function returns
    
    // Process file...
    return nil
}

// Multiple defers (LIFO order)
func example() {
    defer fmt.Println("First")
    defer fmt.Println("Second")
    defer fmt.Println("Third")
    // Prints: Third, Second, First
}
```

---

## 🛠️ Hands-On Exercises

### Exercise 1: Server Stats
```go
// Return multiple stats from a function
func getServerStats(name string) (cpu, memory, disk float64) {
    // TODO: Implement with named returns
}
```

<details>
<summary>💡 Solution</summary>

```go
func getServerStats(name string) (cpu, memory, disk float64) {
    // Simulated stats
    cpu = 75.5
    memory = 68.2
    disk = 45.0
    return
}

func main() {
    cpu, mem, disk := getServerStats("web-01")
    fmt.Printf("CPU: %.1f%%, Memory: %.1f%%, Disk: %.1f%%\n", cpu, mem, disk)
}
```
</details>

### Exercise 2: Retry with Options
```go
// Create a flexible retry function
func withRetry(fn func() error, maxAttempts int) error {
    // TODO: Execute fn up to maxAttempts times
    // Return nil on success, last error on failure
}
```

<details>
<summary>💡 Solution</summary>

```go
import "time"

func withRetry(fn func() error, maxAttempts int) error {
    var lastErr error
    
    for attempt := 1; attempt <= maxAttempts; attempt++ {
        if err := fn(); err == nil {
            return nil
        } else {
            lastErr = err
            fmt.Printf("Attempt %d failed: %v\n", attempt, err)
            if attempt < maxAttempts {
                time.Sleep(time.Second)
            }
        }
    }
    
    return lastErr
}
```
</details>

---

## ❓ Interview Questions

1. **What's unique about Go's multiple return values?**
   > First-class support, commonly used for (value, error) pattern.

2. **When does defer execute?**
   > When the surrounding function returns, in LIFO order.

3. **What is a closure?**
   > A function that captures variables from its enclosing scope.

---

## 🧠 Quiz

1. Multiple defers execute in:
   - a) FIFO order
   - b) LIFO order ✅

2. Variadic parameter syntax:
   - a) `...int`  ✅
   - b) `int...`
   - c) `*int`

3. Named returns allow:
   - a) Only one return
   - b) Naked return statements ✅

---

**Next Step**: [Structs and Methods →](../05-Structs-and-Methods/README.md)
