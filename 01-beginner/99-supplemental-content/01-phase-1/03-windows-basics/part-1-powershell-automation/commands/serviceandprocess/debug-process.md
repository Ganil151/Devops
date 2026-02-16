# Debug-Process

## Purpose
Attaches a debugger to one or more running processes on the local computer.

## Examples

### Attach the default debugger to a process by ID
```powershell
Debug-Process -Id 4567
```

### Attach a debugger to a process by name and confirm action
```powershell
Debug-Process -Name "CalculatorApp" -Confirm
```
