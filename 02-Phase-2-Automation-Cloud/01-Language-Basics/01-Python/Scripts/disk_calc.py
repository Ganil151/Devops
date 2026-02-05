import sys

def calculate_usage(used, total):
    """Calculates disk usage percentage and prints warnings."""
    try:
        used = float(used)
        total = float(total)
        
        if total == 0:
            print("Error: Total space cannot be zero.")
            sys.exit(1)
            
        percentage = (used / total) * 100
        print(f"Usage: {percentage:.1f}%")
        
        if percentage > 80:
            print("WARNING: High disk usage!")
            
    except ValueError:
        print("Error: Please provide numeric values for used and total space.")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python disk_calc.py <used_gb> <total_gb>")
        sys.exit(1)
        
    calculate_usage(sys.argv[1], sys.argv[2])
