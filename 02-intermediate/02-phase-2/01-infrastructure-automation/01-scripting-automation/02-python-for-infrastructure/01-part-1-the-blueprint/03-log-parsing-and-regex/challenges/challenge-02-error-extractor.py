"""
Challenge: Global Error Extractor
Scenario: You have a massive log file (app.log). You need to create 
a "crash report" that contains only the lines with the word "ERROR" 
or "CRITICAL", along with the timestamp.

TODO: Implement `extract_errors(input_log, output_summary)`.
1. Use Regex to find lines containing `(ERROR|CRITICAL)`.
2. Extract the timestamp if it's in a standard format like 
   `[2026-01-13 12:00:00]`.
3. Write the extracted lines to the `output_summary` file.
4. Return the total count of errors found.
"""
import re

def extract_errors(input_log, output_summary):
    """
    Extracts critical errors to a new file.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    count = extract_errors("app.log", "errors_summary.txt")
    print(f"Total errors extracted: {count}")
pip
"""
