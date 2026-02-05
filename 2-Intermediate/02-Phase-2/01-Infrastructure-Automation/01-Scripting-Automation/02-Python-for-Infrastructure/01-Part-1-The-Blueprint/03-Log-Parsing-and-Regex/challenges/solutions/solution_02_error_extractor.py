"""
Solution: Global Error Extractor
"""
import re

def extract_errors(input_log, output_summary):
    error_pattern = re.compile(r"(ERROR|CRITICAL)")
    error_count = 0
    
    try:
        with open(input_log, "r") as src, open(output_summary, "w") as dest:
            for line in src:
                if error_pattern.search(line):
                    dest.write(line)
                    error_count += 1
    except FileNotFoundError:
        print("Input file missing.")
        
    return error_count

if __name__ == "__main__":
    pass
