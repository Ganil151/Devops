# Go Fundamentals - DevOps Challenges

## Challenge 1: Build Information Script
**Scenario**: Your team needs a tool that outputs build metadata for Docker image tags.

**Requirements:**
1. Create a Go program that prints:
   - Git commit hash (simulated as a variable)
   - Build timestamp
   - Go version
2. Output should be in `KEY=VALUE` format for easy parsing in shell scripts

**Verification:**
```bash
go run main.go
# Expected output format:
# BUILD_COMMIT=abc123
# BUILD_TIME=2024-01-15T10:30:00Z
# GO_VERSION=go1.21.5
```

---

## Challenge 2: Cross-Platform Binary Builder
**Scenario**: Create a script that builds binaries for multiple platforms.

**Requirements:**
1. Write a shell script that uses Go to build for:
   - Linux (amd64)
   - Darwin/macOS (arm64)
   - Windows (amd64)
2. Name each binary with the platform in the filename (e.g., `tool-linux-amd64`)

**Verification:**
```bash
./build.sh
ls -lh dist/
# Should show 3 binaries
```

---

## Challenge 3: Package Dependency Analyzer
**Scenario**: You need to audit which standard library packages a Go project uses.

**Requirements:**
1. Create a program that scans a `.go` file
2. Extract all `import` statements
3. Print a sorted list of imported packages

**Verification:**
```bash
go run analyzer.go main.go
# Expected: List of imports like "fmt", "runtime", "os"
```

---

## Challenge 4 (Advanced): CI/CD Build Tag Injector
**Scenario**: Inject build information into a Go binary at compile time using `-ldflags`.

**Requirements:**
1. Create a `version.go` file with variables: `Version`, `Commit`, `BuildTime`
2. Write a build script that injects values using:
   ```bash
   go build -ldflags "-X main.Version=1.0.0 -X main.Commit=abc123"
   ```
3. The program should print these values when run

**Verification:**
```bash
./build-with-version.sh
./myapp --version
# Expected: Version: 1.0.0, Commit: abc123, BuildTime: 2024-01-15...
```
