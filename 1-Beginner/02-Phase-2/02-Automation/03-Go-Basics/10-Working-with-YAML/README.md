# Working with YAML
*Configuration Files for DevOps*

YAML is the standard for Kubernetes, Ansible, and most DevOps tools. Use `gopkg.in/yaml.v3`.

---

## 🎯 Learning Objectives

- Parse YAML configurations
- Generate YAML output
- Handle K8s manifests

---

## 📚 Core Concepts

### 1. Parsing YAML

```go
import "gopkg.in/yaml.v3"

type Config struct {
    Server   string   `yaml:"server"`
    Port     int      `yaml:"port"`
    Features []string `yaml:"features"`
}

yamlData := `
server: localhost
port: 8080
features:
  - logging
  - metrics
`

var config Config
yaml.Unmarshal([]byte(yamlData), &config)
```

### 2. Generating YAML

```go
config := Config{
    Server:   "prod.example.com",
    Port:     443,
    Features: []string{"ssl", "auth"},
}

data, _ := yaml.Marshal(config)
fmt.Println(string(data))
```

### 3. K8s Manifest Handling

```go
type Deployment struct {
    APIVersion string `yaml:"apiVersion"`
    Kind       string `yaml:"kind"`
    Metadata   struct {
        Name   string            `yaml:"name"`
        Labels map[string]string `yaml:"labels"`
    } `yaml:"metadata"`
}
```

---

## 🛠️ Hands-On Exercise

```go
// Create a function to generate K8s ConfigMap YAML
func generateConfigMap(name string, data map[string]string) string {
    // TODO: Return valid K8s ConfigMap YAML
}
```

---

## 🧠 Quiz

1. Which package is commonly used for YAML in Go?
   - a) `encoding/yaml`
   - b) `gopkg.in/yaml.v3` ✅

2. YAML struct tags use:
   - a) `json:"field"`
   - b) `yaml:"field"` ✅

---

**Next Step**: [Command Line Flags →](../11-Command-Line-Flags/README.md)
