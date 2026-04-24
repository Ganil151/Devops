# Variables and Types - DevOps Challenges

## Challenge 1: Database Connection String Builder
**Scenario**: Build a type-safe database connection string from individual config variables.

**Requirements:**
1. Create a struct `DBConfig` with fields: `Host`, `Port`, `Username`, `Password`, `Database`, `SSLMode` (bool)
2. Write a function that constructs a PostgreSQL connection string
3. Handle missing required fields with appropriate error messages

**Verification:**
```bash
go run db-config.go
# Expected: postgresql://user:pass@localhost:5432/mydb?sslmode=enable
```

---

## Challenge 2: Resource Limit Parser
**Scenario**: Parse Kubernetes-style resource limits (e.g., "2Gi", "500m") into bytes/milli-units.

**Requirements:**
1. Parse memory strings like "1Gi", "512Mi", "100M" into bytes (int64)
2. Parse CPU strings like "500m", "2" into milli-cores (int)
3. Handle invalid inputs gracefully

**Verification:**
```bash
go run resource-parser.go "2Gi" "500m"
# Expected: Memory: 2147483648 bytes, CPU: 500 milli-cores
```

---

## Challenge 3: Feature Flag Configuration
**Scenario**: Implement a type-safe feature flag system that reads from environment variables.

**Requirements:**
1. Create a `FeatureFlags` struct with boolean fields for different features
2. Parse from environment variables with prefix `FEATURE_`
3. Print enabled/disabled features with emoji indicators

**Verification:**
```bash
FEATURE_NEW_UI=true FEATURE_BETA_API=false go run features.go
# Expected:
# ✅ NEW_UI: enabled
# ❌ BETA_API: disabled
```

---

## Challenge 4 (Advanced): Multi-Environment Config Loader
**Scenario**: Load configuration from different sources based on priority.

**Requirements:**
1. Support config from: CLI flags > Environment variables > Config file > Defaults
2. Create a struct that merges all sources
3. Print the final config with the source of each value

**Verification:**
```bash
go run config-loader.go --port 9000
# Expected: Port: 9000 (source: cli)
#          Host: localhost (source: default)
```
