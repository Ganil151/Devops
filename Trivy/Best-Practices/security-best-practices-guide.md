# Trivy Security Best Practices

## Scanning Strategy

### Multi-Layer Security Approach
```bash
# 1. Source code scanning
trivy fs --scanners vuln,secret,config .

# 2. Dependency scanning
trivy fs --scanners vuln --vuln-type library .

# 3. Infrastructure scanning
trivy config .

# 4. Container image scanning
trivy image myapp:latest

# 5. Runtime scanning (if applicable)
trivy k8s --report summary cluster
```

### Continuous Security Integration
```yaml
# Security scanning matrix
scan_matrix:
  - stage: "pre-commit"
    scans: ["secret", "config"]
    severity: ["HIGH", "CRITICAL"]
    exit_code: 1
  
  - stage: "pull_request"
    scans: ["vuln", "secret", "config"]
    severity: ["MEDIUM", "HIGH", "CRITICAL"]
    exit_code: 1
  
  - stage: "main_branch"
    scans: ["vuln", "secret", "config", "license"]
    severity: ["LOW", "MEDIUM", "HIGH", "CRITICAL"]
    exit_code: 0  # Report only
  
  - stage: "production"
    scans: ["vuln", "secret"]
    severity: ["HIGH", "CRITICAL"]
    exit_code: 1
```

## Performance Optimization

### Caching Strategies
```bash
# Persistent cache configuration
export TRIVY_CACHE_DIR="/var/cache/trivy"
export TRIVY_DB_REPOSITORY="ghcr.io/aquasecurity/trivy-db"

# Cache optimization script
#!/bin/bash
setup_trivy_cache() {
    local cache_dir="/var/cache/trivy"
    
    # Create cache directory
    mkdir -p $cache_dir
    
    # Pre-download database
    trivy image --download-db-only
    
    # Set permissions
    chmod -R 755 $cache_dir
    
    echo "Trivy cache initialized at $cache_dir"
}

# Parallel scanning for multiple images
scan_images_parallel() {
    local images=("$@")
    local max_jobs=4
    
    for image in "${images[@]}"; do
        (($(jobs -r | wc -l) >= max_jobs)) && wait
        {
            echo "Scanning $image..."
            trivy image --format json --output "${image//[:\/]/_}.json" "$image"
        } &
    done
    wait
}
```

### Scan Optimization
```bash
# Skip unnecessary scans
trivy image --skip-files "/usr/share/doc/*,/usr/share/man/*" nginx:latest

# Skip specific directories
trivy fs --skip-dirs "node_modules,vendor,.git" .

# Limit scan scope
trivy image --vuln-type os nginx:latest  # OS packages only
trivy image --vuln-type library node:16  # Language libraries only

# Offline scanning for air-gapped environments
trivy image --offline --cache-dir /path/to/cache nginx:latest
```

## Security Policy Management

### Vulnerability Management Policy
```yaml
# vulnerability-policy.yaml
vulnerability_management:
  severity_levels:
    critical:
      action: "block_deployment"
      sla: "immediate"
      notification: ["security-team", "dev-team"]
    
    high:
      action: "require_approval"
      sla: "24_hours"
      notification: ["dev-team"]
    
    medium:
      action: "create_ticket"
      sla: "7_days"
      notification: ["dev-team"]
    
    low:
      action: "log_only"
      sla: "30_days"
      notification: []

  exceptions:
    - cve: "CVE-2021-44228"  # Log4j
      reason: "Not applicable - Java not used"
      expiry: "2024-12-31"
      approved_by: "security-team"
```

### Custom Ignore Policies
```bash
# .trivyignore - Global ignores
# Ignore specific CVEs with justification
CVE-2019-1234  # Fixed in next release
CVE-2020-5678  # Not exploitable in our environment

# Ignore by path
/test/**
/docs/**
*.test.js

# Ignore by package
npm:lodash@4.17.20  # Specific version
go:github.com/example/pkg  # Entire package
```

## Compliance and Reporting

### Compliance Frameworks
```bash
# CIS Benchmarks
trivy image --compliance docker-cis nginx:latest
trivy k8s --compliance k8s-cis cluster

# NIST Framework
trivy config --compliance nist-csf .

# Custom compliance
trivy image --policy custom-compliance.rego nginx:latest
```

### Automated Reporting
```bash
#!/bin/bash
# generate-security-report.sh

REPORT_DATE=$(date +%Y-%m-%d)
REPORT_DIR="security-reports/$REPORT_DATE"
mkdir -p "$REPORT_DIR"

# Scan multiple targets
targets=(
    "nginx:latest"
    "redis:alpine"
    "postgres:13"
)

echo "Generating security report for $REPORT_DATE"

# Executive summary
cat > "$REPORT_DIR/executive-summary.md" << EOF
# Security Scan Report - $REPORT_DATE

## Overview
This report contains security scan results for all production images.

## Summary
EOF

total_critical=0
total_high=0
total_medium=0

for target in "${targets[@]}"; do
    echo "Scanning $target..."
    
    # Generate detailed JSON report
    trivy image --format json --output "$REPORT_DIR/${target//[:\/]/_}.json" "$target"
    
    # Generate HTML report
    trivy image --format template --template "@contrib/html.tpl" \
        --output "$REPORT_DIR/${target//[:\/]/_}.html" "$target"
    
    # Extract metrics
    critical=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' "$REPORT_DIR/${target//[:\/]/_}.json")
    high=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH")] | length' "$REPORT_DIR/${target//[:\/]/_}.json")
    medium=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "MEDIUM")] | length' "$REPORT_DIR/${target//[:\/]/_}.json")
    
    total_critical=$((total_critical + critical))
    total_high=$((total_high + high))
    total_medium=$((total_medium + medium))
    
    # Add to summary
    cat >> "$REPORT_DIR/executive-summary.md" << EOF

### $target
- Critical: $critical
- High: $high
- Medium: $medium
EOF
done

# Add totals to summary
cat >> "$REPORT_DIR/executive-summary.md" << EOF

## Total Vulnerabilities
- Critical: $total_critical
- High: $total_high
- Medium: $total_medium

## Recommendations
$([ $total_critical -gt 0 ] && echo "🚨 Immediate action required for critical vulnerabilities")
$([ $total_high -gt 10 ] && echo "⚠️  High number of high-severity vulnerabilities detected")
$([ $total_medium -gt 50 ] && echo "📋 Consider addressing medium-severity vulnerabilities")
EOF

echo "Report generated in $REPORT_DIR"
```

## Secret Management

### Secret Detection Configuration
```yaml
# secret-config.yaml
rules:
  - id: aws-access-key
    pattern: 'AKIA[0-9A-Z]{16}'
    description: "AWS Access Key ID"
    severity: "HIGH"
  
  - id: github-token
    pattern: 'ghp_[a-zA-Z0-9]{36}'
    description: "GitHub Personal Access Token"
    severity: "CRITICAL"
  
  - id: slack-webhook
    pattern: 'https://hooks\.slack\.com/services/[A-Z0-9/]+'
    description: "Slack Webhook URL"
    severity: "MEDIUM"

allowlist:
  - path: "test/**"
    reason: "Test files with dummy secrets"
  - pattern: "EXAMPLE_.*"
    reason: "Example configuration values"
```

### Secret Scanning Best Practices
```bash
# Pre-commit secret scanning
#!/bin/bash
# .git/hooks/pre-commit

echo "Running secret scan..."
trivy fs --scanners secret --exit-code 1 .

if [ $? -ne 0 ]; then
    echo "❌ Secrets detected! Commit blocked."
    echo "Remove secrets or add to .trivyignore if false positive"
    exit 1
fi

echo "✅ No secrets detected"
```

## Integration Security

### Secure Trivy Deployment
```yaml
# trivy-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: trivy-server
spec:
  replicas: 2
  selector:
    matchLabels:
      app: trivy-server
  template:
    metadata:
      labels:
        app: trivy-server
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
      containers:
      - name: trivy
        image: aquasec/trivy:latest
        args:
          - server
          - --listen
          - 0.0.0.0:8080
        ports:
        - containerPort: 8080
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          capabilities:
            drop:
            - ALL
        resources:
          limits:
            cpu: 1000m
            memory: 1Gi
          requests:
            cpu: 500m
            memory: 512Mi
        volumeMounts:
        - name: cache
          mountPath: /tmp/trivy
        - name: tmp
          mountPath: /tmp
      volumes:
      - name: cache
        emptyDir: {}
      - name: tmp
        emptyDir: {}
```

### Network Security
```yaml
# trivy-network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: trivy-server-netpol
spec:
  podSelector:
    matchLabels:
      app: trivy-server
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: trivy-client
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 443  # HTTPS for database updates
    - protocol: TCP
      port: 53   # DNS
  - to: []
    ports:
    - protocol: UDP
      port: 53   # DNS
```

## Monitoring and Alerting

### Metrics Collection
```bash
#!/bin/bash
# trivy-metrics.sh

# Collect scan metrics
collect_metrics() {
    local target=$1
    local scan_result=$(trivy image --format json --quiet "$target")
    
    # Extract metrics
    local total_vulns=$(echo "$scan_result" | jq '[.Results[]?.Vulnerabilities[]] | length')
    local critical_vulns=$(echo "$scan_result" | jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length')
    local high_vulns=$(echo "$scan_result" | jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH")] | length')
    
    # Send to monitoring system (Prometheus format)
    cat << EOF
# HELP trivy_vulnerabilities_total Total number of vulnerabilities
# TYPE trivy_vulnerabilities_total gauge
trivy_vulnerabilities_total{image="$target",severity="total"} $total_vulns
trivy_vulnerabilities_total{image="$target",severity="critical"} $critical_vulns
trivy_vulnerabilities_total{image="$target",severity="high"} $high_vulns
EOF
}

# Usage
collect_metrics "nginx:latest" > /var/lib/node_exporter/textfile_collector/trivy_nginx.prom
```

### Alerting Rules
```yaml
# trivy-alerts.yaml
groups:
- name: trivy-security
  rules:
  - alert: CriticalVulnerabilitiesDetected
    expr: trivy_vulnerabilities_total{severity="critical"} > 0
    for: 0m
    labels:
      severity: critical
    annotations:
      summary: "Critical vulnerabilities detected in {{ $labels.image }}"
      description: "{{ $value }} critical vulnerabilities found in image {{ $labels.image }}"

  - alert: HighVulnerabilityCount
    expr: trivy_vulnerabilities_total{severity="high"} > 10
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High number of vulnerabilities in {{ $labels.image }}"
      description: "{{ $value }} high-severity vulnerabilities found in image {{ $labels.image }}"
```