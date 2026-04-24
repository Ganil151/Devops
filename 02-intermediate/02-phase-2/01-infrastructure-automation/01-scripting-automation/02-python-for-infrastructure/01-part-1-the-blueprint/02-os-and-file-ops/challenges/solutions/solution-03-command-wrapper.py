"""
Solution: Command Execution Wrapper
"""
import subprocess
import time

def run_standard_cmd(cmd_list, timeout=10):
    start_time = time.time()
    try:
        result = subprocess.run(
            cmd_list, 
            capture_output=True, 
            text=True, 
            timeout=timeout
        )
        duration = time.time() - start_time
        return {
            "success": result.returncode == 0,
            "stdout": result.stdout.strip(),
            "stderr": result.stderr.strip(),
            "exit_code": result.returncode,
            "duration": round(duration, 4)
        }
    except subprocess.TimeoutExpired:
        return {
            "success": False,
            "stdout": "",
            "stderr": f"Command timed out after {timeout} seconds",
            "exit_code": -1,
            "duration": timeout
        }
    except Exception as e:
        return {
            "success": False,
            "stdout": "",
            "stderr": str(e),
            "exit_code": -1,
            "duration": time.time() - start_time
        }

if __name__ == "__main__":
    # Test logic
    pass
