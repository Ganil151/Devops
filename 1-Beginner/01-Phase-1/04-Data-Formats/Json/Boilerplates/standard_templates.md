# ⚙️ JSON Boilerplates: Security and Observability

This directory contains essential JSON templates used for cloud security (IAM) and log analysis.

## 1. AWS IAM Policy Blueprint
A standard policy for strict S3 access control.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::prod-artifacts-bucket",
        "arn:aws:s3:::prod-artifacts-bucket/*"
      ],
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "203.0.113.0/24"
        }
      }
    }
  ]
}
```

## 2. Structured Log Entry Template
Example of a production-grade structured log entry for ELK/Splunk ingestion.

```json
{
  "timestamp": "2026-01-24T04:25:00Z",
  "level": "error",
  "service": "billing-api",
  "trace_id": "8f3a-9b2c-1d0e",
  "context": {
    "user_id": 4567,
    "path": "/v1/charge",
    "method": "POST"
  },
  "message": "Payment gateway timeout after 5000ms",
  "metadata": {
    "node_id": "worker-05",
    "cluster": "k8s-prod-us-east-1"
  }
}
```
