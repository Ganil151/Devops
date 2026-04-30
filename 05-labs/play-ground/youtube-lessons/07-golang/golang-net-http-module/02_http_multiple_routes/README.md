Go HTTP server that demonstrates **query parameter handling**, **multiple route registration**, and **dynamic response generation**—essential patterns for building APIs, health endpoints, and operational tooling.

---

## 📜 Fully Annotated Code

```go
// =======================================================================
// PACKAGE & IMPORTS
// =======================================================================
package main

import (
	"fmt"      // Formatted I/O: Sprintf for string building, Println for output
	"net/http" // Standard library HTTP server: handlers, routing, request/response
)

// =======================================================================
// ROUTE HANDLER 1: ROOT ENDPOINT (/)
// =======================================================================
// Signature: func(w http.ResponseWriter, r *http.Request)
// • Matches the http.HandlerFunc type — any function with this signature 
//   can serve HTTP requests
// • w: interface for writing the HTTP response (body, headers, status)
// • r: pointer to http.Request struct containing all request details
func rootHandler(w http.ResponseWriter, r *http.Request) {
	// ----------------------------------------------------------------
	// WRITE WELCOME MESSAGE
	// ----------------------------------------------------------------
	// w.Write([]byte(...)): sends bytes as the HTTP response body
	// • Return values: (n int, err error) — bytes written + any I/O error
	// • Using _, _ ignores both: acceptable for learning, but log errors in production
	//
	// 🔍 Why []byte? Write() expects a byte slice, not a string
	// • Conversion: []byte("string") allocates a new slice
	// • Alternative: io.WriteString(w, "string") avoids allocation
	_, _ = w.Write([]byte("Welcome try to /hello?name=Ganil"))
	// ✅ What happens automatically:
	// • If WriteHeader() wasn't called, Go sends "200 OK" before first Write()
	// • Content-Length header is set based on body size
	// • Content-Type defaults to "text/plain; charset=utf-8"
}

// ============================================================================
// ROUTE HANDLER 2: DYNAMIC ENDPOINT (/hello?name=VALUE)
// ============================================================================
func helloHandler(w http.ResponseWriter, r *http.Request) {
	// ------------------------------------------------------------------------
	// STEP 1: PARSE QUERY PARAMETERS
	// ------------------------------------------------------------------------
	// r.URL: *url.URL struct containing parsed URL components
	// • r.URL.Path: the path portion ("/hello")
	// • r.URL.RawQuery: the raw query string ("name=Ganil&age=30")
	// • r.URL.Query(): returns url.Values (map[string][]string) of parsed params
	//
	// Query().Get(key): returns FIRST value for key, or "" if missing
	// • Safe: never panics, even if query is malformed or key absent
	// • Case-sensitive: "name" ≠ "Name" ≠ "NAME"
	// • Single-value: if URL has ?name=Alice&name=Bob, Get("name") returns "Alice"
	name := r.URL.Query().Get("name")
	// Example URLs and results:
	// /hello?name=Ganil     → name = "Ganil"
	// /hello                → name = "" (key missing)
	// /hello?name=          → name = "" (empty value)
	// /hello?other=value    → name = "" (different key)

	// ------------------------------------------------------------------------
	// STEP 2: APPLY DEFAULT VALUE (DEFENSIVE PROGRAMMING)
	// ------------------------------------------------------------------------
	// If name is empty string (missing or blank), use fallback "Guest"
	// • This prevents returning "Hello, !" which looks broken to users
	// • In production: consider logging when defaults are applied for observability
	if name == "" {
		name = "Guest"
	}
	// 🔍 Why check == "" and not != ""?
	// • Go idiom: handle the "missing/invalid" case early, then proceed with valid data
	// • Alternative: use a helper function for reusable default logic

	// ------------------------------------------------------------------------
	// STEP 3: FORMAT AND WRITE DYNAMIC RESPONSE
	// ------------------------------------------------------------------------
	// fmt.Sprintf: formats string and RETURNS it (unlike Printf which prints)
	// • %s: placeholder for string value
	// • Safe for user input? ⚠️ See security notes below!
	response := fmt.Sprintf("Hello, %s!", name)
	
	// Write the formatted response
	_, _ = w.Write([]byte(response))
	// Output examples:
	// /hello?name=Ganil     → "Hello, Ganil!"
	// /hello                → "Hello, Guest!"
	// /hello?name=<script>  → "Hello, <script>!" ⚠️ Potential XSS (see below)
}

// ============================================================================
// MAIN: SERVER SETUP & ROUTE REGISTRATION
// ============================================================================
func main() {
	// ------------------------------------------------------------------------
	// STEP 1: REGISTER ROUTE HANDLERS
	// ------------------------------------------------------------------------
	// http.HandleFunc: registers a handler for a URL pattern using DefaultServeMux
	// • Pattern "/": matches ALL paths not matched more specifically
	//   - Acts as a "catch-all" or fallback route
	//   - Order matters: register specific routes BEFORE catch-all
	//
	// • Pattern "/hello": matches EXACT path /hello (NOT /hello/world)
	//   - For prefix matching, use trailing slash: "/hello/" matches /hello/*
	//
	// 🔍 ServeMux matching rules (longest prefix wins):
	//   /hello      → matches /hello exactly
	//   /hello/     → matches /hello/anything (prefix match)
	//   /           → matches everything (fallback)
	http.HandleFunc("/", rootHandler)      // Catch-all: /, /foo, /bar → rootHandler
	http.HandleFunc("/hello", helloHandler) // Exact: /hello → helloHandler

	// ------------------------------------------------------------------------
	// STEP 2: START HTTP SERVER
	// ------------------------------------------------------------------------
	// http.ListenAndServe: starts server and BLOCKS until error or shutdown
	// • addr ":5000" = listen on all network interfaces, port 5000
	// • handler nil = use DefaultServeMux (where we registered handlers)
	// • Returns error only if server FAILS to start (e.g., port in use)
	// • Does NOT return on normal operation (blocks forever)
	err := http.ListenAndServe(":5000", nil)
	
	// ------------------------------------------------------------------------
	// STEP 3: HANDLE STARTUP ERRORS
	// ------------------------------------------------------------------------
	// If ListenAndServe returns, something went wrong:
	// • "listen tcp :5000: bind: address already in use"
	// • Permission denied (privileged port < 1024 without sudo)
	// • Invalid address format
	fmt.Println(err)
	// ⚠️ Production improvement:
	// • Use log.Fatal(err) to exit with code 1 + stderr output
	// • Or structured logging: slog.Error("server failed", "error", err)
	// • Note: After printing, main() exits naturally (return code 0)
}
```

---

## 🔍 Deep Dive: Query Parameters & URL Parsing

### 1. **url.Values: The Query Parameter Map**
```go
// r.URL.Query() returns url.Values, which is map[string][]string:
// • Keys: parameter names ("name", "age", "filter")
// • Values: SLICE of strings (because params can repeat: ?tag=go&tag=devops)

// Example: /hello?name=Alice&name=Bob&age=30
query := r.URL.Query()
// query = map[string][]string{
//     "name": {"Alice", "Bob"},  // Multiple values preserved
//     "age":  {"30"},            // Single value still in slice
// }

// Access patterns:
name := query.Get("name")        // "Alice" (first value only)
allNames := query["name"]        // []string{"Alice", "Bob"} (all values)
hasName := query.Has("name")     // true (checks key existence)
missing := query.Get("missing")  // "" (safe: no panic)

// 💡 Infrastructure Application: Filtering resources by labels
// /pods?label=app=api&label=tier=backend
labels := r.URL.Query()["label"] // []string{"app=api", "tier=backend"}
for _, label := range labels {
	// Apply each label filter to Kubernetes API query
}
```

### 2. **Default Values & Validation Patterns**
```go
// ❌ Naive: only check for empty string
name := r.URL.Query().Get("name")
if name == "" {
	name = "Guest" // What if user explicitly sent ?name= (empty)?
}

// ✅ Better: distinguish missing vs empty vs invalid
query := r.URL.Query()
name, hasName := query["name"], query.Has("name")

if !hasName {
	name = "Guest" // Truly missing → use default
} else if len(name) == 0 || name[0] == "" {
	// Explicitly empty: ?name= → decide policy: reject or accept?
	http.Error(w, "name parameter cannot be empty", http.StatusBadRequest)
	return
}
// else: valid non-empty name → proceed

// ✅ Best: use a helper for reusable validation
func getQueryParam(r *http.Request, key, defaultVal string, required bool) (string, error) {
	val := r.URL.Query().Get(key)
	if val == "" {
		if required {
			return "", fmt.Errorf("missing required parameter: %s", key)
		}
		return defaultVal, nil
	}
	return val, nil
}

// Usage in handler:
name, err := getQueryParam(r, "name", "Guest", false)
if err != nil {
	http.Error(w, err.Error(), http.StatusBadRequest)
	return
}
```

### 3. **Security: Sanitizing User Input**
```go
// ⚠️ XSS Risk: User input reflected directly in HTML response
// /hello?name=<script>alert('xss')</script>
// → Response: "Hello, <script>alert('xss')</script>!" 
// → If rendered in browser, script executes!

// ✅ Mitigation 1: HTML-escape output (for HTML responses)
import "html"
escaped := html.EscapeString(name) // "<script>" → "&lt;script&gt;"
fmt.Fprintf(w, "Hello, %s!", escaped)

// ✅ Mitigation 2: Use JSON response (safer for APIs)
import "encoding/json"
w.Header().Set("Content-Type", "application/json")
json.NewEncoder(w).Encode(map[string]string{"message": fmt.Sprintf("Hello, %s!", name)})
// json.Encoder auto-escapes special characters

// ✅ Mitigation 3: Validate input against allowlist
if !isValidName(name) {
	http.Error(w, "invalid name parameter", http.StatusBadRequest)
	return
}
func isValidName(s string) bool {
	// Only allow letters, numbers, spaces, hyphens
	return regexp.MustCompile(`^[a-zA-Z0-9\s\-]+$`).MatchString(s)
}

// 💡 Infrastructure Rule: Never trust user input — validate, sanitize, or escape!
```

---

## 🛠️ DevOps & Infrastructure Applications

| Use Case | Query Param Pattern | Why It Fits |
|----------|-------------------|-------------|
| **Health Check with Details** | `/health?verbose=true` → return detailed status | Kubernetes probes, load balancer checks with debug mode |
| **Resource Filtering** | `/pods?namespace=prod&label=app=api` | Kubernetes API-style filtering for CLI tools or dashboards |
| **Feature Flag Toggles** | `/deploy?force=true&skipTests=false` | Safe rollout controls with explicit opt-in flags |
| **Metrics Endpoint** | `/metrics?format=prometheus` or `?format=json` | Support multiple output formats for different monitoring systems |
| **Webhook Validation** | `/webhook?token=SECRET` → verify token before processing | Secure event ingestion from GitHub, GitLab, CI/CD systems |

**Real-World Example: Terraform Cloud-like API Filter**
```go
func listRunsHandler(w http.ResponseWriter, r *http.Request) {
	// Parse filtering params
	workspace := r.URL.Query().Get("workspace")
	status := r.URL.Query().Get("status") // "pending", "applied", "errored"
	limit := r.URL.Query().Get("limit")
	
	// Apply defaults + validation
	if limit == "" { limit = "20" }
	maxRuns, err := strconv.Atoi(limit)
	if err != nil || maxRuns < 1 || maxRuns > 100 {
		http.Error(w, "limit must be 1-100", http.StatusBadRequest)
		return
	}
	
	// Query backend (e.g., database, Terraform Cloud API)
	runs, err := backend.ListRuns(workspace, status, maxRuns)
	if err != nil {
		http.Error(w, "failed to list runs: "+err.Error(), http.StatusInternalServerError)
		return
	}
	
	// Return JSON response
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(runs)
}
// ✅ Enables CLI: terraform-cli runs list --workspace=prod --status=applied
```

---

## ⚠️ Common Pitfalls & Best Practices

| Pitfall | Why It Happens | Idiomatic Fix |
|---------|----------------|---------------|
| **Route registration order** | Registering `/` before `/hello` → all requests hit rootHandler | Register specific routes FIRST, catch-all `/` LAST |
| **Ignoring query validation** | Assuming `?name=value` is always well-formed | Always validate/sanitize user input; return 400 for bad params |
| **Reflecting input unsafely** | `fmt.Fprintf(w, "Hello, %s!", name)` in HTML → XSS risk | Escape HTML output or use JSON for APIs |
| **Not setting Content-Type** | Default is `text/plain`; APIs should use `application/json` | Always set `w.Header().Set("Content-Type", "application/json")` for APIs |
| **Ignoring Write() errors** | `_, _ = w.Write(...)` hides I/O failures | Log errors in production: `if _, err := w.Write(...); err != nil { log.Printf("write failed: %v", err) }` |
| **Blocking handler logic** | Long-running work in handler blocks HTTP worker goroutine | Offload heavy work to background goroutine; return 202 Accepted |

**Pro Tip:** Add request logging middleware early:
```go
func logRequests(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		log.Printf("%s %s?%s completed in %v", 
			r.Method, r.URL.Path, r.URL.RawQuery, time.Since(start))
	})
}

// Usage in main():
mux := http.NewServeMux()
mux.HandleFunc("/", rootHandler)
mux.HandleFunc("/hello", helloHandler)
http.ListenAndServe(":5000", logRequests(mux))
```

---

## 🧠 Critical Thinking Prompts for Your Context

1. **CLI Tool with HTTP API**:  
   > *"If I'm building a DevOps CLI that exposes an HTTP endpoint for remote status checks, how would I authenticate requests (e.g., API key in query param vs header) while keeping the handler logic clean?"*  
   → Hint: Prefer headers over query params for secrets: `r.Header.Get("Authorization")`; use middleware to validate.

2. **Kubernetes Operator Filtering**:  
   > *"When building a webhook receiver for Kubernetes events, how would I parse query params like `?namespace=prod&kind=Deployment` to filter which events to process?"*  
   → Sketch: Parse params → validate against allowed values → apply label selector to Kubernetes client.List() call.

3. **Metrics Endpoint Design**:  
   > *"How would I extend `/metrics?format=prometheus` to support multiple output formats (Prometheus, JSON, plain text) without duplicating handler logic?"*  
   → Insight: Extract metric collection into a shared function; format output based on `Accept` header or query param.

4. **Testing Query Handlers**:  
   > *"How would I write a table-driven test for `helloHandler` that covers missing name, empty name, and XSS-like input?"*  
   → Answer: Use `httptest.NewRequest("GET", "/hello?name=<script>", nil)` + `httptest.NewRecorder()`; assert response body and status.

---

## 🔄 HTTP Query Handling Patterns Cheat Sheet

```go
// ✅ Parse single query param with default
name := r.URL.Query().Get("name")
if name == "" { name = "Guest" }

// ✅ Parse multiple values for same key
tags := r.URL.Query()["tag"] // []string{"go", "devops"}

// ✅ Validate required param
if r.URL.Query().Get("token") == "" {
	http.Error(w, "missing token", http.StatusUnauthorized)
	return
}

// ✅ Safe HTML output (prevent XSS)
import "html"
fmt.Fprintf(w, "Hello, %s!", html.EscapeString(userInput))

// ✅ JSON API response
w.Header().Set("Content-Type", "application/json")
json.NewEncoder(w).Encode(map[string]string{"message": "Hello!"})

// ✅ Register routes: specific BEFORE catch-all
mux := http.NewServeMux()
mux.HandleFunc("/hello", helloHandler) // Specific
mux.HandleFunc("/", rootHandler)       // Catch-all (last!)
http.ListenAndServe(":5000", mux)

// ✅ Logging middleware
func logMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		log.Printf("%s %s?%s %v", r.Method, r.URL.Path, r.URL.RawQuery, time.Since(start))
	})
}
```


