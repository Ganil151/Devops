# Logging & Cloud Metrics Challenges 📜

Master the art of centralized logging and tracing for distributed systems.

---

## 🏆 Challenge 01: Centralized Log Aggregation
**Objective**: Build a "Log Pipeline" from instance to dashboard.

1.  **Task**: Install the **CloudWatch Agent** or **Fluentd** on a Linux server.
2.  **Logic**: Configure the agent to tail `/var/log/nginx/access.log`.
3.  **Advanced**: Research **Metric Filters**. Create a filter that counts the number of "404" errors in the raw logs and converts them into a CloudWatch Metric.
4.  **Verification**: View the metric graph in the CloudWatch dashboard.

---

## 🏆 Challenge 02: Log Retention & Compliance
**Objective**: Manage log data costs and satisfy legal requirements.

1.  **Scenario**: Your logs are costing $500/month. You discovered they are being kept "Forever."
2.  **Requirement**: Configure a 14-day **Retention Policy** for all Application Log Groups.
3.  **Lab**: Draft an AWS CLI command or Terraform block that ensures all NEW log groups default to a 30-day retention.
4.  **Goal**: Explain why keeping logs "Forever" is a double risk (Financial and Legal/GDPR).

---

## 🏆 Challenge 03: Distributed Tracing Foundations
**Objective**: Follow a single user request across 5 microservices.

1.  **Requirement**: Research **AWS X-Ray** or **OpenTelemetry (Jaeger)**.
2.  **Task**: Define what a **Trace ID** is.
3.  **Discovery**: How does a "Span" differ from a "Trace"?
4.  **Goal**: Diagram the journey of a request that hits:
    *   API Gateway -> Lambda -> SQS -> Worker DynamoDB.

---

## 📁 Solutions
Fluentd configuration files and CloudWatch Agent JSON templates are in the `Boilerplates/` directory.
