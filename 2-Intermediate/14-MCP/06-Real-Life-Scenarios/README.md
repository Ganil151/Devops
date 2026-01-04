# 06: Real-Life Scenarios

See how the Model Context Protocol (MCP) is revolutionizing DevOps workflows.

## 🛠️ Scenario 1: AI-Driven "Post-Mortem" Investigation
**Context**: A backend service is throwing 500 errors in production. The on-call engineer is overwhelmed.
**Challenge**: Quickly identify the root cause among millions of logs and multiple microservices.
**Solution**:
1. **MCP Setup**: An MCP server is deployed with access to CloudWatch Logs and Kubernetes `describe` tools.
2. **AI Action**: The engineer asks: *"Investigate the 500 errors in the 'billing' service."*
3. **Execution**: The AI uses MCP to fetch the logs, sees a 'Connection Timeout' to the database, and then uses another MCP tool to check the RDS instance status.
4. **Resolution**: The AI identifies that an RDS maintenance window just started. It proposes a failover or informs the engineer of the estimated recovery time.

---

## 📈 Scenario 2: Automated Infrastructure "Sanity Check"
**Context**: A developer just merged a complex Terraform change that modifies the core networking of a staging VPC.
**Challenge**: Ensure the changes didn't break connectivity to shared services (like Vault or Jenkins).
**Solution**:
1. **MCP Setup**: An MCP server has tools like `ping`, `dig`, and `curl` to be executed from a "prober" container inside the VPC.
2. **AI Action**: After the TF apply, the AI runs a "Sanity Check" prompt.
3. **Execution**: The AI calls the MCP tools to verify that internal DNS resolves and that shared services are reachable over the network.
4. **Outcome**: The AI reports: *"Connectivity Verified. All 5 core services are reachable."* or *"WARNING: Cannot reach Vault at 10.0.1.5"*.

---

## 🔑 Scenario 3: Secure Secrets Retrieval for AI Assistants
**Context**: An AI assistant needs to fetch an API key to run a smoke test, but the key is stored in AWS Secrets Manager.
**Challenge**: Give the AI access without hardcoding secrets or exposing them to the chat history.
**Solution**:
1. **MCP Setup**: An MCP server is configured with the `get_secret` tool.
2. **Execution**: The AI calls `get_secret(secret_name="smoke-test-api-key")`.
3. **Control**: The MCP server handles the IAM authentication to AWS.
4. **Safety**: The AI uses the key internally to run the test and only reports the *result* (Success/Failure) to the user, never the raw key value.

---

## 🏗️ Scenario 4: AI-Powered Kubernetes "Janitor"
**Context**: A development cluster is cluttered with hundreds of "Evicted" pods and old "Completed" jobs, wasting resources and making `kubectl get pods` unreadable.
**Challenge**: Clean up the cluster safely without deleting active resources.
**Solution**:
1. **MCP Setup**: An MCP server with `list_pods`, `list_jobs`, and `delete_resource` tools.
2. **AI Action**: Engineer asks: *"Identfy and clean up all resources older than 7 days that are not in a 'Running' state."*
3. **Execution**: The AI fetches the list, filters by age and status, and presents a list of 45 items to the engineer for approval.
4. **Outcome**: Upon approval, the AI executes the deletions via MCP, leaving the cluster clean.

---

## ⚡ Scenario 5: Self-Healing CI/CD Pipelines
**Context**: A Jenkins build fails because a Docker image wasn't found in the registry.
**Challenge**: Fix the build without manual intervention.
**Solution**:
1. **MCP Setup**: MCP server with tools to query ECR and trigger Jenkins.
2. **Detection**: A webhook triggers an AI agent when the build fails.
3. **Reasoning**: The AI reads the build log via MCP, identifies the missing image tag, and checks ECR to see if the tag exists.
4. **Action**: Finding the tag is missing, the AI triggers the "Image Build" job first and then restarts the failing Jenkins build once the image is ready.
