"""
Challenge: CSV Report Exporter
Scenario: Your manager wants the health check results as a CSV file so they 
can open it in Excel.

TODO: Implement `export_to_csv(results, filename)`.
1. Use the `csv` module.
2. Define headers: `Name`, `Host`, `Status`, `Latency(ms)`.
3. Write each result from the `results` list into the CSV.
"""
import csv

def export_to_csv(results, filename):
    """
    Exports health check results to a CSV file.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    test_results = [
        {"name": "App", "host": "1.1.1.1", "status": "OK", "latency_ms": 15},
        {"name": "DB", "host": "2.2.2.2", "status": "TIMEOUT", "latency_ms": None}
    ]
    export_to_csv(test_results, "health_report.csv")
