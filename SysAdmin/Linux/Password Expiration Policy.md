### Check Password Expiration Info
```bash
chage -l ganil
```
Output: 
```bash
Last password change      : Sep 01, 2024
Password expires          : Jan 01, 2025
Password inactive         : never
Account expires           : never
Minimum number of days between password change  : 0
Maximum number of days between password change  : 99999
Number of days of warning before password change : 7
```
### Reset Password Expiration for Your User
```bash
sudo chage -I -1 -m 0 -M 99999 -E -1 ganil
```
This command sets:
- `-I -1`: No inactive period after expiry
- `-m 0`: Minimum password age (0 days)
- `-M 99999`: Maximum password age (effectively "never")
- `-E -1`: Never expire the account
✅ This disables password expiration for your user (`ganil`).
### Change Your Password (if prompted)
Sometimes the system forces a password update immediately.
```bash
passwd
```
### Disable Password Policy Globally (Optional)
If you're using this CentOS VM as a development environment and want to avoid future issues:
Edit the login defs file:
```bash
sudo nano /etc/login.defs
```
Change:
```bash
PASS_MAX_DAYS   99999
PASS_MIN_DAYS   0
PASS_WARN_AGE   0
```
Save and exit.
Then apply to your user:
```bash
sudo chage -M 99999 -W 0 ganil
```