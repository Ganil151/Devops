# Splunk: Enterprise Log Management & SIEM

Splunk is an industry-leading platform for searching, monitoring, and analyzing machine-generated big data via a Web-style interface. It captures, indexes, and correlates real-time data in a searchable repository from which it can generate graphs, reports, alerts, dashboards, and visualizations.

---

## �️ Core Architecture & The Data Pipeline

Splunk's horizontal scaling is achieved through three primary components, moving data through a structured pipeline.

### 1. Forwarders (Collection)
Lightweight agents that send data to Splunk Indexers.
- **Universal Forwarder (UF)**: The standard agent for 99% of data collection. No parsing, just streaming.
- **Heavy Forwarder (HF)**: A full Splunk instance that parses data (identifies `sourcetypes`) before forwarding. Useful for masking sensitive data (e.g., PII) before it leaves a secure zone.

### 2. Indexers (Processing & Storage)
The Indexer receives data from forwarders, breaks it into events, and stores it in **Buckets**.
- **Parsing Pipeline**: Breaks the byte stream into lines, identifies timestamps, and extracts metadata like `host`, `source`, and `sourcetype`.
- **Indexing Pipeline**: Writes the parsed events to disk and builds index files for rapid retrieval.

### 3. Search Heads (Intelligence)
The web interface where users run queries. A Search Head sends the user's SPL query to all connected Indexers, collects the results, and performs final aggregations.

---

## 🔍 Practical SPL Examples (Splunk Processing Language)

SPL is what makes Splunk powerful. It uses a "search command | transformation" pattern.

### 1. Monitoring Web Traffic Errors
Find all 404 or 500 errors and count them by the endpoint URL.
```sql
index=web_logs (status=404 OR status=500)
| stats count by uri_path
| sort - count
```

### 2. Detecting Failed Login Bruteforce
Identify users who have failed to login more than 5 times within a 1-minute window.
```sql
index=security status=failure action=login
| stats count as login_attempts by user
| where login_attempts > 5
```

### 3. Transaction Monitoring (End-to-End Latency)
Calculate the time taken for a checkout process (from 'start' event to 'success' event) using a unique `transaction_id`.
```sql
index=app_logs transaction_id=*
| transaction transaction_id startswith="action=start" endswith="action=success"
| table transaction_id duration
| eval avg_duration = duration/60
```

---

## 🚨 Advanced Alerting
Splunk alerts are triggered by search results. You can configure:
- **Per-Result Alerting**: Fires an alert for every single match.
- **Throttling**: If an alert fires, don't fire it again for the same `host` for the next 30 minutes.
- **Action**: Send to Webhook (Slack/Teams), run a script, or trigger a PagerDuty incident.

---

## 🆚 Splunk vs. ELK Stack

| Feature | Splunk | ELK (Elastic/Logstash/Kibana) |
| :--- | :--- | :--- |
| **Data Structure** | Schema-on-Read (Query anything) | Schema-on-Write (Requires mapping) |
| **Search Speed** | Extremely fast on massive datasets | Fast, but scales linearly with infra |
| **Enterprise Features** | Role-based access, SIEM, Audit built-in | Often requires plugins/Elastic Cloud |
| **Licensing** | Data volume based ($$$) | Open-source foundation (Ops resources) |

---

**Next Steps**: Check out [Nagios](../05-nagios/readme.md) for infrastructure-level monitoring.
