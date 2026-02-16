import socket
import time
import sys

def resolve_dns(domain, iterations=5, delay=2):
    """
    SRE Tool: Checks for DNS propagation stability and resolution speed.
    Helpful when debugging 'It works for some but not others' issues.
    """
    print(f"🔍 Monitoring DNS for: {domain}\n" + "-"*40)
    
    for i in range(1, iterations + 1):
        start_time = time.time()
        try:
            # The operational reality of gethostbyname
            ip_address = socket.gethostbyname(domain)
            latency = (time.time() - start_time) * 1000
            print(f"Attempt {i}: {ip_address} | Time: {latency:.2f}ms")
        except socket.gaierror:
            print(f"Attempt {i}: ❌ FAILED to resolve.")
        
        if i < iterations:
            time.sleep(delay)

if __name__ == "__main__":
    target_domain = sys.argv[1] if len(sys.argv) > 1 else "google.com"
    resolve_dns(target_domain)
