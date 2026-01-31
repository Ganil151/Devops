# 🧠 Practice Quiz: Terraform Infrastructure

### 1. Which command is used to show the execution plan without making actual changes?
- A) terraform apply
- B) terraform init
- C) terraform plan
- D) terraform graph

### 2. In which file does Terraform store its source of truth about the infrastructure it manages?
- A) providers.tf
- B) terraform.tfstate
- C) main.tf
- D) .terraform.lock.hcl

### 3. What is the purpose of `terraform init`?
- A) To create the virtual machine.
- B) To download providers and initialize the backend.
- C) To delete resources.
- D) To format the code.

### 4. How do you handle a resource that was manually deleted outside of Terraform?
- A) Terraform will ignore it.
- B) Terraform will detect the change during the next 'plan' and offer to re-create it.
- C) You must delete the state file.
- D) You must run 'terraform destroy'.

### 5. What is a Terraform 'Module'?
- A) A single line of code.
- B) A container for multiple resources that are used together.
- C) A type of database.
- D) A plugin for VS Code.

### 6. Which attribute in a variable definition prevents it from being logged to the console?
- A) private = true
- B) sensitive = true
- C) hidden = true
- D) log = false

### 7. What does the `-var-file` flag do?
- A) It creates a new file.
- B) It allows you to load variables from a specific `.tfvars` file.
- C) It deletes all variables.
- D) It encrypts the variables.

### 8. True or False: Terraform is an 'Agentless' tool.
- A) True (It communicates via APIs)
- B) False (It requires software to be installed on target servers)

### 9. What is a 'Provider' in Terraform?
- A) A person who writes code.
- B) A plugin that translates HCL into API calls for a specific service (AWS, Azure, etc).
- C) An internet service provider.
- D) A type of server.

### 10. What is the purpose of the `.terraform.lock.hcl` file?
- A) To lock the state file.
- B) To ensure that the exact same provider versions are used across different machines.
- C) To store passwords.
- D) To prevent other users from running terraform.

---

## 🔑 Answer Key
1: C | 2: B | 3: B | 4: B | 5: B | 6: B | 7: B | 8: A | 9: B | 10: B
