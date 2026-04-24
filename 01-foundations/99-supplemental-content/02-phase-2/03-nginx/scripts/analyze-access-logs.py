"""
Nginx Access Log Analyzer
Description: Parses access logs for top IPs, status codes, and paths.
"""

import collections
import re
import argparse

def analyze_log(file_path):
    ip_counter = collections.Counter()
    status_counter = collections.Counter()
    path_counter = collections.Counter()
    
    # Nginx default format regex (approximate)
    log_pattern = re.compile(r'(?P<ip>[\d\.]+) - - \[.*\] "(?P<method>\w+) (?P<path>.*?) .*" (?P<status>\d+) .*')
    
    print(f"Analyzing {file_path}...")
    
    try:
        with open(file_path, 'r') as f:
            for line in f:
                match = log_pattern.match(line)
                if match:
                    data = match.groupdict()
                    ip_counter[data['ip']] += 1
                    status_counter[data['status']] += 1
                    path_counter[data['path']] += 1
                    
        print("\nTop 5 IP Addresses:")
        for ip, count in ip_counter.most_common(5):
            print(f"  {ip}: {count}")
            
        print("\nStatus Codes:")
        for status, count in status_counter.most_common():
            print(f"  {status}: {count}")
            
        print("\nTop 5 Requested Paths:")
        for path, count in path_counter.most_common(5):
            print(f"  {path}: {count}")
            
    except FileNotFoundError:
        print("File not found.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("file", help="Path to access.log")
    args = parser.parse_args()
    analyze_log(args.file)
