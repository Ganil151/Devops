# ❓ Azure ARM Interview & Quiz Questions

## 📋 Interview Questions

**Q1: What is the difference between ARM Templates and Azure CLI?**
**A:** ARM Templates are **declarative** (define the end state), while Azure CLI is primarily **imperative** (provide a series of commands to achieve the state). Templates provide consistency and idempotency out of the box.

**Q2: What are the two deployment modes in ARM?**
**A:** 
- **Incremental** (default): Adds new resources and modifies existing ones. Does not delete resources not in the template.
- **Complete**: Replaces the entire resource group. Anything NOT in the template is deleted.

**Q3: How do you handle circular dependencies in ARM templates?**
**A:** Circular dependencies happen when Resource A depends on B, and B depends on A. They must be resolved by refactoring the template, using a third resource as a coordinator, or removing unnecessary dependencies.

**Q4: What is the purpose of the 'uniqueString()' function?**
**A:** It generates a deterministic, unique hash (usually 13 characters) based on the inputs provided (like the resource group ID). It's essential for creating unique names for global resources like Storage Accounts.

**Q5: How can you pass secrets securely to a template?**
**A:** By using Azure Key Vault references in the parameters file. The secret is retrieved during deployment without being exposed in the code.

---

## 📝 Quiz Section (20+ Questions)

1. **What is the root-level element that contains the actual Azure services?**
   - A) services
   - B) infrastructure
   - C) resources ✅
   - D) components

2. **Which file format is used for ARM templates?**
   - A) YAML
   - B) XML
   - C) JSON ✅
   - D) HCL

3. **In 'Incremental' mode, what happens to resources not defined in the template?**
   - A) They are deleted
   - B) They remain unchanged ✅
   - C) They are moved to a different group
   - D) They are stopped

4. **Which function calculates the resource ID of a service?**
   - A) getResourceId()
   - B) reference()
   - C) resourceId() ✅
   - D) findId()

5. **What is the maximum size of an ARM template file?**
   - A) 1 MB
   - B) 4 MB ✅
   - C) 10 MB
   - D) 500 KB

6. **Which command is used to deploy a template at the Resource Group level?**
   - A) az deployment create
   - B) az deployment group create ✅
   - C) az group deploy
   - D) az resource create

7. **How do you define a constant value that can be reused throughout the template?**
   - A) parameters
   - B) variables ✅
   - C) constants
   - D) values

8. **Which character starts a template expression?**
   - A) {
   - B) [ ✅
   - C) (
   - D) $

9. **What does 'resourceGroup().location' return?**
   - A) The global Azure location
   - B) The location of the resource group target for the deployment ✅
   - C) The location of the user
   - D) The subscription ID

10. **Which element ensures one resource is created before another?**
    - A) order
    - B) after
    - C) dependsOn ✅
    - D) sequence

11. **What attribute allows deploying multiple instances of a resource?**
    - A) loop
    - B) multiply
    - C) copy ✅
    - D) repeat

12. **Which function allows merging two or more strings?**
    - A) merge()
    - B) concat() ✅
    - C) combine()
    - D) join()

13. **What is a 'Linked Template'?**
    - A) A template for another cloud provider
    - B) A template called from a main template using a URI ✅
    - C) A template that is manually linked in the portal
    - D) A template that is shared between accounts

14. **Which CLI operation lets you preview changes?**
    - A) preview
    - B) check-diff
    - C) what-if ✅
    - D) dry-run

15. **What is the max number of resources allowed in a single ARM template?**
    - A) 100
    - B) 500
    - C) 800 ✅
    - D) 1000

16. **Which section is used to pass information back to the user after deployment?**
    - A) results
    - B) outputs ✅
    - C) return
    - D) logs

17. **What does the 'apiBatch' property do?**
    - A) Speeds up deployment
    - B) Doesn't exist ✅ (Trick question)
    - C) Groups requests
    - D) Limits costs

18. **Can you deploy ARM templates to a Subscription instead of a Resource Group?**
    - A) No
    - B) Yes, using `az deployment sub create` ✅
    - C) Only for security groups
    - D) Only via the Portal

19. **What is the '$schema' field for?**
    - A) Documentation for the user
    - B) Defines the version of the template language and provides validation/IntelliSense ✅
    - C) Encryption
    - D) Billing information

20. **Which tool can export a Resource Group into an ARM template?**
    - A) Azure Monitor
    - B) Azure Portal (Export Template feature) ✅
    - C) Azure Advisor
    - D) Azure Backup

21. **What is 'Template Spec'?**
    - A) A technical specification document
    - B) A managed resource that stores an ARM template in Azure for reuse ✅
    - C) A type of premium account
    - D) A debugging tool
