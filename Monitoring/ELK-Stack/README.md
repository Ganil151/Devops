# ELK Stack (Elasticsearch, Logstash, Kibana)

Complete guide to log management and analysis using the ELK Stack.

## ELK Stack Architecture

### Components Overview
```bash
# Elasticsearch - Search and analytics engine
- Distributed, RESTful search engine
- Document-oriented database
- Real-time search and analytics
- Horizontal scaling capabilities

# Logstash - Data processing pipeline
- Data ingestion and transformation
- Multiple input/output plugins
- Real-time data processing
- Filtering and parsing capabilities

# Kibana - Visualization and exploration
- Web-based interface for Elasticsearch
- Interactive dashboards and visualizations
- Real-time data exploration
- Alerting and reporting features

# Beats - Lightweight data shippers
- Filebeat: Log files
- Metricbeat: System and service metrics
- Packetbeat: Network data
- Winlogbeat: Windows event logs
```

## Elasticsearch Setup and Configuration

### Docker Compose Setup
```yaml
# docker-compose.yml
version: '3.8'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.5.0
    container_name: elasticsearch
    environment:
      - node.name=elasticsearch
      - cluster.name=elk-cluster
      - discovery.type=single-node
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
      - "9300:9300"
    networks:
      - elk

  logstash:
    image: docker.elastic.co/logstash/logstash:8.5.0
    container_name: logstash
    volumes:
      - ./logstash/config/logstash.yml:/usr/share/logstash/config/logstash.yml
      - ./logstash/pipeline:/usr/share/logstash/pipeline
    ports:
      - "5044:5044"
      - "5000:5000/tcp"
      - "5000:5000/udp"
      - "9600:9600"
    environment:
      LS_JAVA_OPTS: "-Xmx256m -Xms256m"
    networks:
      - elk
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:8.5.0
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      ELASTICSEARCH_URL: http://elasticsearch:9200
      ELASTICSEARCH_HOSTS: '["http://elasticsearch:9200"]'
    networks:
      - elk
    depends_on:
      - elasticsearch

volumes:
  elasticsearch_data:

networks:
  elk:
    driver: bridge
```

### Elasticsearch Configuration
```yaml
# elasticsearch.yml
cluster.name: "elk-cluster"
node.name: "elasticsearch-node-1"
path.data: /usr/share/elasticsearch/data
path.logs: /usr/share/elasticsearch/logs
network.host: 0.0.0.0
http.port: 9200
discovery.type: single-node

# Index settings
index.number_of_shards: 1
index.number_of_replicas: 0

# Memory settings
bootstrap.memory_lock: true

# Security settings (for production)
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
xpack.security.http.ssl.enabled: true
```

### Index Templates and Mappings
```json
{
  "index_patterns": ["logs-*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0,
      "index.refresh_interval": "5s"
    },
    "mappings": {
      "properties": {
        "@timestamp": {
          "type": "date"
        },
        "level": {
          "type": "keyword"
        },
        "message": {
          "type": "text",
          "analyzer": "standard"
        },
        "service": {
          "type": "keyword"
        },
        "host": {
          "type": "keyword"
        },
        "response_time": {
          "type": "float"
        },
        "status_code": {
          "type": "integer"
        }
      }
    }
  }
}
```

## Logstash Configuration and Pipelines

### Basic Logstash Configuration
```ruby
# logstash/pipeline/logstash.conf
input {
  beats {
    port => 5044
  }
  
  tcp {
    port => 5000
    codec => json_lines
  }
  
  file {
    path => "/var/log/application/*.log"
    start_position => "beginning"
    sincedb_path => "/dev/null"
    tags => ["application"]
  }
}

filter {
  # Parse application logs
  if "application" in [tags] {
    grok {
      match => { 
        "message" => "%{TIMESTAMP_ISO8601:timestamp} \[%{LOGLEVEL:level}\] %{GREEDYDATA:log_message}" 
      }
    }
    
    date {
      match => [ "timestamp", "ISO8601" ]
    }
    
    if [level] == "ERROR" {
      mutate {
        add_tag => ["error"]
      }
    }
  }
  
  # Parse nginx access logs
  if [fields][log_type] == "nginx" {
    grok {
      match => { 
        "message" => "%{COMBINEDAPACHELOG}" 
      }
    }
    
    mutate {
      convert => { "response" => "integer" }
      convert => { "bytes" => "integer" }
    }
    
    if [response] >= 400 {
      mutate {
        add_tag => ["http_error"]
      }
    }
  }
  
  # Parse JSON logs
  if [fields][log_type] == "json" {
    json {
      source => "message"
    }
  }
  
  # Add hostname
  mutate {
    add_field => { "hostname" => "%{host}" }
  }
  
  # Remove unwanted fields
  mutate {
    remove_field => [ "agent", "ecs", "input", "log" ]
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "logs-%{+YYYY.MM.dd}"
  }
  
  # Output errors to separate index
  if "error" in [tags] or "http_error" in [tags] {
    elasticsearch {
      hosts => ["elasticsearch:9200"]
      index => "errors-%{+YYYY.MM.dd}"
    }
  }
  
  # Debug output
  if [level] == "DEBUG" {
    stdout { 
      codec => rubydebug 
    }
  }
}
```

### Advanced Logstash Patterns
```ruby
# Custom grok patterns
# patterns/custom_patterns
CUSTOM_TIMESTAMP %{YEAR}-%{MONTHNUM}-%{MONTHDAY} %{TIME}
API_LOG %{CUSTOM_TIMESTAMP:timestamp} \[%{LOGLEVEL:level}\] %{WORD:service} - %{GREEDYDATA:message}
DATABASE_LOG %{TIMESTAMP_ISO8601:timestamp} %{NUMBER:thread_id} \[%{LOGLEVEL:level}\] %{GREEDYDATA:query}

# Multi-line log processing
filter {
  # Java stack traces
  if [fields][log_type] == "java" {
    multiline {
      pattern => "^%{TIMESTAMP_ISO8601}"
      negate => true
      what => "previous"
    }
  }
  
  # Python tracebacks
  if [fields][log_type] == "python" {
    multiline {
      pattern => "^Traceback"
      what => "next"
    }
  }
}
```

## Filebeat Configuration

### Filebeat Setup
```yaml
# filebeat.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/nginx/*.log
  fields:
    log_type: nginx
    environment: production
  fields_under_root: true
  
- type: log
  enabled: true
  paths:
    - /var/log/application/*.log
  fields:
    log_type: application
    service: myapp
  fields_under_root: true
  multiline.pattern: '^\d{4}-\d{2}-\d{2}'
  multiline.negate: true
  multiline.match: after

- type: docker
  containers.ids:
    - "*"
  processors:
    - add_docker_metadata:
        host: "unix:///var/run/docker.sock"

output.logstash:
  hosts: ["logstash:5044"]

processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
  - add_cloud_metadata: ~
  - add_fields:
      target: ''
      fields:
        datacenter: us-east-1
        environment: production

logging.level: info
logging.to_files: true
logging.files:
  path: /var/log/filebeat
  name: filebeat
  keepfiles: 7
  permissions: 0644
```

### Metricbeat Configuration
```yaml
# metricbeat.yml
metricbeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false

metricbeat.modules:
- module: system
  metricsets:
    - cpu
    - load
    - memory
    - network
    - process
    - process_summary
    - socket_summary
  enabled: true
  period: 10s
  processes: ['.*']

- module: docker
  metricsets:
    - container
    - cpu
    - diskio
    - healthcheck
    - info
    - memory
    - network
  hosts: ["unix:///var/run/docker.sock"]
  period: 10s
  enabled: true

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
  index: "metricbeat-%{+yyyy.MM.dd}"

setup.template.settings:
  index.number_of_shards: 1
  index.codec: best_compression
```

## Kibana Dashboards and Visualizations

### Index Patterns and Field Mapping
```bash
# Create index pattern via Kibana API
curl -X POST "kibana:5601/api/saved_objects/index-pattern/logs-*" \
  -H "Content-Type: application/json" \
  -H "kbn-xsrf: true" \
  -d '{
    "attributes": {
      "title": "logs-*",
      "timeFieldName": "@timestamp"
    }
  }'
```

### Dashboard Configuration
```json
{
  "version": "8.5.0",
  "objects": [
    {
      "id": "application-logs-dashboard",
      "type": "dashboard",
      "attributes": {
        "title": "Application Logs Dashboard",
        "hits": 0,
        "description": "Dashboard for application log analysis",
        "panelsJSON": "[{\"version\":\"8.5.0\",\"gridData\":{\"x\":0,\"y\":0,\"w\":24,\"h\":15},\"panelIndex\":\"1\",\"embeddableConfig\":{},\"panelRefName\":\"panel_1\"}]",
        "timeRestore": false,
        "timeTo": "now",
        "timeFrom": "now-24h",
        "refreshInterval": {
          "pause": false,
          "value": 30000
        }
      }
    }
  ]
}
```

### Visualization Examples
```json
{
  "title": "Log Levels Over Time",
  "type": "histogram",
  "params": {
    "grid": {
      "categoryLines": false,
      "style": {
        "color": "#eee"
      }
    },
    "categoryAxes": [
      {
        "id": "CategoryAxis-1",
        "type": "category",
        "position": "bottom",
        "show": true,
        "style": {},
        "scale": {
          "type": "linear"
        },
        "labels": {
          "show": true,
          "truncate": 100
        },
        "title": {}
      }
    ],
    "valueAxes": [
      {
        "id": "ValueAxis-1",
        "name": "LeftAxis-1",
        "type": "value",
        "position": "left",
        "show": true,
        "style": {},
        "scale": {
          "type": "linear",
          "mode": "normal"
        },
        "labels": {
          "show": true,
          "rotate": 0,
          "filter": false,
          "truncate": 100
        },
        "title": {
          "text": "Count"
        }
      }
    ]
  },
  "aggs": [
    {
      "id": "1",
      "enabled": true,
      "type": "count",
      "schema": "metric",
      "params": {}
    },
    {
      "id": "2",
      "enabled": true,
      "type": "date_histogram",
      "schema": "segment",
      "params": {
        "field": "@timestamp",
        "interval": "auto",
        "customInterval": "2h",
        "min_doc_count": 1,
        "extended_bounds": {}
      }
    },
    {
      "id": "3",
      "enabled": true,
      "type": "terms",
      "schema": "group",
      "params": {
        "field": "level.keyword",
        "size": 5,
        "order": "desc",
        "orderBy": "1"
      }
    }
  ]
}
```

## Advanced ELK Features

### Elasticsearch Queries and Aggregations
```json
{
  "query": {
    "bool": {
      "must": [
        {
          "range": {
            "@timestamp": {
              "gte": "now-1h",
              "lte": "now"
            }
          }
        },
        {
          "term": {
            "level.keyword": "ERROR"
          }
        }
      ]
    }
  },
  "aggs": {
    "error_count_over_time": {
      "date_histogram": {
        "field": "@timestamp",
        "calendar_interval": "5m"
      }
    },
    "top_error_messages": {
      "terms": {
        "field": "message.keyword",
        "size": 10
      }
    }
  }
}
```

### Watcher (Alerting)
```json
{
  "trigger": {
    "schedule": {
      "interval": "5m"
    }
  },
  "input": {
    "search": {
      "request": {
        "search_type": "query_then_fetch",
        "indices": ["logs-*"],
        "body": {
          "query": {
            "bool": {
              "must": [
                {
                  "range": {
                    "@timestamp": {
                      "gte": "now-5m"
                    }
                  }
                },
                {
                  "term": {
                    "level.keyword": "ERROR"
                  }
                }
              ]
            }
          }
        }
      }
    }
  },
  "condition": {
    "compare": {
      "ctx.payload.hits.total": {
        "gt": 10
      }
    }
  },
  "actions": {
    "send_email": {
      "email": {
        "to": ["admin@company.com"],
        "subject": "High Error Rate Alert",
        "body": "More than 10 errors detected in the last 5 minutes"
      }
    }
  }
}
```

### Machine Learning Jobs
```json
{
  "job_id": "log_anomaly_detection",
  "description": "Detect anomalies in log patterns",
  "analysis_config": {
    "bucket_span": "15m",
    "detectors": [
      {
        "function": "count",
        "by_field_name": "level.keyword"
      },
      {
        "function": "rare",
        "by_field_name": "message.keyword"
      }
    ]
  },
  "data_description": {
    "time_field": "@timestamp"
  },
  "model_plot_config": {
    "enabled": true
  }
}
```

## Performance Optimization

### Elasticsearch Optimization
```yaml
# Cluster settings
PUT /_cluster/settings
{
  "persistent": {
    "indices.memory.index_buffer_size": "20%",
    "indices.memory.min_index_buffer_size": "48mb",
    "thread_pool.write.queue_size": 1000
  }
}

# Index settings for performance
PUT /logs-template
{
  "index_patterns": ["logs-*"],
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0,
    "refresh_interval": "30s",
    "index.codec": "best_compression",
    "index.merge.policy.max_merged_segment": "5gb"
  }
}
```

### Logstash Performance Tuning
```ruby
# logstash.yml
pipeline.workers: 4
pipeline.batch.size: 1000
pipeline.batch.delay: 50

# JVM settings
-Xms2g
-Xmx2g
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
```

### Index Lifecycle Management
```json
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_size": "10gb",
            "max_age": "1d"
          }
        }
      },
      "warm": {
        "min_age": "7d",
        "actions": {
          "allocate": {
            "number_of_replicas": 0
          },
          "forcemerge": {
            "max_num_segments": 1
          }
        }
      },
      "cold": {
        "min_age": "30d",
        "actions": {
          "allocate": {
            "number_of_replicas": 0
          }
        }
      },
      "delete": {
        "min_age": "90d"
      }
    }
  }
}
```

## Security and Best Practices

### Security Configuration
```yaml
# Elasticsearch security
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
xpack.security.http.ssl.enabled: true

# User roles
POST /_security/role/log_reader
{
  "cluster": ["monitor"],
  "indices": [
    {
      "names": ["logs-*"],
      "privileges": ["read", "view_index_metadata"]
    }
  ]
}

# Create user
POST /_security/user/log_user
{
  "password": "secure_password",
  "roles": ["log_reader"],
  "full_name": "Log Reader User"
}
```

### Monitoring and Alerting
```bash
# Elasticsearch cluster health
curl -X GET "elasticsearch:9200/_cluster/health?pretty"

# Index statistics
curl -X GET "elasticsearch:9200/_cat/indices?v"

# Node statistics
curl -X GET "elasticsearch:9200/_nodes/stats?pretty"
```

### Best Practices
```bash
# 1. Index Management
- Use time-based indices
- Implement proper retention policies
- Monitor index size and performance
- Use appropriate shard sizing

# 2. Query Optimization
- Use filters instead of queries when possible
- Avoid wildcard queries on large datasets
- Use appropriate field types
- Implement proper caching strategies

# 3. Security
- Enable authentication and authorization
- Use SSL/TLS for all communications
- Implement proper network security
- Regular security updates

# 4. Monitoring
- Monitor cluster health and performance
- Set up alerting for critical issues
- Track resource utilization
- Monitor query performance
```