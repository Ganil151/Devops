# 📝 Notes API — Go + Gin + MongoDB for DevOps Engineers

> A production-ready, beginner-friendly REST API built with Go, Gin, and MongoDB.  
> 🎯 Perfect for learning CRUD patterns, clean architecture, and DevOps integration.

```
🚀 Gin HTTP Framework • 🗄️ MongoDB Driver • 🔐 Config via .env • 🔄 Hot Reload with air
```

---

## 🧭 Table of Contents

```markdown
1. 🎯 What This Project Does
2. 📦 Prerequisites & Setup
3. 🗂️ Project Structure Explained
4. 🔧 Environment Configuration (.env)
5. 🧱 Core Concepts: CRUD, Gin, MongoDB
6. 🧠 Deep Dive: Context.Context in Go
7. 🔄 JSON vs BSON: What DevOps Engineers Need to Know
8. 🚀 How to Run & Test Locally
9. 🧪 API Endpoint Reference
10. 🛠️ DevOps Integration Guide
11. 🚨 Troubleshooting Checklist
12. 📚 Glossary: Go Terms for DevOps
13. ✅ Quick Reference Cheat Sheet
```

---

## 1. 🎯 What This Project Does

This is a **Notes API** that lets you:

```bash
# Create a new note
POST   /notes     → {"title": "My Note", "content": "..."}

# List all notes
GET    /notes     → [{"id": "...", "title": "...", ...}]

# Get one note by ID
GET    /notes/:id → {"id": "...", "title": "...", ...}

# Update a note
PUT    /notes/:id → {"title": "Updated", "content": "..."}

# Delete a note
DELETE /notes/:id → {"message": "Note deleted"}
```

### 🔁 Data Flow Diagram

```
[HTTP Request]
       │
       ▼
[Gin Router] → /notes/:id → note_handler.go
       │
       ▼
[Handler] → Validate input → Call Repository
       │
       ▼
[Repository] → MongoDB Query (with Context)
       │
       ▼
[Database] → Return BSON → Unmarshal to Go Struct
       │
       ▼
[Handler] → Marshal to JSON → HTTP Response
```

> 💡 **DevOps Mental Model**: Think of this as a **microservice template**—swap "notes" for "deployments", "configs", or "alerts", and you've got the foundation for internal tooling.

---

## 2. 📦 Prerequisites & Setup

### 🔹 Install Go (1.21+ Recommended)

```bash
# Verify installation
go version  # → go version go1.21.0 linux/amd64

# Set GOPATH if needed (usually not required with modules)
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

### 🔹 Install MongoDB

```bash
# Docker (Recommended for DevOps)
docker run -d \
  -p 8080:8080 \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=secret \
  --name mongo \
  mongo:7

# Or native install: https://www.mongodb.com/docs/manual/installation/
```

### 🔹 Install Project Dependencies

```bash
# Navigate to project root
cd notes-api

# Install Go packages (as listed in your prompt)
go get github.com/gin-gonic/gin@latest
go get github.com/joho/godotenv
go get go.mongodb.org/mongo-driver/mongo
go get go.mongodb.org/mongo-driver/v2

# Install air for hot-reload development
go install github.com/air-verse/air@latest
```

> ✅ **Why These Packages?**

| Package         | Purpose                         | DevOps Analogy                               |
| --------------- | ------------------------------- | -------------------------------------------- |
| `gin-gonic/gin` | High-performance HTTP framework | Like Flask/FastAPI but compiled & concurrent |
| `joho/godotenv` | Load `.env` config files        | Like `source .env` in bash                   |
| `mongo-driver`  | Official MongoDB client         | Like `pymongo` or `mongosh` but type-safe    |
| `air`           | Hot-reload file watcher         | Like `nodemon` or `systemd --watch`          |

---

## 3. 🗂️ Project Structure Explained

```
.
├── cmd
│   └── api
│       └── main.go          # 🚀 Entry point: wires config, DB, router
├── go.mod                   # 📦 Go module definition + dependencies
├── go.sum                   # 🔐 Checksums for dependency integrity
├── internal                 # 🔒 Private application code (not importable externally)
│   ├── config
│   │   └── config.go        # ⚙️ Load & validate .env config
│   ├── db
│   │   └── mongo.go         # 🔌 MongoDB connection logic
│   └── server
│       └── router.go        # 🗺️ Gin router setup + middleware
├── notes                    # 📝 Feature module: all note-related logic
│   ├── note_handler.go      # 🎯 HTTP handlers: parse request → call repo → respond
│   ├── note_model.go        # 🧱 Data models: Go structs with JSON/BSON tags
│   ├── note_repo.go         # 🗄️ Database operations: CRUD queries
│   └── note_routes.go       # 🔗 Route definitions: map URLs to handlers
├── README.md                # 📖 You are here!
└── tmp                      # 🗑️ Build artifacts from air (safe to ignore)
    ├── api.exe
    └── build-errors.log
```

### 🔹 Why This Structure? (Clean Architecture Lite)

| Directory   | Responsibility           | DevOps Benefit                                                          |
| ----------- | ------------------------ | ----------------------------------------------------------------------- |
| `cmd/api`   | Application composition  | Easy to swap main.go for different deploy targets (CLI, server, worker) |
| `internal/` | Business logic           | Prevents accidental external imports; enforces boundaries               |
| `notes/`    | Feature isolation        | Add `deployments/`, `alerts/` modules without tangled code              |
| `config/`   | Configuration management | Single source of truth for env vars; testable config loading            |

> 🧠 **Analogy**: Think of `internal/` as your `src/` in a Docker build—only what's needed gets exposed.

---

## 4. 🔧 Environment Configuration (.env)

### 🔹 Create `.env` in Project Root

```env
# Server Configuration
SERVER_PORT=8080
SERVER_MODE=debug  # debug, release, or test

# MongoDB Configuration
MONGODB_URI=mongodb://admin:secret@localhost:27017
MONGODB_DATABASE=notes_db
MONGODB_COLLECTION=notes

# Optional: Connection Pool Settings
MONGODB_MIN_POOL_SIZE=5
MONGODB_MAX_POOL_SIZE=20
MONGODB_TIMEOUT_SECONDS=30
```

### 🔹 Load .env in Code (`internal/config/config.go`)

```go
package config

import (
	"github.com/joho/godotenv"
	"os"
)

type Config struct {
	ServerPort string
	ServerMode string
	MongoURI   string
	MongoDB    string
	MongoColl  string
}

func Load() (*Config, error) {
	// Load .env file (silently ignore if not found in prod)
	_ = godotenv.Load()

	cfg := &Config{
		ServerPort: getEnv("SERVER_PORT", "8080"),
		ServerMode: getEnv("SERVER_MODE", "release"),
		MongoURI:   getEnv("MONGODB_URI", "mongodb://localhost:27017"),
		MongoDB:    getEnv("MONGODB_DATABASE", "notes_db"),
		MongoColl:  getEnv("MONGODB_COLLECTION", "notes"),
	}

	// Validate required fields
	if cfg.MongoURI == "" {
		return nil, fmt.Errorf("MONGODB_URI is required")
	}

	return cfg, nil
}

func getEnv(key, defaultVal string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return defaultVal
}
```

🛡️ **Security Note**: Never commit `.env` to version control! Add to `.gitignore`:
```gitignore
.env
*.log
tmp/
```

## 5. 🧱 Core Concepts: CRUD, Gin, MongoDB

### 🔹 CRUD Operations Explained

| Operation      | HTTP Method | Endpoint     | MongoDB Action | Go Function     |
| -------------- | ----------- | ------------ | -------------- | --------------- |
| **C**reate     | `POST`      | `/notes`     | `InsertOne()`  | `CreateNote()`  |
| **R**ead (all) | `GET`       | `/notes`     | `Find()`       | `ListNotes()`   |
| **R**ead (one) | `GET`       | `/notes/:id` | `FindOne()`    | `GetNoteByID()` |
| **U**pdate     | `PUT`       | `/notes/:id` | `UpdateOne()`  | `UpdateNote()`  |
| **D**elete     | `DELETE`    | `/notes/:id` | `DeleteOne()`  | `DeleteNote()`  |

> 💡 **DevOps Analogy**: CRUD is like `kubectl` verbs:  
> `create` → `apply`, `read` → `get`, `update` → `patch`, `delete` → `delete`

---

### 🔹 Gin Web Framework: Why DevOps Engineers Love It

```go
// internal/server/router.go
func NewRouter(db *mongo.Database) *gin.Engine {
	r := gin.Default()  // Logger + Recovery middleware built-in

	// Health check endpoint (critical for K8s probes!)
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "timestamp": time.Now().UTC()})
	})

	// Register note routes
	notes.RegisterRoutes(r.Group("/notes"), db)

	return r
}
```

#### 🎯 Gin Features That Matter for DevOps

| Feature                  | Benefit                                      | Example Use Case                        |
| ------------------------ | -------------------------------------------- | --------------------------------------- |
| **Middleware**           | Cross-cutting concerns (logging, auth, CORS) | Add Prometheus metrics to every request |
| **Binding & Validation** | Auto-parse JSON → struct + validate          | Reject invalid note payloads with 400   |
| **Context Integration**  | Request lifecycle management                 | Cancel DB query if client disconnects   |
| **Test Helpers**         | `gin.CreateTestContext()`                    | Unit test handlers without HTTP server  |
| **Performance**          | Radix tree router + sync.Pool                | Handle 10k+ RPS on modest hardware      |

#### 🔄 Example: Middleware for Logging

```go
// Add to router setup
r.Use(gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
	return fmt.Sprintf("[API] %s %s %d %v\n",
		param.Method, param.Path, param.StatusCode, param.Latency)
}))
```

 📊 **Output**: `[API] POST /notes 201 12.345ms` — perfect for log aggregation (Loki, CloudWatch).

---

### 🔹 MongoDB Integration: Connection & CRUD

#### 🔌 Connecting to MongoDB (`internal/db/mongo.go`)

```go
func Connect(cfg config.Config) (*mongo.Client, *mongo.Database, error) {
	ctx, cancel := context.WithTimeout(context.Background(),
		time.Duration(30)*time.Second)
	defer cancel()

	clientOpts := options.Client().ApplyURI(cfg.MongoURI)
	client, err := mongo.Connect(ctx, clientOpts)
	if err != nil {
		return nil, nil, fmt.Errorf("mongo connect: %w", err)
	}

	// Ping to verify connection
	if err := client.Ping(ctx, nil); err != nil {
		return nil, nil, fmt.Errorf("mongo ping: %w", err)
	}

	db := client.Database(cfg.MongoDB)
	return client, db, nil
}

func Disconnect(client *mongo.Client) error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	return client.Disconnect(ctx)
}
```

#### 🧱 Note Model (`notes/note_model.go`)

```go
type Note struct {
	ID        primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	Title     string             `bson:"title" json:"title" binding:"required"`
	Content   string             `bson:"content" json:"content" binding:"required"`
	CreatedAt time.Time          `bson:"created_at" json:"created_at"`
	UpdatedAt time.Time          `bson:"updated_at" json:"updated_at"`
}
```

 🔑 **Key Tags Explained**:
 - `bson:"..."` → MongoDB field mapping
 - `json:"..."` → HTTP JSON mapping
 - `binding:"required"` → Gin validation rule

#### 🗄️ Repository Pattern (`notes/note_repo.go`)
```go
func (r *NoteRepo) Create(ctx context.Context, note *Note) error {
	note.CreatedAt = time.Now().UTC()
	note.UpdatedAt = note.CreatedAt

	// If no ID, generate one
	if note.ID.IsZero() {
		note.ID = primitive.NewObjectID()
	}

	_, err := r.collection.InsertOne(ctx, note)
	return err
}

func (r *NoteRepo) FindByID(ctx context.Context, id string) (*Note, error) {
	objID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return nil, err
	}

	var note Note
	err = r.collection.FindOne(ctx, bson.M{"_id": objID}).Decode(&note)
	return &note, err
}
```

 🧠 **Why Repository Pattern?**
 - Decouples HTTP layer from database logic
 - Easy to mock for testing
 - Swap MongoDB for PostgreSQL later without touching handlers

---

## 6. 🧠 Deep Dive: Context.Context in Go

### 🔹 What Is `context.Context`?

> `context.Context` is Go's standard way to carry **deadlines, cancellation signals, and request-scoped values** across API boundaries.

### 🔹 Why DevOps Engineers Care

| Use Case                | How Context Helps                            | Example                                                   |
| ----------------------- | -------------------------------------------- | --------------------------------------------------------- |
| **Request Timeouts**    | Cancel slow DB queries automatically         | `ctx, cancel := context.WithTimeout(..., 5*time.Second)`  |
| **Graceful Shutdown**   | Stop processing when server receives SIGTERM | `ctx, cancel := context.WithCancel(context.Background())` |
| **Distributed Tracing** | Propagate trace IDs across services          | `ctx = context.WithValue(ctx, "trace_id", "abc123")`      |
| **Resource Cleanup**    | Ensure DB connections close even on error    | `defer cancel()` after `context.WithTimeout`              |

### 🔹 Practical Example in Our Code

```go
// In note_handler.go
func (h *NoteHandler) GetNote(c *gin.Context) {
	// 🎯 Gin's request context → convert to standard context
	ctx := c.Request.Context()

	id := c.Param("id")

	// 🔌 Pass ctx to repository: DB query respects cancellation
	note, err := h.repo.FindByID(ctx, id)
	if err != nil {
		c.JSON(404, gin.H{"error": "not found"})
		return
	}

	c.JSON(200, note)
}
```

#### 🔄 What Happens If Client Disconnects?

```
1. Client closes connection (e.g., timeout, user navigates away)
2. Gin detects disconnect → cancels c.Request.Context()
3. MongoDB driver receives ctx.Done() signal
4. Query stops immediately → frees DB resources
5. Handler returns early → no wasted CPU
```

> 🛡️ **DevOps Win**: Prevents "zombie queries" that exhaust database connections during traffic spikes.

### 🔹 Common Context Patterns
```go
// ✅ Timeout for external API call
ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
defer cancel()
resp, err := http.GetWithContext(ctx, url)

// ✅ Cancellation for graceful shutdown
ctx, cancel := context.WithCancel(context.Background())
// Later, on SIGTERM:
cancel()  // All ctx.Done() listeners stop

// ✅ Request-scoped value (use sparingly!)
ctx = context.WithValue(ctx, "user_id", "ganil151")
// Retrieve later:
if uid, ok := ctx.Value("user_id").(string); ok { ... }
```

> ⚠️ **Warning**: Never store critical data in `context.WithValue`—it's for optional metadata only. Use structs for required data.

---

## 7. 🔄 JSON vs BSON: What DevOps Engineers Need to Know

### 🔹 The Short Answer

| Format   | Full Name                  | Used For                          | Go Package                         |
| -------- | -------------------------- | --------------------------------- | ---------------------------------- |
| **JSON** | JavaScript Object Notation | HTTP APIs, config files           | `encoding/json`                    |
| **BSON** | Binary JSON                | MongoDB storage, internal queries | `go.mongodb.org/mongo-driver/bson` |

### 🔹 Why Both? The Data Journey
```
[HTTP Request]
       │
       ▼
JSON: {"title": "Deploy Plan", "content": "Step 1..."}
       │
       ▼
Gin binds JSON → Go struct (using `json:"..."` tags)
       │
       ▼
Repository converts struct → BSON (using `bson:"..."` tags)
       │
       ▼
MongoDB stores BSON document
       │
       ▼
[Response Flow Reverse]: BSON → Go struct → JSON → HTTP
```

### 🔹 Struct Tags: The Translation Layer
```go
type Note struct {
	ID        primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	//          │                    │
	//          │                    └─ HTTP: "id" (clean, no underscore)
	//          └─ MongoDB: "_id" (required), omit if zero value
}
```

#### 🧠 Key Differences

| Feature          | JSON Tag            | BSON Tag            | Why It Matters                                  |
| ---------------- | ------------------- | ------------------- | ----------------------------------------------- |
| **Field Name**   | `json:"user_name"`  | `bson:"user_name"`  | MongoDB uses underscores; APIs prefer camelCase |
| **Omit Empty**   | `json:",omitempty"` | `bson:",omitempty"` | Avoid storing null fields in DB                 |
| **ID Field**     | `json:"id"`         | `bson:"_id"`        | MongoDB requires `_id`; clients prefer `id`     |
| **Custom Types** | `json:"created_at"` | `bson:"created_at"` | `time.Time` serializes differently in each      |

### 🔹 Practical Example: Dual-Tag Struct
```go
type Deployment struct {
	ID          string    `bson:"_id,omitempty" json:"id"`
	ServiceName string    `bson:"service_name" json:"serviceName" binding:"required"`
	Version     string    `bson:"version" json:"version"`
	Status      string    `bson:"status" json:"status"` // "pending", "running", "failed"
	LogsURL     *string   `bson:"logs_url,omitempty" json:"logsUrl,omitempty"` // Pointer = optional
	CreatedAt   time.Time `bson:"created_at" json:"createdAt"`
}
```

> ✅ **DevOps Tip**: Use pointers (`*string`, `*int`) for optional fields—lets you distinguish "not set" vs "empty string".

### 🔹 When to Use `bson.M` (Dynamic Queries)
```go
// Static query (type-safe)
filter := bson.M{"status": "running"}

// Dynamic query (flexible)
filter := bson.M{}
if serviceName != "" {
	filter["service_name"] = serviceName
}
if since != nil {
	filter["created_at"] = bson.M{"$gte": since}
}

// Use in Find()
cursor, err := collection.Find(ctx, filter)
```

> 🎯 **Use Case**: Building admin dashboards where filters are user-defined.

---

## 8. 🚀 How to Run & Test Locally

### 🔹 Start MongoDB (Docker)

```bash
docker run -d \
  -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=secret \
  --name mongo-notes \
  mongo:7
```

### 🔹 Configure `.env` (See Section 4)

### 🔹 Run with Hot-Reload (Development)

```bash
# Start air watcher
air

# Or run directly
go run cmd/api/main.go
```

 ✅ **Expected Output**:
 ```bash
 [GIN-debug] [WARNING] Running in "debug" mode...
 [GIN-debug] GET    /health                   --> notes-api/internal/server.NewRouter.func1 (4 handlers)
 [GIN-debug] POST   /notes                    --> notes-api/notes.NoteHandler.CreateNote-fm (4 handlers)
 ...
 [GIN] 2024/01/15 - 10:30:00 | 200 |     12.345µs |       127.0.0.1 | GET      "/health"
 ```
### 🔹 Run in Production Mode
```bash
# Set environment
export SERVER_MODE=release
export GIN_MODE=release

# Build optimized binary
go build -o bin/api cmd/api/main.go

# Run
./bin/api
```

 🛡️ **Production Checklist**:
 - [ ] `SERVER_MODE=release` (disables Gin debug logs)
 - [ ] MongoDB credentials via secrets manager (not `.env`)
 - [ ] Health endpoint (`/health`) for K8s probes
 - [ ] Structured logging (replace `log.Printf` with `slog` or `zap`)

---

## 9. 🧪 API Endpoint Reference

### 🔹 Health Check

```bash
GET /health
```

```json
{
	"status": "ok",
	"timestamp": "2024-01-15T10:30:00Z"
}
```

### 🔹 Create Note
```bash
POST /notes
Content-Type: application/json

{
  "title": "Deploy Checklist",
  "content": "1. Run tests\n2. Build image\n3. Update K8s manifest"
}
```

```json
{
	"id": "65a1b2c3d4e5f6789012345",
	"title": "Deploy Checklist",
	"content": "1. Run tests\n2. Build image\n3. Update K8s manifest",
	"created_at": "2024-01-15T10:30:00Z",
	"updated_at": "2024-01-15T10:30:00Z"
}
```

### 🔹 List Notes

```bash
GET /notes?page=1&limit=10
```

```json
[
	{
		"id": "65a1b2c3d4e5f6789012345",
		"title": "Deploy Checklist",
		"content": "...",
		"created_at": "...",
		"updated_at": "..."
	}
]
```

### 🔹 Get Note by ID
```bash
GET /notes/65a1b2c3d4e5f6789012345
```

### 🔹 Update Note
```bash
PUT /notes/65a1b2c3d4e5f6789012345
Content-Type: application/json

{
  "title": "Updated Deploy Checklist",
  "content": "1. Run tests\n2. Scan image\n3. Canary deploy"
}
```

### 🔹 Delete Note
```bash
DELETE /notes/65a1b2c3d4e5f6789012345
```

```json
{
	"message": "Note deleted successfully"
}
```

---

## 10. 🛠️ DevOps Integration Guide

### 🔹 Kubernetes Deployment Snippet
```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: notes-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: notes-api
  template:
    metadata:
      labels:
        app: notes-api
    spec:
      containers:
        - name: api
          image: your-registry/notes-api:v1.2.3
          ports:
            - containerPort: 8080
          env:
            - name: SERVER_MODE
              value: 'release'
            - name: MONGODB_URI
              valueFrom:
                secretKeyRef:
                  name: mongo-secret
                  key: uri
          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 10
            periodSeconds: 15
          readinessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
```
### 🔹 Prometheus Metrics (Add to Router)
```go
import "github.com/prometheus/client_golang/prometheus/promhttp"

func NewRouter(db *mongo.Database) *gin.Engine {
	r := gin.Default()

	// 📈 Expose metrics endpoint
	r.GET("/metrics", gin.WrapH(promhttp.Handler()))

	// ... other routes
	return r
}
```

```bash
# Scrape metrics
curl http://localhost:8080/metrics

# Example metric to add in handlers:
var requestDuration = prometheus.NewHistogramVec(
	prometheus.HistogramOpts{Name: "notes_api_request_duration_seconds"},
	[]string{"endpoint", "method", "status"},
)
```

### 🔹 Structured Logging (Go 1.21+ `log/slog`)

```go
import "log/slog"

func (h *NoteHandler) CreateNote(c *gin.Context) {
	logger := slog.With("trace_id", c.GetHeader("X-Trace-ID"))

	var note Note
	if err := c.ShouldBindJSON(&note); err != nil {
		logger.Warn("invalid request", "error", err)
		c.JSON(400, gin.H{"error": "invalid payload"})
		return
	}

	logger.Info("creating note", "title", note.Title)
	// ... rest of logic
}
```

> 📊 **Output**: `time=2024-01-15T10:30:00Z level=INFO msg="creating note" trace_id=abc123 title="Deploy Plan"`

### 🔹 Dockerfile (Multi-Stage Build)

```dockerfile
# Build stage
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o api cmd/api/main.go

# Runtime stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates tzdata
WORKDIR /root/
COPY --from=builder /app/api .
COPY .env .  # Or mount via Kubernetes ConfigMap
EXPOSE 8080
USER nobody  # Run as non-root for security
CMD ["./api"]
```

---

## 11. 🚨 Troubleshooting Checklist

| Symptom                         | Likely Cause                          | Fix                                                         |
| ------------------------------- | ------------------------------------- | ----------------------------------------------------------- |
| `mongo: no reachable servers`   | MongoDB not running or wrong URI      | `docker ps \| grep mongo`; check `.env`                     |
| `duplicate key error`           | Trying to insert duplicate `_id`      | Let MongoDB generate ID (`omitempty`)                       |
| `binding: required` error       | Missing field in JSON payload         | Check `binding:"required"` tags; validate client request    |
| `context deadline exceeded`     | DB query too slow or network issue    | Increase timeout in `Connect()`; check MongoDB logs         |
| `air: command not found`        | `go install` didn't add to PATH       | Add `export PATH=$PATH:$(go env GOPATH)/bin` to `~/.bashrc` |
| `panic: server failed`          | Port already in use                   | `lsof -i :8080`; change `SERVER_PORT` in `.env`             |
| JSON fields missing in response | Struct field not exported (lowercase) | Ensure fields are `Title` not `title`                       |

### 🔹 Debug MongoDB Connection

```bash
# Test connection manually
mongosh "mongodb://admin:secret@localhost:27017/notes_db" --eval "db.notes.countDocuments({})"

# Check MongoDB logs
docker logs mongo-notes
```

### 🔹 Enable Gin Debug Logs

```go
// In main.go or router setup
gin.SetMode(gin.DebugMode)  // Forces verbose logging
```

---

## 12. 📚 Glossary: Go Terms for DevOps Engineers

| Go Term               | Plain English                   | DevOps Analogy                              |
| --------------------- | ------------------------------- | ------------------------------------------- |
| `context.Context`     | Request lifecycle token         | Kubernetes `context` or `--timeout` flag    |
| `bson.M`              | Dynamic map for MongoDB queries | `jq` filter or `yq` expression              |
| `primitive.ObjectID`  | MongoDB's 12-byte unique ID     | Like Kubernetes `uid` or AWS `request-id`   |
| `binding:"required"`  | Gin validation rule             | Like OpenAPI `required: [field]`            |
| `middleware`          | Function that wraps handlers    | Like nginx `proxy_pass` + logging           |
| `goroutine`           | Lightweight concurrent thread   | Like async worker in Celery or Sidekiq      |
| `interface{}` / `any` | "Any type" placeholder          | Like `dynamic` in C# or `Any` in TypeScript |
| `defer`               | Schedule cleanup function       | Like `trap 'cleanup' EXIT` in bash          |

---

## 13. ✅ Quick Reference Cheat Sheet

### 🔹 Common Gin Patterns

```go
// Get path parameter
id := c.Param("id")  // /notes/:id → "65a1b2c3..."

// Get query parameter
page := c.DefaultQuery("page", "1")  // ?page=2 → "2"

// Bind JSON to struct
var note Note
if err := c.ShouldBindJSON(&note); err != nil {
	c.JSON(400, gin.H{"error": err.Error()})
	return
}

// Return JSON response
c.JSON(201, note)  // Status + body in one call
```

### 🔹 MongoDB Query Patterns

```go
// Find one
var note Note
err := collection.FindOne(ctx, bson.M{"_id": objID}).Decode(&note)

// Find many
cursor, err := collection.Find(ctx, bson.M{"status": "active"})
var notes []Note
cursor.All(ctx, &notes)

// Update
_, err := collection.UpdateOne(
	ctx,
	bson.M{"_id": objID},
	bson.M{"$set": bson.M{"updated_at": time.Now()}},
)

// Delete
_, err := collection.DeleteOne(ctx, bson.M{"_id": objID})
```

### 🔹 Context Patterns

```go
// Timeout
ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
defer cancel()

// Cancellation
ctx, cancel := context.WithCancel(context.Background())
// Later: cancel()

// With value (use sparingly)
ctx = context.WithValue(ctx, "user", "ganil151")
```

### 🔹 Testing Checklist

- [ ] `GET /health` returns 200 + JSON
- [ ] `POST /notes` with valid JSON → 201 + ID
- [ ] `POST /notes` with missing `title` → 400
- [ ] `GET /notes/:invalid-id` → 400 (not 500)
- [ ] MongoDB connection fails gracefully (check logs)
- [ ] `/metrics` endpoint exposes Prometheus format

---

## 💬 Final Thought: You're Building Infrastructure Tooling

> 🔁 **Remember**: This Notes API isn't just about notes.  
> Swap `Note` for `Deployment`, `Alert`, `ConfigMap`, or `Secret`, and you've got the foundation for:
>
> - Internal developer portals
> - GitOps control planes
> - Self-service infrastructure APIs
> - Observability dashboards

Every line of Go you write here scales to the systems that keep production running. That's powerful. 💪

_Built with ❤️ for DevOps engineers learning Go — by Ganil_ 🚀

---

> 📬 **Found a typo? Want a Kubernetes example or Terraform module?**  
> Open an issue or DM me. Let's build reliable systems together. 🤝

```bash
# Quick start reminder:
git clone <your-repo>
cd notes-api
cp .env.example .env  # Edit with your MongoDB URI
air  # Start coding with hot-reload!
```


```
# Stopped at: https://youtu.be/DR4QhvIlFfQ?t=18829
```
