# 🌐 JSON API Standard: The Universal Data Transit
*Version 1.0 | Mastering the Lingua Franca of Microservices*

---

## 📖 Overview
JSON (JavaScript Object Notation) is a lightweight, language-independent data-interchange format. For DevOps and SREs, JSON is the standard for API responses from AWS/GCP, storage for modern databases (MongoDB), and the internal language of logs and telemetry data.

---

## 🏛️ JSON Structure

### Objects `{}`
**Definition**: An unordered collection of name/value pairs inside curly braces.
**Example**:
```json
{
  "status": "up",
  "node_id": "us-east-1a"
}
```

### Arrays `[]`
**Definition**: An ordered collection of values inside square brackets.
**Example**:
```json
"active_ips": ["10.0.0.1", "10.0.0.2", "10.0.0.3"]
```

### Data Types
**Definition**: JSON supports Strings, Numbers, Booleans, `null`, Objects, and Arrays.
**Example**:
```json
{
  "project": "monitoring",   // String
  "priority": 1.0,           // Number
  "alert_active": false,     // Boolean
  "deleted_at": null         // Null
}
```

---

## 🚀 Advanced JSON Manipulation

### JSONPath / Selectors
**Definition**: A query language for JSON data, allowing you to extract specific fields from massive API responses.
**SRE Example**: Extracting all instance IDs from a Boto3 response.
**Syntax**: `$.Reservations[*].Instances[*].InstanceId`

### Compact vs. Pretty-Print
**Definition**: Compact mode removes whitespace to save bandwidth; Pretty-print adds indentation for human readability.
**Command**: `cat data.json | jq .` (Pretty-prints in terminal).

### JSON Schema
**Definition**: A specification for checking the structure and validation of JSON data.
**Usage**: Used in CI/CD to ensure that an application's configuration file isn't missing critical keys.

---

## 🔍 DevOps Use Cases

### Cloud API Responses
**Description**: Querying infrastructure state (e.g., `aws ec2 describe-instances`).
**Example**:
```json
{
  "Instances": [
    {
      "InstanceId": "i-1234567890abcdef0",
      "InstanceType": "t2.micro"
    }
  ]
}
```

### Structured Logging
**Description**: Exporting application logs in JSON format so they can be parsed by Splunk, ELK, or Datadog effortlessly.
**Example**:
```json
{
  "timestamp": "2024-01-26T10:00:00Z",
  "level": "ERROR",
  "message": "Out of memory in worker-04",
  "trace_id": "8b2a"
}
```

---

## 💡 SRE Pro-Tips
- **The jq Essential**: Every DevOps engineer must master `jq`. It is the "awk" for JSON.
  - `jq '.status'` extracts the status key.
  - `jq '.[] | select(.id == 1)'` filters an array.
- **Strict Syntax**: JSON is unforgiving. A single missing comma or a trailing comma will break the parser. Always use `jsonlint`.
- **Double Quotes Only**: Unlike Python or JavaScript, keys and strings **must** use double quotes (`"`), not single quotes (`'`).

---
**Next Step**: [TOML Configuration Standard →](./TOML-Configuration-Ref.md)
