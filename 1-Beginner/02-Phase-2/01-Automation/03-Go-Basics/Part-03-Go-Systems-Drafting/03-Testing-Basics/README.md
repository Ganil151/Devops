# 🧪 Testing Basics in Go

> **"In DevOps, untested code is broken code. Go treats testing as a first-class citizen, building a robust test runner, coverage tool, and benchmark engine directly into the standard `go` command. No external frameworks required."**

Unlike other languages that require heavy third-party libraries (like JUnit or PyTest), Go's `testing` package is simple, efficient, and standardized. By mastering Go testing, you ensure your infrastructure tools are reliable before they ever touch production.

![Testing in Go](./go_testing_hero.png)

## Table of Contents

*   [The Go Testing Philosophy](#the-go-testing-philosophy)
*   [Writing Your First Test](#writing-your-first-test)
*   [Table-Driven Tests: The Idiomatic Way](#table-driven-tests-the-idiomatic-way)
*   [Subtests and Runners](#subtests-and-runners)
*   [Benchmarking Performance](#benchmarking-performance)
*   [Knowledge Vault (Scenarios, Interview, Quiz)](#knowledge-vault)
*   [Additional Resources](#additional-resources)
*   [The Automation Why: The Confidence Engine](#the-automation-why-the-confidence-engine)

---

## 💼 The Automation Why: The Confidence Engine

**The Beginner's Question**: "Testing takes longer than writing the code. Is it worth it for a small tool?"

**The Answer**: **Debugging in production takes longer than writing tests.**
In DevOps, your code often runs with high privileges (root access, cloud-admin keys) and at high scale. A small logic error like `if cpuUsage > 0` instead of `if cpuUsage > 90` could trigger a global server restart by mistake. Testing allows you to catch these "logic bombs" on your laptop, not during a 3 AM incident call.

### The Seatbelt Analogy 🏎️

- **Untested Code** = **Driving without a Seatbelt**: You might feel fast and free, and most of the time, everything is fine. But the first time you hit an unexpected "bug" (A sudden stop or crash), the results are catastrophic. There is no safety net, and the "damage" (Data loss/Outage) is permanent.
- **Go Testing** = **The Automated Safety System**: Tests are the seatbelts, airbags, and anti-lock brakes of your code. They don't slow down the car; they give the driver (The Engineer) the confidence to drive faster and push boundaries. If you make a radical change to your code, the tests catch you before you "fly through the windshield" of a production outage.

---

## The Go Testing Philosophy

1.  **No Assertions**: Go tests use standard `if` statements and comparison operators. There is no `assert.Equal(expected, actual)`. This makes tests explicit and readable.
2.  **File Naming**: Tests live right next to your code. If you have `server.go`, your tests go in `server_test.go`.
3.  **Function Naming**: Test functions must start with `Test` and take `*testing.T` as an argument (e.g., `func TestConnect(t *testing.T)`).

---

## Writing Your First Test

All tests must be in a file ending with `_test.go`.

```go
// calculator.go
package main

func Add(a, b int) int {
    return a + b
}
```

```go
// calculator_test.go
package main

import "testing"

func TestAdd(t *testing.T) {
    got := Add(2, 3)
    want := 5

    if got != want {
        t.Errorf("Add(2, 3) = %d; want %d", got, want)
    }
}
```

**Running Tests**:
```bash
go test -v ./...
```

---

## Table-Driven Tests: The Idiomatic Way

Go developers prefer "Table-Driven Tests" to avoid repeating code. You define a slice of structs (the table) containing inputs and expected outputs, then iterate over them.

```go
func TestHealthCheck(t *testing.T) {
    // 1. Define the table
    tests := []struct {
        name     string
        cpuUsage int
        expected string
    }{
        {"Healthy System", 40, "OK"},
        {"Warning State", 85, "WARNING"},
        {"Critical State", 95, "CRITICAL"},
    }

    // 2. Iterate and Run
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := CheckHealth(tt.cpuUsage)
            if result != tt.expected {
                t.Errorf("CheckHealth(%d) = %s; want %s", tt.cpuUsage, result, tt.expected)
            }
        })
    }
}
```

---

## Subtests and Runners

The `t.Run()` method in the example above creates a **Subtest**.
*   **Isolation**: Each subtest is independent.
*   **Reporting**: If one fails, `go test` reports exactly which case failed (e.g., `TestHealthCheck/Critical_State`).
*   **Concurrency**: You can run subtests in parallel using `t.Parallel()`.

---

## Benchmarking Performance

Go has a built-in benchmarking tool to measure code performance. Benchmark functions start with `Benchmark` and use `*testing.B`.

```go
func BenchmarkAdd(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Add(2, 3)
    }
}
```

**Running Benchmarks**:
```bash
go test -bench=.
```
Output:
`BenchmarkAdd-8    1000000000    0.25 ns/op` (It runs 1 billion times, taking 0.25 nanoseconds per operation).

---

## Knowledge Vault

### Real-World Scenarios

#### Scenario 1: The "Flaky" CI/CD Pipeline
A team's deployment pipeline failed 30% of the time because a test relied on an external weather API.
**Go Solution**: They refactored the code to use an **Interface** for the API client. In `main.go`, they used the real client. In `main_test.go`, they used a "Mock" struct that returned fixed data. This made the tests instant, deterministic, and free of external dependencies.

#### Scenario 2: Detecting a Memory Leak
A log parsing tool was getting slower over time. The team couldn't find the bottleneck.
**Go Solution**: They wrote a Benchmark test `BenchmarkLogParser` and ran it with memory profiling: `go test -bench=. -benchmem`. The output showed `100 allocs/op`, revealing that they were creating excessive strings in a loop. They switched to `strings.Builder` and re-ran the benchmark, proving a 90% reduction in allocations.

### Interview Preparation

1.  **Why doesn't Go use assertions like `assert.True()`?**
    > Go strictly avoids "magic" behavior. Standard `if` statements and `t.Errorf` are unambiguous, readable by any programmer, and print clear error messages without needing a framework to interpret the failure.

2.  **What is the purpose of `t.Helper()`?**
    > When you write a helper function for your tests (e.g., `assertNoError`), calling `t.Helper()` inside it tells Go to mark that function as a helper. If a test fails, the error line number reported will be the line *calling* the helper, not the line inside the helper itself.

3.  **How do you mock dependencies in Go?**
    > Go mocks are typically implemented using Interfaces. You define an interface for the dependency (e.g., `DatabaseReader`), then create a `MockDatabase` struct that satisfies that interface but returns static test data.

4.  **What does `go test -cover` do?**
    > It calculates the percentage of code lines that were executed during the test run. It helps identify logic paths (like error handling branches) that are not being tested.

### Knowledge Check (Quiz)

1.  **What must a test file be named?**
    *   a) `test_main.go`
    *   b) `main_test.go` ✅
    *   c) `main.test`

2.  **What is the argument type for a standard test function?**
    *   a) `*testing.T` ✅
    *   b) `*testing.B`
    *   c) `*testing.Test`

3.  **How do you run only the tests matching a name?**
    *   a) `go test -only=Name`
    *   b) `go test -run Name` ✅
    *   c) `go test -name Name`

4.  **In a table-driven test, what method creates a subtest?**
    *   a) `t.Sub()`
    *   b) `t.Spawn()`
    *   c) `t.Run()` ✅

5.  **Which flag is used to run benchmarks?**
    *   a) `-bench` ✅
    *   b) `-perf`
    *   c) `-speed`

---

## Additional Resources

*   **Go Testing Package Docs**: [pkg.go.dev/testing](https://pkg.go.dev/testing)
*   **Learn Go with Tests**: [quii.gitbook.io](https://quii.gitbook.io/learn-go-with-tests/)
*   **Go Wiki: TableDrivenTests**: [github.com/golang/go/wiki/TableDrivenTests](https://github.com/golang/go/wiki/TableDrivenTests)

---

**Next Step**: [Capstone Project: Building a CLI Tool →](../04-Capstone-CLI-Tool/README.md)
