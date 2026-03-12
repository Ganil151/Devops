# ECS Monitoring and Troubleshooting Guide

## Table of Contents
1. [Monitoring Architecture](#monitoring-architecture)
2. [CloudWatch Integration](#cloudwatch-integration)
3. [Container Insights](#container-insights)
4. [Application Monitoring](#application-monitoring)
5. [Log Management](#log-management)
6. [Alerting and Notifications](#alerting-and-notifications)
7. [Performance Monitoring](#performance-monitoring)
8. [Troubleshooting Methodology](#troubleshooting-methodology)
9. [Common Issues and Solutions](#common-issues-and-solutions)
10. [Debugging Tools and Techniques](#debugging-tools-and-techniques)

## Monitoring Architecture

### Comprehensive Monitoring Stack
```
┌─────────────────────────────────────────────────────────────┐
│                    Monitoring Stack                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                 CloudWatch                          │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   Metrics   │  │    Logs     │  │   Alarms    │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Container Insights                     │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │ Cluster     │  │  Service    │  │    Task     │ │   │
│  │  │ Metrics     │  │  Metrics    │  │   Metrics   │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Application Layer                      │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   Custom    │  │    APM      │  │   Health    │ │   │
│  │  │   Metrics   │  │   Tools     │  │   Checks    │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              External Tools                         │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │ Prometheus  │  │   Grafana   │  │    X-Ray    │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Monitoring Components
- **Infrastructure Metrics**: CPU, memory, network, disk
- **Application Metrics**: Custom business metrics, performance counters
- **Log Aggregation**: Centralized logging with structured data
- **Distributed Tracing**: Request flow across microservices
- **Health Monitoring**: Service and container health checks

## CloudWatch Integration

### Container Insights Setup
```hcl
# cloudwatch-insights.tf
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Environment = var.environment
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "ecs_cluster" {
  name              = "/aws/ecs/containerinsights/${var.cluster_name}/performance"
  retention_in_days = 30

  tags = {
    Environment = var.environment
    Purpose     = "container-insights"
  }
}

resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/ecs/${var.cluster_name}"
  retention_in_days = 14

  tags = {
    Environment = var.environment
    Purpose     = "application-logs"
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "ecs_dashboard" {
  dashboard_name = "${var.cluster_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", var.service_name, "ClusterName", var.cluster_name],
            [".", "MemoryUtilization", ".", ".", ".", "."],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.load_balancer_name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ECS Service Performance"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "RunningTaskCount", "ServiceName", var.service_name, "ClusterName", var.cluster_name],
            [".", "PendingTaskCount", ".", ".", ".", "."],
            [".", "DesiredCount", ".", ".", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Task Counts"
          period  = 300
        }
      }
    ]
  })
}
```

### Custom Metrics Collection
```hcl
# custom-metrics.tf
resource "aws_cloudwatch_log_metric_filter" "error_count" {
  name           = "application-errors"
  log_group_name = aws_cloudwatch_log_group.application_logs.name
  pattern        = "[timestamp, request_id, level=\"ERROR\", ...]"

  metric_transformation {
    name      = "ApplicationErrors"
    namespace = "ECS/Application"
    value     = "1"
    
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "response_time" {
  name           = "response-time"
  log_group_name = aws_cloudwatch_log_group.application_logs.name
  pattern        = "[timestamp, request_id, level, method, url, status_code, response_time]"

  metric_transformation {
    name      = "ResponseTime"
    namespace = "ECS/Application"
    value     = "$response_time"
    
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_count" {
  name           = "request-count"
  log_group_name = aws_cloudwatch_log_group.application_logs.name
  pattern        = "[timestamp, request_id, level=\"INFO\", method, url, status_code, response_time]"

  metric_transformation {
    name      = "RequestCount"
    namespace = "ECS/Application"
    value     = "1"
    
    default_value = "0"
  }
}
```

## Container Insights

### Container Insights Agent Configuration
```json
{
  "family": "cwagent-ecs-fargate",
  "taskRoleArn": "arn:aws:iam::123456789012:role/CWAgentECSTaskRole",
  "executionRoleArn": "arn:aws:iam::123456789012:role/CWAgentECSExecutionRole",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "containerDefinitions": [
    {
      "name": "cloudwatch-agent",
      "image": "amazon/cloudwatch-agent:latest",
      "essential": true,
      "environment": [
        {
          "name": "CW_CONFIG_CONTENT",
          "value": "{\"logs\":{\"metrics_collected\":{\"emf\":{}}},\"metrics\":{\"namespace\":\"CWAgent\",\"metrics_collected\":{\"cpu\":{\"measurement\":[\"cpu_usage_idle\",\"cpu_usage_iowait\",\"cpu_usage_user\",\"cpu_usage_system\"],\"metrics_collection_interval\":60},\"disk\":{\"measurement\":[\"used_percent\"],\"metrics_collection_interval\":60,\"resources\":[\"*\"]},\"diskio\":{\"measurement\":[\"io_time\",\"read_bytes\",\"write_bytes\",\"reads\",\"writes\"],\"metrics_collection_interval\":60,\"resources\":[\"*\"]},\"mem\":{\"measurement\":[\"mem_used_percent\"],\"metrics_collection_interval\":60},\"netstat\":{\"measurement\":[\"tcp_established\",\"tcp_time_wait\"],\"metrics_collection_interval\":60},\"swap\":{\"measurement\":[\"swap_used_percent\"],\"metrics_collection_interval\":60}}}}"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/aws/ecs/containerinsights/production-cluster/performance",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

### Performance Monitoring Queries
```sql
-- CloudWatch Insights Queries

-- 1. Top CPU consuming tasks
fields @timestamp, TaskId, CpuUtilized
| filter Type = "Task"
| sort CpuUtilized desc
| limit 10

-- 2. Memory usage trends
fields @timestamp, TaskId, MemoryUtilized
| filter Type = "Task"
| stats avg(MemoryUtilized) by bin(5m)

-- 3. Network I/O analysis
fields @timestamp, TaskId, NetworkRxBytes, NetworkTxBytes
| filter Type = "Task"
| stats sum(NetworkRxBytes), sum(NetworkTxBytes) by TaskId

-- 4. Service-level metrics
fields @timestamp, ServiceName, RunningTaskCount, PendingTaskCount
| filter Type = "Service"
| sort @timestamp desc

-- 5. Container restart analysis
fields @timestamp, TaskId, LastStatus, DesiredStatus, StoppedReason
| filter Type = "Task" and LastStatus = "STOPPED"
| stats count() by StoppedReason
```

## Application Monitoring

### Application Metrics Implementation
```javascript
// metrics.js - Node.js application metrics
const express = require('express');
const promClient = require('prom-client');
const AWS = require('aws-sdk');

const cloudwatch = new AWS.CloudWatch({ region: 'us-west-2' });

// Create a Registry
const register = new promClient.Registry();

// Add default metrics
promClient.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

const httpRequestsTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

const activeConnections = new promClient.Gauge({
  name: 'active_connections',
  help: 'Number of active connections'
});

const businessMetrics = new promClient.Counter({
  name: 'business_transactions_total',
  help: 'Total number of business transactions',
  labelNames: ['type', 'status']
});

// Register metrics
register.registerMetric(httpRequestDuration);
register.registerMetric(httpRequestsTotal);
register.registerMetric(activeConnections);
register.registerMetric(businessMetrics);

// CloudWatch custom metrics
const publishToCloudWatch = async (metricName, value, unit = 'Count', dimensions = []) => {
  const params = {
    Namespace: 'ECS/Application',
    MetricData: [
      {
        MetricName: metricName,
        Value: value,
        Unit: unit,
        Dimensions: dimensions,
        Timestamp: new Date()
      }
    ]
  };

  try {
    await cloudwatch.putMetricData(params).promise();
  } catch (error) {
    console.error('Failed to publish metric to CloudWatch:', error);
  }
};

// Middleware for metrics collection
const metricsMiddleware = (req, res, next) => {
  const start = Date.now();
  
  res.on('finish', async () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;
    
    // Prometheus metrics
    httpRequestDuration
      .labels(req.method, route, res.statusCode)
      .observe(duration);
    
    httpRequestsTotal
      .labels(req.method, route, res.statusCode)
      .inc();
    
    // CloudWatch metrics
    await publishToCloudWatch('RequestDuration', duration, 'Seconds', [
      { Name: 'Method', Value: req.method },
      { Name: 'StatusCode', Value: res.statusCode.toString() }
    ]);
    
    await publishToCloudWatch('RequestCount', 1, 'Count', [
      { Name: 'Method', Value: req.method },
      { Name: 'StatusCode', Value: res.statusCode.toString() }
    ]);
  });
  
  next();
};

// Health check with detailed status
const healthCheck = async (req, res) => {
  const healthStatus = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    version: process.env.npm_package_version || '1.0.0',
    checks: {}
  };

  // Database health check
  try {
    // await db.query('SELECT 1');
    healthStatus.checks.database = { status: 'healthy', latency: 10 };
  } catch (error) {
    healthStatus.checks.database = { status: 'unhealthy', error: error.message };
    healthStatus.status = 'unhealthy';
  }

  // Redis health check
  try {
    // await redis.ping();
    healthStatus.checks.redis = { status: 'healthy' };
  } catch (error) {
    healthStatus.checks.redis = { status: 'unhealthy', error: error.message };
    healthStatus.status = 'unhealthy';
  }

  // Memory check
  const memoryUsage = process.memoryUsage();
  const memoryPercentage = (memoryUsage.heapUsed / memoryUsage.heapTotal) * 100;
  
  if (memoryPercentage > 90) {
    healthStatus.checks.memory = { status: 'warning', percentage: memoryPercentage };
    healthStatus.status = 'degraded';
  } else {
    healthStatus.checks.memory = { status: 'healthy', percentage: memoryPercentage };
  }

  const statusCode = healthStatus.status === 'healthy' ? 200 : 503;
  res.status(statusCode).json(healthStatus);
};

module.exports = {
  metricsMiddleware,
  healthCheck,
  register,
  publishToCloudWatch,
  businessMetrics
};
```

### X-Ray Tracing Integration
```javascript
// tracing.js - AWS X-Ray integration
const AWSXRay = require('aws-xray-sdk-core');
const AWS = AWSXRay.captureAWS(require('aws-sdk'));

// Configure X-Ray
AWSXRay.config([
  AWSXRay.plugins.ECSPlugin,
  AWSXRay.plugins.EC2Plugin
]);

// Middleware for Express
const xrayMiddleware = AWSXRay.express.openSegment('ECS-Application');

// Custom subsegment for database operations
const traceDatabaseOperation = async (operation, query) => {
  const subsegment = AWSXRay.getSegment().addNewSubsegment('database');
  
  subsegment.addAnnotation('operation', operation);
  subsegment.addMetadata('query', query);
  
  try {
    const result = await performDatabaseOperation(query);
    subsegment.addMetadata('result', { rowCount: result.length });
    subsegment.close();
    return result;
  } catch (error) {
    subsegment.addError(error);
    subsegment.close(error);
    throw error;
  }
};

// Custom subsegment for external API calls
const traceExternalAPI = async (apiName, url, options) => {
  const subsegment = AWSXRay.getSegment().addNewSubsegment(`external-${apiName}`);
  
  subsegment.addAnnotation('api', apiName);
  subsegment.addAnnotation('url', url);
  
  try {
    const response = await fetch(url, options);
    subsegment.addAnnotation('status_code', response.status);
    subsegment.close();
    return response;
  } catch (error) {
    subsegment.addError(error);
    subsegment.close(error);
    throw error;
  }
};

module.exports = {
  xrayMiddleware,
  traceDatabaseOperation,
  traceExternalAPI,
  closeSegment: AWSXRay.express.closeSegment()
};
```

## Log Management

### Structured Logging Configuration
```javascript
// logger.js - Structured logging setup
const winston = require('winston');
const { format } = winston;

// Custom format for ECS
const ecsFormat = format.combine(
  format.timestamp(),
  format.errors({ stack: true }),
  format.json(),
  format.printf(({ timestamp, level, message, ...meta }) => {
    const logEntry = {
      '@timestamp': timestamp,
      level: level.toUpperCase(),
      message,
      service: process.env.SERVICE_NAME || 'unknown',
      version: process.env.SERVICE_VERSION || '1.0.0',
      environment: process.env.NODE_ENV || 'development',
      container_id: process.env.HOSTNAME || 'unknown',
      ...meta
    };

    // Add request context if available
    if (meta.req) {
      logEntry.request = {
        method: meta.req.method,
        url: meta.req.url,
        user_agent: meta.req.get('User-Agent'),
        ip: meta.req.ip,
        request_id: meta.req.id
      };
      delete logEntry.req;
    }

    // Add response context if available
    if (meta.res) {
      logEntry.response = {
        status_code: meta.res.statusCode,
        response_time: meta.responseTime
      };
      delete logEntry.res;
      delete logEntry.responseTime;
    }

    return JSON.stringify(logEntry);
  })
);

// Create logger
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: ecsFormat,
  defaultMeta: {
    service: process.env.SERVICE_NAME || 'web-service'
  },
  transports: [
    new winston.transports.Console({
      handleExceptions: true,
      handleRejections: true
    })
  ],
  exitOnError: false
});

// Request logging middleware
const requestLogger = (req, res, next) => {
  const start = Date.now();
  
  // Generate request ID
  req.id = require('crypto').randomUUID();
  
  // Log request
  logger.info('Request started', {
    req,
    request_id: req.id
  });
  
  // Log response
  res.on('finish', () => {
    const responseTime = Date.now() - start;
    
    logger.info('Request completed', {
      req,
      res,
      responseTime,
      request_id: req.id
    });
  });
  
  next();
};

// Error logging
const errorLogger = (error, req, res, next) => {
  logger.error('Request error', {
    error: {
      message: error.message,
      stack: error.stack,
      name: error.name
    },
    req,
    request_id: req.id
  });
  
  next(error);
};

module.exports = {
  logger,
  requestLogger,
  errorLogger
};
```

### Log Aggregation with Fluent Bit
```yaml
# fluent-bit-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
data:
  fluent-bit.conf: |
    [SERVICE]
        Flush         1
        Log_Level     info
        Daemon        off
        Parsers_File  parsers.conf
        HTTP_Server   On
        HTTP_Listen   0.0.0.0
        HTTP_Port     2020

    [INPUT]
        Name              tail
        Tag               ecs.*
        Path              /var/log/containers/*.log
        Parser            docker
        DB                /var/log/flb_kube.db
        Mem_Buf_Limit     50MB
        Skip_Long_Lines   On
        Refresh_Interval  10

    [FILTER]
        Name                parser
        Match               ecs.*
        Key_Name            log
        Parser              json
        Reserve_Data        True

    [FILTER]
        Name                modify
        Match               ecs.*
        Add                 cluster_name ${CLUSTER_NAME}
        Add                 service_name ${SERVICE_NAME}

    [OUTPUT]
        Name                cloudwatch_logs
        Match               ecs.*
        region              ${AWS_REGION}
        log_group_name      /ecs/${CLUSTER_NAME}
        log_stream_prefix   ${SERVICE_NAME}-
        auto_create_group   true

  parsers.conf: |
    [PARSER]
        Name        json
        Format      json
        Time_Key    @timestamp
        Time_Format %Y-%m-%dT%H:%M:%S.%L
        Time_Keep   On

    [PARSER]
        Name        docker
        Format      json
        Time_Key    time
        Time_Format %Y-%m-%dT%H:%M:%S.%L
        Time_Keep   On
```

## Alerting and Notifications

### CloudWatch Alarms Configuration
```hcl
# cloudwatch-alarms.tf
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.service_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS service CPU utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    ServiceName = var.service_name
    ClusterName = var.cluster_name
  }

  tags = {
    Environment = var.environment
    Service     = var.service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "${var.service_name}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "This metric monitors ECS service memory utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ServiceName = var.service_name
    ClusterName = var.cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "service_task_count" {
  alarm_name          = "${var.service_name}-low-task-count"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors running task count"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ServiceName = var.service_name
    ClusterName = var.cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "application_errors" {
  alarm_name          = "${var.service_name}-application-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApplicationErrors"
  namespace           = "ECS/Application"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors application error rate"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "response_time" {
  alarm_name          = "${var.service_name}-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "ResponseTime"
  namespace           = "ECS/Application"
  period              = "300"
  statistic           = "Average"
  threshold           = "2"
  alarm_description   = "This metric monitors application response time"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.service_name}-alerts"

  tags = {
    Environment = var.environment
    Service     = var.service_name
  }
}

# SNS Topic Subscription
resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Slack integration
resource "aws_sns_topic_subscription" "slack_alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "https"
  endpoint  = var.slack_webhook_url
}
```

### Composite Alarms
```hcl
# composite-alarms.tf
resource "aws_cloudwatch_composite_alarm" "service_health" {
  alarm_name        = "${var.service_name}-service-health"
  alarm_description = "Composite alarm for overall service health"

  alarm_rule = join(" OR ", [
    "ALARM(${aws_cloudwatch_metric_alarm.high_cpu.alarm_name})",
    "ALARM(${aws_cloudwatch_metric_alarm.high_memory.alarm_name})",
    "ALARM(${aws_cloudwatch_metric_alarm.service_task_count.alarm_name})",
    "ALARM(${aws_cloudwatch_metric_alarm.application_errors.alarm_name})"
  ])

  alarm_actions = [aws_sns_topic.critical_alerts.arn]
  ok_actions    = [aws_sns_topic.critical_alerts.arn]

  tags = {
    Environment = var.environment
    Service     = var.service_name
    Type        = "composite"
  }
}

resource "aws_sns_topic" "critical_alerts" {
  name = "${var.service_name}-critical-alerts"

  tags = {
    Environment = var.environment
    Service     = var.service_name
    Priority    = "critical"
  }
}
```

## Performance Monitoring

### Performance Metrics Dashboard
```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/ECS", "CPUUtilization", "ServiceName", "web-service", "ClusterName", "production-cluster"],
          [".", "MemoryUtilization", ".", ".", ".", "."]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-west-2",
        "title": "Resource Utilization",
        "period": 300,
        "yAxis": {
          "left": {
            "min": 0,
            "max": 100
          }
        }
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "production-alb"],
          [".", "RequestCount", ".", "."],
          [".", "HTTPCode_Target_2XX_Count", ".", "."],
          [".", "HTTPCode_Target_4XX_Count", ".", "."],
          [".", "HTTPCode_Target_5XX_Count", ".", "."]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-west-2",
        "title": "Load Balancer Metrics",
        "period": 300
      }
    },
    {
      "type": "log",
      "properties": {
        "query": "SOURCE '/ecs/production-cluster'\n| fields @timestamp, level, message, response_time\n| filter level = \"ERROR\"\n| sort @timestamp desc\n| limit 20",
        "region": "us-west-2",
        "title": "Recent Errors",
        "view": "table"
      }
    }
  ]
}
```

### Performance Analysis Queries
```sql
-- CloudWatch Insights Performance Queries

-- 1. Response time percentiles
fields @timestamp, response_time
| filter ispresent(response_time)
| stats avg(response_time), pct(response_time, 50), pct(response_time, 95), pct(response_time, 99) by bin(5m)

-- 2. Error rate analysis
fields @timestamp, level, message
| filter level = "ERROR"
| stats count() as error_count by bin(5m)

-- 3. Request volume patterns
fields @timestamp, method, url, status_code
| filter ispresent(method)
| stats count() as request_count by method, bin(5m)

-- 4. Slow queries identification
fields @timestamp, message, response_time
| filter response_time > 1000
| sort response_time desc
| limit 50

-- 5. Memory usage trends
fields @timestamp, memory
| filter ispresent(memory)
| stats avg(memory.heapUsed), max(memory.heapUsed) by bin(5m)
```

## Troubleshooting Methodology

### Systematic Troubleshooting Approach
```bash
#!/bin/bash
# ecs-troubleshooting-toolkit.sh

set -e

CLUSTER_NAME="${1:-production-cluster}"
SERVICE_NAME="${2:-}"
REGION="${3:-us-west-2}"

echo "=== ECS Troubleshooting Toolkit ==="
echo "Cluster: $CLUSTER_NAME"
echo "Service: $SERVICE_NAME"
echo "Region: $REGION"
echo

# 1. Cluster Health Check
echo "1. Checking cluster health..."
aws ecs describe-clusters --clusters $CLUSTER_NAME --region $REGION --query 'clusters[0].{Status:status,ActiveServicesCount:activeServicesCount,RunningTasksCount:runningTasksCount,PendingTasksCount:pendingTasksCount}'
echo

# 2. Service Status (if service specified)
if [ ! -z "$SERVICE_NAME" ]; then
    echo "2. Service status for $SERVICE_NAME..."
    aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $REGION --query 'services[0].{Status:status,RunningCount:runningCount,PendingCount:pendingCount,DesiredCount:desiredCount,TaskDefinition:taskDefinition}'
    echo
    
    # Service events
    echo "3. Recent service events..."
    aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $REGION --query 'services[0].events[:5].{CreatedAt:createdAt,Message:message}'
    echo
    
    # Current tasks
    echo "4. Current tasks..."
    TASK_ARNS=$(aws ecs list-tasks --cluster $CLUSTER_NAME --service-name $SERVICE_NAME --region $REGION --query 'taskArns[]' --output text)
    
    if [ ! -z "$TASK_ARNS" ]; then
        aws ecs describe-tasks --cluster $CLUSTER_NAME --tasks $TASK_ARNS --region $REGION --query 'tasks[*].{TaskArn:taskArn,LastStatus:lastStatus,HealthStatus:healthStatus,CreatedAt:createdAt,CpuUtilization:cpu,MemoryUtilization:memory}'
    else
        echo "No running tasks found"
    fi
    echo
    
    # Stopped tasks (for failure analysis)
    echo "5. Recent stopped tasks..."
    STOPPED_TASKS=$(aws ecs list-tasks --cluster $CLUSTER_NAME --service-name $SERVICE_NAME --desired-status STOPPED --region $REGION --query 'taskArns[:3]' --output text)
    
    if [ ! -z "$STOPPED_TASKS" ]; then
        aws ecs describe-tasks --cluster $CLUSTER_NAME --tasks $STOPPED_TASKS --region $REGION --query 'tasks[*].{TaskArn:taskArn,LastStatus:lastStatus,StoppedReason:stoppedReason,StoppedAt:stoppedAt}'
    else
        echo "No stopped tasks found"
    fi
    echo
else
    echo "2. Listing all services..."
    aws ecs list-services --cluster $CLUSTER_NAME --region $REGION --query 'serviceArns[]' --output table
    echo
fi

# 6. Container Instance Health (for EC2 launch type)
echo "6. Container instances..."
CONTAINER_INSTANCES=$(aws ecs list-container-instances --cluster $CLUSTER_NAME --region $REGION --query 'containerInstanceArns[]' --output text)

if [ ! -z "$CONTAINER_INSTANCES" ]; then
    aws ecs describe-container-instances --cluster $CLUSTER_NAME --container-instances $CONTAINER_INSTANCES --region $REGION --query 'containerInstances[*].{InstanceId:ec2InstanceId,Status:status,RunningTasksCount:runningTasksCount,PendingTasksCount:pendingTasksCount,AgentConnected:agentConnected}'
else
    echo "No container instances (likely using Fargate)"
fi
echo

# 7. Load Balancer Health (if applicable)
if [ ! -z "$SERVICE_NAME" ]; then
    echo "7. Load balancer target health..."
    TARGET_GROUP_ARN=$(aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $REGION --query 'services[0].loadBalancers[0].targetGroupArn' --output text)
    
    if [ "$TARGET_GROUP_ARN" != "None" ] && [ ! -z "$TARGET_GROUP_ARN" ]; then
        aws elbv2 describe-target-health --target-group-arn $TARGET_GROUP_ARN --region $REGION --query 'TargetHealthDescriptions[*].{Target:Target.Id,Health:TargetHealth.State,Reason:TargetHealth.Reason,Description:TargetHealth.Description}'
    else
        echo "No load balancer configured"
    fi
    echo
fi

# 8. Recent CloudWatch alarms
echo "8. Recent CloudWatch alarms..."
aws cloudwatch describe-alarms --state-value ALARM --region $REGION --query 'MetricAlarms[?contains(AlarmName, `'$CLUSTER_NAME'`) || contains(AlarmName, `'$SERVICE_NAME'`)].{AlarmName:AlarmName,StateReason:StateReason,StateUpdatedTimestamp:StateUpdatedTimestamp}' --output table
echo

echo "=== Troubleshooting Complete ==="
```

## Common Issues and Solutions

### Task Startup Issues
```bash
# Task startup troubleshooting
check_task_startup_issues() {
    local cluster_name=$1
    local service_name=$2
    local region=$3
    
    echo "Checking task startup issues..."
    
    # Get stopped tasks
    STOPPED_TASKS=$(aws ecs list-tasks \
        --cluster $cluster_name \
        --service-name $service_name \
        --desired-status STOPPED \
        --region $region \
        --query 'taskArns[:10]' \
        --output text)
    
    if [ ! -z "$STOPPED_TASKS" ]; then
        echo "Analyzing stopped tasks..."
        aws ecs describe-tasks \
            --cluster $cluster_name \
            --tasks $STOPPED_TASKS \
            --region $region \
            --query 'tasks[*].{TaskArn:taskArn,StoppedReason:stoppedReason,StoppedAt:stoppedAt,Containers:containers[*].{Name:name,ExitCode:exitCode,Reason:reason}}'
    fi
    
    # Common issues and solutions
    echo "Common task startup issues:"
    echo "1. Image pull failures - Check ECR permissions and image existence"
    echo "2. Resource constraints - Check CPU/memory limits vs. available capacity"
    echo "3. Health check failures - Verify health check endpoint and timing"
    echo "4. Network issues - Check security groups and subnet configuration"
    echo "5. IAM permission issues - Verify task execution and task roles"
}
```

### Service Scaling Issues
```bash
# Service scaling troubleshooting
check_scaling_issues() {
    local cluster_name=$1
    local service_name=$2
    local region=$3
    
    echo "Checking service scaling issues..."
    
    # Check service configuration
    SERVICE_INFO=$(aws ecs describe-services \
        --cluster $cluster_name \
        --services $service_name \
        --region $region \
        --query 'services[0]')
    
    echo "Service scaling configuration:"
    echo $SERVICE_INFO | jq '.{DesiredCount:.desiredCount,RunningCount:.runningCount,PendingCount:.pendingCount,PlacementStrategy:.placementStrategy,PlacementConstraints:.placementConstraints}'
    
    # Check auto scaling configuration
    aws application-autoscaling describe-scalable-targets \
        --service-namespace ecs \
        --resource-ids "service/$cluster_name/$service_name" \
        --region $region
    
    # Check scaling policies
    aws application-autoscaling describe-scaling-policies \
        --service-namespace ecs \
        --resource-id "service/$cluster_name/$service_name" \
        --region $region
}
```

### Network Connectivity Issues
```bash
# Network troubleshooting
check_network_issues() {
    local cluster_name=$1
    local service_name=$2
    local region=$3
    
    echo "Checking network connectivity issues..."
    
    # Get task network configuration
    TASK_ARNS=$(aws ecs list-tasks \
        --cluster $cluster_name \
        --service-name $service_name \
        --region $region \
        --query 'taskArns[0]' \
        --output text)
    
    if [ "$TASK_ARNS" != "None" ] && [ ! -z "$TASK_ARNS" ]; then
        TASK_INFO=$(aws ecs describe-tasks \
            --cluster $cluster_name \
            --tasks $TASK_ARNS \
            --region $region \
            --query 'tasks[0]')
        
        echo "Task network configuration:"
        echo $TASK_INFO | jq '.attachments[0].details[] | select(.name == "subnetId" or .name == "networkInterfaceId")'
        
        # Get ENI information
        ENI_ID=$(echo $TASK_INFO | jq -r '.attachments[0].details[] | select(.name == "networkInterfaceId") | .value')
        
        if [ "$ENI_ID" != "null" ] && [ ! -z "$ENI_ID" ]; then
            echo "Network interface details:"
            aws ec2 describe-network-interfaces \
                --network-interface-ids $ENI_ID \
                --region $region \
                --query 'NetworkInterfaces[0].{PrivateIpAddress:PrivateIpAddress,SubnetId:SubnetId,SecurityGroups:Groups[*].GroupId}'
        fi
    fi
}
```

### Performance Issues
```bash
# Performance troubleshooting
check_performance_issues() {
    local cluster_name=$1
    local service_name=$2
    local region=$3
    
    echo "Checking performance issues..."
    
    # Get recent CloudWatch metrics
    END_TIME=$(date -u +%Y-%m-%dT%H:%M:%S)
    START_TIME=$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S)
    
    # CPU utilization
    aws cloudwatch get-metric-statistics \
        --namespace AWS/ECS \
        --metric-name CPUUtilization \
        --dimensions Name=ServiceName,Value=$service_name Name=ClusterName,Value=$cluster_name \
        --start-time $START_TIME \
        --end-time $END_TIME \
        --period 300 \
        --statistics Average,Maximum \
        --region $region \
        --query 'Datapoints[*].{Timestamp:Timestamp,Average:Average,Maximum:Maximum}' \
        --output table
    
    # Memory utilization
    aws cloudwatch get-metric-statistics \
        --namespace AWS/ECS \
        --metric-name MemoryUtilization \
        --dimensions Name=ServiceName,Value=$service_name Name=ClusterName,Value=$cluster_name \
        --start-time $START_TIME \
        --end-time $END_TIME \
        --period 300 \
        --statistics Average,Maximum \
        --region $region \
        --query 'Datapoints[*].{Timestamp:Timestamp,Average:Average,Maximum:Maximum}' \
        --output table
}
```

## Debugging Tools and Techniques

### ECS Exec for Container Debugging
```bash
# Enable ECS Exec on service
aws ecs update-service \
    --cluster production-cluster \
    --service web-service \
    --enable-execute-command \
    --region us-west-2

# Execute commands in running container
aws ecs execute-command \
    --cluster production-cluster \
    --task TASK_ARN \
    --container web-container \
    --interactive \
    --command "/bin/bash" \
    --region us-west-2
```

### Container Log Analysis
```bash
#!/bin/bash
# log-analysis.sh

analyze_container_logs() {
    local log_group=$1
    local start_time=$2
    local end_time=$3
    
    echo "Analyzing container logs..."
    
    # Error analysis
    aws logs filter-log-events \
        --log-group-name $log_group \
        --start-time $start_time \
        --end-time $end_time \
        --filter-pattern "ERROR" \
        --query 'events[*].{Timestamp:timestamp,Message:message}' \
        --output table
    
    # Performance analysis
    aws logs filter-log-events \
        --log-group-name $log_group \
        --start-time $start_time \
        --end-time $end_time \
        --filter-pattern "[timestamp, request_id, level, method, url, status_code, response_time > 1000]" \
        --query 'events[*].message' \
        --output text
    
    # Memory usage analysis
    aws logs filter-log-events \
        --log-group-name $log_group \
        --start-time $start_time \
        --end-time $end_time \
        --filter-pattern "memory" \
        --query 'events[*].message' \
        --output text
}

# Usage
START_TIME=$(date -d '1 hour ago' +%s)000
END_TIME=$(date +%s)000
analyze_container_logs "/ecs/production-cluster" $START_TIME $END_TIME
```

### Health Check Debugging
```bash
# Health check debugging
debug_health_checks() {
    local cluster_name=$1
    local service_name=$2
    local region=$3
    
    echo "Debugging health checks..."
    
    # Get task definition
    TASK_DEF_ARN=$(aws ecs describe-services \
        --cluster $cluster_name \
        --services $service_name \
        --region $region \
        --query 'services[0].taskDefinition' \
        --output text)
    
    # Check health check configuration
    aws ecs describe-task-definition \
        --task-definition $TASK_DEF_ARN \
        --region $region \
        --query 'taskDefinition.containerDefinitions[*].{Name:name,HealthCheck:healthCheck}' \
        --output json
    
    # Check load balancer target health
    TARGET_GROUP_ARN=$(aws ecs describe-services \
        --cluster $cluster_name \
        --services $service_name \
        --region $region \
        --query 'services[0].loadBalancers[0].targetGroupArn' \
        --output text)
    
    if [ "$TARGET_GROUP_ARN" != "None" ]; then
        aws elbv2 describe-target-health \
            --target-group-arn $TARGET_GROUP_ARN \
            --region $region \
            --query 'TargetHealthDescriptions[*].{Target:Target.Id,Health:TargetHealth.State,Reason:TargetHealth.Reason}'
    fi
}
```

### Performance Profiling
```bash
# Performance profiling script
profile_application_performance() {
    local cluster_name=$1
    local task_arn=$2
    local container_name=$3
    local region=$4
    
    echo "Profiling application performance..."
    
    # CPU profiling
    aws ecs execute-command \
        --cluster $cluster_name \
        --task $task_arn \
        --container $container_name \
        --interactive \
        --command "top -b -n 1" \
        --region $region
    
    # Memory profiling
    aws ecs execute-command \
        --cluster $cluster_name \
        --task $task_arn \
        --container $container_name \
        --interactive \
        --command "free -h" \
        --region $region
    
    # Network connections
    aws ecs execute-command \
        --cluster $cluster_name \
        --task $task_arn \
        --container $container_name \
        --interactive \
        --command "netstat -tuln" \
        --region $region
    
    # Disk usage
    aws ecs execute-command \
        --cluster $cluster_name \
        --task $task_arn \
        --container $container_name \
        --interactive \
        --command "df -h" \
        --region $region
}
```

### Automated Monitoring Script
```bash
#!/bin/bash
# continuous-monitoring.sh

monitor_ecs_service() {
    local cluster_name=$1
    local service_name=$2
    local region=$3
    local interval=${4:-60}
    
    echo "Starting continuous monitoring for $service_name..."
    
    while true; do
        clear
        echo "=== ECS Service Monitor - $(date) ==="
        echo "Cluster: $cluster_name"
        echo "Service: $service_name"
        echo
        
        # Service status
        echo "Service Status:"
        aws ecs describe-services \
            --cluster $cluster_name \
            --services $service_name \
            --region $region \
            --query 'services[0].{Status:status,Running:runningCount,Pending:pendingCount,Desired:desiredCount}' \
            --output table
        
        # Task health
        echo "Task Health:"
        TASK_ARNS=$(aws ecs list-tasks \
            --cluster $cluster_name \
            --service-name $service_name \
            --region $region \
            --query 'taskArns[]' \
            --output text)
        
        if [ ! -z "$TASK_ARNS" ]; then
            aws ecs describe-tasks \
                --cluster $cluster_name \
                --tasks $TASK_ARNS \
                --region $region \
                --query 'tasks[*].{Task:taskArn,Status:lastStatus,Health:healthStatus,CPU:cpu,Memory:memory}' \
                --output table
        fi
        
        # Load balancer health
        TARGET_GROUP_ARN=$(aws ecs describe-services \
            --cluster $cluster_name \
            --services $service_name \
            --region $region \
            --query 'services[0].loadBalancers[0].targetGroupArn' \
            --output text)
        
        if [ "$TARGET_GROUP_ARN" != "None" ] && [ ! -z "$TARGET_GROUP_ARN" ]; then
            echo "Load Balancer Health:"
            aws elbv2 describe-target-health \
                --target-group-arn $TARGET_GROUP_ARN \
                --region $region \
                --query 'TargetHealthDescriptions[*].{Target:Target.Id,Health:TargetHealth.State}' \
                --output table
        fi
        
        sleep $interval
    done
}

# Usage
# monitor_ecs_service "production-cluster" "web-service" "us-west-2" 30
```

This comprehensive monitoring and troubleshooting guide provides the tools and techniques needed to effectively monitor, debug, and maintain ECS services in production environments.