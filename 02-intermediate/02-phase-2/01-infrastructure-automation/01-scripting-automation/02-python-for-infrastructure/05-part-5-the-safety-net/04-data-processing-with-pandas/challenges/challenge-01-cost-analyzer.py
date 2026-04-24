"""
Challenge: AWS Cost Analyzer
Scenario: You have a CSV (`costs.csv`) containing: 
`Date, Account, Service, Cost`. You need to find which service is 
the most expensive in the 'Production' account.

TODO: Implement `analyze_costs(csv_file)`.
1. Load the CSV into a Pandas DataFrame.
2. Filter the data to show only the 'Production' account.
3. Group the data by 'Service' and sum the 'Cost'.
4. Sort the result by cost descending.
5. Return the name of the most expensive service.
"""
import pandas as pd

def analyze_costs(csv_file):
    """
    Analyzes production costs using Pandas.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Create mock CSV
    data = {
        'Account': ['Dev', 'Prod', 'Prod', 'Prod', 'Dev'],
        'Service': ['EC2', 'EC2', 'S3', 'RDS', 'S3'],
        'Cost': [10, 50, 20, 100, 5]
    }
    pd.DataFrame(data).to_csv('costs.csv', index=False)
    
    expensive = analyze_costs('costs.csv')
    print(f"Most expensive Prod service: {expensive}")
