"""
Solution: Sensitive Data Masker
"""
import re

def sanitize_logs(text):
    """Sanitize sensitive info using regex substitution."""
    
    # 1. Mask passwords in URIs: user:password@host -> user:****@host
    # Pattern: match : followed by non-whitespace up to @
    text = re.sub(r':([^:@\s]+)@', r':****@', text)
    
    # 2. Mask last two octets of IP: 1.2.3.4 -> 1.2.x.x
    # Pattern: matching 4 octets, capturing first 2
    text = re.sub(r'(\d{1,3}\.\d{1,3})\.\d{1,3}\.\d{1,3}', r'\1.x.x', text)
    
    return text

if __name__ == "__main__":
    log = "Connect to mysql://root:password123@localhost from 192.168.1.10"
    print(sanitize_logs(log))
