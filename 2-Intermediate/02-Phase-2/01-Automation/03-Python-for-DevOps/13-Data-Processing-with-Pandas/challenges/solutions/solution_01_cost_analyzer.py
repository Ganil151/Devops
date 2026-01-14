"""
Solution: AWS Cost Analyzer
"""
import pandas as pd

def analyze_costs(csv_file):
    try:
        df = pd.read_csv(csv_file)
        
        # 1. Filter Prod
        prod_df = df[df['Account'] == 'Prod']
        
        # 2. Group by Service
        service_costs = prod_df.groupby('Service')['Cost'].sum()
        
        # 3. Get most expensive
        return service_costs.idxmax()
        
    except Exception as e:
        print(f"Analysis failed: {e}")
        return None

if __name__ == "__main__":
    pass
