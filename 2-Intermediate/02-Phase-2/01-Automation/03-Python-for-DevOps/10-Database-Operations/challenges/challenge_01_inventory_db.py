"""
Challenge: SQLite Inventory Tracker
Scenario: You need a local database to track your virtual machines 
and their current statuses.

TODO: Implement `update_server_status(hostname, status)`.
1. Connect to `inventory.db`.
2. Ensure a table `servers` exists with columns: `hostname` (TEXT), `status` (TEXT).
3. If the `hostname` exists, update its `status`.
4. If it doesn't exist, insert a new record.
5. Use parameterized queries to prevent SQL injection.
6. Commit changes and close the connection.
"""
import sqlite3

def update_server_status(hostname, status):
    """
    Updates or inserts server status in the database.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    update_server_status("web-prod-01", "online")
    update_server_status("db-prod-01", "offline")
    
    # Verification query
    conn = sqlite3.connect('inventory.db')
    print(conn.execute("SELECT * FROM servers").fetchall())
    conn.close()
