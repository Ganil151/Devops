# Cloud Troubleshooting

Comprehensive guide to diagnosing and resolving common cloud infrastructure and application issues.

## General Troubleshooting Methodology

### Systematic Approach
```yaml
1. Problem Identification:
   - Gather symptoms and error messages
   - Identify affected components
   - Determine impact scope
   - Check recent changes

2. Information Gathering:
   - Review logs and metrics
   - Check system status
   - Verify configurations
   - Test connectivity

3. Root Cause Analysis:
   - Isolate the problem
   - Test hypotheses
   - Trace request flows
   - Analyze dependencies

4. Resolution and Validation:
   - Implement fixes
   - Test solutions
   - Monitor results
   - Document findings
```

### Essential Tools
```bash
# Network diagnostics
ping -c 4 target-host
traceroute target-host
nslookup domain.com
dig domain.com
telnet host port
nc -zv host port

# System diagnostics
top
htop
iostat
vmstat
netstat -tuln
ss -tuln
lsof -i :port

# Log analysis
tail -f /var/log/syslog
journalctl -f
grep -r "ERROR" /var/log/
awk '/ERROR/ {print $0}' logfile.log
```

## AWS Troubleshooting

### EC2 Instance Issues

#### Instance Launch Failures
```bash
# Check instance status
aws ec2 describe-instances --instance-ids i-1234567890abcdef0

# View instance console output
aws ec2 get-console-output --instance-id i-1234567890abcdef0

# Check security group rules
aws ec2 describe-security-groups --group-ids sg-12345678

# Verify subnet and VPC configuration
aws ec2 describe-subnets --subnet-ids subnet-12345678
aws ec2 describe-vpcs --vpc-ids vpc-12345678

# Check IAM instance profile
aws iam get-instance-profile --instance-profile-name MyInstanceProfile
```

#### Connectivity Issues
```bash
# Test security group rules
aws ec2 authorize-security-group-ingress \
  --group-id sg-12345678 \
  --protocol tcp \
  --port 22 \
  --source-group sg-87654321

# Check route tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=vpc-12345678"

# Verify internet gateway
aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=vpc-12345678"

# Check network ACLs
aws ec2 describe-network-acls --filters "Name=vpc-id,Values=vpc-12345678"
```

### Automation Troubleshooting
For issues specific to SDK/CLI scripting, API throttling, and automation hacks, see the **[Automation Troubleshooting & Hacks Guide](../../Intermediate-Level/10-Cloud-Automation/automation-troubleshooting-hacks.md)**.

### Security Troubleshooting
For debugging IAM "Access Denied" errors, decoding authorization messages, and incident response hacks, see the **[Security Hacks & Troubleshooting Guide](security-hacks-troubleshooting.md)**.

### RDS Database Issues
```bash
# Check database status
aws rds describe-db-instances --db-instance-identifier mydb

# View database logs
aws rds describe-db-log-files --db-instance-identifier mydb
aws rds download-db-log-file-portion \
  --db-instance-identifier mydb \
  --log-file-name error/mysql-error.log

# Check parameter groups
aws rds describe-db-parameter-groups --db-parameter-group-name myparamgroup

# Monitor performance
aws rds describe-db-instances \
  --db-instance-identifier mydb \
  --query 'DBInstances[0].{Status:DBInstanceStatus,Engine:Engine,Class:DBInstanceClass}'
```

### S3 Access Issues
```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket my-bucket

# Verify bucket ACL
aws s3api get-bucket-acl --bucket my-bucket

# Test object access
aws s3api head-object --bucket my-bucket --key my-object

# Check CORS configuration
aws s3api get-bucket-cors --bucket my-bucket

# Verify encryption settings
aws s3api get-bucket-encryption --bucket my-bucket
```

## Azure Troubleshooting

### Virtual Machine Issues

#### VM Performance Problems
```bash
# Check VM status
az vm get-instance-view --resource-group myRG --name myVM

# View boot diagnostics
az vm boot-diagnostics get-boot-log --resource-group myRG --name myVM

# Check VM sizes and availability
az vm list-sizes --location eastus

# Monitor VM metrics
az monitor metrics list \
  --resource /subscriptions/{subscription-id}/resourceGroups/myRG/providers/Microsoft.Compute/virtualMachines/myVM \
  --metric "Percentage CPU"

# Check disk performance
az disk show --resource-group myRG --name myDisk
```

#### Network Connectivity Issues
```bash
# Check network security group rules
az network nsg show --resource-group myRG --name myNSG

# Test network connectivity
az network watcher test-connectivity \
  --source-resource myVM \
  --dest-address 8.8.8.8 \
  --dest-port 80

# Check effective routes
az network nic show-effective-route-table \
  --resource-group myRG \
  --name myNIC

# Verify DNS resolution
az network dns record-set list --resource-group myRG --zone-name example.com
```

### Azure SQL Database Issues
```bash
# Check database status
az sql db show --resource-group myRG --server myserver --name mydatabase

# View database metrics
az monitor metrics list \
  --resource /subscriptions/{subscription-id}/resourceGroups/myRG/providers/Microsoft.Sql/servers/myserver/databases/mydatabase \
  --metric "cpu_percent"

# Check firewall rules
az sql server firewall-rule list --resource-group myRG --server myserver

# Monitor query performance
az sql db query-store show --resource-group myRG --server myserver --database mydatabase
```

## Google Cloud Troubleshooting

### Compute Engine Issues

#### Instance Problems
```bash
# Check instance status
gcloud compute instances describe my-instance --zone=us-central1-a

# View serial console output
gcloud compute instances get-serial-port-output my-instance --zone=us-central1-a

# Check firewall rules
gcloud compute firewall-rules list
gcloud compute firewall-rules describe allow-http

# Test connectivity
gcloud compute ssh my-instance --zone=us-central1-a --command="ping -c 4 8.8.8.8"

# Check metadata
gcloud compute instances describe my-instance --zone=us-central1-a --format="value(metadata.items)"
```

#### Network Issues
```bash
# Check VPC configuration
gcloud compute networks describe my-vpc

# View subnet details
gcloud compute networks subnets describe my-subnet --region=us-central1

# Check routes
gcloud compute routes list --filter="network:my-vpc"

# Test internal connectivity
gcloud compute ssh my-instance --zone=us-central1-a --command="curl -I internal-service:8080"
```

### Cloud SQL Issues
```bash
# Check instance status
gcloud sql instances describe my-instance

# View logs
gcloud sql operations list --instance=my-instance
gcloud sql operations describe operation-id

# Check authorized networks
gcloud sql instances describe my-instance --format="value(settings.ipConfiguration.authorizedNetworks)"

# Test connectivity
gcloud sql connect my-instance --user=root
```

## Kubernetes Troubleshooting

### Pod Issues
```bash
# Check pod status
kubectl get pods -o wide
kubectl describe pod my-pod

# View pod logs
kubectl logs my-pod
kubectl logs my-pod -c container-name
kubectl logs my-pod --previous

# Debug pod issues
kubectl exec -it my-pod -- /bin/bash
kubectl port-forward my-pod 8080:80

# Check resource usage
kubectl top pods
kubectl describe node my-node
```

### Service and Networking Issues
```bash
# Check service configuration
kubectl get services
kubectl describe service my-service

# Test service connectivity
kubectl run test-pod --image=busybox --rm -it -- /bin/sh
# Inside the pod:
nslookup my-service
wget -qO- my-service:80

# Check ingress configuration
kubectl get ingress
kubectl describe ingress my-ingress

# Debug DNS issues
kubectl exec -it my-pod -- nslookup kubernetes.default.svc.cluster.local
```

### Cluster Issues
```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes
kubectl describe node my-node

# Check system pods
kubectl get pods -n kube-system
kubectl logs -n kube-system kube-apiserver-master

# Check resource quotas
kubectl get resourcequota
kubectl describe resourcequota my-quota

# Monitor cluster events
kubectl get events --sort-by=.metadata.creationTimestamp
```

## Application-Level Troubleshooting

### Performance Issues

#### Database Performance
```sql
-- PostgreSQL performance analysis
SELECT query, calls, total_time, mean_time, rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- Check active connections
SELECT count(*) FROM pg_stat_activity;

-- Analyze slow queries
SELECT query, query_start, state, wait_event
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY query_start;

-- MySQL performance analysis
SHOW PROCESSLIST;
SHOW ENGINE INNODB STATUS;

SELECT * FROM performance_schema.events_statements_summary_by_digest
ORDER BY sum_timer_wait DESC
LIMIT 10;
```

#### Application Monitoring
```python
# Python application debugging
import logging
import time
import psutil
from functools import wraps

# Performance monitoring decorator
def monitor_performance(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start_time = time.time()
        start_memory = psutil.Process().memory_info().rss
        
        try:
            result = func(*args, **kwargs)
            return result
        except Exception as e:
            logging.error(f"Function {func.__name__} failed: {str(e)}")
            raise
        finally:
            end_time = time.time()
            end_memory = psutil.Process().memory_info().rss
            
            execution_time = end_time - start_time
            memory_diff = end_memory - start_memory
            
            logging.info(f"Function {func.__name__}: "
                        f"Time: {execution_time:.2f}s, "
                        f"Memory: {memory_diff/1024/1024:.2f}MB")
    
    return wrapper

# Health check endpoint
@app.route('/health')
def health_check():
    checks = {
        'database': check_database_connection(),
        'redis': check_redis_connection(),
        'external_api': check_external_api(),
        'disk_space': check_disk_space(),
        'memory': check_memory_usage()
    }
    
    all_healthy = all(checks.values())
    status_code = 200 if all_healthy else 503
    
    return jsonify({
        'status': 'healthy' if all_healthy else 'unhealthy',
        'checks': checks,
        'timestamp': datetime.utcnow().isoformat()
    }), status_code
```

## Monitoring and Alerting

### Log Analysis
```bash
# Centralized log analysis
#!/bin/bash
# log-analyzer.sh

LOG_FILE="$1"
TIME_RANGE="${2:-1h}"

echo "Log Analysis Report"
echo "=================="

# Error rate analysis
echo "Error Rate (last $TIME_RANGE):"
grep -E "(ERROR|FATAL)" "$LOG_FILE" | wc -l

# Top error messages
echo -e "\nTop Error Messages:"
grep -E "(ERROR|FATAL)" "$LOG_FILE" | \
awk '{for(i=4;i<=NF;i++) printf "%s ", $i; print ""}' | \
sort | uniq -c | sort -nr | head -10

# Response time analysis
echo -e "\nResponse Time Analysis:"
grep "response_time" "$LOG_FILE" | \
awk '{print $NF}' | \
awk '{sum+=$1; count++; if($1>max) max=$1; if(min=="" || $1<min) min=$1} 
     END {print "Average:", sum/count "ms"; print "Max:", max "ms"; print "Min:", min "ms"}'

# Traffic patterns
echo -e "\nTraffic Patterns:"
grep -E "GET|POST|PUT|DELETE" "$LOG_FILE" | \
awk '{print $4}' | cut -d: -f2 | \
sort | uniq -c | sort -nr | head -10
```

### Automated Remediation
```bash
#!/bin/bash
# auto-remediation.sh

ALERT_TYPE="$1"
SEVERITY="$2"
RESOURCE="$3"

case "$ALERT_TYPE" in
    "high_cpu")
        if [[ "$SEVERITY" == "critical" ]]; then
            # Scale up instances
            aws autoscaling set-desired-capacity \
                --auto-scaling-group-name web-asg \
                --desired-capacity 5
            
            echo "Scaled up ASG due to high CPU"
        fi
        ;;
    
    "disk_full")
        # Clean up temporary files
        find /tmp -type f -mtime +7 -delete
        find /var/log -name "*.log" -mtime +30 -delete
        
        # Rotate logs
        logrotate -f /etc/logrotate.conf
        
        echo "Cleaned up disk space"
        ;;
    
    "service_down")
        # Restart service
        systemctl restart "$RESOURCE"
        
        # Wait and check status
        sleep 10
        if systemctl is-active "$RESOURCE" --quiet; then
            echo "Service $RESOURCE restarted successfully"
        else
            echo "Failed to restart service $RESOURCE"
            # Escalate to on-call
            curl -X POST "$PAGERDUTY_WEBHOOK" \
                -d "{\"service_key\":\"$PD_SERVICE_KEY\",\"event_type\":\"trigger\",\"description\":\"Failed to restart $RESOURCE\"}"
        fi
        ;;
esac
```

This comprehensive troubleshooting guide provides systematic approaches to diagnosing and resolving cloud infrastructure and application issues across multiple platforms.