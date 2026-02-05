#!/usr/bin/env python3
"""
Name: report_gen.py
Description: Analyze CSV data using Pandas.
Requires: pip install pandas
"""

import pandas as pd
import logging
from io import StringIO

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("pandas_ops")

# Dummy CSV Data
csv_data = """hostname,environment,cost
web-01,prod,100
web-02,prod,100
db-01,prod,500
dev-web,dev,20
test-db,test,50
"""

def analyze_cost(csv_content):
    """
    Groups servers by environment and sums the cost.
    """
    try:
        # Load Data
        df = pd.read_csv(StringIO(csv_content))
        
        logger.info("--- Raw Data ---")
        logger.info(f"\n{df}")
        
        # GroupBy
        report = df.groupby("environment")["cost"].sum().reset_index()
        
        logger.info("--- Cost Report ---")
        logger.info(f"\n{report}")
        
        # Filter
        high_cost = df[df["cost"] > 200]
        logger.info(f"High Cost Servers:\n{high_cost}")
        
        return report
        
    except Exception as e:
        logger.error(f"Analysis Failed: {e}")

if __name__ == "__main__":
    analyze_cost(csv_data)
