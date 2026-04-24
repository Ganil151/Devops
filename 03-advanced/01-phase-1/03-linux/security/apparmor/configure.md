 AppArmor is a Linux kernel security module that provides mandatory access control (MAC) to restrict programs' capabilities. Configuring AppArmor on Kali Linux involves enabling, setting up profiles, and managing its status.
### 1. Install AppArmor Packages
Ensure AppArmor is installed on your system. Use the following commands:
```bash
sudo apt update
sudo apt install apparmor apparmor-utils apparmor-profiles apparmor-profiles-extra
```
### 2. Enable AppArmor
AppArmor might not be enabled by default. Check its status and enable it if necessary:

Check if AppArmor is enabled:
```bash
sudo aa-status
```
If AppArmor is not active, enable it in the GRUB bootloader:
Edit the GRUB configuration file:
```bash
sudo nano /etc/default/grub
```
Add or modify the GRUB_CMDLINE_LINUX line to include:
```makefile
GRUB_CMDLINE_LINUX="apparmor=1 security=apparmor"
Update GRUB:
```
```bash
sudo update-grub
```
Reboot the system:
```bash
sudo reboot
```
Verify AppArmor is active:
```bash
sudo aa-status
```
### 3. Load AppArmor Profiles
Profiles define the access rules for specific applications. Enable default profiles or create custom ones:

List available profiles:
```bash
sudo ls /etc/apparmor.d/
```
Enforce or complain mode for a profile:

Enforce mode (strict):
```bash
sudo aa-enforce /etc/apparmor.d/<profile_name>
```
Complain mode (log potential violations but do not block):

```bash
sudo aa-complain /etc/apparmor.d/<profile_name>
```
## 4. Manage Profiles
Create a new profile for an application:
```bash
sudo aa-genprof <application>
```
Manually edit a profile:
```bash
sudo nano /etc/apparmor.d/<profile_name>
```
Reload profiles after editing:
```bash
sudo systemctl reload apparmor
```
## 5. Start and Enable AppArmor Service
To ensure AppArmor starts at boot:
Start the service:
```bash
sudo systemctl start apparmor
```
Enable it to run on boot:
```bash
sudo systemctl enable apparmor
```
## 6. Test and Monitor AppArmor
Check active profiles:
```bash
sudo aa-status
```
View AppArmor logs:
```bash
sudo journalctl | grep apparmor
```
## 7. Debugging and Troubleshooting
If you encounter issues:
Set profiles to complain mode to identify the problem without blocking:
```bash
sudo aa-complain <profile>
```
---

### Creating an AppArmor profile for a specific application involves the following steps. The profile defines the allowed interactions between the application and the system. You can create a profile from scratch or generate one using AppArmor's tools.

Here’s how to create a basic AppArmor profile:

## 1. Generate a Basic Profile Using `aa-genprof`
The easiest way to create a profile for an application is by using `aa-genprof`, which helps you generate a profile by monitoring the application's behavior during its execution. Here's the process:

## Step 1: Start Profile Generation
```bash
sudo aa-genprof <application_name>
```
For example, if you want to create a profile for /usr/bin/example:
```bash
sudo aa-genprof /usr/bin/example
```
This command will launch the aa-genprof tool, which will monitor the application’s actions and allow you to generate rules.

## Step 2: Run the Application
After executing the above command, you'll need to run the application as usual. The aa-genprof tool will log all of the actions the application attempts to perform. You’ll typically need to interact with the application to ensure it performs a wide range of tasks, such as opening files or creating directories.

For example, run:
```bash
/usr/bin/example
```
While the application is running, `aa-genprof` will monitor its behavior and ask you questions about what actions to allow or deny based on observed activity.

## Step 3: Approve or Deny Actions
During the process, aa-genprof will prompt you to either:
Allow actions that the application attempts, or
Deny actions that you don't want the application to perform.
For example, if it attempts to open a file, you can approve it, deny it, or specify permissions (e.g., read-only).

## Step 4: Finalize the Profile
Once you have finished interacting with the application, aa-genprof will prompt you to either save or discard the profile. Save the profile if you’re satisfied with it.

Step 5: Set the Profile to Enforce Mode
After generating the profile, you can set it to Enforce Mode to enforce the restrictions:
```bash
sudo aa-enforce /etc/apparmor.d/<profile_name>
```
For example, if the generated profile is stored as `/etc/apparmor.d/usr.bin.example`, run:
```bash
sudo aa-enforce /etc/apparmor.d/usr.bin.example
```
## 2. Create a Custom Profile Manually
If you prefer to create a profile manually or need more control over the rules, follow these steps:

Step 1: Create a New Profile File
Create a new file in `/etc/apparmor.d/` with the application’s name. For example, for example:
```bash
sudo nano /etc/apparmor.d/usr.bin.example
```

## Step 2: Define the Basic Structure
A basic AppArmor profile might look like this:
```plaintext
# Profile for /usr/bin/example

#include <tunables/global>

profile /usr/bin/example flags=(attach_disconnected) {
  # Allow reading files
  /usr/bin/example r,

  # Allow opening files in /etc
  /etc/* r,

  # Allow access to some directories
  /var/log/** r,

  # Deny access to sensitive directories
  deny /root/** rw,
  deny /home/** rw,
}
```

## Step 3: Define Access Permissions
- `r` stands for read permission.
- `w` stands for write permission.
- `x` stands for execute permission.
- `rw` allows both read and write.

deny explicitly blocks an operation.
You can customize these rules based on your application’s needs.

## Step 4: Load the Profile
After saving the profile, load it into AppArmor:
```bash
sudo apparmor_parser -r /etc/apparmor.d/usr.bin.example
```

## Step 5: Set the Profile to Enforce Mode
To apply the profile in Enforce Mode (which will block any violations):
```bash
sudo aa-enforce /etc/apparmor.d/usr.bin.example
```
## 3. Testing and Adjusting the Profile
After creating and enforcing the profile, test the application to make sure it works as expected. If it encounters permission issues, you can either:

Adjust the profile to grant additional permissions,
Change the profile to complain mode (which only logs violations but doesn’t enforce them) for troubleshooting:
```bash
sudo aa-complain /etc/apparmor.d/usr.bin.example
```

This will allow you to see what actions the application is trying to perform that are being blocked.
Once you identify any issues, adjust the profile and re-enable enforce mode.

Example: Basic Profile for a Custom Application
Here’s an example profile for a custom application `/usr/bin/customapp:`
```plaintext
#include <tunables/global>

profile /usr/bin/customapp flags=(attach_disconnected) {
  # Basic read/write access to /usr/bin and /etc
  /usr/bin/customapp r,
  /etc/customapp.conf r,
  /usr/lib/customapp/** r,

  # Allow logging to /var/log
  /var/log/customapp/** rw,

  # Allow access to /tmp for temporary file storage
  /tmp/** rw,

  # Restrict access to the home directory
  deny /home/** rw,

  # Deny access to critical system files
  deny /root/** rw,
  deny /etc/shadow r,

  # Allow network access (if needed)
  network inet stream,
}
```
## 4. Monitoring and Adjusting the Profile
Once the profile is applied and running, you can monitor AppArmor logs to ensure it’s working as expected:
```bash
sudo journalctl | grep apparmor
```
This will show you any violations or denials.