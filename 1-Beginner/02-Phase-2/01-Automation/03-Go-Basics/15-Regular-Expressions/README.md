# Regular Expressions
*Pattern Matching in Go*

The `regexp` package provides efficient regular expression support.

---

## 🎯 Learning Objectives

- Compile and use regex patterns
- Extract matches
- Replace text

---

## 📚 Core Concepts

### 1. Basic Matching

```go
import "regexp"

// Compile pattern (do once, reuse)
pattern := regexp.MustCompile(`\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}`)

// Check match
if pattern.MatchString("Server IP: 10.0.0.1") {
    fmt.Println("Contains IP address")
}

// Find match
ip := pattern.FindString("Server IP: 10.0.0.1")  // "10.0.0.1"
```

### 2. Capture Groups

```go
pattern := regexp.MustCompile(`(\w+)-(\w+)-(\d+)`)

matches := pattern.FindStringSubmatch("web-prod-01")
// matches[0] = "web-prod-01"
// matches[1] = "web"
// matches[2] = "prod"
// matches[3] = "01"
```

### 3. Replace

```go
pattern := regexp.MustCompile(`password=\S+`)
result := pattern.ReplaceAllString(config, "password=***")
```

---

## 🛠️ Hands-On Exercise

```go
// Extract log level and message from log line
// "2026-01-11 ERROR: Connection failed"
func parseLog(line string) (level, message string) {
    // TODO: Use regex to extract
}
```

<details>
<summary>💡 Solution</summary>

```go
var logPattern = regexp.MustCompile(`^\S+ (\w+): (.+)$`)

func parseLog(line string) (level, message string) {
    matches := logPattern.FindStringSubmatch(line)
    if len(matches) >= 3 {
        return matches[1], matches[2]
    }
    return "", ""
}
```
</details>

---

## 🧠 Quiz

1. `MustCompile` panics if:
   - a) No match found
   - b) Invalid pattern ✅

2. `FindStringSubmatch` returns:
   - a) Just groups
   - b) Full match + groups ✅

---

**Next Step**: [Testing Basics →](../16-Testing-Basics/README.md)
