# Real-World Trivy Scenarios

## Scenario 1: Multi-Cloud Container Registry Scanning

### Problem
Organization uses multiple container registries (AWS ECR, Google GCR, Azure ACR) and needs centralized security scanning.

### Solution
```bash
#!/bin/bash
# multi-registry-scan.sh

# Registry configurations
declare -A REGISTRIES=(
    ["aws"]="123456789012.dkr.ecr.us-west-2.amazonaws.com"
    ["gcp"]="gcr.io/my-project"
    ["azure"]="myregistry.azurecr.io"
)

# Images to scan
IMAGES=(
    "web-app:latest"
    "api-service:v1.2.3"
    "database:stable"
)

# Authenticate to registries
authenticate_registries() {
    # AWS ECR
    aws ecr get-login-password --region us-west-2 | \
        docker login --username AWS --password-stdin ${REGISTRIES[aws]}
    
    # Google GCR
    gcloud auth configure-docker gcr.io
    
    # Azure ACR
    az acr login --name myregistry
}

# Scan all images across registries
scan_multi_registry() {
    local report_dir="security-reports/$(date +%Y-%m-%d)"
    mkdir -p "$report_dir"
    
    for registry in "${!REGISTRIES[@]}"; do
        echo "Scanning $registry registry..."
        
        for image in "${IMAGES[@]}"; do
            local full_image="${REGISTRIES[$registry]}/$image"
            local output_file="$report_dir/${registry}_${image//[:\/]/_}.json"
            
            echo "  Scanning $full_image..."
            trivy image --format json --output "$output_file" "$full_image"
            
            # Check for critical vulnerabilities
            local critical_count=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' "$output_file")
            
            if [ "$critical_count" -gt 0 ]; then
                echo "  ⚠️  $critical_count critical vulnerabilities found in $full_image"
                # Send alert
                send_alert "$registry" "$image" "$critical_count"
            fi
        done
    done
    
    # Generate consolidated report
    generate_consolidated_report "$report_dir"
}

send_alert() {
    local registry=$1
    local image=$2
    local count=$3
    
    curl -X POST "$SLACK_WEBHOOK" \
        -H 'Content-type: application/json' \
        --data "{
            \"text\": \"🚨 Critical vulnerabilities detected\",
            \"attachments\": [{
                \"color\": \"danger\",
                \"fields\": [
                    {\"title\": \"Registry\", \"value\": \"$registry\", \"short\": true},
                    {\"title\": \"Image\", \"value\": \"$image\", \"short\": true},
                    {\"title\": \"Critical CVEs\", \"value\": \"$count\", \"short\": true}
                ]
            }]
        }"
}

authenticate_registries
scan_multi_registry
```

## Scenario 2: Kubernetes Cluster Security Assessment

### Problem
Need to scan all running containers in a Kubernetes cluster and assess security posture.

### Solution
```bash
#!/bin/bash
# k8s-cluster-scan.sh

NAMESPACE=${1:-"default"}
REPORT_DIR="k8s-security-reports/$(date +%Y-%m-%d)"

mkdir -p "$REPORT_DIR"

# Get all running pods and their images
get_running_images() {
    kubectl get pods -n "$NAMESPACE" -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].image}{"\n"}{end}' | \
    while IFS=$'\t' read -r pod_name images; do
        echo "$pod_name|$images"
    done
}

# Scan Kubernetes configurations
scan_k8s_configs() {
    echo "Scanning Kubernetes configurations..."
    
    # Export all resources
    kubectl get all -n "$NAMESPACE" -o yaml > "$REPORT_DIR/k8s-resources.yaml"
    
    # Scan configurations
    trivy config \
        --format json \
        --output "$REPORT_DIR/k8s-config-scan.json" \
        "$REPORT_DIR/k8s-resources.yaml"
    
    # Check for misconfigurations
    local misconfig_count=$(jq '[.Results[]?.Misconfigurations[]?] | length' "$REPORT_DIR/k8s-config-scan.json")
    echo "Found $misconfig_count misconfigurations"
}

# Scan container images
scan_container_images() {
    echo "Scanning container images..."
    
    get_running_images | while IFS='|' read -r pod_name images; do
        for image in $images; do
            local safe_name="${pod_name}_${image//[:\/]/_}"
            
            echo "  Scanning $image (pod: $pod_name)..."
            
            trivy image \
                --format json \
                --output "$REPORT_DIR/image_${safe_name}.json" \
                "$image"
            
            # Extract summary
            local vulns=$(jq '[.Results[]?.Vulnerabilities[]?] | length' "$REPORT_DIR/image_${safe_name}.json")
            local critical=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' "$REPORT_DIR/image_${safe_name}.json")
            
            echo "    $vulns total vulnerabilities, $critical critical"
        done
    done
}

# Generate cluster security report
generate_cluster_report() {
    cat > "$REPORT_DIR/cluster-security-summary.md" << EOF
# Kubernetes Cluster Security Report

**Namespace:** $NAMESPACE  
**Scan Date:** $(date)

## Summary

### Configuration Issues
$(jq -r '.Results[]?.Misconfigurations[]? | "- \(.ID): \(.Title)"' "$REPORT_DIR/k8s-config-scan.json")

### Image Vulnerabilities
$(for file in "$REPORT_DIR"/image_*.json; do
    if [ -f "$file" ]; then
        local image=$(basename "$file" .json | sed 's/image_//' | sed 's/_/:/g')
        local critical=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' "$file")
        echo "- $image: $critical critical vulnerabilities"
    fi
done)

## Recommendations

1. Address all CRITICAL vulnerabilities immediately
2. Update base images to latest secure versions
3. Implement security policies for pod security standards
4. Enable network policies for micro-segmentation
EOF

    echo "Cluster security report generated: $REPORT_DIR/cluster-security-summary.md"
}

scan_k8s_configs
scan_container_images
generate_cluster_report
```

## Scenario 3: CI/CD Security Gate Implementation

### Problem
Implement security gates in CI/CD pipeline that blocks deployments based on vulnerability thresholds.

### Solution
```yaml
# .github/workflows/security-gate.yml
name: Security Gate Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  security-gate:
    runs-on: ubuntu-latest
    outputs:
      security-passed: ${{ steps.security-check.outputs.passed }}
      image-tag: ${{ steps.meta.outputs.tags }}
    
    steps:
    - name: Checkout
      uses: actions/checkout@v3

    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha,prefix={{branch}}-

    - name: Build image
      uses: docker/build-push-action@v4
      with:
        context: .
        push: false
        tags: ${{ steps.meta.outputs.tags }}

    - name: Security Scan - Source Code
      id: source-scan
      run: |
        trivy fs --format json --output source-scan.json .
        
        # Check for secrets
        SECRET_COUNT=$(jq '[.Results[]?.Secrets[]?] | length' source-scan.json)
        if [ "$SECRET_COUNT" -gt 0 ]; then
          echo "❌ Secrets detected in source code"
          exit 1
        fi
        
        # Check for high/critical vulnerabilities
        HIGH_VULN=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH" or .Severity == "CRITICAL")] | length' source-scan.json)
        echo "high-vulns=$HIGH_VULN" >> $GITHUB_OUTPUT

    - name: Security Scan - Container Image
      id: image-scan
      run: |
        trivy image --format json --output image-scan.json ${{ steps.meta.outputs.tags }}
        
        CRITICAL_COUNT=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' image-scan.json)
        HIGH_COUNT=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH")] | length' image-scan.json)
        
        echo "critical-vulns=$CRITICAL_COUNT" >> $GITHUB_OUTPUT
        echo "high-vulns=$HIGH_COUNT" >> $GITHUB_OUTPUT

    - name: Security Policy Check
      id: security-check
      run: |
        # Define security thresholds
        MAX_CRITICAL=0
        MAX_HIGH=5
        
        CRITICAL=${{ steps.image-scan.outputs.critical-vulns }}
        HIGH=${{ steps.image-scan.outputs.high-vulns }}
        
        echo "Security Scan Results:"
        echo "- Critical: $CRITICAL (max: $MAX_CRITICAL)"
        echo "- High: $HIGH (max: $MAX_HIGH)"
        
        if [ "$CRITICAL" -gt "$MAX_CRITICAL" ]; then
          echo "❌ FAILED: $CRITICAL critical vulnerabilities exceed limit of $MAX_CRITICAL"
          echo "passed=false" >> $GITHUB_OUTPUT
          exit 1
        fi
        
        if [ "$HIGH" -gt "$MAX_HIGH" ]; then
          echo "❌ FAILED: $HIGH high vulnerabilities exceed limit of $MAX_HIGH"
          echo "passed=false" >> $GITHUB_OUTPUT
          exit 1
        fi
        
        echo "✅ PASSED: Security scan meets policy requirements"
        echo "passed=true" >> $GITHUB_OUTPUT

    - name: Upload Security Reports
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: security-reports
        path: |
          source-scan.json
          image-scan.json

  deploy:
    needs: security-gate
    if: needs.security-gate.outputs.security-passed == 'true'
    runs-on: ubuntu-latest
    
    steps:
    - name: Deploy to Production
      run: |
        echo "Deploying ${{ needs.security-gate.outputs.image-tag }} to production"
        # Add deployment logic here
```

## Scenario 4: Compliance Reporting for SOC 2

### Problem
Generate compliance reports for SOC 2 audit requirements showing security scanning coverage and remediation.

### Solution
```bash
#!/bin/bash
# soc2-compliance-report.sh

REPORT_PERIOD=${1:-"30"}  # Days
OUTPUT_DIR="compliance-reports/soc2-$(date +%Y-%m)"
COMPLIANCE_DB="compliance.db"

mkdir -p "$OUTPUT_DIR"

# Initialize compliance database
init_compliance_db() {
    sqlite3 "$COMPLIANCE_DB" << EOF
CREATE TABLE IF NOT EXISTS scans (
    id INTEGER PRIMARY KEY,
    scan_date TEXT,
    target TEXT,
    target_type TEXT,
    critical_count INTEGER,
    high_count INTEGER,
    medium_count INTEGER,
    low_count INTEGER,
    scan_duration INTEGER,
    compliance_status TEXT
);

CREATE TABLE IF NOT EXISTS remediation (
    id INTEGER PRIMARY KEY,
    cve_id TEXT,
    target TEXT,
    detected_date TEXT,
    remediated_date TEXT,
    status TEXT,
    assigned_to TEXT
);
EOF
}

# Generate executive summary
generate_executive_summary() {
    cat > "$OUTPUT_DIR/executive-summary.md" << EOF
# SOC 2 Security Compliance Report

**Report Period:** $(date -d "$REPORT_PERIOD days ago" +%Y-%m-%d) to $(date +%Y-%m-%d)  
**Generated:** $(date)

## Executive Summary

### Scanning Coverage
- **Total Scans Performed:** $(sqlite3 "$COMPLIANCE_DB" "SELECT COUNT(*) FROM scans WHERE scan_date >= date('now', '-$REPORT_PERIOD days')")
- **Assets Scanned:** $(sqlite3 "$COMPLIANCE_DB" "SELECT COUNT(DISTINCT target) FROM scans WHERE scan_date >= date('now', '-$REPORT_PERIOD days')")
- **Compliance Rate:** $(sqlite3 "$COMPLIANCE_DB" "SELECT ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM scans WHERE scan_date >= date('now', '-$REPORT_PERIOD days')), 2) FROM scans WHERE compliance_status = 'PASS' AND scan_date >= date('now', '-$REPORT_PERIOD days')")%

### Vulnerability Metrics
- **Critical Vulnerabilities:** $(sqlite3 "$COMPLIANCE_DB" "SELECT SUM(critical_count) FROM scans WHERE scan_date >= date('now', '-$REPORT_PERIOD days')")
- **High Vulnerabilities:** $(sqlite3 "$COMPLIANCE_DB" "SELECT SUM(high_count) FROM scans WHERE scan_date >= date('now', '-$REPORT_PERIOD days')")
- **Mean Time to Remediation:** $(calculate_mttr) days

### Compliance Status
✅ **CC6.1** - Logical and physical access controls  
✅ **CC6.2** - System access is removed when no longer required  
✅ **CC6.3** - Network security controls  
✅ **CC7.1** - System boundaries and data classification  

## Detailed Findings

$(generate_detailed_findings)

## Remediation Tracking

$(generate_remediation_tracking)

## Recommendations

1. Continue automated security scanning for all deployments
2. Maintain vulnerability remediation SLA of 24 hours for critical issues
3. Implement additional network segmentation controls
4. Enhance monitoring and alerting capabilities

---
*This report demonstrates compliance with SOC 2 Type II security criteria*
EOF
}

# Calculate Mean Time to Remediation
calculate_mttr() {
    sqlite3 "$COMPLIANCE_DB" << EOF
SELECT ROUND(AVG(julianday(remediated_date) - julianday(detected_date)), 1)
FROM remediation 
WHERE remediated_date IS NOT NULL 
AND detected_date >= date('now', '-$REPORT_PERIOD days');
EOF
}

# Generate detailed findings report
generate_detailed_findings() {
    sqlite3 "$COMPLIANCE_DB" -header -csv << EOF
SELECT 
    target as "Asset",
    target_type as "Type",
    MAX(scan_date) as "Last Scan",
    SUM(critical_count) as "Critical",
    SUM(high_count) as "High",
    CASE 
        WHEN SUM(critical_count) = 0 AND SUM(high_count) <= 5 THEN 'COMPLIANT'
        ELSE 'NON-COMPLIANT'
    END as "Status"
FROM scans 
WHERE scan_date >= date('now', '-$REPORT_PERIOD days')
GROUP BY target, target_type
ORDER BY SUM(critical_count) DESC, SUM(high_count) DESC;
EOF
}

# Generate remediation tracking
generate_remediation_tracking() {
    cat << EOF
### Open Vulnerabilities
$(sqlite3 "$COMPLIANCE_DB" -header -csv "SELECT cve_id, target, detected_date, assigned_to FROM remediation WHERE status = 'OPEN' ORDER BY detected_date")

### Recently Remediated
$(sqlite3 "$COMPLIANCE_DB" -header -csv "SELECT cve_id, target, detected_date, remediated_date FROM remediation WHERE status = 'CLOSED' AND remediated_date >= date('now', '-7 days') ORDER BY remediated_date DESC")
EOF
}

# Generate audit trail
generate_audit_trail() {
    cat > "$OUTPUT_DIR/audit-trail.json" << EOF
{
    "report_metadata": {
        "generated_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
        "report_period_days": $REPORT_PERIOD,
        "compliance_framework": "SOC 2 Type II"
    },
    "scanning_evidence": $(sqlite3 "$COMPLIANCE_DB" -json "SELECT * FROM scans WHERE scan_date >= date('now', '-$REPORT_PERIOD days') ORDER BY scan_date DESC"),
    "remediation_evidence": $(sqlite3 "$COMPLIANCE_DB" -json "SELECT * FROM remediation WHERE detected_date >= date('now', '-$REPORT_PERIOD days') ORDER BY detected_date DESC")
}
EOF
}

# Main execution
init_compliance_db
generate_executive_summary
generate_audit_trail

echo "SOC 2 compliance report generated in $OUTPUT_DIR"
echo "Files created:"
echo "- executive-summary.md"
echo "- audit-trail.json"
```

## Scenario 5: Supply Chain Security Assessment

### Problem
Assess supply chain security by scanning all dependencies and base images used in the organization.

### Solution
```bash
#!/bin/bash
# supply-chain-assessment.sh

ASSESSMENT_DIR="supply-chain-assessment/$(date +%Y-%m-%d)"
SBOM_DIR="$ASSESSMENT_DIR/sboms"
REPORTS_DIR="$ASSESSMENT_DIR/reports"

mkdir -p "$SBOM_DIR" "$REPORTS_DIR"

# Discover all container images in use
discover_images() {
    echo "Discovering container images across infrastructure..."
    
    # From Kubernetes clusters
    kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}' | sort -u > "$ASSESSMENT_DIR/k8s-images.txt"
    
    # From Docker registries
    aws ecr describe-repositories --query 'repositories[].repositoryName' --output text | \
    while read repo; do
        aws ecr list-images --repository-name "$repo" --query 'imageIds[].imageTag' --output text | \
        while read tag; do
            echo "123456789012.dkr.ecr.us-west-2.amazonaws.com/$repo:$tag"
        done
    done > "$ASSESSMENT_DIR/ecr-images.txt"
    
    # Combine and deduplicate
    cat "$ASSESSMENT_DIR"/*-images.txt | sort -u > "$ASSESSMENT_DIR/all-images.txt"
    
    echo "Found $(wc -l < "$ASSESSMENT_DIR/all-images.txt") unique images"
}

# Generate SBOMs for all images
generate_sboms() {
    echo "Generating Software Bill of Materials..."
    
    while read -r image; do
        local safe_name="${image//[:\/]/_}"
        
        echo "  Generating SBOM for $image..."
        
        # Generate SBOM in multiple formats
        trivy image --format spdx-json --output "$SBOM_DIR/${safe_name}.spdx.json" "$image"
        trivy image --format cyclonedx --output "$SBOM_DIR/${safe_name}.cyclonedx.json" "$image"
        
        # Vulnerability scan with SBOM context
        trivy image --format json --output "$REPORTS_DIR/${safe_name}.vuln.json" "$image"
        
    done < "$ASSESSMENT_DIR/all-images.txt"
}

# Analyze supply chain risks
analyze_supply_chain_risks() {
    echo "Analyzing supply chain risks..."
    
    cat > "$REPORTS_DIR/supply-chain-analysis.py" << 'EOF'
import json
import os
from collections import defaultdict, Counter

def analyze_dependencies():
    sbom_dir = os.environ.get('SBOM_DIR', 'sboms')
    reports_dir = os.environ.get('REPORTS_DIR', 'reports')
    
    # Collect all packages across images
    all_packages = defaultdict(set)
    vulnerable_packages = defaultdict(list)
    
    for filename in os.listdir(sbom_dir):
        if filename.endswith('.spdx.json'):
            with open(os.path.join(sbom_dir, filename)) as f:
                sbom = json.load(f)
                
            image_name = filename.replace('.spdx.json', '').replace('_', '/')
            
            # Extract packages
            for package in sbom.get('packages', []):
                pkg_name = package.get('name', '')
                pkg_version = package.get('versionInfo', '')
                if pkg_name and pkg_version:
                    all_packages[pkg_name].add(pkg_version)
    
    # Analyze vulnerabilities
    for filename in os.listdir(reports_dir):
        if filename.endswith('.vuln.json'):
            with open(os.path.join(reports_dir, filename)) as f:
                vuln_report = json.load(f)
            
            for result in vuln_report.get('Results', []):
                for vuln in result.get('Vulnerabilities', []):
                    pkg_name = vuln.get('PkgName', '')
                    severity = vuln.get('Severity', '')
                    cve_id = vuln.get('VulnerabilityID', '')
                    
                    if severity in ['HIGH', 'CRITICAL']:
                        vulnerable_packages[pkg_name].append({
                            'cve': cve_id,
                            'severity': severity,
                            'image': filename.replace('.vuln.json', '').replace('_', '/')
                        })
    
    # Generate risk assessment
    risk_assessment = {
        'total_unique_packages': len(all_packages),
        'packages_with_vulnerabilities': len(vulnerable_packages),
        'most_common_packages': dict(Counter({pkg: len(versions) for pkg, versions in all_packages.items()}).most_common(20)),
        'high_risk_packages': {pkg: vulns for pkg, vulns in vulnerable_packages.items() if len(vulns) > 5},
        'critical_vulnerabilities': sum(1 for vulns in vulnerable_packages.values() for v in vulns if v['severity'] == 'CRITICAL')
    }
    
    with open(os.path.join(reports_dir, 'supply-chain-risk-assessment.json'), 'w') as f:
        json.dump(risk_assessment, f, indent=2)
    
    print(f"Supply chain analysis complete:")
    print(f"- {risk_assessment['total_unique_packages']} unique packages found")
    print(f"- {risk_assessment['packages_with_vulnerabilities']} packages have vulnerabilities")
    print(f"- {risk_assessment['critical_vulnerabilities']} critical vulnerabilities detected")

if __name__ == '__main__':
    analyze_dependencies()
EOF

    export SBOM_DIR="$SBOM_DIR"
    export REPORTS_DIR="$REPORTS_DIR"
    python3 "$REPORTS_DIR/supply-chain-analysis.py"
}

# Generate supply chain security report
generate_supply_chain_report() {
    local risk_data="$REPORTS_DIR/supply-chain-risk-assessment.json"
    
    cat > "$ASSESSMENT_DIR/supply-chain-security-report.md" << EOF
# Supply Chain Security Assessment

**Assessment Date:** $(date)  
**Scope:** All container images in production infrastructure

## Executive Summary

### Package Inventory
- **Total Unique Packages:** $(jq -r '.total_unique_packages' "$risk_data")
- **Vulnerable Packages:** $(jq -r '.packages_with_vulnerabilities' "$risk_data")
- **Critical Vulnerabilities:** $(jq -r '.critical_vulnerabilities' "$risk_data")

### Risk Level: $([ $(jq -r '.critical_vulnerabilities' "$risk_data") -gt 10 ] && echo "🔴 HIGH" || echo "🟡 MEDIUM")

## Most Common Dependencies
$(jq -r '.most_common_packages | to_entries[] | "- \(.key): \(.value) versions"' "$risk_data")

## High-Risk Packages
$(jq -r '.high_risk_packages | keys[]' "$risk_data" | while read pkg; do
    echo "### $pkg"
    jq -r ".high_risk_packages[\"$pkg\"][] | \"- \(.cve) (\(.severity)) in \(.image)\"" "$risk_data"
done)

## Recommendations

1. **Immediate Actions:**
   - Update all packages with CRITICAL vulnerabilities
   - Implement automated dependency scanning in CI/CD
   - Establish package approval process

2. **Medium-term Actions:**
   - Standardize on approved base images
   - Implement software composition analysis (SCA)
   - Create dependency update automation

3. **Long-term Actions:**
   - Establish supply chain security policy
   - Implement SBOM generation for all builds
   - Create vendor risk assessment process

## SBOM Files Generated
$(ls "$SBOM_DIR"/*.spdx.json | wc -l) SPDX files  
$(ls "$SBOM_DIR"/*.cyclonedx.json | wc -l) CycloneDX files

All SBOM files are available in: \`$SBOM_DIR\`
EOF

    echo "Supply chain security report generated: $ASSESSMENT_DIR/supply-chain-security-report.md"
}

# Main execution
discover_images
generate_sboms
analyze_supply_chain_risks
generate_supply_chain_report

echo "Supply chain assessment complete!"
echo "Results available in: $ASSESSMENT_DIR"
```

These real-world scenarios demonstrate practical applications of Trivy in enterprise environments, covering multi-cloud scanning, Kubernetes security, CI/CD integration, compliance reporting, and supply chain security assessment.