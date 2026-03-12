"""
Solution: NGINX Log Parser
"""
import re

def parse_nginx_log(log_line):
    """Parse NGINX access log line using named groups."""
    pattern = r'(?P<ip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) - - \[(?P<timestamp>[^\]]+)\] "(?P<method>\w+) (?P<path>\S+) HTTP/[\d.]+" (?P<status>\d+) (?P<size>\d+)'
    
    match = re.match(pattern, log_line)
    if match:
        data = match.groupdict()
        data['status'] = int(data['status'])
        data['size'] = int(data['size'])
        return data
    return None

if __name__ == "__main__":
    sample = '10.0.0.1 - - [12/Jan/2026:10:30:45 +0000] "GET /api/health HTTP/1.1" 200 1234'
    print(parse_nginx_log(sample))
