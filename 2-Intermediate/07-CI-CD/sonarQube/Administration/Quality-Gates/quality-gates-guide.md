# SonarQube Quality Gates Guide

Comprehensive guide for configuring and managing Quality Gates in SonarQube to enforce code quality standards.

## What are Quality Gates?

Quality Gates are sets of conditions that must be met for a project to pass quality checks. They act as automated gatekeepers that prevent poor-quality code from being deployed to production.

### Key Benefits
- **Automated Quality Control**: Enforce quality standards without manual intervention
- **Fail-Fast Approach**: Catch issues early in the development cycle
- **Consistent Standards**: Apply uniform quality criteria across all projects
- **Risk Mitigation**: Prevent deployment of vulnerable or buggy code

## Default Quality Gate

### Sonar Way (Default)
SonarQube comes with a built-in "Sonar Way" quality gate with these conditions:

```
Coverage on New Code < 80%
Duplicated Lines (%) on New Code > 3%
Maintainability Rating on New Code > A
Reliability Rating on New Code > A
Security Rating on New Code > A
Security Hotspots Reviewed on New Code < 100%
```

### Understanding Ratings
- **A**: Best (0 issues or very low technical debt)
- **B**: Good (minor issues)
- **C**: Average (moderate issues)
- **D**: Poor (major issues)
- **E**: Worst (critical issues or very high technical debt)

## Creating Custom Quality Gates

### Step 1: Access Quality Gates
1. Login to SonarQube as Administrator
2. Navigate to **Quality Gates** in the top menu
3. Click **Create** to create a new quality gate

### Step 2: Basic Configuration
```
Name: Production Quality Gate
Description: Strict quality gate for production deployments
Copy from: Sonar way (optional)
```

### Step 3: Add Conditions

#### Coverage Conditions
```
Metric: Coverage on New Code
Operator: is less than
Error threshold: 80
Warning threshold: 70
```

```
Metric: Coverage
Operator: is less than
Error threshold: 60
Warning threshold: 50
```

#### Duplication Conditions
```
Metric: Duplicated Lines (%) on New Code
Operator: is greater than
Error threshold: 3
Warning threshold: 2
```

#### Security Conditions
```
Metric: Security Rating on New Code
Operator: is worse than
Error threshold: A
```

```
Metric: Security Hotspots Reviewed on New Code
Operator: is less than
Error threshold: 100
Warning threshold: 95
```

#### Reliability Conditions
```
Metric: Reliability Rating on New Code
Operator: is worse than
Error threshold: A
```

```
Metric: Bugs on New Code
Operator: is greater than
Error threshold: 0
```

#### Maintainability Conditions
```
Metric: Maintainability Rating on New Code
Operator: is worse than
Error threshold: A
```

```
Metric: Technical Debt Ratio on New Code
Operator: is greater than
Error threshold: 5
Warning threshold: 3
```

## Quality Gate Examples

### 1. Strict Production Gate
```json
{
  "name": "Strict Production",
  "conditions": [
    {
      "metric": "new_coverage",
      "op": "LT",
      "error": "85"
    },
    {
      "metric": "new_duplicated_lines_density",
      "op": "GT",
      "error": "2"
    },
    {
      "metric": "new_maintainability_rating",
      "op": "GT",
      "error": "1"
    },
    {
      "metric": "new_reliability_rating",
      "op": "GT",
      "error": "1"
    },
    {
      "metric": "new_security_rating",
      "op": "GT",
      "error": "1"
    },
    {
      "metric": "new_security_hotspots_reviewed",
      "op": "LT",
      "error": "100"
    },
    {
      "metric": "new_bugs",
      "op": "GT",
      "error": "0"
    },
    {
      "metric": "new_vulnerabilities",
      "op": "GT",
      "error": "0"
    }
  ]
}
```

### 2. Development Gate
```json
{
  "name": "Development",
  "conditions": [
    {
      "metric": "new_coverage",
      "op": "LT",
      "error": "70",
      "warning": "60"
    },
    {
      "metric": "new_duplicated_lines_density",
      "op": "GT",
      "error": "5",
      "warning": "3"
    },
    {
      "metric": "new_maintainability_rating",
      "op": "GT",
      "error": "2",
      "warning": "1"
    },
    {
      "metric": "new_reliability_rating",
      "op": "GT",
      "error": "2",
      "warning": "1"
    },
    {
      "metric": "new_security_rating",
      "op": "GT",
      "error": "2",
      "warning": "1"
    }
  ]
}
```

### 3. Legacy Code Gate
```json
{
  "name": "Legacy Code",
  "conditions": [
    {
      "metric": "new_coverage",
      "op": "LT",
      "error": "50"
    },
    {
      "metric": "new_duplicated_lines_density",
      "op": "GT",
      "error": "10"
    },
    {
      "metric": "new_bugs",
      "op": "GT",
      "error": "5"
    },
    {
      "metric": "new_vulnerabilities",
      "op": "GT",
      "error": "2"
    },
    {
      "metric": "new_code_smells",
      "op": "GT",
      "error": "50"
    }
  ]
}
```

## Assigning Quality Gates to Projects

### Method 1: Web Interface
1. Go to **Project Settings > Quality Gate**
2. Select desired quality gate from dropdown
3. Click **Save**

### Method 2: Project Selection
1. Go to **Quality Gates**
2. Select your quality gate
3. Click **Projects** tab
4. Use **Select** or **Deselect** to manage projects

### Method 3: Bulk Assignment
```bash
# Using SonarQube API
curl -X POST \
  -u admin:admin \
  "http://sonarqube:9000/api/qualitygates/select" \
  -d "gateId=1&projectKey=my-project"

# Bulk assignment script
#!/bin/bash
PROJECTS=("project1" "project2" "project3")
GATE_ID=2

for project in "${PROJECTS[@]}"; do
  curl -X POST \
    -u admin:admin \
    "http://sonarqube:9000/api/qualitygates/select" \
    -d "gateId=${GATE_ID}&projectKey=${project}"
done
```

## Advanced Quality Gate Configurations

### Branch-Specific Quality Gates
```bash
# Set quality gate for specific branch
curl -X POST \
  -u admin:admin \
  "http://sonarqube:9000/api/qualitygates/select" \
  -d "gateId=1&projectKey=my-project&branch=main"

# Different gate for feature branches
curl -X POST \
  -u admin:admin \
  "http://sonarqube:9000/api/qualitygates/select" \
  -d "gateId=2&projectKey=my-project&branch=feature/*"
```

### Conditional Quality Gates
```groovy
// Jenkins Pipeline with conditional quality gates
stage('Quality Gate') {
    steps {
        script {
            def qg = waitForQualityGate()
            
            if (env.BRANCH_NAME == 'main') {
                // Strict gate for main branch
                if (qg.status != 'OK') {
                    error "Production quality gate failed: ${qg.status}"
                }
            } else if (env.BRANCH_NAME.startsWith('release/')) {
                // Medium strictness for release branches
                if (qg.status == 'ERROR') {
                    error "Release quality gate failed: ${qg.status}"
                }
            } else {
                // Lenient for feature branches
                if (qg.status == 'ERROR') {
                    unstable "Feature branch quality gate failed: ${qg.status}"
                }
            }
        }
    }
}
```

## Quality Gate Metrics Reference

### Coverage Metrics
```
Coverage: Overall test coverage percentage
Coverage on New Code: Test coverage for new/changed code
Line Coverage: Percentage of lines covered by tests
Branch Coverage: Percentage of branches covered by tests
```

### Duplication Metrics
```
Duplicated Lines (%): Percentage of duplicated lines
Duplicated Lines (%) on New Code: Duplication in new code
Duplicated Blocks: Number of duplicated blocks
Duplicated Files: Number of files with duplications
```

### Maintainability Metrics
```
Maintainability Rating: A-E rating based on technical debt
Technical Debt: Time needed to fix maintainability issues
Technical Debt Ratio: Technical debt vs development cost
Code Smells: Maintainability issues count
```

### Reliability Metrics
```
Reliability Rating: A-E rating based on bugs
Bugs: Number of bug issues
Bugs on New Code: Bugs in new/changed code
```

### Security Metrics
```
Security Rating: A-E rating based on vulnerabilities
Vulnerabilities: Number of security vulnerabilities
Security Hotspots: Potential security issues requiring review
Security Hotspots Reviewed: Percentage of reviewed hotspots
```

### Size Metrics
```
Lines of Code: Total lines of code
Lines of Code on New Code: New lines added
Statements: Number of statements
Functions: Number of functions/methods
Classes: Number of classes
Files: Number of files
```

## Quality Gate API Operations

### Create Quality Gate
```bash
curl -X POST \
  -u admin:admin \
  "http://sonarqube:9000/api/qualitygates/create" \
  -d "name=My Custom Gate"
```

### Add Condition
```bash
curl -X POST \
  -u admin:admin \
  "http://sonarqube:9000/api/qualitygates/create_condition" \
  -d "gateId=1&metric=new_coverage&op=LT&error=80"
```

### Update Condition
```bash
curl -X POST \
  -u admin:admin \
  "http://sonarqube:9000/api/qualitygates/update_condition" \
  -d "id=1&metric=new_coverage&op=LT&error=85&warning=75"
```

### Delete Condition
```bash
curl -X POST \
  -u admin:admin \
  "http://sonarqube:9000/api/qualitygates/delete_condition" \
  -d "id=1"
```

### Get Quality Gate Status
```bash
curl -u admin:admin \
  "http://sonarqube:9000/api/qualitygates/project_status?projectKey=my-project"
```

## Monitoring Quality Gates

### Quality Gate Dashboard
Create custom dashboard to monitor quality gate status:

```sql
-- SQL query for quality gate metrics
SELECT 
    p.name as project_name,
    p.kee as project_key,
    qg.name as quality_gate,
    qgs.status as gate_status,
    s.created_at as last_analysis
FROM projects p
JOIN project_qgates pqg ON p.uuid = pqg.project_uuid
JOIN quality_gates qg ON pqg.quality_gate_uuid = qg.uuid
LEFT JOIN snapshots s ON p.uuid = s.component_uuid
LEFT JOIN quality_gate_status qgs ON s.uuid = qgs.snapshot_uuid
WHERE p.qualifier = 'TRK'
ORDER BY s.created_at DESC;
```

### Automated Reporting
```bash
#!/bin/bash
# Quality gate status report script

SONAR_URL="http://sonarqube:9000"
SONAR_TOKEN="your-token"

# Get all projects
projects=$(curl -s -u ${SONAR_TOKEN}: \
  "${SONAR_URL}/api/projects/search" | \
  jq -r '.components[].key')

echo "Quality Gate Status Report - $(date)"
echo "=================================="

for project in $projects; do
  status=$(curl -s -u ${SONAR_TOKEN}: \
    "${SONAR_URL}/api/qualitygates/project_status?projectKey=${project}" | \
    jq -r '.projectStatus.status')
  
  echo "Project: $project - Status: $status"
done
```

## Best Practices

### 1. Start with Sonar Way
- Begin with the default "Sonar Way" quality gate
- Gradually customize based on team needs
- Don't make gates too strict initially

### 2. Focus on New Code
- Prioritize conditions on new code over overall code
- Use "New Code" metrics to prevent quality degradation
- Allow legacy code to improve gradually

### 3. Gradual Implementation
```
Phase 1: Warning-only quality gates
Phase 2: Fail builds on critical issues only
Phase 3: Full quality gate enforcement
```

### 4. Team-Specific Gates
- Create different gates for different teams/projects
- Consider project maturity and team experience
- Align gates with business requirements

### 5. Regular Review
- Review and adjust quality gates quarterly
- Monitor gate pass/fail rates
- Gather team feedback on gate effectiveness

### 6. Documentation
- Document quality gate rationale
- Provide clear guidance on fixing failures
- Train teams on quality gate concepts

## Troubleshooting Quality Gates

### Common Issues

#### Quality Gate Always Fails
```bash
# Check project analysis
curl -u admin:admin \
  "http://sonarqube:9000/api/measures/component?component=my-project&metricKeys=coverage,bugs,vulnerabilities"

# Verify quality gate conditions
curl -u admin:admin \
  "http://sonarqube:9000/api/qualitygates/show?id=1"
```

#### Webhook Not Working
```bash
# Test webhook manually
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"status":"OK","projectKey":"my-project"}' \
  "http://jenkins:8080/sonarqube-webhook/"
```

#### Incorrect Metrics
```bash
# Check available metrics
curl -u admin:admin \
  "http://sonarqube:9000/api/metrics/search"

# Verify project metrics
curl -u admin:admin \
  "http://sonarqube:9000/api/measures/component?component=my-project&metricKeys=ncloc,coverage,bugs"
```

This completes the comprehensive Quality Gates guide with configuration examples, API operations, monitoring, and best practices.