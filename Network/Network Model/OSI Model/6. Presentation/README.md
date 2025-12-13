# Presentation Layer (Layer 6) - OSI Model

## Overview

The Presentation Layer handles data formatting, encryption, compression, and translation between different data representations. It ensures that data sent by one system can be understood by another system, regardless of their internal data formats.

## Key Functions

### 1. Data Translation
- **Character Encoding**: ASCII, UTF-8, UTF-16, EBCDIC conversion
- **Data Format Conversion**: Between different data representations
- **Endianness Handling**: Big-endian vs little-endian byte ordering
- **Protocol Translation**: Between different communication protocols

### 2. Data Encryption/Decryption
- **Symmetric Encryption**: AES, DES, 3DES
- **Asymmetric Encryption**: RSA, ECC, DSA
- **Hash Functions**: SHA-256, MD5, HMAC
- **Digital Signatures**: Authentication and non-repudiation

### 3. Data Compression/Decompression
- **Lossless Compression**: ZIP, GZIP, LZ77, Huffman coding
- **Lossy Compression**: JPEG, MP3, MPEG
- **Real-time Compression**: For streaming applications
- **Bandwidth Optimization**: Reducing data transmission size

## Character Encoding and Data Formats

### Character Encoding Systems
```python
# Character encoding examples
text = "Hello, 世界! 🌍"

# UTF-8 encoding (variable length)
utf8_bytes = text.encode('utf-8')
print(f"UTF-8: {utf8_bytes}")
# b'Hello, \xe4\xb8\x96\xe7\x95\x8c! \xf0\x9f\x8c\x8d'

# UTF-16 encoding (fixed 16-bit)
utf16_bytes = text.encode('utf-16')
print(f"UTF-16: {utf16_bytes}")

# ASCII encoding (limited character set)
ascii_text = "Hello World"
ascii_bytes = ascii_text.encode('ascii')
print(f"ASCII: {ascii_bytes}")

# Base64 encoding (for binary data in text format)
import base64
base64_encoded = base64.b64encode(utf8_bytes)
print(f"Base64: {base64_encoded}")
```

### Data Serialization Formats
```python
# JSON serialization
import json

data = {
    "name": "John Doe",
    "age": 30,
    "skills": ["Python", "DevOps", "Networking"]
}

json_string = json.dumps(data)
parsed_data = json.loads(json_string)

# XML serialization
import xml.etree.ElementTree as ET

root = ET.Element("person")
name = ET.SubElement(root, "name")
name.text = "John Doe"
age = ET.SubElement(root, "age")
age.text = "30"

xml_string = ET.tostring(root, encoding='unicode')

# Protocol Buffers (protobuf)
# person.proto
"""
syntax = "proto3";

message Person {
  string name = 1;
  int32 age = 2;
  repeated string skills = 3;
}
"""

# YAML serialization
import yaml

yaml_string = yaml.dump(data)
parsed_yaml = yaml.safe_load(yaml_string)

# MessagePack (binary JSON)
import msgpack

packed_data = msgpack.packb(data)
unpacked_data = msgpack.unpackb(packed_data, raw=False)
```

## Encryption and Cryptography

### Symmetric Encryption
```python
# AES encryption example
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
import os

# Fernet (AES 128 in CBC mode with HMAC)
key = Fernet.generate_key()
cipher_suite = Fernet(key)

plaintext = b"Sensitive data to encrypt"
ciphertext = cipher_suite.encrypt(plaintext)
decrypted = cipher_suite.decrypt(ciphertext)

# AES-256-CBC encryption
def aes_encrypt(plaintext, key):
    # Generate random IV
    iv = os.urandom(16)
    
    # Pad plaintext to block size
    padder = padding.PKCS7(128).padder()
    padded_data = padder.update(plaintext) + padder.finalize()
    
    # Encrypt
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
    encryptor = cipher.encryptor()
    ciphertext = encryptor.update(padded_data) + encryptor.finalize()
    
    return iv + ciphertext

def aes_decrypt(ciphertext, key):
    # Extract IV and ciphertext
    iv = ciphertext[:16]
    actual_ciphertext = ciphertext[16:]
    
    # Decrypt
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
    decryptor = cipher.decryptor()
    padded_plaintext = decryptor.update(actual_ciphertext) + decryptor.finalize()
    
    # Remove padding
    unpadder = padding.PKCS7(128).unpadder()
    plaintext = unpadder.update(padded_plaintext) + unpadder.finalize()
    
    return plaintext
```

### Asymmetric Encryption
```python
# RSA encryption example
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes, serialization

# Generate RSA key pair
private_key = rsa.generate_private_key(
    public_exponent=65537,
    key_size=2048
)
public_key = private_key.public_key()

# Encrypt with public key
message = b"Secret message"
ciphertext = public_key.encrypt(
    message,
    padding.OAEP(
        mgf=padding.MGF1(algorithm=hashes.SHA256()),
        algorithm=hashes.SHA256(),
        label=None
    )
)

# Decrypt with private key
plaintext = private_key.decrypt(
    ciphertext,
    padding.OAEP(
        mgf=padding.MGF1(algorithm=hashes.SHA256()),
        algorithm=hashes.SHA256(),
        label=None
    )
)

# Digital signature
signature = private_key.sign(
    message,
    padding.PSS(
        mgf=padding.MGF1(hashes.SHA256()),
        salt_length=padding.PSS.MAX_LENGTH
    ),
    hashes.SHA256()
)

# Verify signature
try:
    public_key.verify(
        signature,
        message,
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.MAX_LENGTH
        ),
        hashes.SHA256()
    )
    print("Signature valid")
except:
    print("Signature invalid")
```

### Hash Functions and HMAC
```python
# Hash functions
import hashlib
import hmac

data = b"Data to hash"

# SHA-256 hash
sha256_hash = hashlib.sha256(data).hexdigest()
print(f"SHA-256: {sha256_hash}")

# MD5 hash (not recommended for security)
md5_hash = hashlib.md5(data).hexdigest()
print(f"MD5: {md5_hash}")

# HMAC (Hash-based Message Authentication Code)
secret_key = b"secret_key"
hmac_hash = hmac.new(secret_key, data, hashlib.sha256).hexdigest()
print(f"HMAC-SHA256: {hmac_hash}")

# Password hashing with salt
import bcrypt

password = b"user_password"
salt = bcrypt.gensalt()
hashed_password = bcrypt.hashpw(password, salt)

# Verify password
if bcrypt.checkpw(password, hashed_password):
    print("Password correct")
```

## Data Compression

### Lossless Compression
```python
# GZIP compression
import gzip
import zlib

data = b"This is some data that we want to compress. " * 100

# GZIP compression
compressed_gzip = gzip.compress(data)
decompressed_gzip = gzip.decompress(compressed_gzip)

print(f"Original size: {len(data)} bytes")
print(f"Compressed size: {len(compressed_gzip)} bytes")
print(f"Compression ratio: {len(compressed_gzip)/len(data):.2%}")

# ZLIB compression
compressed_zlib = zlib.compress(data)
decompressed_zlib = zlib.decompress(compressed_zlib)

# LZ4 compression (fast)
import lz4.frame

compressed_lz4 = lz4.frame.compress(data)
decompressed_lz4 = lz4.frame.decompress(compressed_lz4)

# Brotli compression (high compression ratio)
import brotli

compressed_brotli = brotli.compress(data)
decompressed_brotli = brotli.decompress(compressed_brotli)
```

### Image and Media Compression
```python
# Image compression with PIL
from PIL import Image
import io

# Load and compress JPEG image
image = Image.open("input.jpg")

# Compress with different quality levels
for quality in [95, 85, 75, 50]:
    output = io.BytesIO()
    image.save(output, format='JPEG', quality=quality, optimize=True)
    compressed_size = len(output.getvalue())
    print(f"Quality {quality}: {compressed_size} bytes")

# Convert to WebP format (better compression)
image.save("output.webp", format='WebP', quality=80)

# PNG optimization
image.save("output.png", format='PNG', optimize=True)
```

## SSL/TLS Implementation

### TLS Configuration
```python
# TLS client example
import ssl
import socket

# Create secure SSL context
context = ssl.create_default_context()
context.check_hostname = False  # For testing only
context.verify_mode = ssl.CERT_NONE  # For testing only

# Connect with TLS
with socket.create_connection(('www.google.com', 443)) as sock:
    with context.wrap_socket(sock, server_hostname='www.google.com') as ssock:
        print(f"TLS version: {ssock.version()}")
        print(f"Cipher: {ssock.cipher()}")
        
        # Send HTTP request
        ssock.send(b"GET / HTTP/1.1\r\nHost: www.google.com\r\n\r\n")
        response = ssock.recv(1024)
        print(response.decode())

# TLS server example
import ssl
import socket

# Create SSL context for server
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain('server.crt', 'server.key')

# Configure cipher suites
context.set_ciphers('ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS')

# Create server socket
with socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0) as sock:
    sock.bind(('localhost', 8443))
    sock.listen(5)
    
    with context.wrap_socket(sock, server_side=True) as ssock:
        while True:
            conn, addr = ssock.accept()
            data = conn.recv(1024)
            conn.send(b"HTTP/1.1 200 OK\r\n\r\nHello, TLS!")
            conn.close()
```

### Certificate Management
```bash
# Generate self-signed certificate
openssl req -x509 -newkey rsa:4096 -keyout server.key -out server.crt -days 365 -nodes

# Generate Certificate Signing Request (CSR)
openssl req -new -newkey rsa:4096 -keyout private.key -out request.csr -nodes

# View certificate information
openssl x509 -in server.crt -text -noout

# Verify certificate chain
openssl verify -CAfile ca.crt server.crt

# Convert certificate formats
openssl x509 -in cert.pem -outform DER -out cert.der
openssl x509 -in cert.der -inform DER -outform PEM -out cert.pem

# Extract public key from certificate
openssl x509 -in server.crt -pubkey -noout > public.key
```

## Data Validation and Integrity

### Data Validation
```python
# JSON Schema validation
import jsonschema

schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string", "minLength": 1},
        "age": {"type": "integer", "minimum": 0, "maximum": 150},
        "email": {"type": "string", "format": "email"}
    },
    "required": ["name", "age", "email"]
}

data = {
    "name": "John Doe",
    "age": 30,
    "email": "john@example.com"
}

try:
    jsonschema.validate(data, schema)
    print("Data is valid")
except jsonschema.ValidationError as e:
    print(f"Validation error: {e.message}")

# XML Schema validation
from lxml import etree

# Load XML schema
with open('schema.xsd', 'r') as schema_file:
    schema_root = etree.XML(schema_file.read())
    schema = etree.XMLSchema(schema_root)

# Validate XML document
with open('document.xml', 'r') as xml_file:
    xml_doc = etree.parse(xml_file)
    
if schema.validate(xml_doc):
    print("XML is valid")
else:
    print("XML validation errors:", schema.error_log)
```

### Data Integrity Checks
```python
# File integrity verification
import hashlib
import os

def calculate_file_hash(filepath, algorithm='sha256'):
    hash_func = hashlib.new(algorithm)
    with open(filepath, 'rb') as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_func.update(chunk)
    return hash_func.hexdigest()

def verify_file_integrity(filepath, expected_hash, algorithm='sha256'):
    actual_hash = calculate_file_hash(filepath, algorithm)
    return actual_hash == expected_hash

# Create checksum file
def create_checksum_file(directory):
    checksums = {}
    for root, dirs, files in os.walk(directory):
        for file in files:
            filepath = os.path.join(root, file)
            checksums[filepath] = calculate_file_hash(filepath)
    
    with open('checksums.txt', 'w') as f:
        for filepath, checksum in checksums.items():
            f.write(f"{checksum}  {filepath}\n")

# Verify checksums
def verify_checksums(checksum_file):
    with open(checksum_file, 'r') as f:
        for line in f:
            expected_hash, filepath = line.strip().split('  ', 1)
            if os.path.exists(filepath):
                if verify_file_integrity(filepath, expected_hash):
                    print(f"✓ {filepath}")
                else:
                    print(f"✗ {filepath} - INTEGRITY FAILURE")
            else:
                print(f"? {filepath} - FILE NOT FOUND")
```

## Performance Optimization

### Compression Strategies
```python
# Adaptive compression based on content type
import mimetypes

def choose_compression(content_type, data_size):
    # Text-based content - use GZIP
    if content_type.startswith('text/') or content_type in ['application/json', 'application/xml']:
        if data_size > 1024:  # Only compress if > 1KB
            return 'gzip'
    
    # Images - already compressed, don't compress further
    elif content_type.startswith('image/'):
        return None
    
    # Binary data - use LZ4 for speed
    elif data_size > 10240:  # Only compress if > 10KB
        return 'lz4'
    
    return None

# Streaming compression for large files
def compress_stream(input_stream, output_stream, chunk_size=8192):
    compressor = zlib.compressobj()
    
    while True:
        chunk = input_stream.read(chunk_size)
        if not chunk:
            break
        
        compressed_chunk = compressor.compress(chunk)
        if compressed_chunk:
            output_stream.write(compressed_chunk)
    
    # Write any remaining data
    final_chunk = compressor.flush()
    if final_chunk:
        output_stream.write(final_chunk)
```

### Caching Strategies
```python
# Content-based caching with ETags
import hashlib
from datetime import datetime, timedelta

class ContentCache:
    def __init__(self):
        self.cache = {}
    
    def generate_etag(self, content):
        return hashlib.md5(content.encode()).hexdigest()
    
    def get_cached_content(self, key, etag=None):
        if key in self.cache:
            cached_item = self.cache[key]
            
            # Check if content hasn't changed
            if etag and cached_item['etag'] == etag:
                return None, 304  # Not Modified
            
            # Check expiration
            if datetime.now() < cached_item['expires']:
                return cached_item['content'], 200
        
        return None, None
    
    def cache_content(self, key, content, ttl_seconds=3600):
        etag = self.generate_etag(content)
        expires = datetime.now() + timedelta(seconds=ttl_seconds)
        
        self.cache[key] = {
            'content': content,
            'etag': etag,
            'expires': expires
        }
        
        return etag
```

## DevOps Integration

### Configuration Management
```yaml
# Ansible playbook for SSL/TLS configuration
---
- name: Configure SSL/TLS
  hosts: web_servers
  tasks:
    - name: Install SSL certificates
      copy:
        src: "{{ item.src }}"
        dest: "{{ item.dest }}"
        mode: "{{ item.mode }}"
      loop:
        - { src: "server.crt", dest: "/etc/ssl/certs/server.crt", mode: "0644" }
        - { src: "server.key", dest: "/etc/ssl/private/server.key", mode: "0600" }
    
    - name: Configure Nginx SSL
      template:
        src: nginx-ssl.conf.j2
        dest: /etc/nginx/sites-available/default
      notify: restart nginx
    
    - name: Enable strong SSL configuration
      lineinfile:
        path: /etc/nginx/nginx.conf
        line: "{{ item }}"
      loop:
        - "ssl_protocols TLSv1.2 TLSv1.3;"
        - "ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;"
        - "ssl_prefer_server_ciphers off;"
```

### Container Security
```dockerfile
# Dockerfile with security best practices
FROM alpine:3.18

# Install security updates
RUN apk update && apk upgrade

# Create non-root user
RUN addgroup -g 1001 appgroup && \
    adduser -D -u 1001 -G appgroup appuser

# Install application dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY --chown=appuser:appgroup . /app
WORKDIR /app

# Switch to non-root user
USER appuser

# Set secure environment
ENV PYTHONPATH=/app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

EXPOSE 8080
CMD ["python", "app.py"]
```

### Infrastructure as Code
```terraform
# Terraform configuration for SSL/TLS
resource "aws_acm_certificate" "main" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  
  subject_alternative_names = [
    "*.${var.domain_name}"
  ]
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.main.arn
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
```

## Best Practices

### 1. Encryption
- Use strong encryption algorithms (AES-256, RSA-2048+)
- Implement proper key management
- Use TLS 1.2 or higher
- Regular security audits

### 2. Data Formats
- Choose appropriate serialization formats
- Validate all input data
- Handle encoding properly
- Use schema validation

### 3. Compression
- Compress text-based content
- Avoid compressing already compressed data
- Consider compression ratio vs CPU usage
- Use streaming for large files

### 4. Performance
- Cache frequently accessed data
- Use appropriate compression levels
- Implement content delivery networks
- Monitor performance metrics