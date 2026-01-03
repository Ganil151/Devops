# The Nodes: Where Policy Meets Reality

A **Node** is any machine (physical, virtual, cloud, or container) that is managed by the Chef Server. It runs the **Chef Infra Client** agent to bring the system into the desired state defined by your policies.

## 1. Deep Dive: The Chef Client Run

The magic happens during the "Chef Run." This is the process where the client synchronizes with the server.

### The Steps of a Chef Run
1.  **Get Configuration**: The client starts, reads `client.rb`, and locates the private key.
2.  **Authenticate**: It connects to the Chef Server attempting to authenticate with its private key.
3.  **Ohai (System Discovery)**: `Ohai` runs to gather system data (IP, Hostname, CPU, Platform, Disk). This becomes the *Automatic Attributes*.
4.  **Register/Sync**: The node saves its updated data to the Chef Server.
5.  **Expand Run List**: The server expands the node's run-list (resolving roles and environments) to find out which recipes need to be run.
6.  **Synchronize Cookbooks**: The client downloads the specific version of cookbooks required for the run list from the server's Bookshelf. It caches them locally (`/var/chef/cache`).
7.  **Compile Phase**: The client loads all recipes. It reads the Ruby code and builds the **Resource Collection** (an ordered list of "Do this, then do that"). *No changes are made to the system yet.*
8.  **Converge Phase**: The client loops through the Resource Collection. For each resource:
    *   It checks the current state of the system (Is Apache running?).
    *   It compares it to the desired state (Apache *should* be running).
    *   **Idempotency**: If the states match, it does nothing. If they differ, it applies the change.
9.  **Notification Handling**: If a resource changed and notified another (e.g., config file changed -> restart service), those actions happen now or immediately depending on configuration.
10. **Exception/Reporting**: If an error occurs, the run stops and reports the failure. If successful, it reports the run implementation to the server.

## 2. Architecture Diagram: The Convergence Loop

```mermaid
sequenceDiagram
    participant Node as Chef Client (Node)
    participant Ohai
    participant Server as Chef Server

Note over Node: Run Starts
    Node->>Server: 1. Authenticate (RSA Key)
    Node->>Ohai: 2. Gather Facts
    Ohai-->>Node: Return Attributes (JSON)
    Node->>Server: 3. Save Node Object (Attributes)
    Node->>Server: 4. Get Run List & Policy
    Server-->>Node: Return Run List
    Node->>Server: 5. Download Cookbooks
    Server-->>Node: Send Cookbook Files
    Note over Node: 6. Compile Phase (Build Resource List)
    Note over Node: 7. Converge Phase (Apply Changes)
    Choice State Check
    Note over Node: Idempotency Check: Change only if needed
    Node->>Server: 8. Report Run Status (Success/Fail)
```

## 3. Real-Life Scenarios

### Scenario A: Configuration Drift
**Situation**: A junior sysadmin manually edited `/etc/ssh/sshd_config` to allow password authentication on a secure server, violating company policy.
**Action**:
1.  Chef Client runs (e.g., every 30 mins).
2.  It reaches the `template '/etc/ssh/sshd_config'` resource.
3.  It sees the file content differs from the desired template.
4.  **Correction**: It overwrites the manual change with the correct content and reloads SSH.
5.  **Result**: Compliance is restored automatically.

### Scenario B: Handling Run Failures
**Situation**: A recipe tries to install a package `myapp-1.0` but the repo is down.
**Action**:
1.  The resource fails.
2.  The Chef run aborts immediately.
3.  The Report Handler sends a failure notification to Slack/Email (if configured).
4.  The system stays in the last known good state (mostly), though partially applied changes from *previous* resources in the same run remain.

## 4. Interview Questions

1.  **What is Idempotency?**
    *   *Answer*: The property where applying an operation multiple times has the same effect as applying it once. In Chef, it means "only change what needs changing." If I tell Chef to install a package and it's already installed, Chef does nothing.

2.  **What is `Ohai`?**
    *   *Answer*: The tool that runs on the node to collect system configuration data (Platform, IP, MAC address, Memory, etc.) and provides them as attributes to the chef-client run.

3.  **Explain the difference between Compile Phase and Converge Phase.**
    *   *Answer*: **Compile Phase**: Ruby code is executed, and the Resource Collection is built. **Converge Phase**: The Resource Collection is traversed, and providers take action to bring the system to the desired state.

4.  **How do you trigger a chef-client run manually?**
    *   *Answer*: SSH into the node and run `sudo chef-client`.

5.  **What is a "Handler" in Chef?**
    *   *Answer*: Code that runs at the start or end of a Chef run. Common uses are reporting (sending success/fail logs to Splunk) or exception handling (sending alerts to PagerDuty).

## 5. Quiz: Test Your Knowledge

1.  **Which phase actually makes changes to the system?**
    *   A) Compile Phase
    *   B) Converge Phase
    *   C) Verify Phase
    *   D) Build Phase

<details><summary>Click for Answer</summary>B) Converge Phase</details>

2.  **What port does the Chef Client listen on?**
    *   A) 443
    *   B) 80
    *   C) It does not listen on any port (Pull model).
    *   D) 22

<details><summary>Click for Answer</summary>C) It does not listen on any port (it executes and initiates connection out).</details>

3.  **How often does the Chef Client run by default?**
    *   A) Every 5 minutes
    *   B) Every 30 minutes
    *   C) Once a day
    *   D) Only when manually triggered

<details><summary>Click for Answer</summary>B) Every 30 minutes (usually with a splay)</details>

4.  **What is "Splay"?**
    *   A) A typo for Display.
    *   B) A random time interval added to the run frequency to prevent all nodes from hitting the server at the exact same second (Thundering Herd).
    *   C) The time it takes to download cookbooks.
    *   D) A type of attribute.

<details><summary>Click for Answer</summary>B) A random time interval...</details>

5.  **The file that contains the unique client name and validation key path on the node is:**
    *   A) `client.rb`
    *   B) `knife.rb`
    *   C) `metadata.rb`
    *   D) `node.json`

<details><summary>Click for Answer</summary>A) client.rb</details>

6.  **Attributes gathered by Ohai are called:**
    *   A) Default Attributes
    *   B) Override Attributes
    *   C) Automatic Attributes
    *   D) Normal Attributes

<details><summary>Click for Answer</summary>C) Automatic Attributes (Highest precedence)</details>

7.  **What happens if a resource fails during the run?**
    *   A) It skips it and continues.
    *   B) The entire run stops immediately (unless `ignore_failure` is set).
    *   C) It retries infinitely.
    *   D) It reboots the server.

<details><summary>Click for Answer</summary>B) The entire run stops immediately...</details>

8.  **Where does the client cache cookbooks?**
    *   A) `/tmp`
    *   B) `/var/chef/cache`
    *   C) `/home/user`
    *   D) Use RAM only

<details><summary>Click for Answer</summary>B) /var/chef/cache</details>

9.  **To run chef-client locally using a local repository instead of a server, you use:**
    *   A) `chef-client --local`
    *   B) `chef-client -z` (Local Mode)
    *   C) `chef-solo` (Legacy)
    *   D) `chef-apply`

<details><summary>Click for Answer</summary>B) `chef-client -z` (Recommended modern way)</details>

10. **The list of resources built during the compile phase is called:**
    *   A) The Run List
    *   B) The Resource Collection
    *   C) The Attribute Map
    *   D) The Recipe Book

<details><summary>Click for Answer</summary>B) The Resource Collection</details>

11. **Which attribute type has the HIGHEST precedence?**
    *   A) Default
    *   B) Override
    *   C) Normal
    *   D) Automatic (Ohai)

<details><summary>Click for Answer</summary>D) Automatic (Ohai)</details>

12. **Which attribute type has the LOWEST precedence?**
    *   A) Default
    *   B) Override
    *   C) Role Default
    *   D) Environment Default

<details><summary>Click for Answer</summary>A) Default (specifically Attribute file default)</details>

13. **What is the command to bootstrap a windows node?**
    *   A) `knife bootstrap windows ...`
    *   B) `knife bootstrap ... -o winrm` (Using WinRM protocol)
    *   C) It's not possible.
    *   D) `chef install windows`

<details><summary>Click for Answer</summary>B) knife bootstrap ... (typically using WinRM)</details>

14. **What ensures the authenticity of the Chef Server/Client communication?**
    *   A) Plain text passwords.
    *   B) RSA Key Pairs (Public/Private Keys).
    *   C) IP Whitelisting.
    *   D) Magic.

<details><summary>Click for Answer</summary>B) RSA Key Pairs</details>

15. **If you change an attribute in a cookbook, when does the node see the change?**
    *   A) Immediately.
    *   B) After you upload the cookbook AND the next client run occurs.
    *   C) After you restart the server.
    *   D) Never.

<details><summary>Click for Answer</summary>B) After upload AND next client run.</details>

16. **What is a "Notification" in a recipe?**
    *   A) An email sent to the admin.
    *   B) A mechanism for one resource to tell another resource to take action (e.g., `notifies :restart, 'service[httpd]'`).
    *   C) A log message.
    *   D) A pop-up on the screen.

<details><summary>Click for Answer</summary>B) A mechanism for one resource to tell another...</details>

17. **"Subscribes" is the opposite of:**
    *   A) Notifies
    *   B) Published
    *   C) Listening
    *   D) Ignoring

<details><summary>Click for Answer</summary>A) Notifies (Same mechanism, different perspective)</details>

18. **Can you run chef-client as a non-root user?**
    *   A) No, it requires root.
    *   B) Yes, but it can only manage resources that user has permission for.
    *   C) Yes, it automatically gains root.
    *   D) No, it won't start.

<details><summary>Click for Answer</summary>B) Yes, but with limited permissions.</details>

19. **What is the default location for the chef-client configuration on Linux?**
    *   A) `/etc/chef/client.rb`
    *   B) `/usr/local/chef/config`
    *   C) `~/.chef/config.rb`
    *   D) `/var/log/chef`

<details><summary>Click for Answer</summary>A) /etc/chef/client.rb</details>

20. **What is "Chef Solo"?**
    *   A) A version of Chef that sings.
    *   B) A legacy equivalent of Chef Client that runs without a Chef Server, using local tarballs.
    *   C) The new name for Chef Workstation.
    *   D) A single user license.

<details><summary>Click for Answer</summary>B) A legacy equivalent of Chef Client...</details>