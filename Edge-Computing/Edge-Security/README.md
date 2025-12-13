# Edge Security

## Overview

Edge security involves protecting distributed edge computing infrastructure, IoT devices, and data from security threats while maintaining performance and operational requirements in resource-constrained environments.

## Security Architecture

### Zero Trust Edge Security

```python
# zero_trust_edge.py
import hashlib
import hmac
import jwt
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64

class ZeroTrustEdgeManager:
    def __init__(self, master_key: str):
        self.master_key = master_key.encode()
        self.device_certificates: Dict[str, Dict] = {}
        self.access_policies: Dict[str, List[str]] = {}
        self.trust_scores: Dict[str, float] = {}
        self.cipher_suite = self._create_cipher()
    
    def _create_cipher(self) -> Fernet:
        """Create encryption cipher from master key"""
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=b'edge_security_salt',
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(self.master_key))
        return Fernet(key)
    
    def register_device(self, device_id: str, device_info: Dict[str, Any]) -> Dict[str, Any]:
        """Register device with zero trust verification"""
        
        # Generate device certificate
        certificate = {
            'device_id': device_id,
            'device_type': device_info.get('device_type'),
            'manufacturer': device_info.get('manufacturer'),
            'model': device_info.get('model'),
            'firmware_version': device_info.get('firmware_version'),
            'issued_at': datetime.now().isoformat(),
            'expires_at': (datetime.now() + timedelta(days=365)).isoformat(),
            'public_key': device_info.get('public_key'),
            'capabilities': device_info.get('capabilities', [])
        }
        
        # Create certificate signature
        cert_data = f"{device_id}:{certificate['issued_at']}:{certificate['expires_at']}"
        signature = hmac.new(
            self.master_key,
            cert_data.encode(),
            hashlib.sha256
        ).hexdigest()
        
        certificate['signature'] = signature
        self.device_certificates[device_id] = certificate
        
        # Initialize trust score
        self.trust_scores[device_id] = 0.5  # Neutral trust
        
        # Set default access policies
        self.access_policies[device_id] = ['read_sensors', 'report_status']
        
        return certificate
    
    def verify_device_identity(self, device_id: str, provided_cert: Dict[str, Any]) -> bool:
        """Verify device identity using certificate"""
        
        if device_id not in self.device_certificates:
            return False
        
        stored_cert = self.device_certificates[device_id]
        
        # Check certificate expiration
        expires_at = datetime.fromisoformat(stored_cert['expires_at'])
        if datetime.now() > expires_at:
            return False
        
        # Verify signature
        cert_data = f"{device_id}:{stored_cert['issued_at']}:{stored_cert['expires_at']}"
        expected_signature = hmac.new(
            self.master_key,
            cert_data.encode(),
            hashlib.sha256
        ).hexdigest()
        
        return hmac.compare_digest(provided_cert.get('signature', ''), expected_signature)
    
    def calculate_trust_score(self, device_id: str, behavior_data: Dict[str, Any]) -> float:
        """Calculate dynamic trust score based on device behavior"""
        
        if device_id not in self.trust_scores:
            return 0.0
        
        current_score = self.trust_scores[device_id]
        
        # Factors affecting trust score
        factors = {
            'authentication_failures': -0.1,
            'successful_authentications': 0.05,
            'anomalous_behavior': -0.2,
            'normal_behavior': 0.02,
            'security_violations': -0.3,
            'compliance_adherence': 0.1
        }
        
        # Apply behavior-based adjustments
        for behavior, impact in factors.items():
            if behavior in behavior_data:
                count = behavior_data[behavior]
                current_score += impact * count
        
        # Keep score within bounds [0, 1]
        current_score = max(0.0, min(1.0, current_score))
        
        self.trust_scores[device_id] = current_score
        return current_score
    
    def authorize_action(self, device_id: str, action: str, resource: str) -> bool:
        """Authorize device action based on zero trust principles"""
        
        # Verify device identity
        if device_id not in self.device_certificates:
            return False
        
        # Check trust score
        trust_score = self.trust_scores.get(device_id, 0.0)
        min_trust_required = self._get_min_trust_for_action(action)
        
        if trust_score < min_trust_required:
            return False
        
        # Check access policies
        allowed_actions = self.access_policies.get(device_id, [])
        if action not in allowed_actions:
            return False
        
        # Additional context-based checks
        return self._context_based_authorization(device_id, action, resource)
    
    def _get_min_trust_for_action(self, action: str) -> float:
        """Get minimum trust score required for action"""
        trust_requirements = {
            'read_sensors': 0.3,
            'write_actuators': 0.7,
            'update_firmware': 0.9,
            'admin_access': 0.95,
            'report_status': 0.2
        }
        return trust_requirements.get(action, 0.5)
    
    def _context_based_authorization(self, device_id: str, action: str, resource: str) -> bool:
        """Perform context-based authorization checks"""
        
        # Time-based access control
        current_hour = datetime.now().hour
        if action == 'admin_access' and not (9 <= current_hour <= 17):  # Business hours only
            return False
        
        # Location-based access control (simplified)
        device_cert = self.device_certificates.get(device_id, {})
        device_location = device_cert.get('location', 'unknown')
        
        if action == 'write_actuators' and device_location == 'public_area':
            return False
        
        return True
    
    def encrypt_communication(self, data: str) -> bytes:
        """Encrypt communication data"""
        return self.cipher_suite.encrypt(data.encode())
    
    def decrypt_communication(self, encrypted_data: bytes) -> str:
        """Decrypt communication data"""
        return self.cipher_suite.decrypt(encrypted_data).decode()
```

### Device Authentication

```python
# device_authentication.py
import hashlib
import secrets
from datetime import datetime, timedelta
from typing import Dict, Optional, Tuple
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

class DeviceAuthenticator:
    def __init__(self):
        self.device_keys: Dict[str, Dict] = {}
        self.authentication_sessions: Dict[str, Dict] = {}
        self.failed_attempts: Dict[str, int] = {}
        self.lockout_duration = timedelta(minutes=15)
    
    def generate_device_keypair(self, device_id: str) -> Tuple[bytes, bytes]:
        """Generate RSA keypair for device"""
        
        private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048
        )
        
        public_key = private_key.public_key()
        
        # Serialize keys
        private_pem = private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        )
        
        public_pem = public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
        
        # Store public key
        self.device_keys[device_id] = {
            'public_key': public_pem,
            'created_at': datetime.now(),
            'status': 'active'
        }
        
        return private_pem, public_pem
    
    def create_challenge(self, device_id: str) -> Optional[str]:
        """Create authentication challenge for device"""
        
        if self._is_device_locked_out(device_id):
            return None
        
        # Generate random challenge
        challenge = secrets.token_hex(32)
        
        # Store challenge with expiration
        self.authentication_sessions[device_id] = {
            'challenge': challenge,
            'created_at': datetime.now(),
            'expires_at': datetime.now() + timedelta(minutes=5),
            'status': 'pending'
        }
        
        return challenge
    
    def verify_challenge_response(self, device_id: str, signature: bytes) -> bool:
        """Verify device's response to authentication challenge"""
        
        if device_id not in self.authentication_sessions:
            return False
        
        session = self.authentication_sessions[device_id]
        
        # Check if challenge has expired
        if datetime.now() > session['expires_at']:
            del self.authentication_sessions[device_id]
            return False
        
        # Get device public key
        if device_id not in self.device_keys:
            return False
        
        try:
            # Load public key
            public_key_pem = self.device_keys[device_id]['public_key']
            public_key = serialization.load_pem_public_key(public_key_pem)
            
            # Verify signature
            challenge_bytes = session['challenge'].encode()
            
            public_key.verify(
                signature,
                challenge_bytes,
                padding.PSS(
                    mgf=padding.MGF1(hashes.SHA256()),
                    salt_length=padding.PSS.MAX_LENGTH
                ),
                hashes.SHA256()
            )
            
            # Authentication successful
            session['status'] = 'authenticated'
            session['authenticated_at'] = datetime.now()
            
            # Reset failed attempts
            if device_id in self.failed_attempts:
                del self.failed_attempts[device_id]
            
            return True
            
        except Exception as e:
            # Authentication failed
            self._record_failed_attempt(device_id)
            return False
    
    def _is_device_locked_out(self, device_id: str) -> bool:
        """Check if device is locked out due to failed attempts"""
        
        if device_id not in self.failed_attempts:
            return False
        
        # Check if lockout period has expired
        last_attempt = self.failed_attempts[device_id].get('last_attempt')
        if last_attempt and datetime.now() - last_attempt > self.lockout_duration:
            del self.failed_attempts[device_id]
            return False
        
        # Check attempt count
        attempt_count = self.failed_attempts[device_id].get('count', 0)
        return attempt_count >= 5  # Lock after 5 failed attempts
    
    def _record_failed_attempt(self, device_id: str):
        """Record failed authentication attempt"""
        
        if device_id not in self.failed_attempts:
            self.failed_attempts[device_id] = {'count': 0}
        
        self.failed_attempts[device_id]['count'] += 1
        self.failed_attempts[device_id]['last_attempt'] = datetime.now()
    
    def is_session_valid(self, device_id: str) -> bool:
        """Check if device has valid authentication session"""
        
        if device_id not in self.authentication_sessions:
            return False
        
        session = self.authentication_sessions[device_id]
        
        return (
            session['status'] == 'authenticated' and
            datetime.now() <= session['expires_at']
        )
    
    def revoke_device_access(self, device_id: str):
        """Revoke device access and invalidate sessions"""
        
        if device_id in self.device_keys:
            self.device_keys[device_id]['status'] = 'revoked'
        
        if device_id in self.authentication_sessions:
            del self.authentication_sessions[device_id]
```

## Network Security

### Secure Communication

```python
# secure_communication.py
import ssl
import socket
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives.asymmetric import rsa, padding
import os

class SecureEdgeCommunication:
    def __init__(self):
        self.tls_context = self._create_tls_context()
        self.symmetric_keys: Dict[str, Fernet] = {}
        self.session_keys: Dict[str, bytes] = {}
    
    def _create_tls_context(self) -> ssl.SSLContext:
        """Create TLS context for secure communication"""
        
        context = ssl.create_default_context(ssl.Purpose.SERVER_AUTH)
        
        # Configure for edge security
        context.minimum_version = ssl.TLSVersion.TLSv1_2
        context.set_ciphers('ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS')
        
        # Enable certificate verification
        context.check_hostname = True
        context.verify_mode = ssl.CERT_REQUIRED
        
        return context
    
    def establish_secure_channel(self, device_id: str, shared_secret: bytes) -> Fernet:
        """Establish secure communication channel with device"""
        
        # Derive encryption key from shared secret
        hkdf = HKDF(
            algorithm=hashes.SHA256(),
            length=32,
            salt=None,
            info=f"edge_device_{device_id}".encode(),
        )
        
        key = hkdf.derive(shared_secret)
        cipher = Fernet(Fernet.generate_key())  # Use derived key in production
        
        self.symmetric_keys[device_id] = cipher
        return cipher
    
    def encrypt_message(self, device_id: str, message: str) -> bytes:
        """Encrypt message for specific device"""
        
        if device_id not in self.symmetric_keys:
            raise ValueError(f"No secure channel established for device {device_id}")
        
        cipher = self.symmetric_keys[device_id]
        return cipher.encrypt(message.encode())
    
    def decrypt_message(self, device_id: str, encrypted_message: bytes) -> str:
        """Decrypt message from specific device"""
        
        if device_id not in self.symmetric_keys:
            raise ValueError(f"No secure channel established for device {device_id}")
        
        cipher = self.symmetric_keys[device_id]
        return cipher.decrypt(encrypted_message).decode()
    
    def create_secure_server(self, host: str, port: int, cert_file: str, key_file: str):
        """Create secure TLS server for edge communication"""
        
        # Load server certificate and key
        self.tls_context.load_cert_chain(cert_file, key_file)
        
        # Create server socket
        server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        
        # Wrap with TLS
        secure_socket = self.tls_context.wrap_socket(
            server_socket, 
            server_side=True
        )
        
        secure_socket.bind((host, port))
        secure_socket.listen(5)
        
        return secure_socket
    
    def create_secure_client_connection(self, host: str, port: int) -> ssl.SSLSocket:
        """Create secure client connection to edge service"""
        
        # Create client socket
        client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        
        # Wrap with TLS
        secure_socket = self.tls_context.wrap_socket(
            client_socket,
            server_hostname=host
        )
        
        secure_socket.connect((host, port))
        return secure_socket
```

### Network Segmentation

```python
# network_segmentation.py
from typing import Dict, List, Set, Optional
from dataclasses import dataclass
from enum import Enum

class SecurityZone(Enum):
    DMZ = "dmz"
    INTERNAL = "internal"
    RESTRICTED = "restricted"
    MANAGEMENT = "management"

@dataclass
class NetworkSegment:
    segment_id: str
    zone: SecurityZone
    subnet: str
    allowed_protocols: List[str]
    access_rules: List[Dict[str, str]]
    devices: Set[str]

class NetworkSegmentationManager:
    def __init__(self):
        self.segments: Dict[str, NetworkSegment] = {}
        self.device_assignments: Dict[str, str] = {}
        self.firewall_rules: List[Dict[str, str]] = []
    
    def create_segment(self, segment_id: str, zone: SecurityZone, 
                      subnet: str, allowed_protocols: List[str]) -> NetworkSegment:
        """Create network segment with security zone"""
        
        segment = NetworkSegment(
            segment_id=segment_id,
            zone=zone,
            subnet=subnet,
            allowed_protocols=allowed_protocols,
            access_rules=[],
            devices=set()
        )
        
        self.segments[segment_id] = segment
        self._generate_firewall_rules(segment)
        
        return segment
    
    def assign_device_to_segment(self, device_id: str, segment_id: str) -> bool:
        """Assign device to network segment"""
        
        if segment_id not in self.segments:
            return False
        
        # Remove from previous segment if assigned
        if device_id in self.device_assignments:
            old_segment_id = self.device_assignments[device_id]
            self.segments[old_segment_id].devices.discard(device_id)
        
        # Assign to new segment
        self.segments[segment_id].devices.add(device_id)
        self.device_assignments[device_id] = segment_id
        
        return True
    
    def add_access_rule(self, segment_id: str, rule: Dict[str, str]) -> bool:
        """Add access rule to segment"""
        
        if segment_id not in self.segments:
            return False
        
        self.segments[segment_id].access_rules.append(rule)
        self._update_firewall_rules(segment_id)
        
        return True
    
    def check_communication_allowed(self, source_device: str, 
                                  target_device: str, protocol: str) -> bool:
        """Check if communication is allowed between devices"""
        
        # Get device segments
        source_segment_id = self.device_assignments.get(source_device)
        target_segment_id = self.device_assignments.get(target_device)
        
        if not source_segment_id or not target_segment_id:
            return False
        
        source_segment = self.segments[source_segment_id]
        target_segment = self.segments[target_segment_id]
        
        # Check protocol allowed in source segment
        if protocol not in source_segment.allowed_protocols:
            return False
        
        # Check zone-based access rules
        return self._check_zone_access(source_segment.zone, target_segment.zone, protocol)
    
    def _check_zone_access(self, source_zone: SecurityZone, 
                          target_zone: SecurityZone, protocol: str) -> bool:
        """Check if access is allowed between security zones"""
        
        # Define zone access matrix
        zone_access_rules = {
            SecurityZone.DMZ: {
                SecurityZone.DMZ: ['http', 'https', 'mqtt'],
                SecurityZone.INTERNAL: [],  # DMZ cannot access internal
                SecurityZone.RESTRICTED: [],  # DMZ cannot access restricted
                SecurityZone.MANAGEMENT: []  # DMZ cannot access management
            },
            SecurityZone.INTERNAL: {
                SecurityZone.DMZ: ['http', 'https'],
                SecurityZone.INTERNAL: ['http', 'https', 'mqtt', 'coap'],
                SecurityZone.RESTRICTED: ['https'],  # Limited access to restricted
                SecurityZone.MANAGEMENT: []  # Internal cannot access management
            },
            SecurityZone.RESTRICTED: {
                SecurityZone.DMZ: [],  # Restricted cannot access DMZ
                SecurityZone.INTERNAL: ['https'],  # Limited access to internal
                SecurityZone.RESTRICTED: ['http', 'https', 'mqtt', 'coap'],
                SecurityZone.MANAGEMENT: ['https', 'ssh']  # Restricted can access management
            },
            SecurityZone.MANAGEMENT: {
                SecurityZone.DMZ: ['http', 'https', 'ssh'],
                SecurityZone.INTERNAL: ['http', 'https', 'ssh', 'snmp'],
                SecurityZone.RESTRICTED: ['http', 'https', 'ssh'],
                SecurityZone.MANAGEMENT: ['http', 'https', 'ssh', 'snmp']
            }
        }
        
        allowed_protocols = zone_access_rules.get(source_zone, {}).get(target_zone, [])
        return protocol in allowed_protocols
    
    def _generate_firewall_rules(self, segment: NetworkSegment):
        """Generate firewall rules for segment"""
        
        # Allow intra-segment communication for allowed protocols
        for protocol in segment.allowed_protocols:
            rule = {
                'action': 'allow',
                'source': segment.subnet,
                'destination': segment.subnet,
                'protocol': protocol,
                'zone': segment.zone.value
            }
            self.firewall_rules.append(rule)
        
        # Default deny rule
        deny_rule = {
            'action': 'deny',
            'source': segment.subnet,
            'destination': 'any',
            'protocol': 'any',
            'zone': segment.zone.value
        }
        self.firewall_rules.append(deny_rule)
    
    def _update_firewall_rules(self, segment_id: str):
        """Update firewall rules for segment"""
        
        segment = self.segments[segment_id]
        
        # Remove old rules for this segment
        self.firewall_rules = [
            rule for rule in self.firewall_rules 
            if rule.get('zone') != segment.zone.value
        ]
        
        # Regenerate rules
        self._generate_firewall_rules(segment)
    
    def get_segment_status(self, segment_id: str) -> Optional[Dict[str, Any]]:
        """Get segment status and statistics"""
        
        if segment_id not in self.segments:
            return None
        
        segment = self.segments[segment_id]
        
        return {
            'segment_id': segment_id,
            'zone': segment.zone.value,
            'subnet': segment.subnet,
            'device_count': len(segment.devices),
            'devices': list(segment.devices),
            'allowed_protocols': segment.allowed_protocols,
            'access_rules_count': len(segment.access_rules)
        }
```

## Best Practices

### Edge Security Best Practices

1. **Defense in Depth**
   - Multiple security layers
   - Network segmentation
   - Device-level security
   - Application security

2. **Zero Trust Architecture**
   - Never trust, always verify
   - Continuous authentication
   - Least privilege access
   - Micro-segmentation

3. **Secure Communication**
   - End-to-end encryption
   - Certificate-based authentication
   - Secure protocols (TLS, DTLS)
   - Message integrity verification

4. **Device Security**
   - Hardware security modules
   - Secure boot processes
   - Regular security updates
   - Device attestation

5. **Monitoring and Response**
   - Continuous security monitoring
   - Anomaly detection
   - Incident response procedures
   - Security event logging

## Conclusion

Edge security requires a comprehensive approach that addresses the unique challenges of distributed, resource-constrained environments. Success depends on implementing zero trust principles, secure communication protocols, network segmentation, and continuous monitoring while maintaining operational efficiency.