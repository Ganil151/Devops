Go's `net/http` package—the foundation of building web servers, APIs, and microservices in Go. This code demonstrates core HTTP handling patterns essential for infrastructure tooling.

---

## 📜 Fully Annotated Code

```go
// =======================================================================
// PACKAGE & IMPORTS
// =======================================================================
package main

import (
	"fmt"      // Formatted I/O for console output
	"net/http" // Go's standard library HTTP server/client package
)

// ============================================================================
// HANDLER FUNCTION: PROCESSING HTTP REQUESTS
// ============================================================================
// Signature: func(w http.ResponseWriter, r *http.Request)
// • http.ResponseWriter: INTERFACE for writing the HTTP response
//   - Write([]byte) sends body content
//   - WriteHeader(statusCode) sets HTTP status (optional; Write() auto-sends 200)
//   - Header() returns http.Header map for setting response headers
//
// • *http.Request: POINTER to struct containing request details
//   - r.Method: HTTP method ("GET", "POST", etc.)
//   - r.URL: *url.URL with path, query params, etc.
//   - r.Header: map[string][]string of request headers
//   - r.Body: io.ReadCloser for reading request body (for POST/PUT)
//
// 🔑 Key Insight: Handlers are FUNCTIONS that match the http.HandlerFunc type:
//   type HandlerFunc func(ResponseWriter, *Request)
// This enables functions, methods, and closures to all serve as HTTP handlers!
func helloHandler(w http.ResponseWriter, r *http.Request) {
	// ------------------------------------------------------------------------
	// STEP 1: VALIDATE HTTP METHOD (DEFENSIVE PROGRAMMING)
	// ------------------------------------------------------------------------
	// http.MethodGet is a constant = "GET" (defined in net/http)
	// • Always use constants instead of string literals: clearer, typo-safe
	// • Checking method prevents unintended behavior (e.g., accepting POST when only GET is supported)
	if r.Method != http.MethodGet {
		// http.Error: convenience function that:
		// 1. Sets Content-Type: text/plain; charset=utf-8
		// 2. Writes the error message as response body
		// 3. Sets the HTTP status code (e.g., 405 Method Not Allowed)
		// 4. Returns after writing (but you should still return explicitly)
		http.Error(w, "Only GET requests allowed", http.StatusMethodNotAllowed)
		// http.StatusMethodNotAllowed = 405 (defined constant)
		return // Explicit return: stop processing after sending error
	}

	// ------------------------------------------------------------------------
	// STEP 2: WRITE SUCCESS RESPONSE
	// ------------------------------------------------------------------------
	// w.Write([]byte(...)): writes bytes to the response body
	// • Return values: (n int, err error) — bytes written + any write error
	// • In simple handlers, we often ignore these with _ (blank identifier)
	// • ⚠️ In production: consider logging write errors for observability
	_, _ = w.Write([]byte("Hello from GO net/http server"))
	// 🔍 Why []byte? Write() expects []byte, not string
	// • Conversion: []byte("string") allocates new byte slice
	// • For performance: reuse buffers or use io.WriteString(w, "string")

	// 💡 What happens automatically:
	// • If WriteHeader() was not called, Go sends "200 OK" before first Write()
	// • Content-Length header is set automatically based on body size
	// • Connection is kept alive (HTTP/1.1 default) unless explicitly closed
}

// ============================================================================
// MAIN: SERVER ENTRY POINT & ROUTE REGISTRATION
// ============================================================================
func main() {
	// ------------------------------------------------------------------------
	// STEP 1: REGISTER ROUTE HANDLER
	// ------------------------------------------------------------------------
	// http.HandleFunc: registers a handler function for a URL pattern
	// • Pattern "/hello": matches exact path /hello (NOT /hello/world)
	// • For prefix matching: use pattern "/hello/" (trailing slash)
	// • Handler: any function matching http.HandlerFunc signature
	http.HandleFunc("/hello", helloHandler)
	// 🔍 Under the hood: adds to DefaultServeMux (the global router)
	// • ServeMux: HTTP request multiplexer (router) that matches URLs to handlers
	// • Thread-safe: safe to register handlers from multiple goroutines during init

	// ------------------------------------------------------------------------
	// STEP 2: START THE HTTP SERVER
	// ------------------------------------------------------------------------
	fmt.Println("try going to 5000 port")
	// • Prints to stdout before server starts (helpful for local dev)
	// • In production: use structured logging (slog, zap) instead of fmt.Println

	// http.ListenAndServe: starts server and BLOCKS until error/shutdown
	// Signature: func ListenAndServe(addr string, handler Handler) error
	// • addr: ":5000" = listen on all interfaces, port 5000
	//   - "localhost:5000" = listen only on loopback interface
	//   - ":80" = privileged port (requires sudo on Unix)
	// • handler: http.Handler interface (nil = use DefaultServeMux)
	// • Returns error only if server fails to start (e.g., port already in use)
	// • Does NOT return on successful shutdown (use http.Server for graceful shutdown)
	err := http.ListenAndServe(":5000", nil)

	// ------------------------------------------------------------------------
	// STEP 3: HANDLE STARTUP ERRORS
	// ------------------------------------------------------------------------
	// If ListenAndServe returns, it means an error occurred:
	// • "listen tcp :5000: bind: address already in use"
	// • "permission denied" (privileged port without sudo)
	// • Invalid address format
	if err != nil {
		// fmt.Println: simple error output for learning
		// ✅ Production: use log.Fatal(err) to exit with code 1 + stderr output
		fmt.Println("Error starting server:", err)
		// ⚠️ Note: After printing, main() exits naturally (return code 0)
		// For proper failure signaling: os.Exit(1) or log.Fatal(err)
	}
	// 🔍 If no error, this line is never reached (ListenAndServe blocks forever)
}
```

---

## 🔍 Deep Dive: Core HTTP Concepts in Go

### 1. **http.ResponseWriter: The Response Interface**
```go
// http.ResponseWriter is an INTERFACE (not a struct):
type ResponseWriter interface {
	Header() Header        // Get header map to set response headers
	Write([]byte) (int, error)  // Write response body
	WriteHeader(statusCode int) // Send HTTP status code
}

// 💡 Why an interface?
// • Enables testing: mock ResponseWriter in unit tests
// • Enables middleware: wrap ResponseWriter to add logging, compression, etc.
// • Enables flexibility: different implementations for HTTP/1.1, HTTP/2, testing

// ✅ Setting headers BEFORE Write() or WriteHeader():
func jsonHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json") // Must call BEFORE Write
	w.WriteHeader(http.StatusOK)                        // Optional; Write() auto-sends 200
	w.Write([]byte(`{"message": "hello"}`))             // Body
}

// ⚠️ Common mistake: setting headers AFTER Write() has started
func brokenHandler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("body"))              // Triggers 200 OK + sends headers
	w.Header().Set("X-Custom", "value")  // ❌ Too late! Headers already sent
}
```

### 2. **http.Request: The Request Pointer**
```go
// Key fields of *http.Request:
type Request struct {
	Method           string          // "GET", "POST", etc.
	URL              *url.URL        // Parsed URL: Path, Query, Host, etc.
	Header           Header          // Request headers (map[string][]string)
	Body             io.ReadCloser   // Request body stream (for POST/PUT)
	RemoteAddr       string          // Client IP:port (e.g., "192.168.1.1:54321")
	Context          context.Context // Request-scoped values + cancellation
	// ... many more fields
}

// ✅ Safe pattern for reading query parameters:
func queryHandler(w http.ResponseWriter, r *http.Request) {
	name := r.URL.Query().Get("name") // Returns "" if key missing (safe)
	if name == "" {
		http.Error(w, "missing 'name' parameter", http.StatusBadRequest)
		return
	}
	fmt.Fprintf(w, "Hello, %s!", name)
}

// ✅ Safe pattern for reading JSON body (POST/PUT):
func jsonBodyHandler(w http.ResponseWriter, r *http.Request) {
	// Limit body size to prevent DoS attacks
	r.Body = http.MaxBytesReader(w, r.Body, 1<<20) // 1MB limit
	
	var payload struct {
		Name string `json:"name"`
	}
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		http.Error(w, "invalid JSON: "+err.Error(), http.StatusBadRequest)
		return
	}
	// Use payload.Name...
}
```

### 3. **ServeMux: Go's Built-in Router**
```go
// http.HandleFunc uses the DefaultServeMux (global router)
// For larger apps, create custom ServeMux for better isolation:

func main() {
	mux := http.NewServeMux() // Create new router (not global)
	
	mux.HandleFunc("/hello", helloHandler)
	mux.HandleFunc("/api/users", usersHandler)
	
	// Middleware pattern: wrap handler with logging
	mux.Handle("/metrics", loggingMiddleware(prometheusHandler))
	
	// Start server with custom mux (instead of nil = DefaultServeMux)
	http.ListenAndServe(":5000", mux)
}

// Simple logging middleware
func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r) // Call next handler
		log.Printf("%s %s completed in %v", r.Method, r.URL.Path, time.Since(start))
	})
}
```

### 4. **Server Lifecycle & Graceful Shutdown**
```go
// http.ListenAndServe blocks forever — no graceful shutdown
// For production: use http.Server with Shutdown()

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/hello", helloHandler)
	
	srv := &http.Server{
		Addr:         ":5000",
		Handler:      mux,
		ReadTimeout:  10 * time.Second,  // Prevent slow-client attacks
		WriteTimeout: 10 * time.Second,  // Prevent slow-write attacks
		IdleTimeout:  60 * time.Second,  // Keep-alive timeout
	}
	
	// Start server in goroutine (non-blocking)
	go func() {
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("server failed: %v", err)
		}
	}()
	
	// Wait for interrupt signal (Ctrl+C)
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt)
	<-stop
	
	// Graceful shutdown: stop accepting new requests, finish in-flight
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	
	if err := srv.Shutdown(ctx); err != nil {
		log.Printf("shutdown error: %v", err)
	}
	log.Println("server stopped gracefully")
}
```

---

## 🛠️ DevOps & Infrastructure Applications

| Use Case | Pattern | Why It Fits |
|----------|---------|-------------|
| **Health Check Endpoint** | `mux.HandleFunc("/health", func(w, r) { w.Write([]byte("OK")) })` | Kubernetes liveness/readiness probes, load balancer checks |
| **Metrics Endpoint** | Prometheus `/metrics` handler with `promhttp.Handler()` | Observability, monitoring, alerting integration |
| **CLI Tool with HTTP API** | Embed HTTP server in CLI for remote control/status | `terraform console`, `kubectl proxy` patterns |
| **Webhook Receiver** | Handler that validates signatures + processes payloads | GitHub/GitLab webhooks, CI/CD event triggers |
| **Internal Admin UI** | Simple HTML/JSON API for operational tasks | Debug endpoints, config reload, feature flag toggles |

**Real-World Example: Kubernetes Operator Health Endpoint**
```go
func setupHealthEndpoints(mux *http.ServeMux, readyCheck func() bool) {
	// Liveness probe: is process alive? (always true if running)
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("alive"))
	})
	
	// Readiness probe: is operator ready to reconcile?
	mux.HandleFunc("/readyz", func(w http.ResponseWriter, r *http.Request) {
		if readyCheck() {
			w.WriteHeader(http.StatusOK)
			w.Write([]byte("ready"))
		} else {
			http.Error(w, "not ready", http.StatusServiceUnavailable)
		}
	})
}
// ✅ Enables Kubernetes to manage pod lifecycle safely
```

---

## ⚠️ Common Pitfalls & Best Practices

| Pitfall | Why It Happens | Idiomatic Fix |
|---------|----------------|---------------|
| **Not checking r.Method** | Assuming all requests are GET | Always validate method; return 405 for unsupported methods |
| **Ignoring Write() errors** | Using `_, _ = w.Write(...)` always | Log errors in production: `if _, err := w.Write(...); err != nil { log.Printf("write failed: %v", err) }` |
| **Setting headers after Write** | Headers sent automatically on first Write() | Always set headers BEFORE calling Write() or WriteHeader() |
| **No request body limits** | Unlimited body → memory exhaustion DoS | Use `http.MaxBytesReader(w, r.Body, maxSize)` for POST/PUT handlers |
| **Blocking handler logic** | Long-running work blocks HTTP worker goroutine | Offload heavy work to background goroutine; return 202 Accepted |
| **Using DefaultServeMux in large apps** | Global state → testing difficulties, route conflicts | Create custom `http.NewServeMux()` per binary or component |

**Pro Tip:** Add request logging middleware early:
```go
func logRequests(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		// Wrap ResponseWriter to capture status code
		lw := &logWriter{ResponseWriter: w, statusCode: http.StatusOK}
		next.ServeHTTP(lw, r)
		log.Printf("%s %s %d %v", r.Method, r.URL.Path, lw.statusCode, time.Since(start))
	})
}

type logWriter struct {
	http.ResponseWriter
	statusCode int
}
func (lw *logWriter) WriteHeader(code int) {
	lw.statusCode = code
	lw.ResponseWriter.WriteHeader(code)
}
```

---

## 🧠 Critical Thinking Prompts for Your Context

1. **Infrastructure as Code API**:  
   > *"If I'm building a CLI tool that exposes an HTTP API for remote deployment control, how would I authenticate requests (e.g., API keys, mTLS) while keeping the handler logic clean?"*  
   
→ Hint: Use middleware: `mux.Handle("/deploy", authMiddleware(deployHandler))`

2. **Health Checks for Kubernetes**:  
   > *"When deploying this server to Kubernetes, what should the `/healthz` and `/readyz` endpoints check? How do I avoid false positives during startup?"*  
   
 → Insight: Liveness = process alive; Readiness = dependencies (DB, API) connected + config loaded.

3. **Metrics & Observability**:  
   > *"How would I add Prometheus metrics to track request latency, error rates, and in-flight requests for this server?"*  
   
 → Sketch: Wrap handler with prometheus middleware; expose `/metrics` via `promhttp.Handler()`.

4. **Testing HTTP Handlers**:  
   > *"How would I write a unit test for `helloHandler` that verifies the 405 response for POST requests without starting a real server?"*  
   
→ Answer: Use `httptest.NewRecorder()` + `httptest.NewRequest()`:  

   ```go
   req := httptest.NewRequest("POST", "/hello", nil)
   rr := httptest.NewRecorder()
   helloHandler(rr, req)
   assert.Equal(t, http.StatusMethodNotAllowed, rr.Code)
   ```

---

## 🔄 HTTP Handler Patterns Cheat Sheet

```go
// ✅ Basic handler signature
func handler(w http.ResponseWriter, r *http.Request) {
	// Validate method
	if r.Method != http.MethodGet {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	// Set headers BEFORE Write
	w.Header().Set("Content-Type", "application/json")
	// Write response
	fmt.Fprintf(w, `{"status": "ok"}`)
}

// ✅ Register with custom mux
mux := http.NewServeMux()
mux.HandleFunc("/path", handler)
http.ListenAndServe(":8080", mux)

// ✅ Middleware pattern
func middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Pre-processing: logging, auth, metrics
		next.ServeHTTP(w, r) // Call next handler
		// Post-processing: cleanup, response modification
	})
}

// ✅ Graceful shutdown skeleton
srv := &http.Server{Addr: ":8080", Handler: mux}
go srv.ListenAndServe()
// ... wait for signal ...
ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
defer cancel()
srv.Shutdown(ctx)

// ✅ Testing handler without server
req := httptest.NewRequest("GET", "/path", nil)
rr := httptest.NewRecorder()
handler(rr, req)
// Assert: rr.Code, rr.Body.String(), rr.Header()
```

