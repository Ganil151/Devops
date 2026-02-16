#!/usr/bin/env python3
"""
Topic: Python-Based Cost Guardrails
Description: Parses Infracost JSON and fails the build if the monthly increase exceeds a threshold.
"""

import json
import sys

# CONFIGURATION: Set the maximum allowed increase in USD per month
MAX_MONTHLY_INCREASE = 100.0 

def check_cost_guardrail(json_file):
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)
        
        # Infracost JSON structure: totalMonthlyCost is a string
        # Diff JSON structure includes 'diffTotalMonthlyCost'
        diff_cost = float(data.get('diffTotalMonthlyCost', 0))
        
        print(f"💰 Monthly Cost Change: ${diff_cost:,.2f}")
        
        if diff_cost > MAX_MONTHLY_INCREASE:
            print(f"🚨 GUARDRAIL FAILED: Increase of ${diff_cost:,.2f} exceeds limit of ${MAX_MONTHLY_INCREASE}")
            sys.exit(1)
        
        print("✅ Guardrail Passed: Cost change is within acceptable limits.")

    except FileNotFoundError:
        print(f"❌ Error: {json_file} not found.")
        sys.exit(1)
    except Exception as e:
        print(f"💥 Error processing cost report: {e}")
        sys.exit(1)

if __name__ == "__main__":
    # Expects the diff.json path as the first argument
    report_path = sys.argv[1] if len(sys.argv) > 1 else "diff.json"
    check_cost_guardrail(report_path)
