# Scaling Policies: The Logic of Elasticity

Scaling policies define *when* and *how* your infrastructure should scale.

## 🧠 Policy Types

### 1. Target Tracking Scaling
- **How it works**: You select a metric (e.g., Average CPU Usage) and a target value (e.g., 50%). The ASG adds/removes instances to keep the metric at that level.
- **Best For**: Most standard web applications.

### 2. Step Scaling
- **How it works**: You define specific "steps" (e.g., "If CPU > 70%, add 2 instances; If CPU > 90%, add 5 instances").
- **Best For**: Handling sudden, massive spikes.

### 3. Scheduled Scaling
- **How it works**: Scaling based on a specific date and time.
- **Best For**: Predictive events like weekend sales or batch jobs.

### 4. Predictive Scaling
- **How it works**: Uses machine learning to anticipate traffic spikes.
- **Best For**: High-traffic sites with cyclical patterns.

## ⚠️ Cooldown Periods
Always configure a "Cooldown Period" (e.g., 300 seconds) to allow new instances to warm up and start taking load before the scaling policy evaluates the metrics again. This prevents "Scaling Flapping".
