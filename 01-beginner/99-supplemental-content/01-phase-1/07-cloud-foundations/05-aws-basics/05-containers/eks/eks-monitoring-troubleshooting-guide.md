# EKS Monitoring and Troubleshooting Guide

## Table of Contents
1. [Monitoring Architecture](#monitoring-architecture)
2. [CloudWatch Integration](#cloudwatch-integration)
3. [Prometheus and Grafana](#prometheus-and-grafana)
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
│  │                  Grafana                            │   │
│  │            (Visualization Layer)                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                 Prometheus                          │   │
│  │              (Metrics Collection)                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐   │
│  │   Node      │  │ Application │  │   Kubernetes    │   │
│  │ Exporter    │  │  Metrics    │  │    Metrics      │   │
│  └─────────────┘  └─────────────┘  └─────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                 Log Aggregation                     │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │ Fluent Bit  │  │ CloudWatch  │  │ Elasticsearch│ │   │
│  │  │             │  │    Logs     │  │   (Optional) │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                AWS CloudWatch                       │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   Metrics   │  │    Logs     │  │   Alarms    │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Monitoring Components
- **Metrics Collection**: Prometheus, CloudWatch
- **Log Aggregation**: Fluent Bit, CloudWatch Logs
- **Visualization**: Grafana, CloudWatch Dashboards
- **Alerting**: AlertManager, CloudWatch Alarms
- **Tracing**: AWS X-Ray, Jaeger (optional)

## CloudWatch Integration

### CloudWatch Container Insights
```yaml
# cloudwatch-insights.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: amazon-cloudwatch
  labels:
    name: amazon-cloudwatch

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cloudwatch-agent
  namespace: amazon-cloudwatch

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cloudwatch-agent-role
rules:
  - apiGroups: [""]
    resources: ["pods", "nodes", "endpoints"]
    verbs: ["list", "watch"]
  - apiGroups: ["apps"]
    resources: ["replicasets"]
    verbs: ["list", "watch"]
  - apiGroups: ["batch"]
    resources: ["jobs"]
    verbs: ["list", "watch"]
  - apiGroups: [""]
    resources: ["nodes/proxy"]
    verbs: ["get"]
  - apiGroups: [""]
    resources: ["nodes/stats", "configmaps", "events"]
    verbs: ["create", "get"]
  - apiGroups: [""]
    resources: ["configmaps"]
    resourceNames: ["cwagent-clusterleader"]
    verbs: ["get", "update"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cloudwatch-agent-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cloudwatch-agent-role
subjects:
  - kind: ServiceAccount
    name: cloudwatch-agent
    namespace: amazon-cloudwatch

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: cwagentconfig
  namespace: amazon-cloudwatch
data:
  cwagentconfig.json: |
    {
      "logs": {
        "metrics_collected": {
          "kubernetes": {
            "cluster_name": "production-cluster",
            "metrics_collection_interval": 60
          }
        },
        "force_flush_interval": 5
      },
      "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
          "cpu": {
            "measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"],
            "metrics_collection_interval": 60
          },
          "disk": {
            "measurement": ["used_percent"],
            "metrics_collection_interval": 60,
            "resources": ["*"]
          },
          "diskio": {
            "measurement": ["io_time", "read_bytes", "write_bytes", "reads", "writes"],
            "metrics_collection_interval": 60,
            "resources": ["*"]
          },
          "mem": {
            "measurement": ["mem_used_percent"],
            "metrics_collection_interval": 60
          },
          "netstat": {
            "measurement": ["tcp_established", "tcp_time_wait"],
            "metrics_collection_interval": 60
          },
          "swap": {
            "measurement": ["swap_used_percent"],
            "metrics_collection_interval": 60
          }
        }
      }
    }

---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: cloudwatch-agent
  namespace: amazon-cloudwatch
spec:
  selector:
    matchLabels:
      name: cloudwatch-agent
  template:
    metadata:
      labels:
        name: cloudwatch-agent
    spec:
      containers:
      - name: cloudwatch-agent
        image: amazon/cloudwatch-agent:1.247358.0b251814
        ports:
        - containerPort: 8125
          hostPort: 8125
          protocol: UDP
        resources:
          limits:
            cpu: 200m
            memory: 200Mi
          requests:
            cpu: 200m
            memory: 200Mi
        env:
        - name: HOST_IP
          valueFrom:
            fieldRef:
              fieldPath: status.hostIP
        - name: HOST_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: K8S_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        volumeMounts:
        - name: cwagentconfig
          mountPath: /etc/cwagentconfig
        - name: rootfs
          mountPath: /rootfs
          readOnly: true
        - name: dockersock
          mountPath: /var/run/docker.sock
          readOnly: true
        - name: varlibdocker
          mountPath: /var/lib/docker
          readOnly: true
        - name: sys
          mountPath: /sys
          readOnly: true
        - name: devdisk
          mountPath: /dev/disk
          readOnly: true
      volumes:
      - name: cwagentconfig
        configMap:
          name: cwagentconfig
      - name: rootfs
        hostPath:
          path: /
      - name: dockersock
        hostPath:
          path: /var/run/docker.sock
      - name: varlibdocker
        hostPath:
          path: /var/lib/docker
      - name: sys
        hostPath:
          path: /sys
      - name: devdisk
        hostPath:
          path: /dev/disk
      terminationGracePeriodSeconds: 60
      serviceAccountName: cloudwatch-agent
```

### Fluent Bit for Log Collection
```yaml
# fluent-bit.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fluent-bit
  namespace: amazon-cloudwatch

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: fluent-bit-role
rules:
  - nonResourceURLs:
      - /metrics
    verbs:
      - get
  - apiGroups: [""]
    resources:
      - namespaces
      - pods
      - pods/logs
    verbs:
      - get
      - list
      - watch

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: fluent-bit-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: fluent-bit-role
subjects:
  - kind: ServiceAccount
    name: fluent-bit
    namespace: amazon-cloudwatch

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
  namespace: amazon-cloudwatch
data:
  fluent-bit.conf: |
    [SERVICE]
        Flush                     5
        Log_Level                 info
        Daemon                    off
        Parsers_File              parsers.conf
        HTTP_Server               On
        HTTP_Listen               0.0.0.0
        HTTP_Port                 2020
        storage.path              /var/fluent-bit/state/flb-storage/
        storage.sync              normal
        storage.checksum          off
        storage.backlog.mem_limit 5M

    @INCLUDE application-log.conf
    @INCLUDE dataplane-log.conf
    @INCLUDE host-log.conf

  application-log.conf: |
    [INPUT]
        Name                tail
        Tag                 application.*
        Exclude_Path        /var/log/containers/cloudwatch-agent*, /var/log/containers/fluent-bit*, /var/log/containers/aws-node*, /var/log/containers/kube-proxy*
        Path                /var/log/containers/*.log
        multiline.parser    docker, cri
        DB                  /var/fluent-bit/state/flb_container.db
        Mem_Buf_Limit       50MB
        Skip_Long_Lines     On
        Refresh_Interval    10
        Rotate_Wait         30
        storage.type        filesystem
        Read_from_Head      ${READ_FROM_HEAD}

    [FILTER]
        Name                kubernetes
        Match               application.*
        Kube_URL            https://kubernetes.default.svc:443
        Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token
        Kube_Tag_Prefix     application.var.log.containers.
        Merge_Log           On
        Merge_Log_Key       log_processed
        K8S-Logging.Parser  On
        K8S-Logging.Exclude Off
        Labels              Off
        Annotations         Off

    [OUTPUT]
        Name                cloudwatch_logs
        Match               application.*
        region              ${AWS_REGION}
        log_group_name      /aws/containerinsights/${CLUSTER_NAME}/application
        log_stream_prefix   ${HOST_NAME}-
        auto_create_group   true
        extra_user_agent    container-insights

  dataplane-log.conf: |
    [INPUT]
        Name                systemd
        Tag                 dataplane.systemd.*
        Systemd_Filter      _SYSTEMD_UNIT=docker.service
        Systemd_Filter      _SYSTEMD_UNIT=containerd.service
        Systemd_Filter      _SYSTEMD_UNIT=kubelet.service
        DB                  /var/fluent-bit/state/systemd.db
        Path                /var/log/journal
        Read_From_Tail      ${READ_FROM_TAIL}

    [INPUT]
        Name                tail
        Tag                 dataplane.tail.*
        Path                /var/log/containers/aws-node*, /var/log/containers/kube-proxy*
        multiline.parser    docker, cri
        DB                  /var/fluent-bit/state/flb_dataplane_tail.db
        Mem_Buf_Limit       50MB
        Skip_Long_Lines     On
        Refresh_Interval    10
        Rotate_Wait         30
        storage.type        filesystem
        Read_from_Head      ${READ_FROM_HEAD}

    [FILTER]
        Name                modify
        Match               dataplane.systemd.*
        Rename              _HOSTNAME                   hostname
        Rename              _SYSTEMD_UNIT              systemd_unit
        Rename              MESSAGE                     message
        Remove_regex        ^((?!hostname|systemd_unit|message).)*$

    [FILTER]
        Name                aws
        Match               dataplane.*
        imds_version        v1

    [OUTPUT]
        Name                cloudwatch_logs
        Match               dataplane.*
        region              ${AWS_REGION}
        log_group_name      /aws/containerinsights/${CLUSTER_NAME}/dataplane
        log_stream_prefix   ${HOST_NAME}-
        auto_create_group   true
        extra_user_agent    container-insights

  host-log.conf: |
    [INPUT]
        Name                tail
        Tag                 host.dmesg
        Path                /var/log/dmesg
        Key                 message
        DB                  /var/fluent-bit/state/flb_dmesg.db
        Mem_Buf_Limit       5MB
        Skip_Long_Lines     On
        Refresh_Interval    10
        Read_from_Head      ${READ_FROM_HEAD}

    [INPUT]
        Name                tail
        Tag                 host.messages
        Path                /var/log/messages
        Parser              syslog
        DB                  /var/fluent-bit/state/flb_messages.db
        Mem_Buf_Limit       5MB
        Skip_Long_Lines     On
        Refresh_Interval    10
        Read_from_Head      ${READ_FROM_HEAD}

    [INPUT]
        Name                tail
        Tag                 host.secure
        Path                /var/log/secure
        Parser              syslog
        DB                  /var/fluent-bit/state/flb_secure.db
        Mem_Buf_Limit       5MB
        Skip_Long_Lines     On
        Refresh_Interval    10
        Read_from_Head      ${READ_FROM_HEAD}

    [FILTER]
        Name                aws
        Match               host.*
        imds_version        v1

    [OUTPUT]
        Name                cloudwatch_logs
        Match               host.*
        region              ${AWS_REGION}
        log_group_name      /aws/containerinsights/${CLUSTER_NAME}/host
        log_stream_prefix   ${HOST_NAME}-
        auto_create_group   true
        extra_user_agent    container-insights

  parsers.conf: |
    [PARSER]
        Name                syslog
        Format              regex
        Regex               ^(?<time>[^ ]* {1,2}[^ ]* [^ ]*) (?<host>[^ ]*) (?<ident>[a-zA-Z0-9_\/\.\-]*)(?:\[(?<pid>[0-9]+)\])?(?:[^\:]*\:)? *(?<message>.*)$
        Time_Key            time
        Time_Format         %b %d %H:%M:%S

    [PARSER]
        Name                container_firstline
        Format              regex
        Regex               (?<log>(?<="log":")\S(?!\.).*?)(?<!\\)".*(?<stream>(?<="stream":").*?)".*(?<time>\d{4}-\d{1,2}-\d{1,2}T\d{2}:\d{2}:\d{2}\.\w*).*(?=})
        Time_Key            time
        Time_Format         %Y-%m-%dT%H:%M:%S.%LZ

    [PARSER]
        Name                cwagent_firstline
        Format              regex
        Regex               (?<log>(?<="log":")\d{4}[\/-]\d{1,2}[\/-]\d{1,2}[ T]\d{2}:\d{2}:\d{2}(?!\.).*?)(?<!\\)".*(?<stream>(?<="stream":").*?)".*(?<time>\d{4}-\d{1,2}-\d{1,2}T\d{2}:\d{2}:\d{2}\.\w*).*(?=})
        Time_Key            time
        Time_Format         %Y-%m-%dT%H:%M:%S.%LZ

---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluent-bit
  namespace: amazon-cloudwatch
spec:
  selector:
    matchLabels:
      name: fluent-bit
  template:
    metadata:
      labels:
        name: fluent-bit
    spec:
      serviceAccountName: fluent-bit
      tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      - operator: "Exists"
        effect: "NoExecute"
      - operator: "Exists"
        effect: "NoSchedule"
      containers:
      - name: fluent-bit
        image: public.ecr.aws/aws-observability/aws-for-fluent-bit:stable
        imagePullPolicy: Always
        env:
        - name: AWS_REGION
          valueFrom:
            configMapKeyRef:
              name: fluent-bit-cluster-info
              key: logs.region
        - name: CLUSTER_NAME
          valueFrom:
            configMapKeyRef:
              name: fluent-bit-cluster-info
              key: cluster.name
        - name: HTTP_SERVER
          value: "On"
        - name: HTTP_PORT
          value: "2020"
        - name: READ_FROM_HEAD
          value: "Off"
        - name: READ_FROM_TAIL
          value: "On"
        - name: HOST_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: HOSTNAME
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.name
        - name: CI_VERSION
          value: "k8s/1.3.9"
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 500m
            memory: 100Mi
        volumeMounts:
        - name: fluentbitstate
          mountPath: /var/fluent-bit/state
        - name: varlog
          mountPath: /var/log
          readOnly: true
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: fluent-bit-config
          mountPath: /fluent-bit/etc/
        - name: runlogjournal
          mountPath: /run/log/journal
          readOnly: true
        - name: dmesg
          mountPath: /var/log/dmesg
          readOnly: true
      terminationGracePeriodSeconds: 10
      hostNetwork: true
      dnsPolicy: ClusterFirstWithHostNet
      volumes:
      - name: fluentbitstate
        hostPath:
          path: /var/fluent-bit/state
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: fluent-bit-config
        configMap:
          name: fluent-bit-config
      - name: runlogjournal
        hostPath:
          path: /run/log/journal
      - name: dmesg
        hostPath:
          path: /var/log/dmesg
```

## Prometheus and Grafana

### Prometheus Installation
```yaml
# prometheus-deployment.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  namespace: monitoring

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/proxy
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: monitoring

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s

    rule_files:
      - "kubernetes.rules"
      - "application.rules"

    alerting:
      alertmanagers:
      - static_configs:
        - targets:
          - alertmanager:9093

    scrape_configs:
    - job_name: 'kubernetes-apiservers'
      kubernetes_sd_configs:
      - role: endpoints
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      relabel_configs:
      - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
        action: keep
        regex: default;kubernetes;https

    - job_name: 'kubernetes-nodes'
      kubernetes_sd_configs:
      - role: node
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
      - target_label: __address__
        replacement: kubernetes.default.svc:443
      - source_labels: [__meta_kubernetes_node_name]
        regex: (.+)
        target_label: __metrics_path__
        replacement: /api/v1/nodes/${1}/proxy/metrics

    - job_name: 'kubernetes-cadvisor'
      kubernetes_sd_configs:
      - role: node
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
      - target_label: __address__
        replacement: kubernetes.default.svc:443
      - source_labels: [__meta_kubernetes_node_name]
        regex: (.+)
        target_label: __metrics_path__
        replacement: /api/v1/nodes/${1}/proxy/metrics/cadvisor

    - job_name: 'kubernetes-service-endpoints'
      kubernetes_sd_configs:
      - role: endpoints
      relabel_configs:
      - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_service_label_(.+)
      - source_labels: [__meta_kubernetes_namespace]
        action: replace
        target_label: kubernetes_namespace
      - source_labels: [__meta_kubernetes_service_name]
        action: replace
        target_label: kubernetes_name

    - job_name: 'kubernetes-pods'
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_pod_label_(.+)
      - source_labels: [__meta_kubernetes_namespace]
        action: replace
        target_label: kubernetes_namespace
      - source_labels: [__meta_kubernetes_pod_name]
        action: replace
        target_label: kubernetes_pod_name

  kubernetes.rules: |
    groups:
    - name: kubernetes.rules
      rules:
      - alert: KubernetesNodeReady
        expr: kube_node_status_condition{condition="Ready",status="true"} == 0
        for: 10m
        labels:
          severity: critical
        annotations:
          summary: Kubernetes Node ready (instance {{ $labels.instance }})
          description: "Node {{ $labels.node }} has been unready for a long time"

      - alert: KubernetesMemoryPressure
        expr: kube_node_status_condition{condition="MemoryPressure",status="true"} == 1
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: Kubernetes memory pressure (instance {{ $labels.instance }})
          description: "Node {{ $labels.node }} has MemoryPressure condition"

      - alert: KubernetesDiskPressure
        expr: kube_node_status_condition{condition="DiskPressure",status="true"} == 1
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: Kubernetes disk pressure (instance {{ $labels.instance }})
          description: "Node {{ $labels.node }} has DiskPressure condition"

      - alert: KubernetesOutOfDisk
        expr: kube_node_status_condition{condition="OutOfDisk",status="true"} == 1
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: Kubernetes out of disk (instance {{ $labels.instance }})
          description: "Node {{ $labels.node }} has OutOfDisk condition"

      - alert: KubernetesPodCrashLooping
        expr: increase(kube_pod_container_status_restarts_total[1h]) > 5
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: Kubernetes pod crash looping (instance {{ $labels.instance }})
          description: "Pod {{ $labels.pod }} is crash looping"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      serviceAccountName: prometheus
      containers:
      - name: prometheus
        image: prom/prometheus:v2.40.0
        args:
          - '--storage.tsdb.retention.time=30d'
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus/'
          - '--web.console.libraries=/etc/prometheus/console_libraries'
          - '--web.console.templates=/etc/prometheus/consoles'
          - '--web.enable-lifecycle'
        ports:
        - containerPort: 9090
        resources:
          requests:
            cpu: 500m
            memory: 500M
          limits:
            cpu: 1
            memory: 1Gi
        volumeMounts:
        - name: prometheus-config-volume
          mountPath: /etc/prometheus/
        - name: prometheus-storage-volume
          mountPath: /prometheus/
      volumes:
      - name: prometheus-config-volume
        configMap:
          defaultMode: 420
          name: prometheus-config
      - name: prometheus-storage-volume
        emptyDir: {}

---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: monitoring
  annotations:
    prometheus.io/scrape: 'true'
    prometheus.io/port: '9090'
spec:
  selector:
    app: prometheus
  type: NodePort
  ports:
    - port: 8080
      targetPort: 9090
      nodePort: 30000
```

### Grafana Deployment
```yaml
# grafana-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      name: grafana
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:9.3.0
        ports:
        - name: grafana
          containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_USER
          value: admin
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: admin
        resources:
          limits:
            memory: "1Gi"
            cpu: "1000m"
          requests:
            memory: 500M
            cpu: "500m"
        volumeMounts:
        - mountPath: /var/lib/grafana
          name: grafana-storage
        - mountPath: /etc/grafana/provisioning/datasources
          name: grafana-datasources
          readOnly: false
      volumes:
      - name: grafana-storage
        emptyDir: {}
      - name: grafana-datasources
        configMap:
          defaultMode: 420
          name: grafana-datasources

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-datasources
  namespace: monitoring
data:
  prometheus.yaml: |-
    {
        "apiVersion": 1,
        "datasources": [
            {
               "access":"proxy",
                "editable": true,
                "name": "prometheus",
                "orgId": 1,
                "type": "prometheus",
                "url": "http://prometheus.monitoring.svc:8080",
                "version": 1
            }
        ]
    }

---
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: monitoring
  annotations:
      prometheus.io/scrape: 'true'
      prometheus.io/port:   '3000'
spec:
  selector:
    app: grafana
  type: NodePort
  ports:
    - port: 3000
      targetPort: 3000
      nodePort: 32000
```

## Application Monitoring

### Application Metrics Instrumentation
```yaml
# application-with-metrics.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-with-metrics
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app-with-metrics
  template:
    metadata:
      labels:
        app: web-app-with-metrics
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9090"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: web-app
        image: myapp:v1.0.0
        ports:
        - containerPort: 8080
          name: http
        - containerPort: 9090
          name: metrics
        env:
        - name: METRICS_PORT
          value: "9090"
        - name: METRICS_PATH
          value: "/metrics"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"

---
# ServiceMonitor for Prometheus Operator
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: web-app-metrics
  namespace: production
  labels:
    app: web-app-with-metrics
spec:
  selector:
    matchLabels:
      app: web-app-with-metrics
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
    honorLabels: true
```

### Custom Metrics Example (Node.js)
```javascript
// metrics.js - Application metrics instrumentation
const express = require('express');
const promClient = require('prom-client');

// Create a Registry to register the metrics
const register = new promClient.Registry();

// Add a default label which is added to all metrics
register.setDefaultLabels({
  app: 'web-app'
});

// Enable the collection of default metrics
promClient.collectDefaultMetrics({ register });

// Create custom metrics
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

// Middleware to collect HTTP metrics
const metricsMiddleware = (req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;
    
    httpRequestDuration
      .labels(req.method, route, res.statusCode)
      .observe(duration);
    
    httpRequestsTotal
      .labels(req.method, route, res.statusCode)
      .inc();
  });
  
  next();
};

// Express app setup
const app = express();
app.use(metricsMiddleware);

// Health endpoints
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.get('/ready', (req, res) => {
  res.status(200).json({ status: 'ready' });
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (ex) {
    res.status(500).end(ex);
  }
});

// Business logic endpoints
app.post('/api/orders', (req, res) => {
  // Simulate order processing
  const success = Math.random() > 0.1; // 90% success rate
  
  if (success) {
    businessMetrics.labels('order', 'success').inc();
    res.status(201).json({ orderId: Date.now() });
  } else {
    businessMetrics.labels('order', 'failure').inc();
    res.status(500).json({ error: 'Order processing failed' });
  }
});

// Update active connections
let connections = 0;
app.use((req, res, next) => {
  connections++;
  activeConnections.set(connections);
  
  res.on('close', () => {
    connections--;
    activeConnections.set(connections);
  });
  
  next();
});

const PORT = process.env.PORT || 8080;
const METRICS_PORT = process.env.METRICS_PORT || 9090;

// Start main application server
app.listen(PORT, () => {
  console.log(`Application server running on port ${PORT}`);
});

// Start metrics server
const metricsApp = express();
metricsApp.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (ex) {
    res.status(500).end(ex);
  }
});

metricsApp.listen(METRICS_PORT, () => {
  console.log(`Metrics server running on port ${METRICS_PORT}`);
});
```

## Log Management

### Structured Logging Configuration
```yaml
# structured-logging-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: structured-logging-app
  namespace: production
spec:
  replicas: 2
  selector:
    matchLabels:
      app: structured-logging-app
  template:
    metadata:
      labels:
        app: structured-logging-app
    spec:
      containers:
      - name: app
        image: myapp:v1.0.0
        env:
        - name: LOG_LEVEL
          value: "info"
        - name: LOG_FORMAT
          value: "json"
        - name: SERVICE_NAME
          value: "web-api"
        - name: SERVICE_VERSION
          value: "v1.0.0"
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
```

### Log Parsing Configuration
```yaml
# log-parsing-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-parsers
  namespace: amazon-cloudwatch
data:
  parsers.conf: |
    [PARSER]
        Name        json
        Format      json
        Time_Key    timestamp
        Time_Format %Y-%m-%dT%H:%M:%S.%L
        Time_Keep   On

    [PARSER]
        Name        nginx
        Format      regex
        Regex       ^(?<remote>[^ ]*) (?<host>[^ ]*) (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\"]*?)(?: +\S*)?)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$
        Time_Key    time
        Time_Format %d/%b/%Y:%H:%M:%S %z

    [PARSER]
        Name        apache
        Format      regex
        Regex       ^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^ ]*) +\S*)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$
        Time_Key    time
        Time_Format %d/%b/%Y:%H:%M:%S %z

    [PARSER]
        Name        k8s-nginx-ingress
        Format      regex
        Regex       ^(?<host>[^ ]*) - (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\s]*?)(?: +\S*)?)?" (?<code>[^ ]*) (?<size>[^ ]*) "(?<referer>[^\"]*)" "(?<agent>[^\"]*)" (?<request_length>[^ ]*) (?<request_time>[^ ]*) \[(?<proxy_upstream_name>[^ ]*)\] \[(?<proxy_alternative_upstream_name>[^ ]*)\] (?<upstream_addr>[^ ]*) (?<upstream_response_length>[^ ]*) (?<upstream_response_time>[^ ]*) (?<upstream_status>[^ ]*) (?<reg_id>[^ ]*).*$
        Time_Key    time
        Time_Format %d/%b/%Y:%H:%M:%S %z
```

## Alerting and Notifications

### AlertManager Configuration
```yaml
# alertmanager-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: monitoring
data:
  alertmanager.yml: |
    global:
      smtp_smarthost: 'smtp.gmail.com:587'
      smtp_from: 'alerts@company.com'
      smtp_auth_username: 'alerts@company.com'
      smtp_auth_password: 'password'

    route:
      group_by: ['alertname']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
      receiver: 'web.hook'
      routes:
      - match:
          severity: critical
        receiver: 'critical-alerts'
      - match:
          severity: warning
        receiver: 'warning-alerts'

    receivers:
    - name: 'web.hook'
      webhook_configs:
      - url: 'http://127.0.0.1:5001/'

    - name: 'critical-alerts'
      email_configs:
      - to: 'oncall@company.com'
        subject: 'CRITICAL: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
      slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
        channel: '#alerts-critical'
        title: 'CRITICAL Alert'
        text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'

    - name: 'warning-alerts'
      email_configs:
      - to: 'team@company.com'
        subject: 'WARNING: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}

    inhibit_rules:
    - source_match:
        severity: 'critical'
      target_match:
        severity: 'warning'
      equal: ['alertname', 'dev', 'instance']

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: alertmanager
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: alertmanager
  template:
    metadata:
      labels:
        app: alertmanager
    spec:
      containers:
      - name: alertmanager
        image: prom/alertmanager:v0.25.0
        args:
          - '--config.file=/etc/alertmanager/alertmanager.yml'
          - '--storage.path=/alertmanager'
        ports:
        - containerPort: 9093
        resources:
          requests:
            cpu: 500m
            memory: 500M
          limits:
            cpu: 1
            memory: 1Gi
        volumeMounts:
        - name: alertmanager-config-volume
          mountPath: /etc/alertmanager
        - name: alertmanager-storage-volume
          mountPath: /alertmanager
      volumes:
      - name: alertmanager-config-volume
        configMap:
          defaultMode: 420
          name: alertmanager-config
      - name: alertmanager-storage-volume
        emptyDir: {}

---
apiVersion: v1
kind: Service
metadata:
  name: alertmanager
  namespace: monitoring
spec:
  selector:
    app: alertmanager
  type: NodePort
  ports:
    - port: 9093
      targetPort: 9093
      nodePort: 31000
```

### CloudWatch Alarms
```yaml
# cloudwatch-alarms.tf
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "eks-high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EKS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors eks cpu utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = "production-cluster"
  }
}

resource "aws_cloudwatch_metric_alarm" "pod_restart" {
  alarm_name          = "eks-pod-restart-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "pod_restart_rate"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors pod restart rate"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = "production-cluster"
  }
}

resource "aws_sns_topic" "alerts" {
  name = "eks-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "alerts@company.com"
}
```

## Performance Monitoring

### Resource Monitoring Dashboard
```json
{
  "dashboard": {
    "title": "EKS Performance Dashboard",
    "panels": [
      {
        "title": "CPU Usage by Node",
        "type": "graph",
        "targets": [
          {
            "expr": "100 - (avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "{{ instance }}"
          }
        ]
      },
      {
        "title": "Memory Usage by Node",
        "type": "graph",
        "targets": [
          {
            "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100",
            "legendFormat": "{{ instance }}"
          }
        ]
      },
      {
        "title": "Pod CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "sum(rate(container_cpu_usage_seconds_total{container!=\"POD\",container!=\"\"}[5m])) by (pod)",
            "legendFormat": "{{ pod }}"
          }
        ]
      },
      {
        "title": "Pod Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "sum(container_memory_working_set_bytes{container!=\"POD\",container!=\"\"}) by (pod)",
            "legendFormat": "{{ pod }}"
          }
        ]
      },
      {
        "title": "Network I/O",
        "type": "graph",
        "targets": [
          {
            "expr": "sum(rate(container_network_receive_bytes_total[5m])) by (pod)",
            "legendFormat": "{{ pod }} - receive"
          },
          {
            "expr": "sum(rate(container_network_transmit_bytes_total[5m])) by (pod)",
            "legendFormat": "{{ pod }} - transmit"
          }
        ]
      }
    ]
  }
}
```

## Troubleshooting Methodology

### Systematic Troubleshooting Approach
```bash
#!/bin/bash
# eks-troubleshooting-toolkit.sh

set -e

NAMESPACE=${1:-default}
POD_NAME=${2:-}
CLUSTER_NAME=${3:-production-cluster}

echo "=== EKS Troubleshooting Toolkit ==="
echo "Namespace: $NAMESPACE"
echo "Pod: $POD_NAME"
echo "Cluster: $CLUSTER_NAME"
echo

# 1. Cluster Health Check
echo "1. Checking cluster health..."
kubectl get nodes
kubectl get pods --all-namespaces | grep -v Running | grep -v Completed || echo "All pods are running"
echo

# 2. Resource Usage
echo "2. Checking resource usage..."
kubectl top nodes
kubectl top pods -n $NAMESPACE
echo

# 3. Events
echo "3. Recent events..."
kubectl get events -n $NAMESPACE --sort-by=.metadata.creationTimestamp | tail -10
echo

# 4. Pod-specific troubleshooting
if [ ! -z "$POD_NAME" ]; then
    echo "4. Pod-specific diagnostics for $POD_NAME..."
    
    # Pod status
    echo "Pod status:"
    kubectl get pod $POD_NAME -n $NAMESPACE -o wide
    echo
    
    # Pod description
    echo "Pod description:"
    kubectl describe pod $POD_NAME -n $NAMESPACE
    echo
    
    # Pod logs
    echo "Pod logs (last 50 lines):"
    kubectl logs $POD_NAME -n $NAMESPACE --tail=50
    echo
    
    # Previous container logs if pod restarted
    echo "Previous container logs (if available):"
    kubectl logs $POD_NAME -n $NAMESPACE --previous --tail=50 2>/dev/null || echo "No previous logs available"
    echo
fi

# 5. Service connectivity
echo "5. Checking service connectivity..."
kubectl get services -n $NAMESPACE
kubectl get endpoints -n $NAMESPACE
echo

# 6. Ingress status
echo "6. Checking ingress status..."
kubectl get ingress -n $NAMESPACE
echo

# 7. Storage issues
echo "7. Checking storage..."
kubectl get pv
kubectl get pvc -n $NAMESPACE
echo

# 8. Network policies
echo "8. Checking network policies..."
kubectl get networkpolicy -n $NAMESPACE
echo

# 9. RBAC issues
echo "9. Checking RBAC..."
kubectl auth can-i --list -n $NAMESPACE
echo

# 10. Node conditions
echo "10. Node conditions..."
kubectl describe nodes | grep -A 5 "Conditions:"
echo

echo "=== Troubleshooting complete ==="
```

## Common Issues and Solutions

### Pod Issues
```bash
# Pod stuck in Pending state
kubectl describe pod <pod-name> -n <namespace>
# Common causes:
# - Insufficient resources
# - Node selector constraints
# - Taints and tolerations
# - PVC mounting issues

# Pod stuck in ImagePullBackOff
kubectl describe pod <pod-name> -n <namespace>
# Common causes:
# - Image doesn't exist
# - Registry authentication issues
# - Network connectivity issues

# Pod CrashLoopBackOff
kubectl logs <pod-name> -n <namespace> --previous
# Common causes:
# - Application errors
# - Misconfigured health checks
# - Resource limits too low
# - Missing dependencies
```

### Network Issues
```bash
# Service connectivity issues
kubectl get endpoints <service-name> -n <namespace>
kubectl describe service <service-name> -n <namespace>

# DNS resolution issues
kubectl run debug --rm -i --restart=Never --image=busybox -- nslookup kubernetes.default
kubectl run debug --rm -i --restart=Never --image=busybox -- nslookup <service-name>.<namespace>.svc.cluster.local

# Ingress issues
kubectl describe ingress <ingress-name> -n <namespace>
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

### Storage Issues
```bash
# PVC mounting issues
kubectl describe pvc <pvc-name> -n <namespace>
kubectl describe pv <pv-name>

# Check storage class
kubectl get storageclass
kubectl describe storageclass <storage-class-name>

# EBS CSI driver issues
kubectl logs -n kube-system deployment/ebs-csi-controller
kubectl get pods -n kube-system -l app=ebs-csi-controller
```

### Performance Issues
```bash
# High CPU usage
kubectl top pods -n <namespace> --sort-by=cpu
kubectl describe node <node-name>

# High memory usage
kubectl top pods -n <namespace> --sort-by=memory
kubectl describe node <node-name>

# Disk pressure
kubectl describe nodes | grep -A 5 "Conditions:"
df -h # on worker nodes
```

## Debugging Tools and Techniques

### Debug Container
```yaml
# debug-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: debug-pod
  namespace: production
spec:
  containers:
  - name: debug
    image: nicolaka/netshoot
    command: ["/bin/bash"]
    args: ["-c", "while true; do sleep 30; done;"]
    securityContext:
      capabilities:
        add: ["NET_ADMIN"]
  restartPolicy: Never
```

### Network Debugging
```bash
# Test connectivity from debug pod
kubectl exec -it debug-pod -n production -- /bin/bash

# Inside the debug pod:
# Test DNS resolution
nslookup kubernetes.default.svc.cluster.local
nslookup <service-name>.<namespace>.svc.cluster.local

# Test HTTP connectivity
curl -v http://<service-name>.<namespace>.svc.cluster.local:<port>

# Test TCP connectivity
telnet <service-name>.<namespace>.svc.cluster.local <port>

# Network tracing
traceroute <service-name>.<namespace>.svc.cluster.local

# Check network interfaces
ip addr show
ip route show
```

### Application Debugging
```bash
# Execute commands in running containers
kubectl exec -it <pod-name> -n <namespace> -- /bin/bash
kubectl exec -it <pod-name> -n <namespace> -c <container-name> -- /bin/bash

# Port forwarding for local debugging
kubectl port-forward pod/<pod-name> 8080:8080 -n <namespace>
kubectl port-forward service/<service-name> 8080:80 -n <namespace>

# Copy files to/from containers
kubectl cp <local-file> <namespace>/<pod-name>:<container-path>
kubectl cp <namespace>/<pod-name>:<container-path> <local-file>

# Stream logs in real-time
kubectl logs -f <pod-name> -n <namespace>
kubectl logs -f <pod-name> -n <namespace> -c <container-name>
```

### Performance Profiling
```bash
# CPU profiling
kubectl exec -it <pod-name> -n <namespace> -- top
kubectl exec -it <pod-name> -n <namespace> -- ps aux

# Memory analysis
kubectl exec -it <pod-name> -n <namespace> -- free -h
kubectl exec -it <pod-name> -n <namespace> -- cat /proc/meminfo

# Disk usage
kubectl exec -it <pod-name> -n <namespace> -- df -h
kubectl exec -it <pod-name> -n <namespace> -- du -sh /*

# Network statistics
kubectl exec -it <pod-name> -n <namespace> -- netstat -tuln
kubectl exec -it <pod-name> -n <namespace> -- ss -tuln
```

### Monitoring Commands
```bash
# Watch resources in real-time
watch kubectl get pods -n <namespace>
watch kubectl top pods -n <namespace>
watch kubectl get events -n <namespace> --sort-by=.metadata.creationTimestamp

# Continuous monitoring script
#!/bin/bash
while true; do
    clear
    echo "=== $(date) ==="
    kubectl get pods -n production
    echo
    kubectl top pods -n production
    echo
    kubectl get events -n production --sort-by=.metadata.creationTimestamp | tail -5
    sleep 10
done
```

This comprehensive monitoring and troubleshooting guide provides the tools and techniques needed to effectively monitor, debug, and maintain EKS clusters in production environments.