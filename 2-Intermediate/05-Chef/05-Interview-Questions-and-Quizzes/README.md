# Chef Interview Questions & Quiz

Solidify your knowledge of Chef and prepare for technical interviews.

---

## 🎤 Top 15 Chef Interview Questions

<b>1. </b>
<details>
<summary>Show Answer</summary>
Answer: * Chef is a configuration management tool that uses a Master-Client architecture. It allows you to define infrastructure as code (Ruby-based DSL) and automatically "converges" servers to that state.
</details>


<b>2. </b>
<details>
<summary>Show Answer</summary>
Answer: * A cookbook is the primary unit of organization in Chef. It contains recipes, attributes, templates, and metadata needed to manage a specific part of a system (e.g., a Database cookbook).
</details>


<b>3. </b>
<details>
<summary>Show Answer</summary>
Answer: * A recipe is a file within a cookbook that contains a series of resources that describe the desired state of a node.
</details>


<b>4. </b>
<details>
<summary>Show Answer</summary>
Answer: * Knife is the command-line tool used by a workstation to interact with the Chef Server (uploading cookbooks, managing nodes, etc.).
</details>


<b>5. </b>
<details>
<summary>Show Answer</summary>
Answer: * A tool used to test Chef cookbooks in isolated environments (like VMs or containers) before deploying them to production.
</details>


<b>6. </b>
<details>
<summary>Show Answer</summary>
Answer: * Ohai is a tool that runs at the beginning of every Chef run. It collects system profiling data (IP, OS, CPU, RAM) and provides it as node attributes.
</details>


<b>7. </b>
<details>
<summary>Show Answer</summary>
Answer: * Chef uses a **Pull model** where the node agent (`chef-client`) checks in with the server for updates. Ansible uses a **Push model** where the central server initiates the connection.
</details>


<b>8. </b>
<details>
<summary>Show Answer</summary>
Answer: * Attributes are key-value pairs of data about a node. They can be set by Ohai (automatic) or defined in cookbooks/environments to drive dynamic configuration.
</details>


<b>9. </b>
<details>
<summary>Show Answer</summary>
Answer: * A resource is the most basic building block of a recipe (e.g., `package`, `service`, `user`). It defines *what* should be done, and Chef figures out *how* to do it based on the OS.
</details>


<b>10. </b>
<details>
<summary>Show Answer</summary>
Answer: * It's the process where `chef-client` execution ensures that every resource on the node matches its definition in the cookbook.
</details>


<b>11. </b>
<details>
<summary>Show Answer</summary>
Answer: * Global JSON objects shared across all nodes, used to store data like user accounts or firewall rules.
</details>


<b>12. </b>
<details>
<summary>Show Answer</summary>
Answer: * Usually with **Encrypted Data Bags** or **Chef Vault**.
</details>


<b>13. </b>
<details>
<summary>Show Answer</summary>
Answer: * It's an ordered list of roles and recipes that tells the node exactly what configuration to apply.
</details>


<b>14. </b>
<details>
<summary>Show Answer</summary>
Answer: * Automatic (Ohai) > Override > Normal > Default.
</details>


<b>15. </b>
<details>
<summary>Show Answer</summary>
Answer: * It ensures that no matter how many times you run the same recipe, the final state of the system is always the same, and changes are only made if necessary.
</details>


---

## 🧠 Chef Knowledge Quiz

<b>1. Which tool is used to communicate from the Workstation to the Chef Server?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>2. Which language is the Chef DSL based on?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>3. What does the "convergence" process do?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>4. Where are Cookbooks stored?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>5. Which component collects system facts at the start of a run?</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>6. What is the smallest unit of configuration in Chef?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>7. Which resource is used to manage system services?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>8. What happens if a resource is already in the desired state?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>9. How do you secure data bags?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>10. Which command installs `chef-client` on a remote node?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>11. What is the default port for Chef Server communication?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>12. "A collection of recipes and resources" defines a:</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>13. In a recipe, `action :nothing` means:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>14. Which directory in a cookbook holds variables for dynamic templates?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>15. What tool allows you to test cookbooks locally?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>16. Which attribute type has the HIGHEST priority?</b>
<details>
<summary>Show Answer</summary>
Answer: D
</details>


<b>17. What does the `metadata.rb` file do?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>18. Chef is primarily based on which model?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>19. What is a "Role"?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>20. What is the extension for Chef recipes?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


---

## ✅ Knowledge Check
- [x] Passed the 20-Question Quiz
- [x] Reviewed the Top 15 Interview Questions
- [x] Understand the difference between Recipes and Cookbooks