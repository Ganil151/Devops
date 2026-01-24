# Compute and Scale Challenges (AWS Focused) ☁️

Master the elasticity of the cloud by building self-healing, auto-scaling compute clusters.

---

## 🏆 Challenge 01: The Auto-Scaling Architect
**Objective**: Configure an AWS Auto Scaling Group (ASG) for high availability.

1.  **Requirement**: Create a **Launch Template** with a simple UserData script that starts an Nginx server.
2.  **Task**: Create an **Auto Scaling Group** using that template.
3.  **Constraints**:
    *   **Desired Capacity**: 2
    *   **Min Capacity**: 2
    *   **Max Capacity**: 5
4.  **Verification**: Manually terminate one instance through the EC2 console and watch the ASG "Self-Heal" by spinning up a new one.

---

## 🏆 Challenge 02: Dynamic Scaling Policies
**Objective**: Automatically grow your cluster during traffic surges.

1.  **Task**: Add a **Target Tracking Scaling Policy** to your ASG.
2.  **Metric**: Set a target CPU utilization of **50%**.
3.  **Lab**: Run a CPU-loading tool (like `stress`) on your instances.
4.  **Goal**: Observe the "Scaling Out" activity in the ASG activity logs.

---

## 🏆 Challenge 03: Spot Instance Optimization
**Objective**: Reduce cloud costs by up to 90%.

1.  **Requirement**: Modify your Launch Template to use **Spot Instances**.
2.  **Task**: Explain the "Interruption" mechanism. How does your app handle a 2-minute warning before the instance is reclaimed?
3.  **Advanced**: Research **Spot Instance Pools** and how to use multiple instance types (e.g., `t3.large` and `m5.large`) to increase availability.

---

## 📁 Solutions
Terraform ASG modules and UserData script templates are in the `Boilerplates/` directory.
