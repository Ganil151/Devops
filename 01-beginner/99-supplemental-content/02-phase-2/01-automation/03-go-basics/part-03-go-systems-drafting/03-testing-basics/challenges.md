# Testing Basics - DevOps Challenges

## Challenge 1: Table-Driven Tests
**Scenario**: Test a URL builder function with multiple cases.

**Requirements:**
1. Function `BuildURL(host, path, protocol) string`
2. Create `url_test.go` with table-driven tests
3. Cover edge cases (missing protocol, trailing slashes)

**Verification:**
```bash
go test -v url_test.go
# Expected: PASS for all test cases
```

---

## Challenge 2: Mocking Interfaces
**Scenario**: Test code that depends on an external API wrapper.

**Requirements:**
1. Define `CloudAPI` interface
2. Create `MockAPI` struct for testing
3. Write test that uses MockAPI to inject predictable responses

**Verification:**
```bash
go test -v api_test.go
# Expected: Tests pass without making real network calls
```

---

## Challenge 3: Benchmark Testing
**Scenario**: Compare performance of two string concatenation methods.

**Requirements:**
1. Function `ConcatPlus` (using +)
2. Function `ConcatBuilder` (using strings.Builder)
3. Write Benchmark functions for both
4. Run benchmarks

**Verification:**
```bash
go test -bench=.
# Expected: Benchmarks show performance difference
```
