# Time and Date
*Handling Time in Go*

Go's `time` package provides comprehensive time handling with unique formatting.

---

## 🎯 Learning Objectives

- Work with time.Time
- Format and parse dates
- Use durations and timers

---

## 📚 Core Concepts

### 1. Current Time

```go
import "time"

now := time.Now()
fmt.Println(now)                    // 2026-01-11 22:30:00...
fmt.Println(now.Unix())             // Unix timestamp
fmt.Println(now.UTC())              // Convert to UTC
```

### 2. Formatting (Go uses reference time!)

```go
// Reference: Mon Jan 2 15:04:05 MST 2006
// 1  2  3  4  5  6  7

t := time.Now()
t.Format("2006-01-02")              // "2026-01-11"
t.Format("2006-01-02 15:04:05")     // "2026-01-11 22:30:00"
t.Format(time.RFC3339)              // "2026-01-11T22:30:00Z"
```

### 3. Durations

```go
// Duration calculations
later := now.Add(24 * time.Hour)
diff := later.Sub(now)

// Sleeping
time.Sleep(5 * time.Second)

// Timeouts
select {
case result := <-ch:
    process(result)
case <-time.After(10 * time.Second):
    log.Println("Timeout!")
}
```

---

## 🛠️ Hands-On Exercise

```go
// Calculate deployment duration
func deploymentDuration(start, end time.Time) string {
    // TODO: Return human-readable duration like "5m30s"
}
```

<details>
<summary>💡 Solution</summary>

```go
func deploymentDuration(start, end time.Time) string {
    d := end.Sub(start)
    return d.Round(time.Second).String()
}
```
</details>

---

## 🧠 Quiz

1. Go's format reference year is:
   - a) 2000
   - b) 2006 ✅

2. `time.Duration` base unit:
   - a) Seconds
   - b) Nanoseconds ✅

---

**Next Step**: [Regular Expressions →](../15-Regular-Expressions/README.md)
