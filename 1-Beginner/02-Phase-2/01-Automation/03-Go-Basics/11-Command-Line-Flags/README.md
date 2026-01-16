# Command Line Flags
*Building CLI Tools with Go*

The `flag` package provides simple argument parsing for CLI tools.

---

## 🎯 Learning Objectives

- Parse command-line flags
- Use different flag types
- Provide help text

---

## 📚 Core Concepts

### 1. Basic Flags

```go
import "flag"

func main() {
    // Define flags
    host := flag.String("host", "localhost", "Server hostname")
    port := flag.Int("port", 8080, "Server port")
    verbose := flag.Bool("verbose", false, "Enable verbose output")
    
    // Parse command line
    flag.Parse()
    
    fmt.Printf("Connecting to %s:%d\n", *host, *port)
    if *verbose {
        fmt.Println("Verbose mode enabled")
    }
}
```

```bash
./tool -host=api.example.com -port=443 -verbose
./tool --host api.example.com --port 443
```

### 2. Positional Arguments

```go
flag.Parse()
args := flag.Args()  // Non-flag arguments

if len(args) < 1 {
    fmt.Println("Usage: tool <command>")
    os.Exit(1)
}
```

### 3. Custom Usage

```go
flag.Usage = func() {
    fmt.Fprintf(os.Stderr, "Usage: %s [options] <file>\n", os.Args[0])
    flag.PrintDefaults()
}
```

---

## 🛠️ Hands-On Challenge

```go
// Build a deployment CLI
// ./deploy -env=prod -replicas=3 myapp
func main() {
    // TODO: Parse env, replicas, and app name
}
```

<details>
<summary>💡 Solution</summary>

```go
func main() {
    env := flag.String("env", "staging", "Environment")
    replicas := flag.Int("replicas", 1, "Number of replicas")
    flag.Parse()
    
    if len(flag.Args()) < 1 {
        log.Fatal("App name required")
    }
    app := flag.Args()[0]
    
    fmt.Printf("Deploying %s to %s with %d replicas\n", app, *env, *replicas)
}
```
</details>

---

## 🧠 Quiz

1. `flag.Parse()` must be called:
   - a) Before defining flags
   - b) After defining flags ✅

2. `flag.Args()` returns:
   - a) All arguments
   - b) Non-flag arguments ✅

---


## 💻 Code Samples

### Deployment Config Parser (Boilerplate)
A simulation of a DevOps tool that parses complex flags for region, environment, and replica counts, complete with custom help text.

**Run the sample:**
```bash
cd boilerplate
go run main.go -region eu-west-1 -replicas 5 -verbose
```
Try running `go run main.go -help` to see the custom usage output!

**Next Step**: [Environment Variables →](../12-Environment-Variables/README.md)
