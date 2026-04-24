"""
Solution: SQLite Inventory Tracker
"""
import sqlite3

def update_server_status(hostname, status):
    conn = sqlite3.connect('inventory.db')
    cursor = conn.cursor()
    
    # 1. Ensure Table
    cursor.execute('''CREATE TABLE IF NOT EXISTS servers 
                      (hostname TEXT PRIMARY KEY, status TEXT)''')
    
    # 2. Upsert logic (Insert or Replace)
    cursor.execute("""
        INSERT OR REPLACE INTO servers (hostname, status) 
        VALUES (?, ?)
    """, (hostname, status))
    
    # 3. Commit
    conn.commit()
    conn.close()

if __name__ == "__main__":
    pass
