# 🛠️ Go Toolchain & SRE Engineering
*Version 1.0 | From Source Code to Production Binary*

---

## 📖 Overview
The Go ecosystem provides a set of powerful tools that handle dependency management, compilation, testing, and documentation without needing external third-party software.

---

## ⚙️ Dependency & Build Management

### 1. Go Modules
The standard for dependency management.
- `go mod init <module-name>`: Start a new module.
- `go mod tidy`: Add missing and remove unused modules.
- `go.sum`: Checksum file for reproducible builds.

### 2. The `go build` Command
- **Static Compilation**: Go produces a single standalone binary with no external dependencies (libc issues are rare).
- **Cross-Compilation**: Build for a different OS from your laptop.
  `GOOS=linux GOARCH=amd64 go build -o app_linux`

---

## 🧪 Testing & Observability

### 1. Testing Framework
- **Unit Tests**: Files named `*_test.go`.
- **Benchmarking**: `func BenchmarkX(b *testing.B) {}` to measure code performance.
- **Coverage**: `go test -cover` to see which lines are tested.

### 2. JSON & YAML Processing
Standard library `encoding/json` and `gopkg.in/yaml.v2` (common community standard) are crucial for parsing infrastructure responses.

---

## 🚀 CLI Engineering Standards

### 1. Command Line Flags
Use the `flag` package for simple tools, or `Cobra` (standard for kubectl/terraform) for complex apps.

### 2. Environment Configuration
**12-Factor App** methodology: Prioritize environment variables for configuration.
```go
dbHost := os.Getenv("DB_HOST")
```

---

## 🛡️ SRE Standard Checklist
- [ ] **Linter**: Use `golangci-lint` to catch bugs and stylistic issues.
- [ ] **Versioning**: Use SemVer (v1.0.0) for your tool releases.
- [ ] **Size Optimization**: Use `-ldflags="-s -w"` to strip debug symbols and reduce binary size for container images.

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain the purpose of the `vendor` directory in Go modules.**
2. **What is an "Interface-based Mock" and how does it improve testing?**
3. **Describe the impact of the `GOMAXPROCS` environment variable.**
4. **How do you perform "Shadowing Detection" in a large Go project?**
5. **What is the difference between `json.Marshal` and `json.Encoder`? When would you use one over the other?**

---
**Back to foundations**: [Go Fundamentals →](./go-fundamentals-ref.md)
