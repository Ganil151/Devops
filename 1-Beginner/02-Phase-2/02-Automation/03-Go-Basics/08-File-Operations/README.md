# File Operations
*Reading and Writing Files in Go*

Go's `os` and `io` packages provide efficient file handling with explicit error checking.

---

## 🎯 Learning Objectives

- Read and write files
- Work with directories
- Handle file permissions
- Process files efficiently

---

## 📚 Core Concepts

### 1. Reading Files

```go
// Read entire file
data, err := os.ReadFile("config.yaml")
if err != nil {
    log.Fatal(err)
}
fmt.Println(string(data))

// Read with more control
file, err := os.Open("log.txt")
if err != nil {
    log.Fatal(err)
}
defer file.Close()

scanner := bufio.NewScanner(file)
for scanner.Scan() {
    fmt.Println(scanner.Text())
}
```

### 2. Writing Files

```go
// Write entire file
content := []byte("Hello, Go!")
err := os.WriteFile("output.txt", content, 0644)

// Write with control
file, err := os.Create("log.txt")
if err != nil {
    log.Fatal(err)
}
defer file.Close()

writer := bufio.NewWriter(file)
writer.WriteString("Log entry\n")
writer.Flush()
```

### 3. Directory Operations

```go
// List directory
entries, _ := os.ReadDir(".")
for _, entry := range entries {
    fmt.Println(entry.Name(), entry.IsDir())
}

// Create directory
os.Mkdir("logs", 0755)
os.MkdirAll("path/to/deep/dir", 0755)

// Remove
os.Remove("file.txt")
os.RemoveAll("directory")
```

---

## 🛠️ Hands-On Exercise

```go
// Create a log file rotator
func rotateLog(path string, maxSize int64) error {
    // TODO: If file > maxSize, rename with timestamp
}
```

<details>
<summary>💡 Solution</summary>

```go
func rotateLog(path string, maxSize int64) error {
    info, err := os.Stat(path)
    if err != nil {
        return err
    }
    
    if info.Size() > maxSize {
        newName := fmt.Sprintf("%s.%d", path, time.Now().Unix())
        return os.Rename(path, newName)
    }
    return nil
}
```
</details>

---

## 🧠 Quiz

1. `defer file.Close()` ensures:
   - a) Immediate close
   - b) Close when function returns ✅

2. `os.ReadFile` returns:
   - a) String
   - b) `[]byte` ✅

---

**Next Step**: [Working with JSON →](../09-Working-with-JSON/README.md)
