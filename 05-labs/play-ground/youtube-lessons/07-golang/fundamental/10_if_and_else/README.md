## 📜 If - Else  

```go
// ============================================================================
// PACKAGE & IMPORTS
// ============================================================================
package main

import (
	"fmt"
)

// ============================================================================
// MAIN ENTRY POINT
// ============================================================================
func main() {
	// =========================================================================
	// VARIABLE DECLARATION: TYPE INFERENCE + INTENT
	// =========================================================================
	// `score := 72` declares an `int` variable inferred from the literal.
	// • In production, this would likely come from: 
	//   - CLI flags: `flag.Int("score", 0, "test score")`
	//   - Config file: parsed YAML/JSON field
	//   - API response: deserialized metric or evaluation result
	//
	// 💡 Pedagogical Note: Using a named constant for thresholds improves 
	// maintainability and prevents "magic numbers":
	//   const PassingThreshold = 45
	score := 72

	// =========================================================================
	// IF-ELSE-IF LADDER: FIRST-MATCH SEMANTICS + ORDER DEPENDENCE
	// =========================================================================
	// Structure:
	//   if cond1 { ... } 
	//   else if cond2 { ... } 
	//   else if cond3 { ... } 
	//   else { ... }
	//
	// 🔍 Evaluation Flow (critical to understand):
	// 1. Evaluate `score >= 90` → 72 >= 90 → false → skip "Grade: A"
	// 2. Evaluate `score >= 75` → 72 >= 75 → false → skip "Grade: B"  
	// 3. Evaluate `score >= 45` → 72 >= 45 → true → execute "Grade: C" → EXIT
	// 4. `else` block is NEVER reached once a prior condition matches
	//
	// 🎯 Why Order Matters:
	// • Conditions are evaluated TOP-DOWN
	// • First `true` condition wins; remaining branches are skipped
	// • If you reversed the order (e.g., `if score >= 45` first), 
	//   a score of 95 would incorrectly match "Grade: C" and stop!
	if score >= 90 {
		// ✅ Boundary: score ∈ [90, ∞)
		fmt.Println("Grade: A")
	} else if score >= 75 {
		// ✅ Boundary: score ∈ [75, 89] (because >=90 already filtered out)
		fmt.Println("Grade: B")
	} else if score >= 45 {
		// ✅ Boundary: score ∈ [45, 74] (because >=75 already filtered out)
		fmt.Println("Grade: C")
	} else {
		// ✅ Boundary: score ∈ (-∞, 44]
		// ⚠️ Production Note: Consider logging or returning an error for 
		// unexpectedly low scores, rather than silently assigning "D"
		fmt.Println("Grade: D")
	}
	
	// 🔍 Scope Note: All branches share the same outer scope.
	// Variables declared INSIDE a branch (e.g., `if ... { grade := "A" }`) 
	// are NOT accessible outside that branch.
}
```

---

## 🔍 Deep Dive: Core Go Concepts at Play

### 1. **First-Match Semantics & Short-Circuit Evaluation**
Go evaluates conditions sequentially and **stops at the first `true`**. This is:
- **Predictable**: No hidden fallthrough (unlike `switch` without `break` in C)
- **Efficient**: Unnecessary conditions are never evaluated
- **Order-Sensitive**: Rearranging branches changes behavior → always document intent

### 2. **Boundary Conditions: The Silent Bug Source**
The logic above works because thresholds are **monotonically decreasing** and **non-overlapping** due to evaluation order. But consider:
```go
// ❌ Dangerous: Overlapping ranges without order discipline
if score >= 45 { fmt.Println("C") }      // 72 matches here → wrong grade!
else if score >= 75 { fmt.Println("B") } // Never reached for 72+
```
✅ **Rule**: When using `>=` or `<=`, order conditions from **most restrictive → least restrictive**.

### 3. **Boolean Strictness**
Go requires explicit boolean expressions:
- ❌ `if score { ... }` → Compile error: `non-bool score (type int) used as if condition`
- ✅ Forces clear comparisons: `score >= 90`, `score < 0`, etc.
- Prevents "truthy" bugs common in JavaScript/Python (`if "0"`, `if []`, etc.)

### 4. **Readability vs. Maintainability Trade-off**
If-else-if ladders are clear for ≤5 branches. Beyond that, consider:
- **Map-based lookup**: `grades := map[int]string{90: "A", 75: "B", ...}` + binary search
- **Slice of thresholds**: Iterate over `[]Threshold{{Min: 90, Grade: "A"}, ...}`
- **Function dispatch**: `gradeFuncs := map[string]func(int) bool{...}`

---

## 🛠️ DevOps & Infrastructure Applications

This pattern is foundational for **policy engines**, **routing logic**, and **threshold-based automation**:

| Use Case | Idiomatic Pattern |
|----------|-------------------|
| **Alert Severity Classification** | `if latency > 5000 { Critical } else if > 1000 { Warning } else { Info }` |
| **Resource Scaling Decisions** | `if cpu > 90 { scaleOut(3) } else if > 70 { scaleOut(1) } else { maintain }` |
| **Config Validation Tiers** | `if env == "prod" { strictChecks() } else if env == "staging" { mediumChecks() }` |
| **Retry Strategy Selection** | `if err == networkErr { exponentialBackoff() } else if err == rateLimit { fixedDelay() }` |

**Real-World Example: Kubernetes HPA (Horizontal Pod Autoscaler) Logic**
```go
func determineScaleAction(metrics Metrics) ScaleAction {
	if metrics.CPUUtilization > 90 {
		return ScaleOut{Replicas: 3, Reason: "critical-cpu"}
	} else if metrics.CPUUtilization > 70 {
		return ScaleOut{Replicas: 1, Reason: "elevated-cpu"}
	} else if metrics.CPUUtilization < 30 && currentReplicas > minReplicas {
		return ScaleIn{Replicas: 1, Reason: "underutilized"}
	}
	return NoOp{Reason: "within-target-range"}
}
// ✅ Clear, testable, and order-dependent logic mirrors production autoscaling
```

---

## ⚠️ Common Pitfalls & Best Practices

| Pitfall | Why It Happens | Idiomatic Fix |
|---------|----------------|---------------|
| **Reversed condition order** | Copy-paste or unclear requirements | Document thresholds; use constants: `const GradeAThreshold = 90` |
| **Off-by-one boundary errors** | Confusing `>=` vs `>` at edges | Write unit tests for boundary values: `[]int{44, 45, 74, 75, 89, 90, 91}` |
| **Magic numbers** | Hardcoding `90`, `75`, `45` inline | Extract to `const` or config struct: `GradeThresholds{A: 90, B: 75, C: 45}` |
| **Deep nesting** | Adding more `else if` without refactoring | Use early returns, helper functions, or table-driven logic |
| **Missing default case** | Assuming all inputs are valid | Always include `else` to catch unexpected values (defensive programming) |

**Pro Tip:** For numeric thresholds, consider a **data-driven approach** for maintainability:
```go
type GradeThreshold struct {
	MinScore int
	Grade    string
}

var thresholds = []GradeThreshold{
	{90, "A"}, {75, "B"}, {45, "C"}, {0, "D"},
}

func getGrade(score int) string {
	for _, t := range thresholds {
		if score >= t.MinScore {
			return t.Grade
		}
	}
	return "Unknown" // fallback
}
// ✅ Easier to modify thresholds without touching control flow logic
```

---

## 🧠 Critical Thinking Prompts for Your Context

1. **Policy Engine Design**:  
   > *"If I were building a Terraform policy-as-code tool that validates resource configurations, how would I structure threshold checks for cost limits (e.g., warn at $100, block at $500) using this pattern?"*  
   → Hint: Combine `if-else-if` with structured logging and early exits for policy violations.

2. **Observability Thresholds**:  
   > *"When designing alerting rules for Prometheus/Grafana, how does Go's first-match semantics map to rule evaluation order in Alertmanager?"*  
   → Insight: Alertmanager evaluates rules top-down too—order matters for suppression and grouping.

3. **Testing Boundary Conditions**:  
   > *"How would you write table-driven tests to verify every boundary (44→D, 45→C, 74→C, 75→B, 89→B, 90→A) and edge cases (negative scores, overflow)?"*  
   → Consider: `[]struct{ score int; expected string }{ {44, "D"}, {45, "C"}, ... }`

4. **Config-Driven Grading**:  
   > *"How would you refactor this to load thresholds from a YAML config file, allowing operators to adjust grading policies without recompiling?"*  
   → Sketch: `type Config struct { Grades []GradeThreshold }` + `yaml.Unmarshal` + validation.

---

