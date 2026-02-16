#!/usr/bin/env python3
"""
Secure Audit Database Module
SQLite backend with encryption support for UX Audit Tool v3.1.0
"""

import sqlite3
import json
import hashlib
import os
import datetime
from pathlib import Path
from typing import Optional, List, Dict

# Optional: cryptography for field-level encryption
try:
    from cryptography.fernet import Fernet
    CRYPTO_AVAILABLE = True
except ImportError:
    CRYPTO_AVAILABLE = False

class AuditDatabase:
    def __init__(self, db_path: str = "audit_store.db", encryption_key: Optional[str] = None):
        self.db_path = Path(db_path)
        self.encryption_key = encryption_key
        self.cipher = Fernet(encryption_key) if encryption_key and CRYPTO_AVAILABLE else None
        
        # Ensure directory exists with secure permissions
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Initialize database
        self._init_schema()
        self._set_secure_permissions()
    
    def _init_schema(self):
        """Create tables if they don't exist."""
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS audits (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    timestamp TEXT NOT NULL,
                    input_hash TEXT UNIQUE NOT NULL,
                    friction_score REAL NOT NULL,
                    intent_gaps TEXT NOT NULL,  -- JSON array
                    refinement_plan TEXT NOT NULL,
                    raw_input BLOB,              -- Optional encrypted storage
                    model_used TEXT DEFAULT 'qwen2.5',
                    session_id TEXT
                )
            """)
            conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_timestamp 
                ON audits(timestamp)
            """)
            conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_friction 
                ON audits(friction_score)
            """)
    
    def _set_secure_permissions(self):
        """Set restrictive file permissions (owner read/write only)."""
        try:
            os.chmod(self.db_path, 0o600)
        except OSError:
            pass  # May fail on some filesystems; log in production
    
    def _hash_input(self, text: str) -> str:
        """Generate SHA-256 hash for deduplication."""
        return hashlib.sha256(text.encode()).hexdigest()
    
    def _encrypt(self, plaintext: str) -> Optional[bytes]:
        """Encrypt sensitive data if key provided."""
        if self.cipher:
            return self.cipher.encrypt(plaintext.encode())
        return None
    
    def save_audit(self, 
                   interaction_log: str, 
                   audit_result: Dict,
                   session_id: Optional[str] = None) -> bool:
        """Persist audit result with deduplication check."""
        input_hash = self._hash_input(interaction_log)
        
        # Check for duplicate
        if self._exists(input_hash):
            return False
        
        # Prepare data
        timestamp = datetime.datetime.utcnow().isoformat()
        intent_gaps_json = json.dumps(audit_result.get('intent_gaps', []))
        
        # Optional encryption of raw input
        encrypted_input = self._encrypt(interaction_log) if self._encrypt else None
        
        try:
            with sqlite3.connect(self.db_path) as conn:
                conn.execute("""
                    INSERT INTO audits 
                    (timestamp, input_hash, friction_score, intent_gaps, 
                     refinement_plan, raw_input, model_used, session_id)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """, (
                    timestamp,
                    input_hash,
                    audit_result.get('ux_friction_score', 0.0),
                    intent_gaps_json,
                    audit_result.get('persona_refinement_plan', ''),
                    encrypted_input,
                    audit_result.get('model_used', 'qwen2.5'),
                    session_id
                ))
            return True
        except sqlite3.IntegrityError:
            # Race condition: duplicate inserted concurrently
            return False
    
    def _exists(self, input_hash: str) -> bool:
        """Check if audit already stored."""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute(
                "SELECT 1 FROM audits WHERE input_hash = ?", 
                (input_hash,)
            )
            return cursor.fetchone() is not None
    
    def get_history(self, 
                    limit: int = 10, 
                    min_score: float = 0.0,
                    session_id: Optional[str] = None) -> List[Dict]:
        """Query historical audits with filters."""
        query = """
            SELECT timestamp, friction_score, intent_gaps, refinement_plan, session_id
            FROM audits
            WHERE friction_score >= ?
        """
        params = [min_score]
        
        if session_id:
            query += " AND session_id = ?"
            params.append(session_id)
            
        query += " ORDER BY timestamp DESC LIMIT ?"
        params.append(limit)
        
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute(query, params)
            results = []
            for row in cursor:
                results.append({
                    'timestamp': row[0],
                    'friction_score': row[1],
                    'intent_gaps': json.loads(row[2]),
                    'refinement_plan': row[3],
                    'session_id': row[4]
                })
            return results
    
    def get_stats(self) -> Dict:
        """Return aggregate statistics."""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute("""
                SELECT 
                    COUNT(*) as total_audits,
                    AVG(friction_score) as avg_friction,
                    MAX(timestamp) as last_audit
                FROM audits
            """)
            row = cursor.fetchone()
            return {
                'total_audits': row[0],
                'avg_friction_score': round(row[1] or 0, 3),
                'last_audit': row[2]
            }
    
    def generate_key(self) -> str:
        """Generate a new Fernet encryption key (if cryptography available)."""
        if not CRYPTO_AVAILABLE:
            raise ImportError("Install 'cryptography' package for encryption support")
        return Fernet.generate_key().decode()
