# Chef Real-Life Scenarios

Understand how Chef is used to solve production challenges at scale.

---

## 🛠️ Scenario 1: Bootstrapping a Fleet of Web Servers
**Problem:** You have 50 new EC2 instances and you need them all configured with Nginx, a custom company banner, and a specific monitoring agent.

**The Strategy:**
1. Create a `base_config` cookbook that includes recipes for Nginx and Monitoring.
2. Use **Knife** to bootstrap the nodes in a loop:
   ```bash
   for IP in $(cat nodes.txt); do
     knife bootstrap $IP --run-list 'recipe[base_config::nginx],recipe[base_config::monitor]'
   done
   ```
3. Each node will independently download the `chef-client`, check in with the server, and configure itself.

---

## 🏗️ Scenario 2: Zero-Downtime Application Update
**Problem:** You need to update your application code stored in a Data Bag, but you don't want all 100 nodes to restart their services at the exact same second.

**The Strategy:**
1. Use **Environments**. Move 10 nodes to a `staging` environment.
2. Update the `staging` data bag with the new code version.
3. Observe the `chef-client` convergence.
4. Once verified, move the remaining 90 nodes to the new environment version in batches.
5. Use **Handlers** to ensure the service only restarts if the code actually changed.

---

## 🌩️ Scenario 3: Cross-Platform Compatibility
**Problem:** Your company uses both Ubuntu and CentOS servers. You need one cookbook that can set up a web server on both without writing two separate recipes.

**The Strategy:**
1. Use **Ohai Attributes**. In your recipe, use a `case` statement based on `node['platform_family']`.
2. Define different package names (`apache2` for Debian, `httpd` for RHEL).
3. Chef automatically detects the platform at the start of the run and chooses the right branch of logic.

---

## 🛍️ Scenario 4: Secure Password Management
**Problem:** You need to distribute a database password to 50 app servers without putting the plain-text password in Git.

**The Strategy:**
1. Create an **Encrypted Data Bag**.
2. Encrypt the password locally on your workstation using a secret key.
3. Upload the encrypted JSON to the Chef Server.
4. Distribute the `secret_key` file to the `/etc/chef/` directory of your nodes (via a secure out-of-band method or a bootstrap script).
5. The nodes will decrypt the password in memory during the run-time without ever writing the plain-text password to the disk.

---

## 🔄 Scenario 5: Handling Failed Convergence
**Problem:** A `chef-client` run failed because a specific third-party repository was down.

**The Strategy:**
1. Check the Chef Server dashboard (or use `knife status`) to identify the "stale" nodes.
2. Use **Test Kitchen** to reproduce the failure on a local VM.
3. Update the recipe to include a retry mechanism or an alternative repository URL.
4. Upload the fix and run `chef-client` manually on one node to verify.
5. Let the rest of the fleet converge automatically on their next scheduled check-in.

---

## 💡 Key Takeaway
Chef is built for **Enterprise Scale**. Its power lies in its ability to handle complex logic (Ruby), tiered stage management (Environments), and massive search capabilities within your infrastructure.
