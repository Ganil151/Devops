# 🧪 Lab: AWS Fault Injection Simulator (FIS) - AZ Failover

> **Scenario**: Your application is "Multi-AZ," but you've never actually tested if it survives a total Availability Zone (AZ) failure.
> **The Mission**: Use AWS FIS to simulate a network partition in `us-east-1a` and verify that the ALB correctly routes 100% of traffic to `us-east-1b` without dropping user sessions.

---

## 🏗️ The Experiment Hypothesis

**"If we block all network traffic to instances in Subnet A (us-east-1a), the Target Group Health Checks will mark them as Unhealthy within 30 seconds, and the ALB will shift all traffic to Subnet B with 0.0% increase in 5XX errors."**

---

## 🛠️ Step 1: Defining the Experiment Template (Terraform)

We use the `aws_fis_experiment_template` resource.

```hcl
resource "aws_fis_experiment_template" "az_outage" {
  description = "Simulate Network Partition in us-east-1a"
  role_arn    = aws_iam_role.fis_role.arn

  # 1. The Action: Disconnect the network
  action {
    name      = "disrupt-network"
    action_id = "aws:ec2:network-latency" # Or custom disruption
    
    parameter {
        key = "duration"
        value = "PT5M" # 5 Minutes
    }
  }

  # 2. The Target: All instances in a specific subnet
  target {
    name           = "instances-in-az-a"
    resource_type  = "aws:ec2:instance"
    selection_mode = "ALL"
    
    resource_tag {
        key = "AvailabilityZone"
        value = "us-east-1a"
    }
  }

  # 3. The Stop Condition: Safety First!
  stop_condition {
    source = "aws:cloudwatch:alarm"
    value  = aws_cloudwatch_metric_alarm.error_rate_high.arn
  }
}
```

---

## 🛠️ Step 2: Measurement & Observation

During the experiment, monitor the following metrics in CloudWatch:

1.  **ALB Target Health**: Watch the `UnHealthyHostCount` for the target group in AZ-A climb.
2.  **Request Count**: Ensure `RequestCount` in AZ-B increases proportionally.
3.  **Error Rate**: If `HTTPCode_Target_5XX_Count` > 0, your failover is NOT "Seamless."

---

## 🛠️ Step 3: The Post-Mortem

### ❓ Why did it fail? (Common SRE Findings)
- **Sticky Sessions**: Users were "stuck" to the failing AZ because session stickiness was enabled at the ALB level with no fallback.
- **Cross-AZ Load Balancing**: If this is DISABLED, the ALB might not have enough healthy capacity in the remaining AZ.
- **Lazy DNS**: If using Route53 health checks instead of ALB, the 60-second TTL might be causing stale requests to hit the dead AZ.

---

## 🚨 Principal Architect Insights: "Blast Radius Control"

- **Tag-Based Targeting**: Never target resources by ID in a script. Always use Tags (e.g., `ChaosReady=True`). This prevents you from accidentally nuking a生产 database that wasn't part of the test.
- **Automated Rollback**: The **Stop Condition** is the most important part of the template. If your Latency goes to 5 seconds, FIS must immediately kill the experiment.
- **The "Game Day" Mindset**: Invite your Security and Networking teams to watch. Often, a "Network Outage" triggers security IDS/IPS alerts that you didn't anticipate.

---
**Module**: Chaos Engineering
**Next Lab**: [K8s Pod Termination with Chaos Mesh](../labs/k8s-network-chaos-lab.md)
