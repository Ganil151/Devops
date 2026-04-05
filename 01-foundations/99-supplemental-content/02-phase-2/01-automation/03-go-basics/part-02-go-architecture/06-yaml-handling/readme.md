# 📄 Working with YAML in Go

> **"YAML is the language of the modern cloud. From Kubernetes manifests to GitHub Actions and Ansible playbooks, YAML is everywhere. In Go, mastering YAML handling is non-negotiable for building tools that orchestrate production infrastructure."**

While JSON is common for APIs, **YAML** (YAML Ain't Markup Language) is the undisputed king of human-readable configuration. Go doesn't have YAML support in the standard library, but the `gopkg.in/yaml.v3` package is the industry standard, providing a seamless, struct-based experience similar to JSON.

![YAML Configurations for DevOps](./go-yaml-hero.png)

## Table of Contents

* [Parsing YAML into Go Structs](#parsing-yaml-into-go-structs)
* [Generating YAML Output](#generating-yaml-output)
* [Managing Kubernetes-Style Manifests](#managing-kubernetes-style-manifests)
* [YAML Struct Tags vs JSON Tags](#yaml-struct-tags-vs-json-tags)
* [Practical Use Case: Application Multi-Environment Config](#practical-use-case-application-multi-environment-config)
* [Knowledge Vault (Scenarios, Interview, Quiz)](#knowledge-vault)
* [Additional Resources](#additional-resources)

---

## 💼 The Automation Why: The Human-Machine Bridge

**The Beginner's Question**: "We already have JSON. Why do we need YAML too?"

**The Answer**: **Humans lead, machines follow.**
While JSON is great for machines, it's painful for humans to write and maintain at scale. Kubernetes, GitHub Actions, and Terraform chose YAML because it supports comments, complex nesting with simple indentation, and multi-line strings. In DevOps, where humans define the *Intent* (YAML) and machines execute the *Automation* (Go), YAML is the bridge that keeps everyone on the same page.

### The Lego Instructions Analogy 🧱

- **JSON** = **The Parts List**: A cold, efficient list of IDs and counts. Great for the computer to verify, but hard for a human to visualize the final castle. One missing comma and the whole list is invalid.
- **YAML** = **The Instruction Booklet**: It has a clear hierarchy (Indentation), it's easy on the eyes, and it tells the "story" of the build. You can add notes (Comments) to explain *why* a particular piece is placed there. You build the castle by reading the instructions, and let the Go code be the hands that snap the bricks together.

---

## Parsing YAML into Go Structs

To read YAML data, we use the `yaml.Unmarshal` function. It works almost exactly like `json.Unmarshal`, requiring a byte slice and a pointer to a struct.

### Basic Unmarshalling
```go
import "gopkg.in/yaml.v3"

type Config struct {
    Server   string   `yaml:"server"`
    Port     int      `yaml:"port"`
    Features []string `yaml:"features"`
}

func main() {
    yamlData := `
server: prod-api-01
port: 8443
features:
  - caching
  - load-balancing
`
    var config Config
    err := yaml.Unmarshal([]byte(yamlData), &config)
    if err != nil {
        log.Fatalf("Error parsing YAML: %v", err)
    }
}
```

---

## Generating YAML Output

Converting a Go struct back into YAML is called **Marshalling**. This is vital when your tool needs to generate or update configuration files automatically.

```go
config := Config{
    Server:   "staging-lb-01",
    Port:     80,
    Features: []string{"metrics", "tracing"},
}

data, _ := yaml.Marshal(config)
fmt.Println(string(data))
```

---

## Managing Kubernetes-Style Manifests

DevOps tools often need to generate or modify Kubernetes YAML files. Because K8s objects are highly nested, we represent them using nested structs.

```go
type Deployment struct {
    APIVersion string `yaml:"apiVersion"`
    Kind       string `yaml:"kind"`
    Metadata   struct {
        Name      string            `yaml:"name"`
        Namespace string            `yaml:"namespace"`
        Labels    map[string]string `yaml:"labels"`
    } `yaml:"metadata"`
    Spec struct {
        Replicas int `yaml:"replicas"`
        Template struct {
            Spec struct {
                Containers []struct {
                    Name  string `yaml:"name"`
                    Image string `yaml:"image"`
                } `yaml:"containers"`
            } `yaml:"spec"`
        } `yaml:"template"`
    } `yaml:"spec"`
}
```

---

## YAML Struct Tags vs JSON Tags

Go allows you to define both JSON and YAML tags on the same field. This is useful for tools that need to read a YAML config but report status via a JSON API.

```go
type DatabaseConfig struct {
    User     string `yaml:"username" json:"user"`
    Password string `yaml:"pass" json:"-"`      // Hidden from JSON
    Host     string `yaml:"db_host" json:"host"`
}
```

* **`yaml:"key"`**: Maps the Go field to the specific YAML key.
* **`yaml:",omitempty"`**: Only includes the field in generated YAML if it's not the default value.
* **`yaml:"-"`**: Completely ignores the field in YAML operations.

---

## Practical Use Case: Application Multi-Environment Config

Imagine a tool that configures different environments (Dev, Staging, Prod) based on a central YAML file.

```go
type AppConfig struct {
    Env     string `yaml:"environment"`
    Database struct {
        URL  string `yaml:"url"`
        Max  int    `yaml:"max_conns"`
    } `yaml:"db"`
}

func loadEnv(yamlBytes []byte) {
    var c AppConfig
    yaml.Unmarshal(yamlBytes, &c)
    
    if c.Env == "production" {
        fmt.Println("CRITICAL: Scaling database connections for Production...")
    }
}
```

---

## Knowledge Vault

### Real-World Scenarios

#### Scenario 1: The "Indentation Trap" in CI/CD
A team was using a Go script to update an Ansible inventory. Their script generated YAML by simple string concatenation. One day, a server name contained a special character, and the indentation broke, causing a production rollout to deploy to the wrong servers.
**Go Solution**: They rewrote the tool to use `yaml.Marshal`. By letting the package handle the indentation and character escaping, they ensured the resulting YAML was always valid and safe, regardless of the input data.

#### Scenario 2: Dynamic K8s Config Generation
An SRE team needed to create 50 identical Kubernetes ConfigMaps, each with a unique ID and region. Doing this manually with `sed` was error-prone.
**Go Solution**: They defined a `ConfigMap` struct and a simple loop. The script generated all 50 YAML files in milliseconds, including proper metadata and labels, significantly reducing the "to-be-done" queue for infrastructure tasks.

### Interview Preparation

1. **Why is `gopkg.in/yaml.v3` used instead of the standard library?**
   > Unlike JSON, YAML support is not built into the Go standard library. The community maintains several packages, with `yaml.v3` being the most feature-complete and widely used for its robust handling of complex YAML features like anchors and nested maps.

2. **How do you handle a YAML field that could be either a string or an object?**
   > You can unmarshal into a variable of type `interface{}` and then use a "Type switch" to detect the actual data structure, or use a custom `UnmarshalYAML` method on a type to implement custom logic.

3. **What is the significance of the `---` separator in YAML?**
   > It allows multiple YAML "documents" to exist in a single file. While `yaml.Unmarshal` handles a single document, you can use `yaml.NewDecoder(reader).Decode(&val)` in a loop to parse files containing multiple documents (common in K8s).

4. **Can you use both `json` and `yaml` tags on the same struct field?**
   > Yes. Go allows multiple tags in the same tag string. This is common in DevOps tools that receive configuration in YAML but present an API or dashboard in JSON.

### Knowledge Check (Quiz)

1. **What is the standard Go package for YAML handling?**
   - a) `encoding/yaml`
   - b) `gopkg.in/yaml.v3` ✅
   - c) `io/yaml`

2. **What happens if a YAML key is missing a matching field in the Go struct?**
   - a) The parser crashes
   - b) The parser skips it silently ✅
   - c) The computer beeps

3. **Which tag option prevents a field from appearing in generated YAML if it's empty?**
   - a) `yaml:"key,empty"`
   - b) `yaml:"key,omitempty"` ✅
   - c) `yaml:"key,hide"`

4. **In the `yaml.Unmarshal` function, what type of data is the first argument?**
   - a) `string`
   - b) `[]byte` ✅
   - c) `int`

5. **Why use structs instead of maps for YAML in production code?**
   - a) Structs are faster to type
   - b) Structs provide type safety and IDE autocompletion ✅
   - c) Maps don't support indentation

---

## Additional Resources

* **YAML Spec (v1.2)**: [yaml.org](https://yaml.org/spec/1.2.2/)
* **Go YAML (yaml.v3) GitHub**: [github.com/go-yaml/yaml](https://github.com/go-yaml/yaml/tree/v3)
* **K8s Documentation: YAML basics**: [kubernetes.io/docs/concepts/configuration/](https://kubernetes.io/docs/concepts/configuration/overview/)

---

**Next Step**: [Regular Expressions →](../07-regular-expressions/readme.md)
