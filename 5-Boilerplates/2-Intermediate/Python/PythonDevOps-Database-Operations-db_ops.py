#!/usr/bin/env python3
"""
Name: db_ops.py
Description: Safe Database Interactions using SQLite (Standard Library).
For Postgres, use psycopg2. For MySQL, use mysql-connector.
"""

import sqlite3
import logging
from contextlib import contextmanager

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("db_ops")

@contextmanager
def get_db_connection(db_file):
    """Context manager for closing connections automatically."""
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        # Enable Row access by name
        conn.row_factory = sqlite3.Row 
        yield conn
    except sqlite3.Error as e:
        logger.error(f"Database Error: {e}")
        raise
    finally:
        if conn:
            conn.close()

def init_db(db_file):
    with get_db_connection(db_file) as conn:
        cursor = conn.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS inventory (
                id INTEGER PRIMARY KEY,
                hostname TEXT NOT NULL,
                ip TEXT
            )
        """)
        conn.commit()
        logger.info("Database initialized.")

def add_server(db_file, hostname, ip):
    with get_db_connection(db_file) as conn:
        cursor = conn.cursor()
        # PARAMETERIZED QUERIES ARE MANDATORY TO PREVENT SQL INJECTION
        cursor.execute("INSERT INTO inventory (hostname, ip) VALUES (?, ?)", (hostname, ip))
        conn.commit()
        logger.info(f"Added {hostname}")

def get_servers(db_file):
    with get_db_connection(db_file) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM inventory")
        rows = cursor.fetchall()
        for row in rows:
            logger.info(f"Server: {row['hostname']} IP: {row['ip']}")

if __name__ == "__main__":
    DB = "operations.db"
    init_db(DB)
    add_server(DB, "web-01", "10.0.0.1")
    get_servers(DB)
    
    # Cleanup for demo
    import os
    os.remove(DB)
