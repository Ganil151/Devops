"""
Challenge: Command Execution Wrapper
Scenario: You are building a framework that runs shell commands for 
different tasks. You need a standard way to execute commands and 
return results in a consistent dictionary format.

TODO: Implement `run_standard_cmd(cmd_list, timeout=10)`.
1. Use `subprocess.run()` with `capture_output=True` and `text=True`.
2. Implement a `try...except` block for `subprocess.TimeoutExpired`.
3. Calculate the duration of the command.
4. Return a dictionary:
   {
     "success": bool,
     "stdout": str,
     "stderr": str,
     "exit_code": int,
     "duration": float
   }
"""
import subprocess
import time

def run_standard_cmd(cmd_list, timeout=10):
    """
    Runs a command and returns a structured result.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test Success
    res = run_standard_cmd(["echo", "Hello Automation"])
    print(f"Result: {res}")
    
    # Test Failure
    res_fail = run_standard_cmd(["ls", "non_existent_file"])
    print(f"Failed Result: {res_fail}")
