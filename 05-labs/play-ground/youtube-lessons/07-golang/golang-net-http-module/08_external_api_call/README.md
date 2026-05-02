# 🐱 Cat Fact API Service — Go for DevOps Engineers

> A beginner-friendly, production-aware Go microservice that fetches cat facts from an external API and serves them via a clean JSON endpoint.  
> 🎯 Perfect for learning Go HTTP patterns, error handling, and DevOps integration.

```
📦 Single binary • 🔄 JSON I/O • 🛡️ Explicit errors • 🚀 Ready for Kubernetes
```

---

## 🧭 Table of Contents

```markdown
1. 🎯 What This Service Does
2. 🗂️ Project Structure
3. 🧱 Code Walkthrough (Line-by-Line)
4. 🔌 How to Run It
5. 🧪 Testing the Endpoint
6. 🛠️ DevOps Integration Guide
7. 🚨 Error Handling & Observability
8. 🔄 Extending This Service
9. 📚 Glossary: Go Terms for DevOps
10. ✅ Quick Reference Cheat Sheet
```

---

## 1. 🎯 What This Service Does

```bash
# You hit this endpoint:
curl http://localhost:5000/external

# And get back structured JSON:
{
  "ok": true,
  "timestamp": "2024-01-15T10:30:00Z",
  "external": {
    "source": "Catfact.ninja",
    "fact": "Cats have over 20 vocalizations...",
    "length": 35
  }
}
```

### 🔁 Data Flow Diagram

```
[Your Curl/Client] 
       │
       ▼
[Go HTTP Server :5000] → /external endpoint
       │
       ▼
[fetchCatFact()] → https://catfact.ninja/fact
       │
       ▼
[JSON Unmarshal] → CatFactResponse struct
       │
       ▼
[writeJson()] → Structured JSON response back to you
```

> 💡 **DevOps Mental Model**: Think of this as a lightweight **API gateway pattern**—your service wraps an external dependency, adds observability (timestamp), and normalizes the response format.

---

## 2. 🗂️ Project Structure

```
cat-fact-service/
├── main.go          # All-in-one for learning (split in prod!)
├── go.mod           # Go module definition
├── README.md        # You are here 👋
├── Dockerfile       # (Optional) Containerize for deployment
└── k8s/             # (Optional) Kubernetes manifests
```

> ✅ **Best Practice**: In production, split `main.go` into packages: `handlers/`, `services/`, `models/`. But for learning? One file is perfect.

---

## 3. 🧱 Code Walkthrough (Newbie-Friendly)

### 🔹 The Imports: Your Toolbox

```go
import (
	"encoding/json"  // 🔄 JSON ↔ Go structs
	"fmt"            // 🖨️ Formatting & printing
	"io"             // 📥 Reading streams (like resp.Body)
	"net/http"       // 🌐 HTTP client & server
	"time"           // ⏰ Timestamps & timeouts
)
```

| Package | DevOps Analogy |
|---------|---------------|
| `encoding/json` | `jq` or `yq`—but type-safe & compile-time checked |
| `net/http` | `curl` + `netcat` + `nginx`—all in one stdlib |
| `time` | `date -u` + `sleep` + timeout logic |

---

### 🔹 The Struct: Your Data Contract

```go
type CatFactResponse struct{
	Fact   string `json:"fact"`
	Length int    `json:"length"`
}
```

#### 🏷️ Understanding Struct Tags
```go
`json:"fact"`  // Maps JSON key "fact" → Go field Fact
```

| JSON from API | Go Struct Field | Why This Matters |
|--------------|-----------------|-----------------|
| `"fact"` | `Fact string` | External API schema → internal type safety |
| `"length"` | `Length int` | Automatic type conversion (JSON number → Go int) |

> ⚠️ **Critical**: Fields must be **capitalized** (`Fact`, not `fact`) to be "exported"—otherwise `json.Unmarshal` can't set them!

---

### 🔹 Helper: `writeJson()` — Consistent API Responses

```go
func writeJson(w http.ResponseWriter, status int, data any) {
	w.Header().Set("Content-Type", "application/json")  // 🎯 Tell clients: "I speak JSON"
	w.WriteHeader(status)                                // 📡 Send HTTP status code
	
	_ = json.NewEncoder(w).Encode(data)                  // 🔄 Stream Go struct → JSON → HTTP response
}
```

#### 🧠 Why This Helper?
- ✅ **DRY Principle**: No repeating `Content-Type` headers everywhere
- ✅ **Streaming**: `json.NewEncoder(w)` writes directly to the response—no buffering entire JSON in memory
- ✅ **Type Flexibility**: `data any` (Go 1.18+) accepts structs, maps, slices—perfect for dynamic responses

#### 🔄 What `any` Means
```go
// Go 1.18+: `any` is an alias for `interface{}`
// It means: "I accept any type here"

// Examples:
writeJson(w, 200, map[string]any{"ok": true})           // ✅ Map
writeJson(w, 200, CatFactResponse{Fact: "Meow"})        // ✅ Struct
writeJson(w, 500, map[string]string{"error": "boom"})   // ✅ Different map type
```

> 🛠️ **DevOps Win**: Consistent JSON error formats make logging, monitoring, and alerting predictable.

---

### 🔹 Core Logic: `fetchCatFact()` — The External API Wrapper

```go
func fetchCatFact() (*CatFactResponse, error){
	url := "https://catfact.ninja/fact"
	
	// 1️⃣ Make the HTTP GET request
	resp, err := http.Get(url)
	if err != nil {
		return &CatFactResponse{}, err  // Return empty struct + error
	}
	defer resp.Body.Close()             // 🧹 Always clean up network resources
	
	// 2️⃣ Validate HTTP status
	if resp.StatusCode != http.StatusOK {
		return &CatFactResponse{}, fmt.Errorf("external API call failed")
	}
	
	// 3️⃣ Read response body
	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return &CatFactResponse{}, err
	}
	
	// 4️⃣ Parse JSON into our struct
	var data CatFactResponse
	if err := json.Unmarshal(bodyBytes, &data); err != nil {
		return &CatFactResponse{}, err
	}
	
	// 5️⃣ Success! Return pointer to populated struct
	return &data, nil
}
```

#### 🔍 Key Patterns Explained

| Pattern | Why It Matters | DevOps Analogy |
|---------|---------------|---------------|
| `return &CatFactResponse{}, err` | Always return same type signature—even on error | Like `exit 1` + logging in bash |
| `defer resp.Body.Close()` | Prevent connection leaks | Like `trap 'cleanup' EXIT` |
| `fmt.Errorf("...")` | Create descriptive errors | Like `echo "ERROR: ..." >&2` |
| `&data` (pointer) | Let caller access the populated struct | Like passing a file handle by reference in PowerShell |

#### 🧠 Why Return a Pointer `*CatFactResponse`?
```go
// Option A: Return value (copy)
func fetch() (CatFactResponse, error) { ... }
// → Every caller gets a copy. Fine for small structs.

// Option B: Return pointer (reference) ← We use this
func fetch() (*CatFactResponse, error) { ... }
// → More efficient for larger structs
// → Allows nil to represent "no data"
// → Consistent with Go convention for complex types
```

---

### 🔹 HTTP Handler: `externalHandler()` — The Router Logic

```go
func externalHandler(w http.ResponseWriter, r *http.Request) {
	// 🔐 Method validation: Only allow GET requests
	if r.Method != http.MethodGet {
		writeJson(w, http.StatusMethodNotAllowed, map[string]any{
			"ok": false,
			"error": "Method not allowed",
		})
		return  // ⚠️ Critical: Stop execution after sending response
	}
	
	// 🔄 Fetch data from external API
	data, err := fetchCatFact()
	if err != nil {
		// 🚨 Map internal error → user-friendly API error
		writeJson(w, http.StatusBadGateway, map[string]any{
			"ok": false,
			"error": "Failed to fetch cat fact",
		})
		return
	}
	
	// ✅ Success: Build enriched response
	writeJson(w, http.StatusOK, map[string]any{
		"ok" : true,
		"timestamp": time.Now().UTC(),  // 🕐 Observability: When did this happen?
		"external": map[string]any{     // 📦 Namespace external data
			"source": "Catfact.ninja",
			"fact": data.Fact,
			"length": data.Length,
		},
	})
}
```

#### 🎯 Why This Structure?

```go
map[string]any{
	"ok": true,                    // ✅ Quick health check for monitors
	"timestamp": time.Now().UTC(), // 📊 Essential for logging/alerting
	"external": { ... }            // 🔒 Isolate third-party data schema
}
```

| Field | DevOps Use Case |
|-------|----------------|
| `"ok"` | Prometheus probe: `curl -s ... | jq .ok` → `1` = healthy |
| `"timestamp"` | Log aggregation: correlate requests across services |
| `"external"` | Schema versioning: if catfact.ninja changes API, your contract stays stable |

> 🛡️ **Security Note**: Never expose raw external API errors to clients. We map `err` → generic `"Failed to fetch"` to avoid leaking internal details.

---

### 🔹 The Entry Point: `main()` — Start the Server

```go
func main() {
	// 🗺️ Register route: "/external" → externalHandler function
	http.HandleFunc("/external", externalHandler)
	
	// 🚀 Start listening on port 5000
	err := http.ListenAndServe(":5000", nil)
	
	// ⚠️ In production: use log.Fatal(err) for proper stderr logging
	fmt.Println(err)
}
```

#### 🔍 What `http.ListenAndServe` Does
```go
// Signature:
func ListenAndServe(addr string, handler Handler) error

// What happens:
// 1. Opens TCP socket on :5000
// 2. Accepts incoming connections
// 3. Spawns a goroutine per request (concurrency built-in!)
// 4. Routes /external → externalHandler
// 5. Blocks forever (or until error)
```

> 🧠 **Concurrency Bonus**: Go's HTTP server handles **thousands of concurrent requests** automatically—no thread pools, no async/await. Just write linear code.

---

## 4. 🔌 How to Run It

### 🖥️ Local Development

```bash
# 1. Ensure Go is installed (1.21+ recommended)
go version

# 2. Initialize module (if starting fresh)
go mod init cat-fact-service

# 3. Run the service
go run main.go

# 4. Test the endpoint
curl http://localhost:5000/external
```

### 🐳 Docker (Production-Ready)

```dockerfile
# Dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/server .
EXPOSE 5000
CMD ["./server"]
```

```bash
# Build & run
docker build -t cat-fact-service .
docker run -p 5000:5000 cat-fact-service
```

> ✅ **Why Multi-Stage?** Smaller image (~10MB vs ~800MB), no build tools in runtime, improved security.

---

## 5. 🧪 Testing the Endpoint

### 🔹 Basic Curl Tests

```bash
# ✅ Success case
$ curl -s http://localhost:5000/external | jq
{
  "ok": true,
  "timestamp": "2024-01-15T10:30:00.123456Z",
  "external": {
    "source": "Catfact.ninja",
    "fact": "Cats make about 100 different sounds...",
    "length": 42
  }
}

# ❌ Method not allowed
$ curl -X POST http://localhost:5000/external
{"ok":false,"error":"Method not allowed"}

# 🌐 Simulate external API failure (block the domain)
$ curl --interface 127.0.0.1 http://localhost:5000/external
{"ok":false,"error":"Failed to fetch cat fact"}
```

### 🔹 Health Check for Kubernetes

```yaml
# k8s/deployment.yaml snippet
livenessProbe:
  httpGet:
    path: /external
    port: 5000
  initialDelaySeconds: 5
  periodSeconds: 10
```

> 💡 **Pro Tip**: Add a dedicated `/health` endpoint that returns `200 OK` without external dependencies for more reliable probes.

---

## 6. 🛠️ DevOps Integration Guide

### 🔹 Logging & Observability

```go
// Add structured logging (example with log/slog - Go 1.21+)
import "log/slog"

func externalHandler(w http.ResponseWriter, r *http.Request) {
	start := time.Now()
	
	// Log request start
	slog.Info("request_started", "method", r.Method, "path", r.URL.Path)
	
	// ... existing logic ...
	
	// Log completion
	slog.Info("request_completed", 
		"duration_ms", time.Since(start).Milliseconds(),
		"status", "success") // or "error"
}
```

#### 📊 Prometheus Metrics (Bonus)
```go
import "github.com/prometheus/client_golang/prometheus/promhttp"

func main() {
	http.HandleFunc("/external", externalHandler)
	
	// 📈 Expose metrics endpoint
	http.Handle("/metrics", promhttp.Handler())
	
	http.ListenAndServe(":5000", nil)
}
```

```bash
# Scrape metrics
curl http://localhost:5000/metrics

# Example metric to add:
var requestCount = prometheus.NewCounterVec(
	prometheus.CounterOpts{Name: "catfact_requests_total"},
	[]string{"status"},
)
```

---

### 🔹 Environment Configuration

```go
// Add config struct
type Config struct {
	Port         string        `env:"PORT" envDefault:"5000"`
	Timeout      time.Duration `env:"API_TIMEOUT" envDefault:"10s"`
	ExternalURL  string        `env:"CATFACT_URL" envDefault:"https://catfact.ninja/fact"`
}

// Load with github.com/caarlos0/env/v6
var cfg Config
env.Parse(&cfg)

// Use in fetchCatFact:
ctx, cancel := context.WithTimeout(context.Background(), cfg.Timeout)
defer cancel()
req, _ := http.NewRequestWithContext(ctx, "GET", cfg.ExternalURL, nil)
resp, err := http.DefaultClient.Do(req)
```

> 🎯 **Why?** Makes your service configurable without code changes—essential for staging vs prod.

---

### 🔹 Error Classification for Alerting

```go
// Define error types for better monitoring
var (
	ErrExternalAPI = errors.New("external API failure")
	ErrJSONParse   = errors.New("JSON parsing failed")
)

// In fetchCatFact:
if resp.StatusCode != http.StatusOK {
	return nil, fmt.Errorf("%w: status %d", ErrExternalAPI, resp.StatusCode)
}

// In handler: check error type
if errors.Is(err, ErrExternalAPI) {
	// 🚨 Alert: third-party dependency down
	metrics.ExternalAPIErrors.Inc()
	writeJson(w, http.StatusBadGateway, ...)
}
```

---

## 7. 🚨 Error Handling & Observability

### 🔹 Error Strategy Table

| Error Type | HTTP Status | Log Level | Alert? | Why |
|------------|-------------|-----------|--------|-----|
| Network timeout | 504 Gateway Timeout | ERROR | ✅ Yes | External dependency failure |
| JSON parse error | 500 Internal Error | ERROR | ⚠️ Maybe | Bug in our code or API changed |
| Method not allowed | 405 Method Not Allowed | WARN | ❌ No | Client error, not our fault |
| Context canceled | 499 Client Closed Request | INFO | ❌ No | Expected in load balancers |

### 🔹 Structured Logging Example

```go
// Instead of fmt.Println:
slog.Error("fetch_catfact_failed",
	"error", err,
	"url", url,
	"status_code", resp.StatusCode,
	"trace_id", r.Header.Get("X-Trace-ID")) // Propagate distributed tracing
```

> 🌐 **Distributed Tracing**: Add `X-Trace-ID` header propagation to correlate logs across microservices.

---

## 8. 🔄 Extending This Service

### 🔹 Add Caching (Reduce External Calls)

```go
var (
	cache     = make(map[string]*CatFactResponse)
	cacheMux  sync.RWMutex
	cacheTTL  = 5 * time.Minute
)

func fetchCatFact() (*CatFactResponse, error) {
	// Check cache first
	cacheMux.RLock()
	if cached, ok := cache["latest"]; ok && time.Since(cachedAt) < cacheTTL {
		cacheMux.RUnlock()
		return cached, nil
	}
	cacheMux.RUnlock()
	
	// ... fetch from API ...
	
	// Update cache
	cacheMux.Lock()
	cache["latest"] = &data
	cacheMux.Unlock()
	
	return &data, nil
}
```

> 🚀 **DevOps Impact**: Reduces API rate limits, improves latency, lowers cost.

---

### 🔹 Add Request Timeout & Retry

```go
func fetchCatFactWithRetry(ctx context.Context) (*CatFactResponse, error) {
	for attempt := 1; attempt <= 3; attempt++ {
		reqCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
		
		resp, err := http.DefaultClient.Do(
			http.NewRequestWithContext(reqCtx, "GET", url, nil))
		
		cancel() // Always clean up context
		
		if err == nil && resp.StatusCode == http.StatusOK {
			// ... parse and return ...
		}
		
		// Exponential backoff before retry
		time.Sleep(time.Duration(attempt) * time.Second)
	}
	return nil, fmt.Errorf("all retry attempts failed")
}
```

---

### 🔹 Add Authentication (For Internal Services)

```go
func requireAPIKey(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		key := r.Header.Get("X-API-Key")
		if key != os.Getenv("EXPECTED_API_KEY") {
			writeJson(w, http.StatusUnauthorized, map[string]any{
				"ok": false, "error": "invalid API key",
			})
			return
		}
		next(w, r)
	}
}

// In main():
http.HandleFunc("/external", requireAPIKey(externalHandler))
```

---

## 9. 📚 Glossary: Go Terms for DevOps Engineers

| Go Term | Plain English | DevOps Analogy |
|---------|--------------|----------------|
| `struct` | Data blueprint | YAML/JSON schema for your app |
| `json:"tag"` | Field mapping rule | `jq` filter or `yq` path |
| `*Type` (pointer) | Reference to data | File descriptor or socket handle |
| `defer` | Schedule cleanup | `trap 'cleanup' EXIT` in bash |
| `any` (interface{}) | "Any type" placeholder | Dynamic config value |
| `goroutine` | Lightweight thread | Async worker process |
| `http.ResponseWriter` | Outgoing HTTP stream | `echo` to stdout in CGI script |
| `context.Context` | Request lifecycle token | Timeout/cancellation signal |

---

## 10. ✅ Quick Reference Cheat Sheet

### 🔹 Common HTTP Status Codes in Go
```go
http.StatusOK          // 200
http.StatusCreated     // 201
http.StatusBadRequest  // 400
http.StatusUnauthorized // 401
http.StatusNotFound    // 404
http.StatusMethodNotAllowed // 405
http.StatusInternalServerError // 500
http.StatusBadGateway  // 502 (perfect for external API failures)
```

### 🔹 JSON Patterns
```go
// Marshal: Go → JSON
jsonBytes, _ := json.Marshal(myStruct)

// Unmarshal: JSON → Go
json.Unmarshal(jsonBytes, &myStruct)

// Stream encode (memory efficient)
json.NewEncoder(w).Encode(myStruct)

// Stream decode (for large payloads)
json.NewDecoder(r.Body).Decode(&myStruct)
```

### 🔹 Error Handling Idioms
```go
// Basic check
if err != nil {
	return nil, err
}

// Wrap with context
if err != nil {
	return nil, fmt.Errorf("fetch failed: %w", err)
}

// Check error type
if errors.Is(err, ErrExternalAPI) {
	// handle specific case
}
```

### 🔹 Testing Checklist
- [ ] Does `GET /external` return 200 + valid JSON?
- [ ] Does `POST /external` return 405?
- [ ] Does external API failure return 502 (not 500)?
- [ ] Is `Content-Type: application/json` always set?
- [ ] Are timestamps in UTC ISO 8601 format?

---

## 🎓 Final Thought: Why This Pattern Matters

This service demonstrates **production-ready Go patterns** in a tiny package:

✅ **Explicit over magical** — Every error path is visible  
✅ **Composable** — `fetchCatFact()` can be tested/reused independently  
✅ **Observable** — Timestamps, structured errors, ready for metrics  
✅ **Deployable** — Single binary, no runtime dependencies  

> 🌱 **Your Next Challenge**:  
> 1. Add a `/health` endpoint that doesn't call external APIs  
> 2. Instrument request duration with Prometheus  
> 3. Containerize and deploy to a local Kubernetes cluster (kind/minikube)  
> 4. Write a unit test for `fetchCatFact()` using `httptest.Server`  

You're not just learning Go—you're building **reliable infrastructure tooling**. And that's a superpower. 💪

---

> 📬 **Found a typo? Want an example in Python/PowerShell for comparison?**  
> Open an issue or DM me. Let's learn together. 🤝

*Built with ❤️ for DevOps engineers learning Go — by Ganil* 🐱⚡