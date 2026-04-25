## 📜 Fully Annotated Code

```go
// ============================================================================
// PACKAGE & IMPORTS
// ============================================================================
package main
import "fmt"

// ============================================================================
// MAIN ENTRY POINT
// ============================================================================
func main() {
	// =========================================================================
	// SHORT VARIABLE DECLARATION + TYPE INFERENCE
	// =========================================================================
	// `day := 3` declares a new variable `day`, infers its type as `int`,
	// and initializes it to 3.
	//
	// ⚠️ Idiomatic Note: The semicolon (`;`) is syntactically valid but 
	// NON-IDIOMATIC in Go. `gofmt` (Go's official formatter) will automatically 
	// remove it. Semicolons are inserted by the lexer at line breaks, so you 
	// only need them for multiple statements on one line.
	// ✅ Preferred: `day := 3`
	day := 3

	// =========================================================================
	// EXPRESSION SWITCH STATEMENT
	// =========================================================================
	// `switch <expression>` evaluates the expression ONCE, then compares it 
	// against each `case` in top-to-bottom order.
	//
	// 🔍 Type Safety: All `case` values must be assignable to the type of `day`
	// (here, `int`). The compiler catches mismatches at build time:
	//   switch day { case "Monday": ... } → ❌ compile error
	switch day {
	// =========================================================================
	// CASE CLAUSES: EXACT MATCH, NO IMPLICIT FALLTHROUGH
	// =========================================================================
	// • Each `case` is an independent block.
	// • When a match is found, its block executes, and the switch TERMINATES.
	// • Unlike C/Java/JavaScript, Go DOES NOT implicitly "fall through" to 
	//   the next case. This eliminates a major class of bugs.
	//
	// 💡 If you WANT fallthrough behavior, you must explicitly write the 
	// `fallthrough` keyword at the end of the case block.
	case 1:
		fmt.Println("Monday")
	case 2:
		fmt.Println("Tuesday")
	case 3:
		fmt.Println("Wednesday")

	// =========================================================================
	// DEFAULT CLAUSE: CATCH-ALL
	// =========================================================================
	// Executes ONLY if no `case` matches.
	// • Can be placed anywhere in the switch block (top, middle, bottom), 
	//   but convention places it at the end for readability.
	// • Critical for defensive programming: prevents silent failures when 
	//   unexpected values occur (e.g., malformed config, out-of-range enums).
	default:
		fmt.Println("Invalid day")
		// In production, you'd likely return an error or log a warning:
		// return fmt.Errorf("invalid day value: %d", day)
	}
}
```

---

## 🔍 Deep Dive: Core Go Concepts at Play

### 1. **Expression Switch vs. Type Switch**
This is an **expression switch** (evaluates a value). Go also supports **type switches** (`switch v := x.(type) { case string: ... }`), which are heavily used in CLI tools that accept heterogeneous inputs (e.g., parsing flags that could be strings, ints, or slices).

### 2. **First-Match Semantics**
Go stops evaluating after the first matching `case`. This means:
- Order matters when cases could logically overlap (though with exact `int` literals, they can't).
- Performance is predictable: `O(n)` in the worst case, but the compiler often optimizes dense `int`/`string` switches into jump tables.

### 3. **No Implicit Fallthrough: A Design Choice**
In C/Java, forgetting `break` caused infamous bugs. Go's designers made **explicit fallthrough** the default to:
- Enforce intentional control flow
- Reduce cognitive load when reading code
- Align with Go's philosophy: *clear code over clever code*

### 4. **Brace Placement Rule**
Notice `switch day {` has the opening brace on the same line. Go's parser enforces this via automatic semicolon insertion. Placing `{` on a new line causes a compile error. This is non-negotiable and enforced by `gofmt`.

---

## 🛠️ DevOps & Infrastructure Applications

Switch statements are **ubiquitous** in infrastructure tooling. Here's how they scale:

| Use Case                   | Pattern Example                                                                                                 |
| -------------------------- | --------------------------------------------------------------------------------------------------------------- |
| **CLI Command Routing**    | `switch command { case "deploy": runDeploy(), case "rollback": runRollback() }`                                 |
| **State Machine Handling** | `switch state { case "pending": poll(), case "running": checkHealth(), case "failed": notify() }`               |
| **Error Code Mapping**     | `switch exitCode { case 0: log("success"), case 1: log("timeout"), case 2: log("auth_failed") }`                |
| **Config Validation**      | `switch region { case "us-east-1", "us-west-2": return nil, default: return fmt.Errorf("unsupported region") }` |

**Real-World Snippet (K8s Controller Pattern):**
```go
switch phase := pod.Status.Phase; phase {
case corev1.PodPending:
    // wait for scheduler
case corev1.PodRunning:
    // readiness check
case corev1.PodFailed, corev1.PodSucceeded:
    // cleanup or archive
default:
    log.Warn("unknown pod phase", "phase", phase)
}
```

---

## ⚠️ Common Pitfalls & Best Practices

| Pitfall | Why It Happens | Idiomatic Fix |
|---------|----------------|---------------|
| **Unused `default` branch** | Assuming input is always valid | Always include `default` for external/untrusted input |
| **Relying on case order for logic** | Thinking later cases override earlier ones | Go stops at first match; refactor to explicit conditions if overlap needed |
| **Forgetting `break` (from C background)** | Trying to exit early | Not needed in Go; switch auto-breaks. Use `return` or `goto` for early exit from outer scope |
| **Switching on untyped constants** | Type ambiguity in complex expressions | Let Go infer, or explicitly type: `switch int(day) { ... }` |

**Pro Tip:** For 3+ cases, consider using a `map[int]string` instead if you're just doing lookups:
```go
days := map[int]string{1: "Monday", 2: "Tuesday", 3: "Wednesday"}
if name, ok := days[day]; ok {
    fmt.Println(name)
} else {
    fmt.Println("Invalid day")
}
```
→ Use `switch` when cases require **different logic** (not just value mapping). Use `map` for **pure lookup**.

---

## 🧠 Critical Thinking Prompts for Your Context

1. **CLI Tool Design**:  
   > *"If I'm building a Terraform-like CLI with subcommands (`plan`, `apply`, `destroy`), when should I use `switch` vs a registry pattern with function pointers?"*  
   → Hint: `switch` is fine for <10 commands. For extensibility, map `string → func()` and load plugins dynamically.

2. **State Validation**:  
   > *"How would you modify this switch to handle out-of-range inputs (e.g., `day = 0` or `day = 8`) gracefully in a production deployment script?"*  
   → Consider: Add validation before switch, or use `default` to return a structured error with telemetry.

3. **Testing Strategy**:  
   > *"What test cases would you write to cover this switch block? How would you ensure the `default` path is actually reachable?"*  
   → Fuzz testing or table-driven tests: `[]int{1, 2, 3, 0, 4, -1, 100}`

---

## 🚀 Next Steps

Would you like to:
- 🔁 See how this scales to **string switches** (common for CLI flags & config keys)?
- 📊 Compare `switch` vs `map` vs `if/else` for performance & readability in infrastructure code?
- 🧪 Refactor this into a **table-driven test** (Go's standard testing pattern)?
- 🌐 Explore how `switch` integrates with **error handling** and **context cancellation** in long-running services?

You're building a strong foundation in Go's control flow. Where should we pivot next? 🎯