# 🌐 Environment Variables in Go

> **"Environment variables are the heart of the 12-Factor App methodology. They allow you to build a single immutable binary that can run in any environment—from a developer laptop to a production Kubernetes cluster—without a single line of code change."**

In DevOps, we never hardcode secrets or configuration. Instead, we use **Environment Variables** to inject external state into our applications. Go's `os` package provides simple yet powerful tools to read, validate, and provide defaults for these variables, ensuring your automation is both portable and secure.

![Environment Variables for DevOps](./go-env-vars-hero.png)

## Table of Contents

* [Reading Variables: Get vs. Lookup](#reading-variables-get-vs-lookup)
* [Implementation: Helper Functions with Defaults](#implementation-helper-functions-with-defaults)
* [The Config Struct Pattern](#the-config-struct-pattern)
* [12-Factor App Principles in Go](#12-factor-app-principles-in-go)
* [Practical Use Case: Secure DB Connection](#practical-use-case-secure-db-connection)
* [Knowledge Vault (Scenarios, Interview, Quiz)](#knowledge-vault)
* [Additional Resources](#additional-resources)

---

## 💼 The Automation Why: The Chameleon of Code

**The Beginner's Question**: "If I have flags, why do I also need environment variables?"

**The Answer**: **Flags are for humans; Envs are for machines.**
Imagine a Kubernetes Pod starting up. It needs to know 50 different secrets and configs. You *could* pass these as flags, but the command line becomes thousands of characters long and hard to debug. Environment variables allow the infrastructure (Kubernetes, AWS Lambda, CI/CD) to "inject" these values safely and silently into your tool.

### The Chameleon Analogy 🦎

- **Hard-coded Scripts** = **A Statue**: It is built for one specific spot. If the "environment" changes (The building is moved), the statue looks out of place or becomes a hazard. It cannot change itself to match a new reality without a sculptor (The Developer) physically altering it.
- **Environment Variables** = **The Chameleon**: The chameleon's core logic (The Go Binary) remains exactly the same, but it changes its "skin" (Configuration/Secrets) to blend perfectly into its surroundings. Whether it's in the green forest of "Dev," the grey desert of "Staging," or the dark cave of "Prod," it adapts instantly based on the environment around it, without ever needing a re-compile.

---

## Reading Variables: Get vs. Lookup

Go provides two main functions for reading environment variables from the host system.

### Option 1: `os.Getenv(key)`
Returns the value of the variable. If the variable is not set, it returns an **empty string**.
```go
dbURL := os.Getenv("DATABASE_URL")
if dbURL == "" {
    fmt.Println("No database URL found, using default...")
}
```

### Option 2: `os.LookupEnv(key)`
Returns the value and a **boolean** indicating if the variable was actually set. This is critical for distinguishing between a variable that is empty and one that is completely missing.
```go
if val, exists := os.LookupEnv("API_KEY"); exists {
    fmt.Println("API Key found")
} else {
    log.Fatal("CRITICAL: API_KEY is missing from environment")
}
```

---

## Implementation: Helper Functions with Defaults

A common pattern in production code is to create a "getter" function that handles missing variables by providing sensible defaults.

```go
func getEnv(key, defaultValue string) string {
    if value, exists := os.LookupEnv(key); exists {
        return value
    }
    return defaultValue
}

// Usage
host := getEnv("APP_HOST", "0.0.0.0")
port := getEnv("APP_PORT", "8080")
```

---

## The Config Struct Pattern

For complex applications, it is best practice to "centralize" all environment reading into a single configuration struct at startup. This ensures that if a required variable is missing, the application fails fast before doing any work.

```go
type Config struct {
    DBURL    string
    Port     int
    LogLevel string
}

func LoadConfig() *Config {
    port, _ := strconv.Atoi(getEnv("PORT", "3000"))
    
    return &Config{
        DBURL:    os.Getenv("DATABASE_URL"),
        Port:     port,
        LogLevel: getEnv("LOG_LEVEL", "info"),
    }
}
```

---

## 12-Factor App Principles in Go

Following the **III. Config** factor of the [12-Factor App](https://12factor.net/config) methodology:
1.  **Strict Separation**: Keep config that varies between deployments (Staging, Prod, Dev) out of your code.
2.  **Environment Variables**: Use them for everything from DB credentials to feature flags.
3.  **No Config Files in Repo**: Never commit `.env` or YAML files containing secrets to Git.

---

## Practical Use Case: Secure DB Connection

Imagine a script that needs to connect to a database. You don't want to hardcode the password.

```go
func connectDB() {
    user := os.Getenv("DB_USER")
    pass := os.Getenv("DB_PASS")
    host := getEnv("DB_HOST", "localhost")
    
    if user == "" || pass == "" {
        log.Fatal("Database credentials missing!")
    }
    
    dsn := fmt.Sprintf("postgres://%s:%s@%s/myapp", user, pass, host)
    // Connect logic...
}
```

---

## Knowledge Vault

### Real-World Scenarios

#### Scenario 1: The "Hardcoded Secret" Leak
A developer accidentally committed a database password to a public GitHub repository. Within 10 minutes, malicious bots had used the credentials to dump the database and delete all backups.
**Go Solution**: By switching to `os.Getenv("DB_PASSWORD")`, the password was moved out of the source code and into a secure environment (like GitHub Secrets or Vault). The code now safely refers to the variable without ever knowing the actual secret.

#### Scenario 2: Environment Drift
An automation tool ran perfectly on a developer's Mac but failed in a Linux Docker container because it assumed a specific file path.
**Go Solution**: The developer added a `DATA_DIR` environment variable. On the Mac, they set it to `/Users/dev/data`; in Docker, they set it to `/var/lib/data`. The Go binary remained identical, but correctly adapted to the host environment using `os.Getenv`.

### Interview Preparation

1. **What is the difference between `os.Getenv` and `os.LookupEnv`?**
   > `os.Getenv` returns an empty string if the variable is not found. `os.LookupEnv` returns a second boolean value (`true`/`false`) that explicitly tells you if the variable exists in the environment, which is safer for mandatory configurations.

2. **Why should you never store secrets in environment variables on shared systems?**
   > On shared systems, other users might be able to see environment variables using commands like `ps e` or looking at `/proc`. In such cases, it's better to use secret managers (like AWS Secrets Manager or HashiCorp Vault) and have Go fetch them at runtime.

3. **How do you handle default values for numeric environment variables?**
   > Since environment variables are always strings, you must read them with `os.Getenv`, then use `strconv.Atoi()` to convert them to integers, handling any potential parsing errors.

4. **What is a `.env` file and how is it used in Go?**
   > A `.env` file is a local text file containing key-value pairs. While Go doesn't support them natively, packages like `godotenv` are commonly used in development to load these files into the environment automatically.

### Knowledge Check (Quiz)

1. **Which function returns a boolean indicating if a variable is set?**
   - a) `os.Getenv()`
   - b) `os.LookupEnv()` ✅
   - c) `os.CheckEnv()`

2. **What does `os.Getenv("MISSING_VAR")` return?**
   - a) `nil`
   - b) An empty string "" ✅
   - c) A runtime panic

3. **In the Config Struct pattern, where should environment variables be read?**
   - a) Inside every function that needs them
   - b) Once, during application startup ✅
   - c) Every 5 minutes using a timer

4. **Which package is used to convert an environment variable string to an integer?**
   - a) `os`
   - b) `fmt`
   - c) `strconv` ✅

5. **Following the 12-factor app principle, where should configuration be stored?**
   - a) In the source code
   - b) In environment variables ✅
   - c) In a database

---

## Additional Resources

* **The 12-Factor App - Config**: [12factor.net/config](https://12factor.net/config)
* **Official os package docs**: [pkg.go.dev/os](https://pkg.go.dev/os)
* **Go DotEnv Library**: [github.com/joho/godotenv](https://github.com/joho/godotenv)

---

**Next Step**: [Testing Basics →](../03-testing-basics/readme.md)
