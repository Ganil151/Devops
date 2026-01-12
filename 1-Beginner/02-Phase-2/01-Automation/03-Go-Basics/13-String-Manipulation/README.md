# String Manipulation
*Text Processing in Go*

The `strings` and `fmt` packages provide powerful text processing capabilities.

---

## 🎯 Learning Objectives

- Use strings package functions
- Format output with fmt
- Work with bytes and runes

---

## 📚 Core Concepts

### 1. Common String Operations

```go
import "strings"

s := "web-server-prod-01"

strings.Contains(s, "prod")     // true
strings.HasPrefix(s, "web")     // true
strings.HasSuffix(s, "01")      // true
strings.Split(s, "-")           // ["web","server","prod","01"]
strings.Join(parts, "-")        // "web-server-prod-01"
strings.ToUpper(s)              // "WEB-SERVER-PROD-01"
strings.TrimSpace("  hello  ") // "hello"
strings.Replace(s, "-", "_", -1)// "web_server_prod_01"
```

### 2. String Formatting

```go
// Printf patterns
fmt.Printf("Server: %s\n", name)        // String
fmt.Printf("Port: %d\n", port)          // Integer
fmt.Printf("CPU: %.2f%%\n", cpu)        // Float with precision
fmt.Printf("Value: %v\n", anyValue)     // Default format
fmt.Printf("Type: %T\n", anyValue)      // Type name
fmt.Printf("Struct: %+v\n", myStruct)   // Struct with field names

// Sprintf returns string
msg := fmt.Sprintf("Error on %s: %v", server, err)
```

### 3. Building Strings

```go
import "strings"

var builder strings.Builder
builder.WriteString("Line 1\n")
builder.WriteString("Line 2\n")
result := builder.String()
```

---

## 🛠️ Hands-On Exercise

```go
// Parse server name: "web-prod-us-east-01"
// Extract: type, env, region, number
func parseServerName(name string) (sType, env, region string, num int) {
    // TODO: Implement
}
```

<details>
<summary>💡 Solution</summary>

```go
func parseServerName(name string) (sType, env, region string, num int) {
    parts := strings.Split(name, "-")
    if len(parts) >= 4 {
        sType = parts[0]
        env = parts[1]
        region = parts[2] + "-" + parts[3]
        if len(parts) >= 5 {
            num, _ = strconv.Atoi(parts[4])
        }
    }
    return
}
```
</details>

---

## 🧠 Quiz

1. `strings.Split("a-b-c", "-")` returns:
   - a) String
   - b) `[]string{"a","b","c"}` ✅

2. `%+v` in Printf shows:
   - a) Just values
   - b) Struct field names and values ✅

---

**Next Step**: [Time and Date →](../14-Time-and-Date/README.md)
