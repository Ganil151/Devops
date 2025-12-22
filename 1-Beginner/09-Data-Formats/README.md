# Data Formats: YAML & JSON Fundamentals

In DevOps, we almost never configure systems through a GUI. Instead, we use **Declarative Configuration** files. The two most common formats for these files are YAML and JSON.

---

## 1. YAML (YAML Ain't Markup Language)
YAML is the industry standard for DevOps tools like Kubernetes, Ansible, and Docker Compose. It is designed to be human-readable.

### Key Syntax Rules
- **Indentation Matters**: Use spaces (usually 2), NEVER tabs.
- **Key-Value Pairs**: `key: value`
- **Lists**: Defined with a dash `-`
- **Comments**: Start with `#`

**Example (Kubernetes Deployment snippet)**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

---

## 2. JSON (JavaScript Object Notation)
JSON is widely used for APIs, cloud configuration (like AWS IAM policies), and Terraform state files. It is more rigid than YAML but very fast for machines to process.

### Key Syntax Rules
- **Braces and Brackets**: `{}` for objects, `[]` for arrays.
- **Quotes**: Keys and string values MUST be in double quotes.
- **No Comments**: Standard JSON does not support comments.

**Example (AWS IAM Policy)**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::example-bucket"
    }
  ]
}
```

---

## 3. Comparison & Tooling

| Feature | YAML | JSON |
| :--- | :--- | :--- |
| **Readability** | High (Clean) | Moderate (Verbose) |
| **Strictness** | Moderate (Indentation) | High (Syntax/Quotes) |
| **Comments** | Supported | Not Supported |
| **DevOps Usage** | K8s, Ansible, Docker | APIs, AWS Policies, Terraform State |

### Essential Tools
- **[yq](https://github.com/mikefarah/yq)**: A lightweight and portable command-line YAML processor.
- **[jq](https://stedolan.github.io/jq/)**: Like `sed` for JSON data – you can use it to slice and filter and map and transform structured data.

---

**Next Step**: Now that you understand data formats, see how they are used to provision infrastructure in [Cloud Foundations](../08-Cloud-Foundations/README.md).
