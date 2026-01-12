# Kubernetes Jobs

## Overview

**Kubernetes Jobs** run pods to completion, ensuring that a specified number of pods successfully terminate. Jobs are ideal for batch processing, data migration, and one-time tasks.

## Basic Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-calculation
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl:5.34.0
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
```

## Parallel Jobs

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: parallel-job
spec:
  parallelism: 3
  completions: 6
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ["sh", "-c", "echo Processing item $RANDOM && sleep 30"]
      restartPolicy: Never
```

## Job with Work Queue

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: work-queue-job
spec:
  parallelism: 2
  template:
    spec:
      containers:
      - name: worker
        image: my-worker:latest
        env:
        - name: QUEUE_URL
          value: "redis://redis-service:6379"
      restartPolicy: Never
```

## Job Patterns

### Single Job with Fixed Completion Count
```yaml
spec:
  completions: 5
  parallelism: 2
```

### Job with Work Queue
```yaml
spec:
  parallelism: 3
  # completions not specified - job completes when queue is empty
```

### Single Job Run to Completion
```yaml
spec:
  # completions and parallelism default to 1
```

## Job Configuration

### Backoff Limit
```yaml
spec:
  backoffLimit: 6  # Retry failed pods up to 6 times
```

### Active Deadline
```yaml
spec:
  activeDeadlineSeconds: 3600  # Job timeout after 1 hour
```

### TTL After Finished
```yaml
spec:
  ttlSecondsAfterFinished: 100  # Clean up job 100 seconds after completion
```

## Database Migration Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration
spec:
  template:
    spec:
      containers:
      - name: migrate
        image: migrate/migrate:latest
        command:
        - migrate
        - -path=/migrations
        - -database=postgres://user:pass@db:5432/mydb?sslmode=disable
        - up
        volumeMounts:
        - name: migrations
          mountPath: /migrations
      volumes:
      - name: migrations
        configMap:
          name: db-migrations
      restartPolicy: Never
  backoffLimit: 3
```

## Backup Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: database-backup
spec:
  template:
    spec:
      containers:
      - name: backup
        image: postgres:13
        command:
        - sh
        - -c
        - pg_dump -h $DB_HOST -U $DB_USER $DB_NAME > /backup/backup-$(date +%Y%m%d-%H%M%S).sql
        env:
        - name: DB_HOST
          value: postgres-service
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: username
        - name: PGPASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
        - name: DB_NAME
          value: myapp
        volumeMounts:
        - name: backup-storage
          mountPath: /backup
      volumes:
      - name: backup-storage
        persistentVolumeClaim:
          claimName: backup-pvc
      restartPolicy: Never
```

## Job Management

```bash
# Create job
kubectl apply -f job.yaml

# Get jobs
kubectl get jobs

# Describe job
kubectl describe job pi-calculation

# Get job pods
kubectl get pods --selector=job-name=pi-calculation

# Check job logs
kubectl logs job/pi-calculation

# Delete job
kubectl delete job pi-calculation

# Delete job and pods
kubectl delete job pi-calculation --cascade=foreground
```

## Job Status

```bash
# Check job completion
kubectl get job pi-calculation -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}'

# Check job failure
kubectl get job pi-calculation -o jsonpath='{.status.conditions[?(@.type=="Failed")].status}'

# Get job metrics
kubectl get job pi-calculation -o jsonpath='{.status}'
```

## Best Practices

- Set appropriate backoff limits
- Use resource limits for job pods
- Implement proper logging
- Clean up completed jobs
- Monitor job execution time

## Troubleshooting

```bash
# Check job events
kubectl describe job my-job

# Check pod logs
kubectl logs -l job-name=my-job

# Check failed pods
kubectl get pods -l job-name=my-job --field-selector=status.phase=Failed

# Debug job configuration
kubectl get job my-job -o yaml
```

## Job vs CronJob

- **Job**: Runs once to completion
- **CronJob**: Runs jobs on a schedule

## Conclusion

Jobs provide essential batch processing capabilities in Kubernetes, enabling reliable execution of one-time tasks and batch workloads with proper error handling and retry mechanisms.