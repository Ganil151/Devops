"""
Solution: CSV Report Exporter
"""
import csv

def export_to_csv(results, filename):
    """Writes results to CSV."""
    headers = ["Name", "Host", "Status", "Latency(ms)"]
    
    with open(filename, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=["name", "host", "status", "latency_ms"])
        # Custom write to match header casing if needed, but simple is often better
        f.write(",".join(headers) + "\n")
        for row in results:
            # Map values
            val_row = {
                "name": row["name"],
                "host": row["host"],
                "status": row["status"],
                "latency_ms": row["latency_ms"] if row["latency_ms"] else "N/A"
            }
            writer.writerow(val_row)

if __name__ == "__main__":
    # Test would produce a file
    pass
