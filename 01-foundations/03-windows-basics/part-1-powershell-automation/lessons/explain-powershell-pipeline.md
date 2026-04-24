# PowerShell Pipeline Fundamentals

## 1. Core Concept

The PowerShell pipeline (`|`) differs from traditional text-based shells (like Bash) by passing **.NET objects** rather than raw text streams. This allows downstream cmdlets to manipulate properties and methods directly without complex text parsing (sed/awk/grep).

### Key Characteristics

- **Object-Oriented**: Passes structured data (Properties and Methods).
- **Sequential Processing**: Objects are processed one at a time as they become available.
- **Parameter Binding**: PowerShell attempts to map output properties from Command A to input parameters of Command B via `ByValue` or `ByPropertyName`.

## 2. Syntax Structure

```powershell
Command-Source | Command-Filter | Command-Process
```

- **Command-Source**: Generates objects (e.g., `Get-Process`, `Get-Service`).
- **Command-Filter**: Reduces the dataset (e.g., `Where-Object`, `Select-Object`).
- **Command-Process**: Performs actions (e.g., `Stop-Process`, `Sort-Object`, `ForEach-Object`).

## 3. Engineering Best Practices

### Filter Left, Format Right

Always filter data as early as possible in the pipeline to reduce memory usage and CPU cycles.

**Inefficient (Filter Right):**

```powershell
# Retrieves ALL services, then filters. High memory cost.
Get-Service | Where-Object { $_.Status -eq 'Running' }
```

**Efficient (Filter Left):**

```powershell
# Retrieves ONLY running services. Low memory cost.
# Note: Not all cmdlets support server-side filtering. Check Get-Help.
Get-Service -Name "s*"
```

## 4. Analysis of `Pipeline.ps1` Examples

### Example 1: Object Manipulation

```powershell
"Hello World" | ForEach-Object { $_.ToUpper() }
```

- **Input**: `System.String` object "Hello World".
- **Action**: Invokes the `.ToUpper()` method on the current object (`$_`).
- **Output**: "HELLO WORLD".

### Example 2: Filtering and Sorting Files

```powershell
Get-ChildItem -Path "C:\Path" | Where-Object { $_.Length -gt 32MB } | Sort-Object Length -Descending | Select-Object Name, Length
```

1. **Get-ChildItem**: Instantiates `System.IO.FileInfo` and `System.IO.DirectoryInfo` objects.
2. **Where-Object**: Filters objects where the `Length` property exceeds 32MB.
3. **Sort-Object**: Reorders the remaining objects by `Length` (Largest to Smallest).
4. **Select-Object**: Creates a custom `PSCustomObject` containing only `Name` and `Length` properties, discarding the rest.

## 5. Related Tools

- `Get-Member`: Inspects the object type and members passing through the pipeline.
- `Trace-Command`: Debugs parameter binding in the pipeline.
