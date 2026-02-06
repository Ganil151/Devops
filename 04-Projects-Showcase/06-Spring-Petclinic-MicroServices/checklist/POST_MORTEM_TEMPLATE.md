# 📟 Incident Post-Mortem Template
**Project**: Spring PetClinic Microservices
**Environment**: [Dev/Prod]
**Incident Date**: YYYY-MM-DD
**Status**: [Completed/Action-Items-Pending]

## 📝 Executive Summary
A brief description of the incident, its impact, and the resolution.

## 📈 Impact
- **Services Affected**: (e.g., API Gateway, Visits Service)
- **User Impact**: (e.g., 5% of users experienced 503 errors)
- **Duration**: [Start Time] to [Resolution Time]

## 🕒 Timeline
- **HH:MM**: Incident detected via [PagerDuty/CloudWatch/Prometheus].
- **HH:MM**: Senior On-call engineer acknowledged incident.
- **HH:MM**: Root cause identified as [Description].
- **HH:MM**: Mitigation [Action] applied.
- **HH:MM**: Incident resolved and services healthy.

## 🔍 Root Cause Analysis (RCA)
Detailed technical explanation of why the incident occurred. Use the "5 Whys" technique.

## 🛠️ Resolution & Recovery
How was the issue fixed? (e.g., Jenkins pipeline rollback to previous tag `${IMAGE_TAG}`).

## 🛡️ Preventative Measures (Action Items)
| ID | Action Item | Owner | Due Date |
| :-- | :--- | :--- | :--- |
| 1 | Improve liveness probe for Visits service | @devops | YYYY-MM-DD |
| 2 | Add CloudWatch Alarm for DB connection limits | @sre | YYYY-MM-DD |
| 3 | Update Runbook documentation | @team | YYYY-MM-DD |

---
*Failure is an opportunity to learn. This document is blameless.*
