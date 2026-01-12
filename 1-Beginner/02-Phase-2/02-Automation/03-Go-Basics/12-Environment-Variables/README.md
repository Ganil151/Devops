# Environment Variables
*Configuring Go Applications*

Use `os.Getenv` and `os.LookupEnv` for environment-based configuration.

---

## 🎯 Learning Objectives

- Read environment variables
- Provide defaults safely
- Follow 12-factor app principles

---

## 📚 Core Concepts

### 1. Reading Environment Variables

```go
import "os"

// Get with empty string if not set
dbURL := os.Getenv("DATABASE_URL")

// Check if set
if value, exists := os.LookupEnv("API_KEY"); exists {
    fmt.Println("API Key:", value)
} else {
    log.Fatal("API_KEY required")
}
```

### 2. Helper Function with Defaults

```go
func getEnv(key, defaultValue string) string {
    if value, exists := os.LookupEnv(key); exists {
        return value
    }
    return defaultValue
}

host := getEnv("HOST", "localhost")
port := getEnv("PORT", "8080")
```

### 3. Config Struct Pattern

```go
type Config struct {
    Host     string
    Port     int
    Debug    bool
}

func LoadConfig() Config {
    port, _ := strconv.Atoi(getEnv("PORT", "8080"))
    return Config{
        Host:  getEnv("HOST", "0.0.0.0"),
        Port:  port,
        Debug: os.Getenv("DEBUG") == "true",
    }
}
```

---

## 🛠️ Hands-On Exercise

```go
// Create a required env checker
func requireEnv(key string) string {
    // TODO: Return value or log.Fatal if missing
}
```

<details>
<summary>💡 Solution</summary>

```go
func requireEnv(key string) string {
    value, exists := os.LookupEnv(key)
    if !exists {
        log.Fatalf("Required environment variable %s not set", key)
    }
    return value
}
```
</details>

---

## 🧠 Quiz

1. `os.Getenv` for missing var returns:
   - a) Error
   - b) Empty string "" ✅

2. `os.LookupEnv` returns:
   - a) Just value
   - b) Value and exists bool ✅

---

**Next Step**: [String Manipulation →](../13-String-Manipulation/README.md)
