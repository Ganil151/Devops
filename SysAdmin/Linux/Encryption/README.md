# Linux Encryption and Security

Complete guide to encryption, authentication, and security mechanisms in Linux.

## GPG (GNU Privacy Guard)

### GPG Key Management
```bash
# Generate GPG key pair
gpg --full-generate-key
gpg --gen-key

# List keys
gpg --list-keys
gpg --list-secret-keys

# Export public key
gpg --export --armor user@example.com > public.key
gpg --export-secret-keys --armor user@example.com > private.key

# Import keys
gpg --import public.key
gpg --import private.key
```

### File Encryption with GPG
```bash
# Encrypt file
gpg --encrypt --recipient user@example.com file.txt
gpg -e -r user@example.com file.txt

# Decrypt file
gpg --decrypt file.txt.gpg > file.txt
gpg -d file.txt.gpg > file.txt

# Sign file
gpg --sign file.txt
gpg --detach-sign file.txt

# Verify signature
gpg --verify file.txt.sig file.txt
```

## Disk Encryption (LUKS)

### LUKS Setup
```bash
# Create encrypted partition
cryptsetup luksFormat /dev/sdb1

# Open encrypted partition
cryptsetup luksOpen /dev/sdb1 encrypted_disk

# Create filesystem
mkfs.ext4 /dev/mapper/encrypted_disk

# Mount encrypted partition
mount /dev/mapper/encrypted_disk /mnt/encrypted

# Close encrypted partition
umount /mnt/encrypted
cryptsetup luksClose encrypted_disk
```

### Automatic Mounting
```bash
# Add to /etc/crypttab
encrypted_disk /dev/sdb1 none luks

# Add to /etc/fstab
/dev/mapper/encrypted_disk /mnt/encrypted ext4 defaults 0 2

# Update initramfs
update-initramfs -u
```

## SSL/TLS Certificates

### Self-Signed Certificates
```bash
# Generate private key
openssl genrsa -out server.key 2048

# Generate certificate signing request
openssl req -new -key server.key -out server.csr

# Generate self-signed certificate
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

# Generate certificate and key in one command
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server.key -out server.crt
```

### Let's Encrypt Certificates
```bash
# Install Certbot
apt install certbot python3-certbot-nginx

# Obtain certificate
certbot --nginx -d example.com -d www.example.com

# Renew certificates
certbot renew --dry-run
certbot renew

# Auto-renewal cron job
echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -
```

## PAM (Pluggable Authentication Module)

### PAM Configuration
```bash
# PAM configuration files location
/etc/pam.d/

# Common PAM modules
# /etc/pam.d/common-auth
auth    [success=1 default=ignore]      pam_unix.so nullok_secure
auth    requisite                       pam_deny.so
auth    required                        pam_permit.so

# Password complexity
# /etc/pam.d/common-password
password requisite pam_pwquality.so retry=3 minlen=8 difok=3
```

### Two-Factor Authentication
```bash
# Install Google Authenticator PAM module
apt install libpam-google-authenticator

# Configure for user
google-authenticator

# Update PAM configuration
# /etc/pam.d/sshd
auth required pam_google_authenticator.so

# Update SSH configuration
# /etc/ssh/sshd_config
ChallengeResponseAuthentication yes
AuthenticationMethods publickey,keyboard-interactive
```

## File System Security

### File Permissions and ACLs
```bash
# Extended ACLs
setfacl -m u:username:rwx /path/to/file
setfacl -m g:groupname:rx /path/to/directory
getfacl /path/to/file

# Remove ACL
setfacl -x u:username /path/to/file
setfacl -b /path/to/file  # Remove all ACLs

# Default ACLs for directories
setfacl -d -m u:username:rwx /path/to/directory
```

### File Integrity Monitoring
```bash
# Install AIDE
apt install aide

# Initialize database
aide --init
mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Check for changes
aide --check

# Update database
aide --update
```