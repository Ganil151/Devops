# Compliance in DevSecOps

Complete guide to compliance frameworks, automation, and implementation in DevSecOps environments.

## Compliance Fundamentals

### Key Compliance Frameworks
```bash
# SOC 2 Type II
- Security controls and processes
- Availability and processing integrity
- Confidentiality and privacy
- Continuous monitoring and reporting

# ISO 27001/27002
- Information security management system (ISMS)
- Risk assessment and treatment
- Security controls implementation
- Continuous improvement process

# PCI DSS (Payment Card Industry Data Security Standard)
- Cardholder data protection
- Secure network architecture
- Strong access control measures
- Regular security testing and monitoring

# GDPR (General Data Protection Regulation)
- Data protection by design and default
- Privacy impact assessments
- Data subject rights and consent
- Breach notification requirements

# HIPAA (Health Insurance Portability and Accountability Act)
- Protected health information (PHI) security
- Administrative, physical, and technical safeguards
- Business associate agreements
- Audit controls and integrity
```

## Automated Compliance Frameworks

### SOC 2 Automation
```bash
# SOC 2 Control Implementation
# CC6.1 - Logical and Physical Access Controls

# Automated access review script
#!/bin/bash
# soc2-access-review.sh

echo "=== SOC 2 Access Review Report ==="
echo "Generated on: $(date)"

# AWS IAM Users Review
echo "## AWS IAM Users with Administrative Access"
aws iam list-users --query 'Users[].UserName' --output text | \
while read user; do
  policies=$(aws iam list-attached-user-policies --user-name $user --query 'AttachedPolicies[].PolicyName' --output text)
  if echo "$policies" | grep -q "AdministratorAccess"; then
    last_used=$(aws iam get-user --user-name $user --query 'User.PasswordLastUsed' --output text)
    echo "User: $user, Last Login: $last_used"
  fi
done

# Kubernetes RBAC Review
echo "## Kubernetes Cluster Admin Users"
kubectl get clusterrolebindings -o json | \
jq -r '.items[] | select(.roleRef.name=="cluster-admin") | .subjects[]? | select(.kind=="User") | .name'

# Generate compliance evidence
cat > soc2-evidence.json << EOF
{
  "control": "CC6.1",
  "description": "Logical and Physical Access Controls",
  "evidence_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "aws_admin_users": $(aws iam list-users --query 'Users[?contains(AttachedUserPolicies[].PolicyName, `AdministratorAccess`)].UserName' --output json),
  "k8s_cluster_admins": $(kubectl get clusterrolebindings -o json | jq '[.items[] | select(.roleRef.name=="cluster-admin") | .subjects[]? | select(.kind=="User") | .name]')
}
EOF
```

### PCI DSS Compliance Automation
```python
# PCI DSS Requirement 2.2 - System Hardening
import boto3
import json
from datetime import datetime

class PCIDSSCompliance:
    def __init__(self):
        self.ec2 = boto3.client('ec2')
        self.rds = boto3.client('rds')
        self.compliance_results = []
    
    def check_requirement_2_2(self):
        """PCI DSS 2.2 - Remove unnecessary services and secure configurations"""
        
        # Check EC2 instances for unnecessary services
        instances = self.ec2.describe_instances()
        
        for reservation in instances['Reservations']:
            for instance in reservation['Instances']:
                instance_id = instance['InstanceId']
                
                # Check security groups for unnecessary ports
                for sg in instance['SecurityGroups']:
                    sg_details = self.ec2.describe_security_groups(GroupIds=[sg['GroupId']])
                    
                    for rule in sg_details['SecurityGroups'][0]['IpPermissions']:
                        # Check for dangerous ports open to internet
                        dangerous_ports = [21, 23, 135, 139, 445, 1433, 3389]
                        
                        if rule.get('FromPort') in dangerous_ports:
                            for ip_range in rule.get('IpRanges', []):
                                if ip_range.get('CidrIp') == '0.0.0.0/0':
                                    self.compliance_results.append({
                                        'requirement': '2.2',
                                        'resource': instance_id,
                                        'finding': f"Dangerous port {rule['FromPort']} open to internet",
                                        'status': 'NON_COMPLIANT',
                                        'remediation': f"Restrict access to port {rule['FromPort']}"
                                    })
    
    def check_requirement_3_4(self):
        """PCI DSS 3.4 - Encryption of cardholder data"""
        
        # Check RDS instances for encryption
        db_instances = self.rds.describe_db_instances()
        
        for db in db_instances['DBInstances']:
            if not db.get('StorageEncrypted', False):
                self.compliance_results.append({
                    'requirement': '3.4',
                    'resource': db['DBInstanceIdentifier'],
                    'finding': 'Database not encrypted at rest',
                    'status': 'NON_COMPLIANT',
                    'remediation': 'Enable encryption for RDS instance'
                })
        
        # Check S3 buckets for encryption
        s3 = boto3.client('s3')
        buckets = s3.list_buckets()
        
        for bucket in buckets['Buckets']:
            bucket_name = bucket['Name']
            try:
                encryption = s3.get_bucket_encryption(Bucket=bucket_name)
                self.compliance_results.append({
                    'requirement': '3.4',
                    'resource': bucket_name,
                    'finding': 'S3 bucket encrypted',
                    'status': 'COMPLIANT',
                    'remediation': 'None required'
                })
            except:
                self.compliance_results.append({
                    'requirement': '3.4',
                    'resource': bucket_name,
                    'finding': 'S3 bucket not encrypted',
                    'status': 'NON_COMPLIANT',
                    'remediation': 'Enable S3 bucket encryption'
                })
    
    def generate_pci_report(self):
        """Generate PCI DSS compliance report"""
        total_checks = len(self.compliance_results)
        compliant_checks = len([r for r in self.compliance_results if r['status'] == 'COMPLIANT'])
        
        report = {
            'framework': 'PCI DSS',
            'assessment_date': datetime.now().isoformat(),
            'total_checks': total_checks,
            'compliant_checks': compliant_checks,
            'compliance_percentage': (compliant_checks / total_checks) * 100 if total_checks > 0 else 0,
            'findings': self.compliance_results,
            'non_compliant_items': [r for r in self.compliance_results if r['status'] == 'NON_COMPLIANT']
        }
        
        return report

# Usage
pci_checker = PCIDSSCompliance()
pci_checker.check_requirement_2_2()
pci_checker.check_requirement_3_4()
report = pci_checker.generate_pci_report()

print(json.dumps(report, indent=2))
```

### GDPR Compliance Automation
```bash
# GDPR Article 32 - Security of Processing
# Automated data protection assessment

#!/bin/bash
# gdpr-security-assessment.sh

echo "=== GDPR Security Assessment ==="

# Check for encryption at rest
echo "## Encryption at Rest Assessment"

# AWS S3 buckets
echo "### S3 Bucket Encryption Status"
aws s3api list-buckets --query 'Buckets[].Name' --output text | \
while read bucket; do
  encryption=$(aws s3api get-bucket-encryption --bucket $bucket 2>/dev/null)
  if [ $? -eq 0 ]; then
    echo "✓ $bucket: Encrypted"
  else
    echo "✗ $bucket: Not encrypted (GDPR Risk)"
  fi
done

# Check for data retention policies
echo "### Data Retention Policies"
aws s3api list-buckets --query 'Buckets[].Name' --output text | \
while read bucket; do
  lifecycle=$(aws s3api get-bucket-lifecycle-configuration --bucket $bucket 2>/dev/null)
  if [ $? -eq 0 ]; then
    echo "✓ $bucket: Lifecycle policy configured"
  else
    echo "✗ $bucket: No lifecycle policy (GDPR Article 5 Risk)"
  fi
done

# Check for access logging
echo "### Access Logging (GDPR Article 30)"
aws s3api list-buckets --query 'Buckets[].Name' --output text | \
while read bucket; do
  logging=$(aws s3api get-bucket-logging --bucket $bucket 2>/dev/null)
  if echo "$logging" | grep -q "LoggingEnabled"; then
    echo "✓ $bucket: Access logging enabled"
  else
    echo "✗ $bucket: Access logging disabled (GDPR Article 30 Risk)"
  fi
done

# Generate GDPR compliance report
cat > gdpr-compliance-report.json << EOF
{
  "framework": "GDPR",
  "assessment_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "articles_assessed": [
    "Article 5 - Data Minimization",
    "Article 30 - Records of Processing",
    "Article 32 - Security of Processing"
  ],
  "encryption_status": "$(aws s3api list-buckets --query 'length(Buckets[])' --output text) buckets assessed",
  "recommendations": [
    "Enable encryption for all data stores",
    "Implement data retention policies",
    "Enable comprehensive access logging",
    "Regular security assessments"
  ]
}
EOF
```

## Policy as Code for Compliance

### Open Policy Agent (OPA) Compliance Policies
```rego
# SOC 2 CC6.1 - Access Control Policy
package soc2.cc6_1

# Deny if user has administrative access without MFA
deny[msg] {
  input.request.kind.kind == "User"
  user := input.request.object
  
  # Check if user has admin privileges
  has_admin_access(user)
  
  # Check if MFA is not enabled
  not user.spec.mfaEnabled
  
  msg := "SOC 2 CC6.1 Violation: Administrative users must have MFA enabled"
}

has_admin_access(user) {
  user.spec.groups[_] == "system:masters"
}

has_admin_access(user) {
  user.spec.clusterRoleBindings[_].roleRef.name == "cluster-admin"
}

# PCI DSS Requirement 7 - Access Control Policy
package pcidss.requirement7

# Deny if service account has unnecessary privileges
deny[msg] {
  input.request.kind.kind == "ServiceAccount"
  sa := input.request.object
  
  # Check for overly broad permissions
  has_wildcard_permissions(sa)
  
  msg := "PCI DSS 7.1 Violation: Service account has excessive privileges"
}

has_wildcard_permissions(sa) {
  sa.spec.rules[_].resources[_] == "*"
  sa.spec.rules[_].verbs[_] == "*"
}

# GDPR Article 25 - Data Protection by Design
package gdpr.article25

# Deny if data store doesn't have encryption
deny[msg] {
  input.request.kind.kind == "PersistentVolumeClaim"
  pvc := input.request.object
  
  not pvc.spec.storageClassName == "encrypted-storage"
  
  msg := "GDPR Article 25 Violation: Data must be encrypted by default"
}

# Deny if service doesn't have data retention policy
deny[msg] {
  input.request.kind.kind == "Deployment"
  deployment := input.request.object
  
  not deployment.metadata.annotations["data-retention-policy"]
  
  msg := "GDPR Article 5 Violation: Data retention policy must be specified"
}
```

### Kubernetes Compliance Policies
```yaml
# Gatekeeper ConstraintTemplate for SOC 2 Compliance
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: soc2securitycontext
spec:
  crd:
    spec:
      names:
        kind: SOC2SecurityContext
      validation:
        properties:
          runAsNonRoot:
            type: boolean
          readOnlyRootFilesystem:
            type: boolean
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package soc2securitycontext
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not container.securityContext.runAsNonRoot
          msg := "SOC 2 CC6.1: Container must run as non-root user"
        }
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not container.securityContext.readOnlyRootFilesystem
          msg := "SOC 2 CC6.1: Container must have read-only root filesystem"
        }

---
# Constraint using the template
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: SOC2SecurityContext
metadata:
  name: soc2-security-requirements
spec:
  match:
    kinds:
      - apiGroups: ["apps"]
        kinds: ["Deployment"]
  parameters:
    runAsNonRoot: true
    readOnlyRootFilesystem: true
```

## Continuous Compliance Monitoring

### Compliance Dashboard
```python
# Compliance monitoring dashboard
import json
import boto3
from datetime import datetime, timedelta
import matplotlib.pyplot as plt

class ComplianceDashboard:
    def __init__(self):
        self.frameworks = ['SOC2', 'PCI_DSS', 'GDPR', 'HIPAA']
        self.compliance_data = {}
    
    def collect_compliance_metrics(self):
        """Collect compliance metrics from various sources"""
        
        # AWS Config compliance
        config_client = boto3.client('config')
        
        for framework in self.frameworks:
            compliance_summary = config_client.get_compliance_summary_by_config_rule()
            
            self.compliance_data[framework] = {
                'compliant_rules': compliance_summary['ComplianceSummary']['ComplianceByConfigRule']['COMPLIANT'],
                'non_compliant_rules': compliance_summary['ComplianceSummary']['ComplianceByConfigRule']['NON_COMPLIANT'],
                'total_rules': compliance_summary['ComplianceSummary']['ComplianceByConfigRule']['COMPLIANT'] + 
                              compliance_summary['ComplianceSummary']['ComplianceByConfigRule']['NON_COMPLIANT']
            }
    
    def calculate_compliance_scores(self):
        """Calculate compliance scores for each framework"""
        scores = {}
        
        for framework, data in self.compliance_data.items():
            if data['total_rules'] > 0:
                score = (data['compliant_rules'] / data['total_rules']) * 100
                scores[framework] = round(score, 2)
            else:
                scores[framework] = 0
        
        return scores
    
    def generate_compliance_trends(self):
        """Generate compliance trends over time"""
        # Simulate historical data (in real implementation, fetch from database)
        dates = [(datetime.now() - timedelta(days=x)).strftime('%Y-%m-%d') for x in range(30, 0, -1)]
        
        trends = {}
        for framework in self.frameworks:
            # Simulate trend data
            base_score = self.compliance_data.get(framework, {}).get('compliant_rules', 0) / max(1, self.compliance_data.get(framework, {}).get('total_rules', 1)) * 100
            trends[framework] = [base_score + (i % 5 - 2) for i in range(30)]
        
        return dates, trends
    
    def create_compliance_report(self):
        """Create comprehensive compliance report"""
        scores = self.calculate_compliance_scores()
        dates, trends = self.generate_compliance_trends()
        
        # Create visualizations
        fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(15, 10))
        
        # Compliance scores bar chart
        frameworks = list(scores.keys())
        score_values = list(scores.values())
        colors = ['green' if score >= 95 else 'orange' if score >= 80 else 'red' for score in score_values]
        
        ax1.bar(frameworks, score_values, color=colors)
        ax1.set_title('Current Compliance Scores')
        ax1.set_ylabel('Compliance %')
        ax1.set_ylim(0, 100)
        
        # Add score labels on bars
        for i, score in enumerate(score_values):
            ax1.text(i, score + 1, f'{score}%', ha='center')
        
        # Compliance trends
        for framework, trend_data in trends.items():
            ax2.plot(dates[::5], trend_data[::5], marker='o', label=framework)
        ax2.set_title('Compliance Trends (30 Days)')
        ax2.set_ylabel('Compliance %')
        ax2.legend()
        ax2.tick_params(axis='x', rotation=45)
        
        # Risk distribution
        risk_levels = ['Low', 'Medium', 'High', 'Critical']
        risk_counts = [15, 8, 3, 1]  # Example data
        ax3.pie(risk_counts, labels=risk_levels, autopct='%1.1f%%', startangle=90)
        ax3.set_title('Risk Distribution')
        
        # Framework comparison
        framework_metrics = {
            'Controls Implemented': [45, 38, 52, 41],
            'Controls Pending': [5, 12, 8, 9],
            'Controls Failed': [2, 3, 1, 2]
        }
        
        x = range(len(frameworks))
        width = 0.25
        
        for i, (metric, values) in enumerate(framework_metrics.items()):
            ax4.bar([xi + width * i for xi in x], values, width, label=metric)
        
        ax4.set_title('Framework Implementation Status')
        ax4.set_xlabel('Frameworks')
        ax4.set_ylabel('Number of Controls')
        ax4.set_xticks([xi + width for xi in x])
        ax4.set_xticklabels(frameworks)
        ax4.legend()
        
        plt.tight_layout()
        plt.savefig('compliance-dashboard.png', dpi=300, bbox_inches='tight')
        
        # Generate JSON report
        report = {
            'report_date': datetime.now().isoformat(),
            'compliance_scores': scores,
            'overall_compliance': sum(scores.values()) / len(scores) if scores else 0,
            'frameworks_assessed': len(self.frameworks),
            'high_risk_findings': sum(1 for score in scores.values() if score < 80),
            'recommendations': self.generate_recommendations(scores)
        }
        
        return report
    
    def generate_recommendations(self, scores):
        """Generate compliance recommendations"""
        recommendations = []
        
        for framework, score in scores.items():
            if score < 80:
                recommendations.append(f"Immediate attention required for {framework} compliance (Score: {score}%)")
            elif score < 95:
                recommendations.append(f"Improvement needed for {framework} compliance (Score: {score}%)")
        
        if not recommendations:
            recommendations.append("All frameworks meeting compliance thresholds. Continue monitoring.")
        
        return recommendations

# Usage
dashboard = ComplianceDashboard()
dashboard.collect_compliance_metrics()
report = dashboard.create_compliance_report()

print(json.dumps(report, indent=2))
```

## Audit Trail and Evidence Collection

### Automated Evidence Collection
```bash
#!/bin/bash
# compliance-evidence-collector.sh

EVIDENCE_DIR="/var/compliance/evidence/$(date +%Y%m%d)"
mkdir -p $EVIDENCE_DIR

echo "=== Compliance Evidence Collection ==="
echo "Collection Date: $(date)"
echo "Evidence Directory: $EVIDENCE_DIR"

# SOC 2 Evidence Collection
echo "## Collecting SOC 2 Evidence"

# CC6.1 - Access Controls
echo "### Access Control Evidence"
aws iam generate-credential-report
aws iam get-credential-report --query 'Content' --output text | base64 -d > $EVIDENCE_DIR/iam-credential-report.csv

# CC6.2 - Logical Access
kubectl get rolebindings,clusterrolebindings -o json > $EVIDENCE_DIR/k8s-rbac-bindings.json

# CC6.3 - Network Security
aws ec2 describe-security-groups > $EVIDENCE_DIR/security-groups.json
aws ec2 describe-network-acls > $EVIDENCE_DIR/network-acls.json

# PCI DSS Evidence Collection
echo "## Collecting PCI DSS Evidence"

# Requirement 1 - Firewall Configuration
iptables -L -n > $EVIDENCE_DIR/iptables-rules.txt

# Requirement 2 - System Hardening
nmap -sS localhost > $EVIDENCE_DIR/localhost-port-scan.txt

# Requirement 3 - Cardholder Data Protection
aws s3api list-buckets --query 'Buckets[].Name' --output text | \
while read bucket; do
  aws s3api get-bucket-encryption --bucket $bucket > $EVIDENCE_DIR/s3-encryption-$bucket.json 2>/dev/null || echo "No encryption" > $EVIDENCE_DIR/s3-encryption-$bucket.json
done

# GDPR Evidence Collection
echo "## Collecting GDPR Evidence"

# Article 30 - Records of Processing
aws logs describe-log-groups > $EVIDENCE_DIR/cloudwatch-log-groups.json

# Article 32 - Security Measures
aws kms list-keys > $EVIDENCE_DIR/kms-keys.json

# Generate evidence manifest
cat > $EVIDENCE_DIR/evidence-manifest.json << EOF
{
  "collection_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "frameworks": ["SOC2", "PCI_DSS", "GDPR"],
  "evidence_files": [
    "iam-credential-report.csv",
    "k8s-rbac-bindings.json",
    "security-groups.json",
    "network-acls.json",
    "iptables-rules.txt",
    "localhost-port-scan.txt",
    "cloudwatch-log-groups.json",
    "kms-keys.json"
  ],
  "collection_method": "automated",
  "retention_period": "7_years"
}
EOF

# Create tamper-evident archive
tar -czf $EVIDENCE_DIR.tar.gz -C /var/compliance/evidence $(basename $EVIDENCE_DIR)
sha256sum $EVIDENCE_DIR.tar.gz > $EVIDENCE_DIR.tar.gz.sha256

echo "Evidence collection completed: $EVIDENCE_DIR.tar.gz"
```

## Compliance Reporting and Attestation

### Automated Compliance Reports
```python
# Compliance report generator
from jinja2 import Template
import json
from datetime import datetime

class ComplianceReportGenerator:
    def __init__(self):
        self.report_template = """
# {{ framework }} Compliance Report

**Assessment Period:** {{ assessment_period }}
**Report Generated:** {{ report_date }}
**Overall Compliance Score:** {{ overall_score }}%

## Executive Summary

This report provides an assessment of {{ framework }} compliance for the period {{ assessment_period }}.
The overall compliance score is {{ overall_score }}%, {% if overall_score >= 95 %}meeting{% else %}below{% endif %} the target threshold of 95%.

## Compliance Status by Control

{% for control in controls %}
### {{ control.id }} - {{ control.name }}
- **Status:** {{ control.status }}
- **Score:** {{ control.score }}%
- **Evidence:** {{ control.evidence_count }} items collected
{% if control.findings %}
- **Findings:** {{ control.findings|length }} issues identified
{% for finding in control.findings %}
  - {{ finding }}
{% endfor %}
{% endif %}

{% endfor %}

## Recommendations

{% for recommendation in recommendations %}
- {{ recommendation }}
{% endfor %}

## Attestation

This report has been generated automatically based on continuous monitoring and assessment.
All evidence has been collected and stored in accordance with retention policies.

**Report Signature:** {{ report_signature }}
        """
    
    def generate_soc2_report(self, assessment_data):
        """Generate SOC 2 compliance report"""
        
        controls = [
            {
                'id': 'CC6.1',
                'name': 'Logical and Physical Access Controls',
                'status': 'COMPLIANT',
                'score': 98,
                'evidence_count': 15,
                'findings': []
            },
            {
                'id': 'CC6.2',
                'name': 'Logical Access - Authentication',
                'status': 'NON_COMPLIANT',
                'score': 85,
                'evidence_count': 12,
                'findings': [
                    '3 users without MFA enabled',
                    '1 service account with excessive privileges'
                ]
            },
            {
                'id': 'CC6.3',
                'name': 'Network Security',
                'status': 'COMPLIANT',
                'score': 96,
                'evidence_count': 8,
                'findings': []
            }
        ]
        
        overall_score = sum(control['score'] for control in controls) / len(controls)
        
        recommendations = [
            'Enable MFA for all administrative users',
            'Review and reduce service account privileges',
            'Implement automated access reviews'
        ]
        
        template = Template(self.report_template)
        report = template.render(
            framework='SOC 2 Type II',
            assessment_period='Q1 2024',
            report_date=datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC'),
            overall_score=round(overall_score, 1),
            controls=controls,
            recommendations=recommendations,
            report_signature=self.generate_report_signature()
        )
        
        return report
    
    def generate_report_signature(self):
        """Generate cryptographic signature for report integrity"""
        import hashlib
        
        # In production, use proper digital signatures
        report_hash = hashlib.sha256(str(datetime.now()).encode()).hexdigest()[:16]
        return f"AUTO-{report_hash}"
    
    def export_to_formats(self, report_content, base_filename):
        """Export report to multiple formats"""
        
        # Markdown
        with open(f"{base_filename}.md", 'w') as f:
            f.write(report_content)
        
        # HTML (requires markdown2)
        try:
            import markdown2
            html_content = markdown2.markdown(report_content)
            with open(f"{base_filename}.html", 'w') as f:
                f.write(html_content)
        except ImportError:
            print("markdown2 not available, skipping HTML export")
        
        # PDF (requires reportlab)
        try:
            from reportlab.lib.pagesizes import letter
            from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
            from reportlab.lib.styles import getSampleStyleSheet
            
            doc = SimpleDocTemplate(f"{base_filename}.pdf", pagesize=letter)
            styles = getSampleStyleSheet()
            story = []
            
            # Convert markdown to PDF (simplified)
            lines = report_content.split('\n')
            for line in lines:
                if line.startswith('# '):
                    story.append(Paragraph(line[2:], styles['Title']))
                elif line.startswith('## '):
                    story.append(Paragraph(line[3:], styles['Heading1']))
                elif line.startswith('### '):
                    story.append(Paragraph(line[4:], styles['Heading2']))
                elif line.strip():
                    story.append(Paragraph(line, styles['Normal']))
                story.append(Spacer(1, 12))
            
            doc.build(story)
        except ImportError:
            print("reportlab not available, skipping PDF export")

# Usage
generator = ComplianceReportGenerator()
soc2_report = generator.generate_soc2_report({})
generator.export_to_formats(soc2_report, "soc2-compliance-report")

print("Compliance reports generated successfully")
```

## Best Practices

### Compliance Automation Strategy
```bash
# 1. Continuous Monitoring
- Real-time compliance checking
- Automated evidence collection
- Continuous control testing
- Drift detection and remediation

# 2. Policy as Code
- Version-controlled compliance policies
- Automated policy deployment
- Policy testing and validation
- Change management processes

# 3. Evidence Management
- Automated evidence collection
- Tamper-evident storage
- Retention policy enforcement
- Audit trail maintenance

# 4. Reporting and Attestation
- Automated report generation
- Multi-format export capabilities
- Digital signatures for integrity
- Stakeholder distribution automation

# 5. Integration and Orchestration
- CI/CD pipeline integration
- SIEM and monitoring integration
- Ticketing system integration
- Notification and alerting
```