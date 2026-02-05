"""
Solution: Remote Health Checker
"""
import paramiko

def check_remote_disk(host, user, pkey_path):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        # Load Private Key
        key = paramiko.RSAKey.from_private_key_file(pkey_path)
        
        # Connect
        ssh.connect(hostname=host, username=user, pkey=key, timeout=5)
        
        # Execute
        cmd = "df -h / | tail -1 | awk '{print $5}'"
        stdin, stdout, stderr = ssh.exec_command(cmd)
        
        output = stdout.read().decode().strip()
        if output.endswith('%'):
            return int(output.replace('%', ''))
            
    except Exception as e:
        print(f"Failed to connect to {host}: {e}")
        return None
    finally:
        ssh.close()

if __name__ == "__main__":
    pass
