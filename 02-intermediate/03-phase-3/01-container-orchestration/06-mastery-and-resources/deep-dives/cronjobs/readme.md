# Kubernetes CronJobs

## Overview

**Kubernetes CronJobs** create Jobs on a repeating schedule. CronJobs are ideal for periodic tasks like backups, report generation, and maintenance operations.

## Basic CronJob

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello-cronjob
spec:
  schedule: "*/1 * * * *"  # Every minute
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox:1.28
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
```

## Cron Schedule Format

```
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday)
# │ │ │ │ │
# │ │ │ │ │
# * * * * *
```

## Common Schedules

```yaml
# Every minute
schedule: "*/1 * * * *"

# Every hour at minute 0
schedule: "0 * * * *"

# Every day at 2:30 AM
schedule: "30 2 * * *"

# Every Monday at 9:00 AM
schedule: "0 9 * * 1"

# Every 15 minutes
schedule: "*/15 * * * *"

# Twice a day (6 AM and 6 PM)
schedule: "0 6,18 * * *"
```

## Database Backup CronJob

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: database-backup
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:13
            command:
            - sh
            - -c
            - |
              BACKUP_FILE="/backup/backup-$(date +%Y%m%d-%H%M%S).sql"
              pg_dump -h $DB_HOST -U $DB_USER $DB_NAME > $BACKUP_FILE
              echo "Backup completed: $BACKUP_FILE"
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
          restartPolicy: OnFailure
```

## Log Cleanup CronJob

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: log-cleanup
spec:
  schedule: "0 1 * * 0"  # Weekly on Sunday at 1 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cleanup
            image: busybox:1.28
            command:
            - sh
            - -c
            - |
              echo "Cleaning up logs older than 7 days..."
              find /var/log -name "*.log" -mtime +7 -delete
              echo "Log cleanup completed"
            volumeMounts:
            - name: log-volume
              mountPath: /var/log
          volumes:
          - name: log-volume
            hostPath:
              path: /var/log
          restartPolicy: OnFailure
```

## Report Generation CronJob

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: daily-report
spec:
  schedule: "0 8 * * 1-5"  # Weekdays at 8 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: report-generator
            image: my-report-app:latest
            command:
            - python
            - generate_report.py
            - --date=$(date +%Y-%m-%d)
            env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: app-secret
                  key: database-url
            - name: EMAIL_SMTP_HOST
              value: smtp.example.com
          restartPolicy: OnFailure
```

## CronJob Configuration

### Concurrency Policy
```yaml
spec:
  concurrencyPolicy: Allow    # Allow concurrent jobs (default)
  # concurrencyPolicy: Forbid   # Skip new job if previous is still running
  # concurrencyPolicy: Replace # Cancel previous job and start new one
```

### History Limits
```yaml
spec:
  successfulJobsHistoryLimit: 3  # Keep 3 successful jobs
  failedJobsHistoryLimit: 1      # Keep 1 failed job
```

### Starting Deadline
```yaml
spec:
  startingDeadlineSeconds: 300  # Job must start within 5 minutes
```

### Suspend
```yaml
spec:
  suspend: true  # Suspend the CronJob
```

## Complete CronJob Example

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: comprehensive-cronjob
spec:
  schedule: "0 */6 * * *"  # Every 6 hours
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  startingDeadlineSeconds: 300
  jobTemplate:
    spec:
      activeDeadlineSeconds: 3600  # Job timeout: 1 hour
      backoffLimit: 3
      template:
        spec:
          containers:
          - name: worker
            image: my-worker:latest
            resources:
              requests:
                cpu: 100m
                memory: 128Mi
              limits:
                cpu: 500m
                memory: 512Mi
          restartPolicy: OnFailure
```

## CronJob Management

```bash
# Create CronJob
kubectl apply -f cronjob.yaml

# Get CronJobs
kubectl get cronjobs

# Describe CronJob
kubectl describe cronjob hello-cronjob

# Get jobs created by CronJob
kubectl get jobs --selector=job-name=hello-cronjob

# Manually trigger CronJob
kubectl create job --from=cronjob/hello-cronjob manual-job

# Suspend CronJob
kubectl patch cronjob hello-cronjob -p '{"spec":{"suspend":true}}'

# Resume CronJob
kubectl patch cronjob hello-cronjob -p '{"spec":{"suspend":false}}'

# Delete CronJob
kubectl delete cronjob hello-cronjob
```

## Monitoring CronJobs

```bash
# Check CronJob status
kubectl get cronjob hello-cronjob -o wide

# Check last schedule time
kubectl get cronjob hello-cronjob -o jsonpath='{.status.lastScheduleTime}'

# Check active jobs
kubectl get cronjob hello-cronjob -o jsonpath='{.status.active}'

# View CronJob events
kubectl describe cronjob hello-cronjob
```

## Best Practices

- Use appropriate concurrency policies
- Set resource limits for job pods
- Implement proper error handling
- Monitor job execution and failures
- Use meaningful names and labels
- Set appropriate history limits
- Test schedules in non-production first

## Troubleshooting

```bash
# Check CronJob events
kubectl describe cronjob my-cronjob

# Check job logs
kubectl logs job/my-cronjob-1234567890

# Check failed jobs
kubectl get jobs -l cronjob=my-cronjob --field-selector=status.successful!=1

# Debug schedule
kubectl get cronjob my-cronjob -o jsonpath='{.spec.schedule}'

# Check timezone (CronJobs use UTC)
kubectl get cronjob my-cronjob -o jsonpath='{.status.lastScheduleTime}'
```

## Time Zones

CronJobs run in UTC by default. For specific timezones:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: timezone-cronjob
spec:
  schedule: "0 9 * * *"  # 9 AM UTC
  timeZone: "America/New_York"  # Kubernetes 1.25+
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: app
            image: busybox
            command: ["date"]
          restartPolicy: OnFailure
```

## Conclusion

CronJobs provide essential scheduled task capabilities in Kubernetes, enabling automated maintenance, backups, and periodic processing with robust scheduling and error handling features.