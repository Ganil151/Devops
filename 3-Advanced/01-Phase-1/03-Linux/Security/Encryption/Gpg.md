## 1. Install GnuPG (if it's not already installed):
GnuPG is typically installed by default on Kali Linux, but in case it's not, you can install it using the following command:
```bash
sudo apt update
sudo apt install gnupg
```
## 2. Generate a GPG Key (if you don't have one):
If you don't have a GPG key pair yet, you'll need to generate one. You can create a key pair by running:
```bash
gpg --full-generate-key
```
Follow the prompts to choose the key type (usually RSA and RSA), key size (2048 or 4096 bits), expiration date (optional), and your name/email address. You'll be asked to set a passphrase for your key.

## 3. List Your Keys (Optional):
If you already have a key pair and want to verify or view your keys, use the command:
```bash
gpg --list-keys
```
This will display the available GPG keys on your system.

## 4. Encrypt a File:
Now, you can encrypt a file using your GPG key. You can either encrypt it for a specific recipient or for yourself.
To encrypt a file for a specific recipient, use their GPG key. If you want to encrypt a file for yourself, simply use your own key.
Encrypting for a specific recipient:
```bash
gpg --output encrypted_file.gpg --encrypt --recipient recipient@example.com filename
```
Here:
encrypted_file.gpg is the output encrypted file.
recipient@example.com is the email associated with the recipient's GPG key.
filename is the file you're encrypting.
Encrypting for yourself (using your own key):
```bash
gpg --output encrypted_file.gpg --encrypt --recipient your-email@example.com filename
```
Replace your-email@example.com with your GPG key's email address.

## 5. Verify the Encrypted File:
You can list the encrypted file by checking its extension (.gpg):
```bash
ls -l encrypted_file.gpg
```
## 6. Decrypting the File:
To decrypt the file later, the recipient (or you, if it's your own key) will need the corresponding private key and passphrase.

To decrypt the file:
```bash
gpg --output decrypted_file --decrypt encrypted_file.gpg
```
After running the command, you will be prompted for the passphrase for your private key (if required).
Additional Options:

If you want to sign the file while encrypting it (to ensure the recipient knows who sent it), add the --sign option:
```bash
gpg --output encrypted_file.gpg --encrypt --sign --recipient recipient@example.com filename
```
To verify a signed file:
```bash
gpg --verify signed_file.gpg
```