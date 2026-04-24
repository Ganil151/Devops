# 🎯 Hands-On Challenges: Arithmetic & Metrics

## Challenge 1: The Disk Space Sentinel (Mission-Based Beginner)

**Objective**: Build a monitoring script that alerts when disk usage is dangerous.

**The Why**: This is the "Hello World" of Site Reliability Engineering (SRE). If you can't monitor space, you can't run servers.

**Scenario**: You need to check the root partition (`/`) usage.

**Tasks**:
1. Run `df /` and look at the output.
2. Use `awk` or `cut` to extract the **Used Percentage** (remove the `%`).
3. Store it in a variable `USED`.
4. Set a threshold variable `LIMIT=80`.
5. Write an `if` statement:
   - If `USED > LIMIT`: Print "⚠️  CRITICAL: Disk at ${USED}%"
   - Else: Print "✅  Status OK: ${USED}%"

**Sample Command to Extract Number**:
```bash
# This gets the percentage integer
df / | awk 'NR==2 {print $5}' | tr -d '%'
```

---

## Challenge 2: The Load Balancer Logic (Modulo Operator)

**Objective**: Simulate a Round-Robin request distributor.

**The Why**: Load balancers use simple math (`Request_ID % Server_Count`) to decide which server handles a user.

**Scenario**: You have 3 servers (`Server_0`, `Server_1`, `Server_2`). You want to distribute 10 incoming requests evenly.

**Tasks**:
1. Create a `for` loop from 1 to 10 (the requests).
2. Inside the loop, calculate `target_server = request_id % 3`.
3. Print: "Request $i routed to Server_$target_server".

**Expected Output**:
```text
Request 1 routed to Server_1
Request 2 routed to Server_2
Request 3 routed to Server_0  <-- Wrapped around!
Request 4 routed to Server_1
...
```

**Key Lesson**: The `%` (Modulo) operator is the engine behind circular rotation loops.

---

## Challenge 3: The Cloud Cost Estimator (Floating Point)

**Objective**: Calculate the projected monthly bill for a Kubernetes cluster.

**The Why**: Your manager wants to know if the new cluster fits the budget. Bash math (`$(( ))`) fails at decimals. You need `bc`.

**Scenario**:
- **Hourly Cost per Node**: $0.45
- **Number of Nodes**: 5
- **Hours in Month**: 720 (30 days * 24 hours)

**Tasks**:
1. Define variables for the above.
2. Calculate `Total_Cost = Cost * Nodes * Hours`.
3. Use `bc` because `$0.45` is a float.
4. Scale result to 2 decimal places.

**Hint**:
```bash
echo "scale=2; $COST * $NODES * $HOURS" | bc
```

---

## Verification Checklist
- [ ] Can extract metrics from `df` or `uptime`
- [ ] Understand difference between integer math (`$(( ))`) and float math (`bc`)
- [ ] Can implement a `%` loop for rotation
- [ ] Know how to compare numbers (`(( a > b ))`) inside `if` statements
