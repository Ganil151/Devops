**Function Patterns** code with the same **pedagogical rigor**, focusing on Go's distinctive approach to functions, error handling, and composability—all critical for infrastructure tooling.

---

## 📜 Fully Annotated Code

```go
// ============================================================================
// PACKAGE & IMPORTS
// ============================================================================
package main

import (
	"fmt"   // Formatted I/O: Println, Printf, etc.
	"log"   // Simple logging with fatal exit capability
	"strconv" // String conversion: Atoi (ASCII to integer), etc.
)

// ========================================================================
// FUNCTION BASICS: SINGLE RETURN VALUE
// ========================================================================
// Syntax: func <name>(<params>) <return-type> { <body> }
// • Parameters: name type, name type (types are NOT repeated: a, b int)
// • Return type: single type after parameter list
// • return keyword: exits function and passes value back to caller
//
// 💡 Why this matters: Functions are FIRST-CLASS in Go
// • Can be assigned to variables, passed as arguments, returned from other functions
// • Enables dependency injection, testing, and modular infrastructure code
func add(a int, b int) int {
	// Return the sum of a and b
	// Type safety: compiler ensures a, b, and return value are all int
	return a + b
}

// ========================================================================
// MULTIPLE RETURN VALUES: GO'S SIGNATURE FEATURE
// ========================================================================
// Syntax: func <name>(<params>) (<type1>, <type2>, ...) { ... }
// • Go allows returning MULTIPLE values—critical for error handling
// • Convention: (result, error) or (value1, value2) for related outputs
// • Caller MUST handle all returns (or explicitly ignore with _)
//
// 🔍 Why multiple returns?
// • Eliminates need for out-parameters or result structs for simple cases
// • Makes error handling explicit and unavoidable
// • Enables patterns like: value, ok := map[key] or data, err := fetch()
func SumAndProduct(a int, b int) (int, int) {
	sum2 := a + b       // Local variable for sum
	product := a * b    // Local variable for product
	return sum2, product // Return BOTH values in order
}

// ========================================================================
// NAMED RETURN VALUES: DOCUMENTATION + "NAKED RETURN"
// ========================================================================
// Syntax: func <name>(<params>) (<resultName> <type>, <resultName2> <type>) { ... }
// • Return values are declared with NAMES at function signature
// • Names are initialized to zero-values when function starts
// • "Naked return": return without arguments returns current values of named results
//
// ⚠️ Pedagogical Warning: Named returns can reduce clarity if overused
// • ✅ Good for: short functions, documenting complex return semantics
// • ❌ Avoid for: long functions where it's unclear where values are set
//
// 🔍 Note: The function name "divided" is misleading—it returns quotient AND sum
// Better name: computeQuotientAndSum or similar (clear naming matters!)
func divided(a, b int) (chuck int, ganil int) {
	// 'chuck' and 'ganil' are already declared and zero-initialized
	chuck = a / b  // Integer division: 10 / 10 = 1
	ganil = a + b  // Sum: 10 + 10 = 20
	return         // "Naked return": returns (chuck, ganil) = (1, 20)
	// Equivalent to: return chuck, ganil
}

// ========================================================================
// VARIADIC FUNCTIONS: VARIABLE NUMBER OF ARGUMENTS
// ========================================================================
// Syntax: func <name>(<fixed-params>, <name> ...<type>) <return-type> { ... }
// • ...<type> means "zero or more arguments of this type"
// • Inside function: <name> is a SLICE of <type> ([]int in this case)
// • Callers can pass: sumAll(1, 2, 3) OR sumAll([]int{1,2,3}...)
//
// 💡 Infrastructure Application: 
// • CLI tools accepting variable flags: cobra.Command with variadic args
// • Aggregating metrics from multiple sources: sumAll(cpu1, cpu2, cpu3...)
func sumAll(nums ...int) int {
	total := 0 // Accumulator pattern: start at zero-value

	// Range over slice: _ ignores index, currentValue gets each element
	for _, currentValue := range nums {
		total = total + currentValue // Accumulate: 0→1→3→6→10→15
	}
	return total // Return final sum
}

// ========================================================================
// MAIN: PROGRAM ENTRY POINT
// ========================================================================
func main() {
	// ========================================================================
	// CALLING FUNCTIONS: CAPTURING RETURN VALUES
	// ========================================================================
	sum1 := add(10, 20) // sum1 = 30
	// Multiple assignment: sum2 gets first return, product gets second
	sum2, product := SumAndProduct(10, 20) // sum2=30, product=200

	// Printf: formatted output with %v (default value formatting)
	fmt.Printf("The sum of one is: %v, and sum two is: %v, and the product is: %v\n", 
		sum1, sum2, product)
	// Output: The sum of one is: 30, and sum two is: 30, and the product is: 200

	// ========================================================================
	// IGNORING RETURN VALUES: THE BLANK IDENTIFIER _
	// ========================================================================
	// When a function returns multiple values but you only need some:
	// • Use _ (blank identifier) to explicitly ignore unwanted returns
	// • Compiler enforces: you CANNOT ignore a return without _
	onlySum, _ := SumAndProduct(10, 2) // Ignore product, keep onlySum=12
	fmt.Printf("The sum is: %v\n", onlySum) // Output: The sum is: 12
	// 💡 DevOps Tip: Use _ for error returns you're intentionally ignoring
	// (but document WHY—usually only in tests or trivial cases)

	// ========================================================================
	// NAMED RETURNS: CAPTURING VALUES
	// ========================================================================
	// Call divided(10, 10): returns (chuck=1, ganil=20)
	q, r := divided(10, 10)
	fmt.Printf("The quotient is: %v, and the remainder is: %v\n", q, r)
	// Output: The quotient is: 1, and the remainder is: 20
	// ⚠️ Note: "remainder" is misleading—ganil is actually the SUM, not remainder!
	// This is why clear naming matters in production code.

	// ========================================================================
	// VARIADIC CALLS: DIRECT AND SLICE-EXPANSION
	// ========================================================================
	// Direct variadic call: pass individual arguments
	total := sumAll(1, 2, 3, 4, 5) // nums = []int{1,2,3,4,5} inside function
	fmt.Printf("The sum of all numbers is: %v\n", total) // Output: 15

	// Slice expansion: use ... to "spread" a slice into variadic args
	values := []int{1, 2, 3, 4, 5}
	total2 := sumAll(values...) // Equivalent to sumAll(1, 2, 3, 4, 5)
	fmt.Printf("The sum of all numbers is: %v\n", total2) // Output: 15
	// 🔍 Why ...? Without it: sumAll(values) would pass []int as SINGLE argument

	// =========================================================================
	// ANONYMOUS FUNCTIONS: FUNCTIONS AS VALUES
	// =========================================================================
	// Functions are first-class: can be assigned to variables
	// Syntax: <var> := func(<params>) <return-type> { <body> }
	res := func(n int) int {
		return n * 2 // Simple doubling function
	}
	fmt.Println(res(2)) // Output: 4 (calls the anonymous function)
	// 💡 Infrastructure Application: Callback patterns, middleware, test mocks

	// =========================================================================
	// IIFE: IMMEDIATELY INVOKED FUNCTION EXPRESSION
	// =========================================================================
	// Pattern: define AND call a function in one expression
	// Useful for: scoping variables, one-time setup, avoiding namespace pollution
	res1 := func(a, b int) int {
		return a + b
	}(13, 33) // ← Note the (13, 33) immediately after function body
	// Execution: function is defined, then immediately called with (13,33)
	// Result: res1 = 46
	fmt.Println(res1) // Output: 46
	// 💡 DevOps Use Case: One-time config initialization with local scope

	// =========================================================================
	// ERROR HANDLING PATTERN: EXPLICIT, COMPOSABLE, TESTABLE
	// =========================================================================
	// Go's philosophy: errors are VALUES, not exceptions
	// Pattern: if err := fn(); err != nil { return err }
	// • Forces explicit error checking at every boundary
	// • Enables layered error context with fmt.Errorf and %w wrapping
	if err := run(); err != nil {
		// log.Fatal: prints error + stack trace + exits with code 1
		// Use in main() for unrecoverable startup errors
		log.Fatal(err)
	}
	// If run() succeeds, program continues (or exits normally)
}

// ============================================================================
// ERROR PROPAGATION: RETURNING ERRORS UP THE CALL STACK
// ============================================================================
// Pattern: func <name>() error { ... return err or nil }
// • Return nil for success, non-nil error for failure
// • Caller decides how to handle: retry, log, exit, or propagate further
func run() error {
	input := "3" // Simulate user input or config value

	// Call parseLevel: returns (int, error)
	level, err := parseLevel(input)
	if err != nil {
		// Propagate error up: caller (main) will handle with log.Fatal
		return err
	}
	// Success path: use the parsed value
	fmt.Printf("The level is: %v\n", level) // Output: The level is: 3
	return nil // Explicit success: no error
}

// ============================================================================
// INPUT VALIDATION + ERROR WRAPPING: DEFENSIVE PROGRAMMING
// ============================================================================
// Pattern: validate input → return descriptive error if invalid
// • Use fmt.Errorf for simple errors
// • Use fmt.Errorf("...: %w", err) for error wrapping (Go 1.13+)
func parseLevel(s string) (int, error) {
	// strconv.Atoi: convert string to int
	// Returns (int, error): error if string is not a valid integer
	n, err := strconv.Atoi(s)
	if err != nil {
		// Wrap error with context: "level must be a number: <original error>"
		// ⚠️ Bug in original code: missing %v or %w to include original error!
		// Fixed version: return 0, fmt.Errorf("level must be a number: %w", err)
		return 0, fmt.Errorf("level must be a number: %s")
	}

	// Business logic validation: level must be 1-5
	if n < 1 || n > 5 {
		// Custom error for domain rule violation
		return 0, fmt.Errorf("level must be between 1 and 5")
	}
	// Success: return parsed value + nil error
	return n, nil
}
```

---

## 🔍 Deep Dive: Core Go Function Concepts

### 1. **Multiple Returns: The Error Handling Foundation**
```go
// Why (value, error) is Go's standard pattern:
func readFile(path string) ([]byte, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err // Propagate error up
	}
	return data, nil // Success: value + nil error
}

// Caller MUST handle both:
data, err := readFile("config.yaml")
if err != nil {
	log.Fatal(err) // Or retry, fallback, etc.
}
// Use data safely here
```

**💡 Infrastructure Impact:** This pattern makes error handling:
- ✅ Explicit: no hidden exceptions
- ✅ Composable: errors flow up call stack naturally
- ✅ Testable: mock functions return (value, error) pairs easily

### 2. **Named Returns: When to Use (and Avoid)**
```go
// ✅ Good use: short function with clear semantics
func splitPath(path string) (dir, file string) {
	// dir and file initialized to ""
	lastSlash := strings.LastIndex(path, "/")
	if lastSlash == -1 {
		file = path // dir remains ""
		return      // Naked return: ("", path)
	}
	dir = path[:lastSlash]
	file = path[lastSlash+1:]
	return // Naked return: (dir, file)
}

// ❌ Avoid: long function where values are set in multiple places
func complexParse(input string) (result Config, err error) {
	// ... 50 lines of code setting result and err in various branches ...
	// Hard to track where result/err get assigned!
	return
}
```

### 3. **Variadic Functions + Slice Expansion**
```go
// Variadic parameter: ...T becomes []T inside function
func logMessages(level string, msgs ...string) {
	for _, msg := range msgs { // msgs is []string
		fmt.Printf("[%s] %s\n", level, msg)
	}
}

// Calling patterns:
logMessages("INFO", "started", "initialized") // Pass individual args
messages := []string{"deploying", "waiting"}
logMessages("DEBUG", messages...) // Expand slice with ...
// ❌ logMessages("DEBUG", messages) // ERROR: expects string, got []string
```

### 4. **Anonymous Functions + Closures**
```go
// Anonymous function assigned to variable
double := func(n int) int { return n * 2 }
fmt.Println(double(5)) // 10

// Closure: function capturing outer variables
func makeMultiplier(factor int) func(int) int {
	return func(n int) int {
		return n * factor // 'factor' captured from outer scope
	}
}
triple := makeMultiplier(3)
fmt.Println(triple(4)) // 12

// 💡 Infrastructure Application: Middleware pattern
func withLogging(handler func(string) error) func(string) error {
	return func(input string) error {
		log.Printf("Processing: %s", input)
		err := handler(input)
		if err != nil {
			log.Printf("Error: %v", err)
		}
		return err
	}
}
```

### 5. **Error Wrapping: Go 1.13+ %w Verb**
```go
// Original code bug: fmt.Errorf("msg: %s") loses original error context
// Fixed with %w for error wrapping:
func parseLevel(s string) (int, error) {
	n, err := strconv.Atoi(s)
	if err != nil {
		// %w wraps the error, preserving it for errors.Is/As
		return 0, fmt.Errorf("level must be a number: %w", err)
	}
	// ...
}

// Caller can inspect wrapped errors:
level, err := parseLevel("invalid")
if err != nil {
	// errors.Is checks if err (or any wrapped error) matches target
	if errors.Is(err, strconv.ErrSyntax) {
		log.Println("User entered non-numeric value")
	}
}
```

---

## 🛠️ DevOps & Infrastructure Applications

| Pattern | Infrastructure Use Case | Example |
|---------|------------------------|---------|
| **Multiple returns** | Config parsing with validation | `cfg, err := loadConfig(path); if err != nil { ... }` |
| **Variadic functions** | CLI argument aggregation | `kubectl label pods --all env=prod tier=web` |
| **Anonymous functions** | Middleware for HTTP handlers | `http.Handle("/api", withAuth(apiHandler))` |
| **Error wrapping** | Layered deployment errors | `return fmt.Errorf("provision failed: %w", underlyingErr)` |
| **IIFE** | One-time resource setup | `db := func() *sql.DB { /* init */ }()` |

**Real-World Example: Terraform Provider Resource Creation**
```go
func createInstance(ctx context.Context, cfg InstanceConfig) (*Instance, error) {
	// Validate input
	if cfg.Region == "" {
		return nil, fmt.Errorf("region is required")
	}
	
	// Call AWS API (returns multiple values)
	instanceID, metadata, err := awsClient.LaunchInstance(cfg)
	if err != nil {
		// Wrap with context for debugging
		return nil, fmt.Errorf("launch instance in %s: %w", cfg.Region, err)
	}
	
	// Return success with value
	return &Instance{ID: instanceID, Metadata: metadata}, nil
}
// ✅ Clear error propagation, testable, and composable
```

---

## ⚠️ Common Pitfalls & Best Practices

| Pitfall | Why It Happens | Idiomatic Fix |
|---------|----------------|---------------|
| **Ignoring errors with _** | `val, _ := riskyCall()` hides failures | Only ignore in tests or trivial cases; document why |
| **Misusing named returns** | Long functions with naked returns → unclear flow | Use explicit `return val, err` for clarity in complex functions |
| **Forgetting ... for slice expansion** | `sumAll(slice)` instead of `sumAll(slice...)` | Remember: variadic functions need `...` to expand slices |
| **Losing error context** | `fmt.Errorf("msg: %s", err)` prints error but loses type | Use `%w` for wrapping: `fmt.Errorf("msg: %w", err)` |
| **Anonymous function scope bugs** | Pre-Go 1.22 loop variable capture in goroutines | Use Go 1.22+ or pass variables as args: `go func(val T) { ... }(v)` |

**Pro Tip:** Create helper functions for repetitive error patterns:
```go
// pkg/errutil/validate.go
func RequireNonEmpty(s, fieldName string) error {
	if s == "" {
		return fmt.Errorf("%s is required", fieldName)
	}
	return nil
}

// Usage in parseLevel:
if err := RequireNonEmpty(s, "level"); err != nil {
	return 0, err
}
```

---

## 🧠 Critical Thinking Prompts for Your Context

1. **Config Validation Pipeline**:  
   > *"If I'm building a CLI tool that validates deployment configs, how would I chain multiple validation functions that each return (bool, error) to provide comprehensive feedback?"*  
   → Hint: Use early returns for hard failures, accumulate warnings in a slice, return combined error at end.

2. **Middleware Composition**:  
   > *"When building an HTTP server for a Kubernetes webhook, how would I use anonymous functions to compose logging, auth, and rate-limiting middleware?"*  
   → Sketch: `handler := withLogging(withAuth(withRateLimit(baseHandler)))`

3. **Error Observability**:  
   > *"If a deployment fails with a wrapped error chain, how would I use errors.As to extract a custom ProvisionError type and trigger specific remediation logic?"*  
   → Consider: `var provErr *ProvisionError; if errors.As(err, &provErr) { retryWithBackoff(provErr.Resource) }`

4. **Testing Variadic Functions**:  
   > *"How would I write table-driven tests for sumAll that cover empty input, single value, and large slices? What edge cases matter?"*  
   → Answer: `[]struct{ input []int; expected int }{ {nil, 0}, {{5}, 5}, {{1,2,3}, 6} }`

---

## 🔄 Function Patterns Cheat Sheet

```go
// ✅ Single return
func add(a, b int) int { return a + b }

// ✅ Multiple returns (value, error pattern)
func fetch(key string) (string, error) {
	if val, ok := cache[key]; ok {
		return val, nil
	}
	return "", fmt.Errorf("not found")
}

// ✅ Named returns (short functions only)
func split(s string) (head, tail string) {
	i := strings.Index(s, "/")
	if i == -1 { return s, "" }
	return s[:i], s[i+1:]
}

// ✅ Variadic + slice expansion
func log(msgs ...string) { for _, m := range msgs { fmt.Println(m) } }
log("a", "b")           // Direct
log(slice...)           // Expand slice

// ✅ Anonymous function + closure
double := func(n int) int { return n * 2 }
makeAdder := func(x int) func(int) int {
	return func(y int) int { return x + y }
}

// ✅ Error wrapping (Go 1.13+)
return fmt.Errorf("context: %w", underlyingErr)

// ✅ Error checking idiom
if err := fn(); err != nil {
	return fmt.Errorf("wrapper: %w", err)
}
```

---

