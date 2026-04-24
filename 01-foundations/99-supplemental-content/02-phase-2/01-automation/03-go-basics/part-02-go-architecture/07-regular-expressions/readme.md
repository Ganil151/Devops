# 🔍 Regular Expressions in Go

> **"Regex is the scalpel of the DevOps toolkit. Whether you're scrubbing sensitive data from logs, validating user input, or parsing legacy configuration files, Go's `regexp` package provides a high-performance, safe engine implementation based on RE2."**

Go's `regexp` package implements the **RE2** syntax, which guarantees linear time execution. This avoids the "catastrophic backtracking" issues found in other languages, making Go regex safe to run on untrusted user input—a critical feature for secure web services.

![Regular Expressions for DevOps](./go-regex-hero.png)

## Table of Contents

* [Compiling: The Performance Key](#compiling-the-performance-key)
* [Matching and Validation](#matching-and-validation)
* [Extraction with Capture Groups](#extraction-with-capture-groups)
* [Replacement and Sanitization](#replacement-and-sanitization)
* [Practical Use Case: Log Scraper](#practical-use-case-log-scraper)
* [Knowledge Vault (Scenarios, Interview, Quiz)](#knowledge-vault)
* [Additional Resources](#additional-resources)

---

## 💼 The Automation Why: The Precision Sifter

**The Beginner's Question**: "Regex looks like gibberish. Can't I just use `strings.Split`?"

**The Answer**: **Unstructured data is the enemy of automation.**
Logs from a legacy database, weirdly formatted CLI outputs, and user-provided email addresses don't follow a clean `key: value` pattern. If you use `Split`, your code becomes a fragile mess of nested loops and if-statements. Regex allows you to define a "Shape" for your data and extract it with surgical precision, regardless of how much "noise" surrounds it.

### The Magnet Analogy 🧲

- **Manual Parsing (strings.Split)** = **Picking through a Pile of Junk by Hand**: You search for one thing, then another. It's tedious, slow, and you might miss something small buried in the middle.
- **Regular Expressions** = **A High-Powered Electromagnet**: You don't pick through the junk; you set the magnet to a specific "frequency" (The Pattern). You wave it over the data, and only the specific pieces you want (The Matches) fly out and stick to the magnet. It doesn't matter how much "junk" (unstructured log data) there is; the magnet only catches the "metal" (IP addresses, specific error codes, timestamps) you asked for.

---

## Compiling: The Performance Key

In Go, parsing a regex pattern is expensive. You should always **compile** your regex once and reuse the object, rather than compiling it inside a loop.

### `Compile` vs `MustCompile`
*   `Compile`: Returns an error if the pattern is invalid. Use when the pattern comes from user input.
*   `MustCompile`: Panics if the pattern is invalid. Use for global variables where the pattern is hardcoded and must be correct.

```go
import "regexp"

// Best Practice: Compile once at package level
var emailRegex = regexp.MustCompile(`^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,4}$`)

func validateEmail(email string) bool {
    return emailRegex.MatchString(email)
}
```

---

## Matching and Validation

The simplest use case is checking if a string matches a pattern.

```go
func main() {
    ipRecord := "192.168.1.1"
    
    // Check if it looks like an IP
    matched, _ := regexp.MatchString(`^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$`, ipRecord)
    
    if matched {
        fmt.Println("Valid IP format")
    }
}
```
*Note: `regexp.MatchString` compiles the pattern every time. For performance, use a pre-compiled object as shown above.*

---

## Extraction with Capture Groups

To extract specific parts of a string (like the year from a date), use parentheses `()` to define **Capture Groups**.

```go
var logPattern = regexp.MustCompile(`^(\d{4}-\d{2}-\d{2}) (\w+): (.*)$`)

func parseLine(line string) {
    // FindStringSubmatch returns: [full_match, group1, group2, ...]
    matches := logPattern.FindStringSubmatch(line)
    
    if len(matches) > 0 {
        fmt.Printf("Date: %s\n", matches[1])    // Group 1
        fmt.Printf("Level: %s\n", matches[2])   // Group 2
        fmt.Printf("Msg: %s\n", matches[3])     // Group 3
    }
}

// Input: "2026-01-20 ERROR: Connection timeout"
// Output: Date: 2026-01-20, Level: ERROR, Msg: Connection timeout
```

---

## Replacement and Sanitization

Regex is perfect for scrubbing sensitive data before logging it.

```go
var creditCardRegex = regexp.MustCompile(`\d{4}-\d{4}-\d{4}-\d{4}`)

func redactLogs(logEntry string) string {
    // Replace all matches with a placeholder
    return creditCardRegex.ReplaceAllString(logEntry, "XXXX-XXXX-XXXX-XXXX")
}

// Input: "User payment: 1234-5678-1234-5678 processed"
// Output: "User payment: XXXX-XXXX-XXXX-XXXX processed"
```

---

## Practical Use Case: Log Scraper

A common DevOps task is parsing unstructured application logs to extract metrics for Prometheus or other monitoring tools.

```go
// Log line: "Duration: 450ms | Status: 200 OK | Path: /api/v1/users"
var metricPattern = regexp.MustCompile(`Duration: (\d+)ms \| Status: (\d+)`)

func processMetrics(logs []string) {
    for _, line := range logs {
        matches := metricPattern.FindStringSubmatch(line)
        if len(matches) == 3 {
            duration, _ := strconv.Atoi(matches[1])
            status := matches[2]
            
            fmt.Printf("Reporting metric: latency=%dms code=%s\n", duration, status)
            // sendToPrometheus(duration, status)
        }
    }
}
```

---

## Knowledge Vault

### Real-World Scenarios

#### Scenario 1: The "Catastrophic Backtracking" Outage
A Node.js service crashed because a user input a specially crafted string that caused a regex to loop infinitely (ReDoS attack).
**Go Solution**: The team rewrote the validator in Go. Because Go's `regexp` package uses the RE2 engine (automata-based) instead of PCRE (backtracking-based), it is mathematically guaranteed to finish in linear time, making the service immune to ReDoS attacks.

#### Scenario 2: Dynamic Config Parsing
An automation tool needed to find all variables in a config file formatted like `${VAR_NAME}`.
**Go Solution**: They used `regexp.MustCompile(`\$\{(\w+)\}`)` and `FindAllStringSubmatch` to extract every variable name into a slice, allowing them to validate that all required environment variables were present before starting the deployment.

### Interview Preparation

1. **Why does Go use `dlcl` (MustCompile) vs `Compile`?**
   > `MustCompile` is a helper that panics if the regex is invalid. It is designed for initializing global variables where a regex error indicates a programmer error that should stop the program immediately. `Compile` returns an error and is safer for dynamic patterns (e.g., user input).

2. **What is the performance implication of calling `regexp.MatchString` inside a loop?**
   > It is very poor for performance because it recompiles the regex engine on every iteration. You should always compile the regex once (outside the loop) and use the compiled object's `MatchString` method.

3. **How do capture groups work in Go's `FindStringSubmatch`?**
   > It returns a slice of strings. The element at index `0` is always the *entire* matched string. The elements at index `1`, `2`, etc., correspond to the parenthesized groups `()` in order from left to right.

4. **Is Go's regex engine PCRE compatible?**
   > Generally yes for syntax, but no for features like lookarounds (lookahead/lookbehind) and backreferences. This is a design choice by the RE2 engine to guarantee consistent, safe performance.

### Knowledge Check (Quiz)

1. **Which function should you use for a hardcoded, global regex pattern?**
   - a) `regexp.Compile`
   - b) `regexp.MustCompile` ✅
   - c) `regexp.New`

2. **What does `matches[0]` contain in a submatch result?**
   - a) The first capture group
   - b) The distinct error code
   - c) The full string that matched the pattern ✅

3. **Why is Go's regex considered "safe" for user input?**
   - a) It runs in a sandbox
   - b) It uses RE2, which avoids catastrophic backtracking ✅
   - c) It is interpreted continuously

4. **How do you replace all occurrences of a pattern?**
   - a) `ReplaceAllString` ✅
   - b) `ReplaceOne`
   - c) `SwapAll`

5. **Which character denotes a capture group?**
   - a) `[]`
   - b) `{}`
   - c) `()` ✅

---

## Additional Resources

* **Go Regexp Syntax (RE2)**: [github.com/google/re2/wiki/Syntax](https://github.com/google/re2/wiki/Syntax)
* **Official regexp package**: [pkg.go.dev/regexp](https://pkg.go.dev/regexp)
* **Regex101 (Select Golang)**: [regex101.com](https://regex101.com)

---

**Next Step**: [Part 03: Systems Drafting - Command Line Flags →](../../part-03-go-systems-drafting/01-command-line-flags/readme.md)
