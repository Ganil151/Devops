# PowerShell Basics 

---

## What are PowerShell Modules?

PowerShell modules are packages that contain PowerShell commands, such as cmdlets, functions, workflows, variables, and aliases. Modules help organize and distribute reusable code, making it easier to manage and share PowerShell functionality.

### Key Points

- Modules can be imported using `Import-Module`.
- They can be installed from the PowerShell Gallery using `Install-Module`.
- Modules can be scripts (`.psm1`), binaries (`.dll`), or manifest files (`.psd1`).
- They enable code reuse and simplify script management.

I'll explain PowerShell modules and provide examples of how to work with them.

## PowerShell Modules Explained

PowerShell modules are packages containing reusable components like:
- Cmdlets
- Functions
- Variables
- Aliases
- Scripts

## Common Module Commands

Here are the essential module-related commands:

1. **List Available Modules**:
````powershell
Get-Module -ListAvailable
````

2. **Import a Module**:
````powershell
Import-Module -Name ModuleName
````

3. **Install a New Module**:
````powershell
Install-Module -Name ModuleName
````

## Practical Example

Here's a complete example showing how to work with a popular PowerShell module:

````powershell
# Check if PSReadLine module is available

Get-Module -Name PSReadLine -ListAvailable

# Import the module
Import-Module PSReadLine

# View commands available in the module
Get-Command -Module PSReadLine

# Remove a module from current session if needed
Remove-Module PSReadLine
````

## Finding Modules

You can search for modules in the PowerShell Gallery:

````powershell
# Search for modules containing "Azure"
Find-Module -Name "*Azure*"

# Get detailed information about a specific module
Find-Module -Name "Az" | Select-Object Name, Version, Description
````

Remember that some modules may require administrator privileges to install. In such cases, run PowerShell as administrator before installing modules.

---


