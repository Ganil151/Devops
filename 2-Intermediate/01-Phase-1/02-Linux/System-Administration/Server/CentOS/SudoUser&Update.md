## On CentOS 8, there are two primary ways to grant sudo privileges to a user:

Add the user to the wheel group (recommended).
Directly edit the `/etc/sudoers` file.
Important Note: Always use the` visudo` command to edit the `/etc/sudoers` file or create new `sudoers` files in `/etc/sudoers.d/. visudo` checks for syntax errors before saving, preventing you from accidentally locking yourself out of root access.
#### Method 1: Add the user to the wheel group (Recommended)
On CentOS, the wheel group is configured by default to have sudo privileges. This is the most secure and common way to grant sudo access.
##### Steps:
Log in as the root user or another user with sudo privileges.
If you are completely locked out of sudo, you might need to reboot into single-user mode or use a rescue disk to gain root access.
```Bash
ssh root@your_server_ip_address
# OR
su - root
```
Add the user gsmash to the wheel group:
```Bash
usermod -aG wheel gsmash
```
`usermod`: Command to modify user accounts.
`-aG`: Appends (-a) the user to the specified group (-G).
wheel: The group that has sudo privileges by default on CentOS.
The username you want to add to the wheel group.
Verify the wheel group is enabled in sudoers (usually enabled by default):
Open the sudoers file using` visudo`:
```Bash
visudo
```
Look for a line similar to this (it might be commented out with a #):
#### Allows members of the 'wheel' group to run all commands
```txt
%wheel  ALL=(ALL)       ALL
```
If the line <font color="#ffff00">%wheel ALL=(ALL) ALL</font> is commented out (starts with #), uncomment it by removing the<font color="#ffff00"> #</font>.
Save and exit visudo (in vi/vim, press Esc, then type :<font color="#ffff00">wq!</font> and press Enter).
```Bash
su - <user>
```
Try a sudo command (you'll be prompted for users password):
```Bash
sudo whoami
```
If it outputs root, user now has sudo privileges.

#### Method 2: Directly edit the /etc/sudoers file
This method is less common for granting full sudo access but can be used for specific permissions or if the wheel group method is not desired for some reason.

##### Steps:
Log in as the root user or another user with sudo privileges.
```Bash
ssh root@your_server_ip_address
# OR
su - root
```
Open the sudoers file using visudo:
```Bash
visudo
```
Add the following line to the end of the file:
<font color="#ffff00">gsmash ALL=(ALL) ALL</font>
gsmash: The username you want to grant sudo privileges to.

ALL=(ALL) ALL: This grants gsmash permission to run any command as any user (the first ALL) on any host (the second ALL).

Optional: To allow gsmash to run commands without a password:
<font color="#ffff00">gsmash ALL=(ALL) NOPASSWD: ALL</font>

Caution: This is generally not recommended for security reasons as it bypasses the password prompt for sudo commands.

Save and exit visudo (<font color="#ffff00">in vi/vim, press Esc, then type :wq and press Enter</font>). visudo will check the syntax before saving.

Test sudo access for gsmash:

Switch to the gsmash user:
```Bash
su - gsmash
```
Try a sudo command (you'll be prompted for gsmash's password, unless you used NOPASSWD):
```Bash
sudo whoami
```
If it outputs root, gsmash now has sudo privileges.

---

## How to Update and Upgrade Packages on CentOS 8

To update and upgrade all packages on CentOS 8, use the `dnf` package manager.

**Note:** CentOS 8 reached End of Life on December 31, 2021, and its default repositories are no longer available.  
To fix "Failed to synchronize cache for repo" errors, you need to point your repositories to the CentOS Vault or another mirror.

Update your repository configuration as follows:

1. Backup your current repo files:
```bash
sudo cp -r /etc/yum.repos.d /etc/yum.repos.d.bak
```

2. Download and replace your repo files with CentOS 8 Vault repos:
```bash
sudo sed -i 's/mirrorlist/#mirrorlist/g; s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo
```

3. Clean the dnf cache:
```bash
sudo dnf clean all
```

4. Update the package repository cache and upgrade all installed packages:
```bash
sudo dnf update
```
If you want to upgrade only a specific package, use:
```bash
sudo dnf update <package_name>
```
To upgrade the system to the latest minor release (if available):
```bash
sudo dnf upgrade --refresh
```
After updating, it's a good idea to reboot if the kernel or critical system libraries were upgraded:
```bash
sudo reboot
```
