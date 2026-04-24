# 🔤 String Manipulation in Go

> **"In DevOps automation, you're constantly parsing log files, extracting metadata from server names, formatting error messages, and building configuration templates. Go's `strings` package is your Swiss Army knife for text processing."**

Strings in Go are immutable sequences of bytes. While this might seem limiting at first, Go provides a rich set of functions in the `strings` package and efficient builders for constructing new strings. Understanding these tools is essential for writing clean, performant automation scripts.

![String Processing for DevOps](./go-strings-hero.png)

## Table of Contents

* [Essential String Operations](#essential-string-operations)
* [String Formatting with fmt](#string-formatting-with-fmt)
* [Efficient String Building](#efficient-string-building)
* [Bytes vs Runes: Unicode Handling](#bytes-vs-runes-unicode-handling)
* [Practical Use Case: Log Parser](#practical-use-case-log-parser)
* [Knowledge Vault (Scenarios, Interview, Quiz)](#knowledge-vault)
* [Additional Resources](#additional-resources)

---

## 💼 The Automation Why: The Universal Data Munger

**The Beginner's Question**: "Static typing is great, but isn't text processing harder than in Python?"

**The Answer**: **Precision handles complexity.**
In DevOps, "data" is rarely perfect. It's often messy logs, inconsistent CSVs, or unformatted API responses. Python is great at "guessing," but Go forces you to be precise. When parsing a 1GB log file, Go’s strings package and efficient memory management ensure your automation doesn't crash the server it's monitoring.

### The Sifter Analogy 🔍

- **Generic Scripting (Search/Replace)** = **A Bucket**: You scoop everything up and hope the "Delete" command finds the right keyword. If the keyword appears in the wrong column, you might delete the wrong server.
- **Go String Manipulation** = **A Precision Sifter**: You use `Split`, `Trim`, and `Contains` to filter specifically by the "Third column of the second row." You don't just "find text"—you understand its coordinate in the data stream. By the time the data reaches your logic, it’s clean, verified, and safe.

---

## Essential String Operations

The `strings` package provides functions for common text manipulation tasks.

### Searching and Checking
```go
import "strings"

serverName := "web-server-prod-us-east-1"

// Check if string contains substring
strings.Contains(serverName, "prod")     // true

// Check prefix/suffix
strings.HasPrefix(serverName, "web")     // true
strings.HasSuffix(serverName, "1")       // true

// Find index
strings.Index(serverName, "prod")        // 11
```

### Splitting and Joining
```go
// Split into parts
parts := strings.Split("web-server-prod", "-")
// Result: []string{"web", "server", "prod"}

// Join parts back
result := strings.Join(parts, "_")
// Result: "web_server_prod"
```

### Transformation
```go
s := "  Hello World  "

strings.ToUpper(s)                    // "  HELLO WORLD  "
strings.ToLower(s)                    // "  hello world  "
strings.TrimSpace(s)                  // "Hello World"
strings.Replace(s, "World", "Go", 1)  // "  Hello Go  "
```

---

## String Formatting with fmt

The `fmt` package provides powerful formatting capabilities for creating structured output.

### Common Format Verbs
```go
name := "api-gateway"
port := 8080
cpu := 75.5

// String
fmt.Printf("Server: %s\n", name)

// Integer
fmt.Printf("Port: %d\n", port)

// Float with precision
fmt.Printf("CPU: %.2f%%\n", cpu)

// Default format (works with any type)
fmt.Printf("Value: %v\n", name)

// Type information
fmt.Printf("Type: %T\n", port)  // "int"
```

### Building Strings
```go
// Sprintf returns a formatted string instead of printing
errorMsg := fmt.Sprintf("Failed to connect to %s on port %d", name, port)
```

---

## Efficient String Building

When concatenating many strings, use `strings.Builder` instead of the `+` operator to avoid creating many intermediate string objects.

```go
import "strings"

var builder strings.Builder

builder.WriteString("Server: ")
builder.WriteString(name)
builder.WriteString("\n")
builder.WriteString("Status: ")
builder.WriteString("Running")

result := builder.String()
```

**Performance Note**: For building strings in a loop, `strings.Builder` is significantly faster than repeated concatenation.

---

## Bytes vs Runes: Unicode Handling

Go strings are sequences of bytes, but characters (runes) can be multi-byte in UTF-8.

```go
s := "Hello, 世界"

// Length in bytes
len(s)              // 13

// Length in runes (characters)
utf8.RuneCountInString(s)  // 9

// Iterate over runes
for i, r := range s {
    fmt.Printf("%d: %c\n", i, r)
}
```

---

## Practical Use Case: Log Parser

A common DevOps task is parsing structured log lines to extract specific information.

```go
func parseLogLine(line string) (timestamp, level, message string) {
    // Example: "2024-01-20 ERROR Failed to connect"
    parts := strings.SplitN(line, " ", 3)
    
    if len(parts) >= 3 {
        timestamp = parts[0]
        level = parts[1]
        message = parts[2]
    }
    
    return
}

// Usage
log := "2024-01-20 ERROR Database connection timeout"
ts, lvl, msg := parseLogLine(log)
fmt.Printf("Time: %s, Level: %s, Message: %s\n", ts, lvl, msg)
```

---

## Knowledge Vault

### Real-World Scenarios

#### Scenario 1: The "String Concatenation" Performance Issue
An engineer wrote a script to generate a 10,000-line configuration file using string concatenation (`result += line`). The script took 45 seconds to run because each concatenation created a new string object, causing excessive memory allocation.
**Go Solution**: By switching to `strings.Builder`, the same operation completed in under 1 second, reducing memory allocations by 99%.

#### Scenario 2: Parsing Server Names
A team had inconsistent server naming conventions across AWS, Azure, and GCP. Some used hyphens, others used underscores, and region formats varied.
**Go Solution**: They created a standardized parser using `strings.Split`, `strings.Replace`, and `strings.ToLower` to normalize all server names into a consistent format before processing, eliminating hundreds of edge-case bugs.

### Interview Preparation

1. **Why are strings immutable in Go?**
   > Immutability ensures thread safety and allows the Go runtime to optimize string storage. Multiple variables can safely reference the same underlying string data without risk of one modifying another's value.

2. **What's the difference between `len(s)` and `utf8.RuneCountInString(s)`?**
   > `len(s)` returns the number of bytes in the string, while `utf8.RuneCountInString(s)` returns the number of Unicode characters (runes). For ASCII strings they're the same, but for strings with multi-byte characters like emoji or Chinese characters, they differ.

3. **When should you use `strings.Builder` instead of concatenation?**
   > Use `strings.Builder` when building strings in a loop or concatenating many strings together. The `+` operator is fine for joining 2-3 strings, but becomes inefficient for larger operations due to creating intermediate string copies.

4. **What does `strings.SplitN(s, sep, n)` do differently from `strings.Split`?**
   > `SplitN` limits the number of substrings returned. For example, `SplitN("a:b:c:d", ":", 2)` returns `["a", "b:c:d"]`, which is useful when you only care about the first few parts of a delimited string.

### Knowledge Check (Quiz)

1. **What does `strings.Split("a-b-c", "-")` return?**
   - a) A string
   - b) `[]string{"a", "b", "c"}` ✅
   - c) An error

2. **Which format verb shows struct field names in Printf?**
   - a) `%v`
   - b) `%+v` ✅
   - c) `%#v`

3. **What is the most efficient way to build a string from many parts?**
   - a) Using `+` operator
   - b) Using `strings.Builder` ✅
   - c) Using `fmt.Sprintf`

4. **What does `strings.TrimSpace` remove?**
   - a) All spaces in the string
   - b) Leading and trailing whitespace ✅
   - c) Only spaces, not tabs or newlines

5. **How do you iterate over individual characters (runes) in a string?**
   - a) `for i := 0; i < len(s); i++`
   - b) `for i, r := range s` ✅
   - c) `for _, char := range strings.Split(s, "")`

---

## Additional Resources

* **Official strings package**: [pkg.go.dev/strings](https://pkg.go.dev/strings)
* **Official fmt package**: [pkg.go.dev/fmt](https://pkg.go.dev/fmt)
* **Go Blog: Strings, bytes, runes**: [blog.golang.org/strings](https://blog.golang.org/strings)

---

**Next Step**: [Time and Date →](../06-time-and-date/readme.md)
