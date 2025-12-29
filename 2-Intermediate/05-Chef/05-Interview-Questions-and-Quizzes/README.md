# Chef Interview Questions & Quiz

Solidify your knowledge of Chef and prepare for technical interviews.

---

## 🎤 Top 15 Chef Interview Questions

### 🔰 Basic Questions
1. **What is Chef and how does it work?**
   - *Answer:* Chef is a configuration management tool that uses a Master-Client architecture. It allows you to define infrastructure as code (Ruby-based DSL) and automatically "converges" servers to that state.
2. **What is a "Cookbook"?**
   - *Answer:* A cookbook is the primary unit of organization in Chef. It contains recipes, attributes, templates, and metadata needed to manage a specific part of a system (e.g., a Database cookbook).
3. **What is a "Recipe"?**
   - *Answer:* A recipe is a file within a cookbook that contains a series of resources that describe the desired state of a node.
4. **What is "Knife"?**
   - *Answer:* Knife is the command-line tool used by a workstation to interact with the Chef Server (uploading cookbooks, managing nodes, etc.).
5. **What is "Test Kitchen"?**
   - *Answer:* A tool used to test Chef cookbooks in isolated environments (like VMs or containers) before deploying them to production.

### ⚙️ Intermediate Questions
6. **What is Ohai?**
   - *Answer:* Ohai is a tool that runs at the beginning of every Chef run. It collects system profiling data (IP, OS, CPU, RAM) and provides it as node attributes.
7. **Explain the difference between "Pull" and "Push" models.**
   - *Answer:* Chef uses a **Pull model** where the node agent (`chef-client`) checks in with the server for updates. Ansible uses a **Push model** where the central server initiates the connection.
8. **What are "Attributes" in Chef?**
   - *Answer:* Attributes are key-value pairs of data about a node. They can be set by Ohai (automatic) or defined in cookbooks/environments to drive dynamic configuration.
9. **What is a "Resource"?**
   - *Answer:* A resource is the most basic building block of a recipe (e.g., `package`, `service`, `user`). It defines *what* should be done, and Chef figures out *how* to do it based on the OS.
10. **What is "Convergence"?**
    - *Answer:* It's the process where `chef-client` execution ensures that every resource on the node matches its definition in the cookbook.

### 🚀 Advanced Questions
11. **What are "Data Bags"?**
    - *Answer:* Global JSON objects shared across all nodes, used to store data like user accounts or firewall rules.
12. **How do you handle secrets in Chef?**
    - *Answer:* Usually with **Encrypted Data Bags** or **Chef Vault**.
13. **What is the `chef-client` Run List?**
    - *Answer:* It's an ordered list of roles and recipes that tells the node exactly what configuration to apply.
14. **Explain the Attribute Priority hierarchy.**
    - *Answer:* Automatic (Ohai) > Override > Normal > Default.
15. **What is "Idempotency" in the context of Chef?**
    - *Answer:* It ensures that no matter how many times you run the same recipe, the final state of the system is always the same, and changes are only made if necessary.

---

## 🧠 Chef Knowledge Quiz

**1. Which tool is used to communicate from the Workstation to the Chef Server?**
- A) Fork
- B) Spoon
- C) Knife
- D) Whisk
*Answer: C*

**2. Which language is the Chef DSL based on?**
- A) Python
- B) Ruby
- C) YAML
- D) Go
*Answer: B*

**3. What does the "convergence" process do?**
- A) Deletes the node
- B) Brings the node into the desired state defined in code
- C) Encrypts the hard drive
- D) Restarts the Chef Server
*Answer: B*

**4. Where are Cookbooks stored?**
- A) In the Workstation only
- B) In the Chef Server
- C) In Git only
- D) In the Node's RAM
*Answer: B*

**5. Which component collects system facts at the start of a run?**
- A) Ohai
- B) Hiho
- C) Ouch
- D) Echo
*Answer: A*

**6. What is the smallest unit of configuration in Chef?**
- A) Cookbook
- B) Data Bag
- C) Recipe
- D) Organization
*Answer: C*

**7. Which resource is used to manage system services?**
- A) `daemon`
- B) `process`
- C) `service`
- D) `systemd`
*Answer: C*

**8. What happens if a resource is already in the desired state?**
- A) Chef crashes
- B) Chef re-installs it anyway
- C) Chef takes no action (Idempotency)
- D) Chef sends an error to the server
*Answer: C*

**9. How do you secure data bags?**
- A) Use a password on the folder
- B) Use Encrypted Data Bags or Chef Vault
- C) You can't secure them
- D) Save them as ZIP files
*Answer: B*

**10. Which command installs `chef-client` on a remote node?**
- A) `knife upload`
- B) `knife bootstrap`
- C) `knife setup`
- D) `knife deploy`
*Answer: B*

**11. What is the default port for Chef Server communication?**
- A) 80
- B) 443
- C) 8080
- D) 22
*Answer: B*

**12. "A collection of recipes and resources" defines a:**
- A) Library
- B) Role
- C) Cookbook
- D) Bag
*Answer: C*

**13. In a recipe, `action :nothing` means:**
- A) The resource is deleted
- B) The resource is ignored until notified by another resource
- C) The resource shuts down the server
- D) The recipe is empty
*Answer: B*

**14. Which directory in a cookbook holds variables for dynamic templates?**
- A) `vars/`
- B) `attributes/`
- C) `templates/`
- D) `files/`
*Answer: B*

**15. What tool allows you to test cookbooks locally?**
- A) Chef Server
- B) Test Kitchen
- C) VirtualBox
- D) SSH
*Answer: B*

**16. Which attribute type has the HIGHEST priority?**
- A) Default
- B) Normal
- C) Override
- D) Automatic (Ohai)
*Answer: D*

**17. What does the `metadata.rb` file do?**
- A) Stores passwords
- B) Defines the cookbook name, version, and dependencies
- C) Lists the node IP addresses
- D) It's optional
*Answer: B*

**18. Chef is primarily based on which model?**
- A) Push
- B) Pull
- C) Peer-to-peer
- D) Manual
*Answer: B*

**19. What is a "Role"?**
- A) A specific user account
- B) A way to group recipes and attributes for a specific server type (e.g., 'webserver')
- C) A security clearance
- D) A piece of code that runs once
*Answer: B*

**20. What is the extension for Chef recipes?**
- A) .yml
- B) .sh
- C) .rb
- D) .cfg
*Answer: C*

---

## ✅ Knowledge Check
- [x] Passed the 20-Question Quiz
- [x] Reviewed the Top 15 Interview Questions
- [x] Understand the difference between Recipes and Cookbooks
