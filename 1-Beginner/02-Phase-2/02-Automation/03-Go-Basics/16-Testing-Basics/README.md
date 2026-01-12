# Testing Basics
*Test-Driven Development in Go*

Go has a built-in testing framework. Tests are first-class citizens.

---

## 🎯 Learning Objectives

- Write and run tests
- Use table-driven tests
- Benchmark code

---

## 📚 Core Concepts

### 1. Basic Tests

```go
// math_test.go
package math

import "testing"

func TestAdd(t *testing.T) {
    result := Add(2, 3)
    if result != 5 {
        t.Errorf("Add(2,3) = %d; want 5", result)
    }
}
```

```bash
go test ./...
go test -v         # Verbose
go test -cover     # Coverage
```

### 2. Table-Driven Tests

```go
func TestHealthStatus(t *testing.T) {
    tests := []struct {
        name     string
        cpu      float64
        expected string
    }{
        {"healthy", 50, "healthy"},
        {"warning", 80, "warning"},
        {"critical", 95, "critical"},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := GetStatus(tt.cpu)
            if result != tt.expected {
                t.Errorf("got %s, want %s", result, tt.expected)
            }
        })
    }
}
```

### 3. Test Helpers

```go
func TestServer(t *testing.T) {
    // Setup
    server := NewTestServer(t)
    defer server.Close()
    
    // Test
    resp := server.Get("/health")
    if resp.StatusCode != 200 {
        t.Fatal("Server unhealthy")
    }
}
```

---

## 🛠️ Hands-On Exercise

```go
// Write tests for validate email function
func TestValidateEmail(t *testing.T) {
    // TODO: Test valid and invalid emails
}
```

<details>
<summary>💡 Solution</summary>

```go
func TestValidateEmail(t *testing.T) {
    tests := []struct {
        email string
        valid bool
    }{
        {"user@example.com", true},
        {"invalid", false},
        {"user@", false},
        {"test@test.co", true},
    }
    
    for _, tt := range tests {
        t.Run(tt.email, func(t *testing.T) {
            if ValidateEmail(tt.email) != tt.valid {
                t.Errorf("%s validation failed", tt.email)
            }
        })
    }
}
```
</details>

---

## 🧠 Quiz

1. Test file names must end with:
   - a) `_spec.go`
   - b) `_test.go` ✅

2. Test functions start with:
   - a) `test_`
   - b) `Test` ✅

---

**Next Step**: [First CLI Tool →](../17-First-CLI-Tool/README.md)
