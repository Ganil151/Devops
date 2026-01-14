# Working with JSON
*API Data Handling in Go*

Go's `encoding/json` package provides fast, type-safe JSON handling with struct tags.

---

## 🎯 Learning Objectives

- Marshal and unmarshal JSON
- Use struct tags for field mapping
- Handle nested structures

---

## 📚 Core Concepts

### 1. Parsing JSON

```go
type Server struct {
    Name   string `json:"name"`
    IP     string `json:"ip"`
    Port   int    `json:"port"`
    Active bool   `json:"active,omitempty"`
}

// Parse JSON
jsonData := `{"name":"web-01","ip":"10.0.0.1","port":8080}`
var server Server
err := json.Unmarshal([]byte(jsonData), &server)
```

### 2. Generating JSON

```go
server := Server{Name: "api-01", IP: "10.0.0.2", Port: 443}

// Marshal to JSON
data, _ := json.Marshal(server)
// {"name":"api-01","ip":"10.0.0.2","port":443}

// Pretty print
data, _ := json.MarshalIndent(server, "", "  ")
```

### 3. Struct Tags

```go
type Config struct {
    Host     string `json:"host"`
    Port     int    `json:"port,omitempty"`  // Omit if zero
    Password string `json:"-"`               // Never serialize
}
```

---

## 🛠️ Hands-On Challenge

```go
// Parse K8s-style JSON response
type Pod struct {
    Metadata struct {
        Name      string `json:"name"`
        Namespace string `json:"namespace"`
    } `json:"metadata"`
    Status struct {
        Phase string `json:"phase"`
    } `json:"status"`
}
```

---

## 🧠 Quiz

1. Which tag excludes a field from JSON?
   - a) `json:"omit"`
   - b) `json:"-"` ✅

2. `json.Unmarshal` requires:
   - a) A string
   - b) A `[]byte` ✅

---

**Next Step**: [Working with YAML →](../10-Working-with-YAML/README.md)
