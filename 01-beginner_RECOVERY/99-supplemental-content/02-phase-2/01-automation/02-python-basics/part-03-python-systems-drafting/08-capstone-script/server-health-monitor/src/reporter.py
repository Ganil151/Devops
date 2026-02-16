import json
from datetime import datetime
from typing import List, Dict, Any

def generate_report(results: List[Dict[str, Any]], output_file: str = None):
    """
    Summarizes results and prints to console. Optionally saves to JSON.
    """
    total = len(results)
    up_count = sum(1 for r in results if r["status"] == "UP")
    down_count = total - up_count
    
    print("\n" + "="*40)
    print(f"🌍 SERVER HEALTH REPORT - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("="*40)
    
    for r in results:
        icon = "✅" if r["status"] == "UP" else "❌"
        print(f"{icon} {r['name']:<15} | Target: {r['target']:<15} | Status: {r['status']}")
        
    print("-" * 40)
    print(f"SUMMARY: Total: {total} | UP: {up_count} | DOWN: {down_count}")
    print("="*40 + "\n")
    
    if output_file:
        with open(output_file, 'w') as f:
            json.dump({
                "timestamp": datetime.now().isoformat(),
                "summary": {"total": total, "up": up_count, "down": down_count},
                "results": results
            }, f, indent=4)
        print(f"Report saved to: {output_file}")

    return down_count == 0
