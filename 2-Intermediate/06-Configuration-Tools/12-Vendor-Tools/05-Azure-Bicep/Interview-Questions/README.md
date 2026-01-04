# ❓ Azure Bicep Interview & Quiz Questions

## 📋 Interview Questions

**Q1: Is Bicep a replacement for ARM templates?**
**A:** Bicep is a newer, more modern way to write ARM templates. It compiles down to standard ARM JSON, so it uses the same underlying engine. Think of it as TypeScript to JavaScript.

**Q2: How does Bicep handle resource dependencies compared to ARM JSON?**
**A:** In ARM JSON, you must explicitly use `dependsOn`. In Bicep, if you reference the symbolic name of one resource in another (e.g., `webApp.id`), Bicep automatically adds the dependency. You only need explicit `dependsOn` for non-obvious relationships.

**Q3: What happens when you run 'bicep build'?**
**A:** The Bicep source file is parsed, validated, and translated into a standard Azure Resource Manager (ARM) JSON template.

**Q4: What is a Bicep Module?**
**A:** A module is simply a Bicep file that is called from another Bicep file. It allows for encapsulation, code reuse, and cleaner parent templates.

**Q5: What is the 'targetScope' and what is its default value?**
**A:** `targetScope` defines the level at which the deployment takes place. The default is `resourceGroup`. Other values include `subscription`, `managementGroup`, and `tenant`.

---

## 📝 Quiz Section (20+ Questions)

1. **What is the file extension for Bicep files?**
   - A) .arm
   - B) .json
   - C) .bicep ✅
   - D) .azure

2. **Which command is used to convert an existing ARM JSON file to Bicep?**
   - A) az bicep convert
   - B) az bicep decompile ✅
   - C) az bicep translate
   - D) az bicep import

3. **In Bicep, how is string interpolation performed?**
   - A) concat(a, b)
   - B) ${varName} ✅
   - C) %varName%
   - D) {{varName}}

4. **Which keyword is used to reference a resource not created in the Bicep file?**
   - A) external
   - B) remote
   - C) existing ✅
   - D) import

5. **Which tool is highly recommended for Bicep development?**
   - A) Visual Studio Code with Bicep extension ✅
   - B) Notepad++
   - C) SQL Management Studio
   - D) Excel

6. **How do you define an optional deployment for a resource?**
   - A) use the 'case' keyword
   - B) use the 'if' keyword before the resource block ✅
   - C) use the 'maybe' keyword
   - D) wrap it in a try-catch block

7. **What is the default target scope for Bicep?**
   - A) subscription
   - B) managementGroup
   - C) resourceGroup ✅
   - D) tenant

8. **Which keyword is used to create a reusable Bicep component?**
   - A) component
   - B) template
   - C) module ✅
   - D) include

9. **What does 'bicep build' produce?**
   - A) An executable file
   - B) An ARM JSON template ✅
   - C) A Docker image
   - D) A ZIP archive

10. **Where can modules be stored for enterprise-wide sharing?**
    - A) Azure Storage
    - B) Azure Container Registry (ACR) ✅
    - C) GitHub Pages
    - D) Email

11. **Does Bicep keep a state file like Terraform?**
    - A) Yes (.bicepstate)
    - B) No, Azure Resource Manager maintains the state ✅
    - C) Only if configured
    - D) Only in advanced mode

12. **Which character is used to comment out a single line in Bicep?**
    - A) #
    - B) // ✅
    - C) /*
    - D) --

13. **What is the 'symbolic name' in a resource declaration?**
    - A) The actual name of the resource in Azure
    - B) The identifier used to reference the resource within the Bicep code ✅
    - C) The resource group name
    - D) The API version

14. **How do you pass a value to a module?**
    - A) Using the 'args' block
    - B) Using the 'params' block ✅
    - C) Via environment variables
    - D) Modules don't take inputs

15. **Which function generates a unique string for resource naming?**
    - A) createGuid()
    - B) uniqueString() ✅
    - C) randomName()
    - D) hash()

16. **How do you access the location of the resource group?**
    - A) location()
    - B) rg().location
    - C) resourceGroup().location ✅
    - D) azure.location

17. **Which command validates and prepares Bicep for deployment in one step?**
    - A) az bicep deploy
    - B) az deployment group create ✅
    - C) az resource create
    - D) az bicep run

18. **Can Bicep deploy resources to multiple resource groups in a single file?**
    - A) No
    - B) Yes, by changing the scope of a module ✅
    - C) Only if they are in the same subscription
    - D) Only if they share the same name

19. **What is the purpose of 'bicepconfig.json'?**
    - A) Stores database credentials
    - B) Configures the Bicep compiler and linter ✅
    - C) It is the main entry point for deployments
    - D) It's not a Bicep file

20. **Which feature allows Bicep to update its own CLI?**
    - A) az bicep upgrade ✅
    - B) az bicep update
    - C) az bicep refresh
    - D) manual download only

21. **What is 'any()' function used for?**
    - A) Finding any resource
    - B) Bypassing the type system for a specific value ✅
    - C) Checking if any resource exists
    - D) Looping through any array
