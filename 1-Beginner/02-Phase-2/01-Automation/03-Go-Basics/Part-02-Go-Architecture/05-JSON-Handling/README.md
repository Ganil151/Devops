# 🌐 Working with JSON in Go

> **"JSON is the lingura franca of the cloud. From Kubernetes API responses to AWS Lambda events, mastering JSON in Go allows you to build high-performance automation that communicates seamlessly with almost any modern infrastructure service."**

Go's built-in `encoding/json` package provides a powerful, type-safe way to handle JSON data. By using **Struct Tags**, you can map complex JSON keys to clean Go fields, ensuring your code remains idiomatic while the data remains interoperable.

![JSON Handling Diagram](./go_json_diagram.png)

## Table of Contents

* [Marshalling: Go to JSON](#marshalling-go-to-json)
* [Unmarshalling: JSON to Go](#unmarshalling-json-to-go)
* [Struct Tags: The Mapping Layer](#struct-tags-the-mapping-layer)
* [Handling Nested and Dynamic Data](#handling-nested-and-dynamic-data)
* [Practical Use Case: Cloud Metadata API](#practical-use-case-cloud-metadata-api)
* [Best Practices](#best-practices)
* [Knowledge Vault (Scenarios, Interview, Quiz)](#knowledge-vault)
* [Additional Resources](#additional-resources)

---

## Marshalling: Go to JSON

**Marshalling** is the process of converting a Go object (usually a struct) into a JSON string or byte slice.

```go
type Server struct {
    Name   string `json:"name"`
    IP     string `json:"ip"`
    Port   int    `json:"port"`
    Active bool   `json:"active"`
}

func main() {
    s := Server{Name: "web-01", IP: "10.0.0.1", Port: 80, Active: true}
    
    // Convert to JSON
    jsonData, err := json.Marshal(s)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println(string(jsonData))
}
```

### Pretty Printing
In DevOps, you often need to log JSON for human eyes. Use `MarshalIndent` for readable output.
```go
data, _ := json.MarshalIndent(s, "", "  ") // Use 2-space indentation
```

---

## Unmarshalling: JSON to Go

**Unmarshalling** is the process of parsing a JSON byte slice into a Go struct or variable. Go requires you to provide a pointer to the destination variable.

```go
rawJSON := `{"name": "api-gateway", "ip": "172.16.0.5", "port": 443}`

var s Server
err := json.Unmarshal([]byte(rawJSON), &s)
if err != nil {
    log.Fatal(err)
}
fmt.Printf("Parsed Server: %s at %s\n", s.Name, s.IP)
```

---

## Struct Tags: The Mapping Layer

Struct tags are metadata attached to struct fields that tell the `json` package how to handle them.

* **`json:"name"`**: Maps the field to the lowercase key "name" in JSON.
* **`json:"key,omitempty"`**: Excludes the field from the JSON output if it has a "zero value" (e.g., empty string, 0, or false).
* **`json:"-"`**: Completely ignores the field during both Marshalling and Unmarshalling (use this for sensitive data like passwords).

---

## Handling Nested and Dynamic Data

### Nested Structs
Common in Kubernetes API objects.
```go
type Pod struct {
    Metadata struct {
        Name      string `json:"name"`
        Namespace string `json:"namespace"`
    } `json:"metadata"`
}
```

### Dynamic Data with `map[string]interface{}`
When you don't know the JSON structure ahead of time, unmarshal into a map.
```go
var dynamicData map[string]interface{}
json.Unmarshal(data, &dynamicData)

// Use type assertion to access values
if val, ok := dynamicData["id"].(float64); ok {
    fmt.Println("ID:", val)
}
```

---

## Practical Use Case: Cloud Metadata API

Automation scripts often query instance metadata (like AWS EC2 or GCP Metadata) which returns JSON.

```go
type InstanceMetadata struct {
    InstanceID string   `json:"instanceId"`
    Region     string   `json:"region"`
    PrivateIPs []string `json:"privateIps,omitempty"`
}

func getMetadata() {
    // Simulated JSON from a cloud metadata endpoint
    clientResponse := `{"instanceId": "i-0abc123", "region": "us-east-1"}`
    
    var meta InstanceMetadata
    json.Unmarshal([]byte(clientResponse), &meta)
    
    fmt.Printf("Auto-scaling instance %s in %s\n", meta.InstanceID, meta.Region)
}
```

---

## Best Practices

* **Always Check Errors**: JSON unmarshalling is a frequent point of failure in network scripts.
* **Use Pointers for Optional Fields**: If a JSON value can be `null`, use a pointer in your Go struct (e.g., `*string`) to distinguish between an empty value and a missing value.
* **Keep Structs Compact**: Only define the fields you actually need from a large API response. Go will ignore any keys in the JSON that aren't in your struct.
* **Capitalized Fields**: Remember that only exported (Capitalized) fields can be Marshalled/Unmarshalled.

---

## Knowledge Vault

### Real-World Scenarios

#### Scenario 1: The "Case-Sensitivity" Trap
An engineer built a tool to parse CloudTrail logs. The Go struct had a field `SourceIP`, but the JSON key was `sourceIP`. The tool ran for months without error but always showed blank IPs because the `json` package couldn't match the keys.
**Go Solution**: By adding the struct tag `` `json:"sourceIP"` ``, the engineer explicitly mapped the keys, and the tool immediately began capturing the missing data.

#### Scenario 2: Handling API Bloat
A microservice was querying a Kubernetes API that returned a 5MB JSON object. The Go script was slow because it was unmarshalling all 200 fields into a massive complex struct.
**Go Solution**: The engineer simplified the struct to only 3 fields (name, namespace, status). The script speed increased by 10x because Go simply skipped the 197 irrelevant fields during the parsing process.

### Interview Preparation

1. **What is the difference between `Marshal` and `Unmarshal`?**
   > `Marshal` converts a Go struct to a JSON byte slice. `Unmarshal` converts a JSON byte slice into a Go struct.

2. **How do you handle a JSON key that contains special characters (like "api-version")?**
   > Use struct tags: `` Version string `json:"api-version"` ``. Go field names cannot have hyphens, but struct tags can.

3. **What is the `omitempty` tag option used for?**
   > It prevents a field from being included in the resulting JSON if the field is empty (0, "", nil, etc.). This is useful for keeping API payloads small and clean.

4. **Why must struct fields be exported (Capitalized) to be used with JSON?**
   > The `encoding/json` package is an external package. In Go, it cannot access "private" (lowercase) fields of a struct defined in another package.

### Knowledge Check (Quiz)

1. **Which package provides JSON support in Go?**
   - a) `os/json`
   - b) `encoding/json` ✅
   - c) `net/json`

2. **What does the tag `` `json:"-"` `` do?**
   - a) Makes the field a negative number
   - b) Excludes the field from all JSON operations ✅
   - c) Renames the field to a hyphen

3. **Which function is used for "Pretty Printing" JSON?**
   - a) `json.MarshalPretty()`
   - b) `json.MarshalIndent()` ✅
   - c) `json.Format()`

4. **When Unmarshalling, why do we pass `&myStruct` (a pointer)?**
   - a) Because pointers are faster
   - b) So the function can modify the original struct with the parsed data ✅
   - c) It's a Go requirement for all functions

5. **If a JSON key is missing from your Go struct, what happens?**
   - a) The program crashes
   - b) Go returns an error
   - c) Go simply ignores that key ✅

---

## Additional Resources

* **Official Go JSON Documentation**: [https://pkg.go.dev/encoding/json](https://pkg.go.dev/encoding/json)
* **Go blog: JSON and Go**: [https://blog.golang.org/json-and-go](https://blog.golang.org/json-and-go)
* **JSON-to-Go Tool**: [https://mholt.github.io/json-to-go/](https://mholt.github.io/json-to-go/) (Vital for DevOps!)

---

**Next Step**: [Working with YAML →](../10-Working-with-YAML/README.md)
