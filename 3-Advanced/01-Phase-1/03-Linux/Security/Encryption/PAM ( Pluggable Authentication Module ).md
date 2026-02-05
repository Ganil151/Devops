## What is PAM and what is it used for?
PAM is a modular framework built on shared libraries designed to manage user authentication and authorization across various applications. It separates the authentication process from individual applications, allowing for greater flexibility.

Applications such as **_su_**, **_passwd_**, **_login_**, **_gdm_**, **_sshd_**, and **_ftpd_** can all utilize PAM. PAM provides each of these applications with a specialized library to verify user identities and determine whether they have the necessary permissions to access resources.

![Simplified PAM workflow](https://www.group-ib.com/wp-content/uploads/blog2-min-2.png)

Figure 2: Simplified PAM workflow.

The PAM framework offers four main types of modules, each serving a specific purpose:

- **Auth**: Validates user identity.
- **Account**: Handles account verification and ensures the account is in good standing.
- **Password**: Manages password updates, checks password complexity, and helps prevent dictionary attacks.
- **Session**: Manages activities and settings during a service session.

![Detailed PAM workflow](https://www.group-ib.com/wp-content/uploads/blog2-3-min.png)

Figure 3: Detailed PAM workflow.

Each PAM module offers various control flags to manage authentication results:

- **Required**
    - Passed: All subsequent controls are executed. If all are successful, the request is allowed.
    - Failed: The request is denied after all other controls are checked.
- **Requisite**
    - Passed: All subsequent controls are executed. If all are successful, the request is allowed.
    - Failed: The request is immediately denied.
- **Sufficient**
    - Passed: If this module succeeds, no further controls are checked, and the request is allowed.
    - Failed: This module is ignored, and the remaining controls are evaluated.
- **Optional**: The result of this control is executed, but its outcome is ignored.

These control flags dictate how PAM handles each request’s result.

The PAM framework is built on a variety of modules, including:

- **_pam_unix_**: Manages global authentication policies.
- **_pam_ldap_**: Authenticates and authorizes against LDAP servers and handles password changes.
- **_pam_wheel_**: Restricts access to the **_su_** command.
- **_pam_cracklib_**: Tests password strength.
- **_pam_console_**: Grants special privileges to users at the physical console.
- **_pam_tally_**: Locks accounts after too many login attempts.
- **_pam_nologin_**: Disables accounts except for root.
- **_pam_limits_**: Sets limits on system resource usage.
- **_pam_time_**: Restricts access times to services.
- **_pam_access_**: Manages user access.
- **_pam_exec_**: Executes external commands.

PAM’s modular architecture offers extensive configuration options to meet diverse administrative needs.

However, it’s important to remember that PAM is not a panacea for all security issues. Adversaries can potentially exploit or modify PAM modules to gain unauthorized access or create backdoors. Malicious changes to PAM components could be used to steal credentials or inject harmful payloads since PAM does not store passwords and the values exchanged with its modules may be in plain text.

## Exploiting pam_exec for full persistence

The Group-IB DFIR Team identified a new technique not yet included in the MITRE ATT&CK framework, which could lead to use the module **_pam_exec_** to obtain a privileged shell on a host and grant a full persistence to a threat actor.

The **_pam_exec_** module is typically used to run external commands when specified in one of the main PAM module interfaces. For example, you could configure PAM to send an email notification whenever a password change occurs. To achieve this, you would add **_pam_exec_** to the **_/etc/pam.d/passwd_** configuration file, which handles password updates, complexity checks, and dictionary attack prevention.

The configuration for **_pam_exec_** in this context might look like this:

pam_exec.so [debug] [expose_authtok] [seteuid] [quiet] [log=file] command

![An example of pam_exec is used.](https://www.group-ib.com/wp-content/uploads/pluggable-authentication-module-4-min.png)

Figure 4: An example of pam_exec is used.

Adding this line to **_/etc/pam.d/passwd_** will configure the system to use the **_pam_exec.so_** module to execute the script **_mail_notification.sh_** with the real user ID of the calling process (as specified by the **_seteuid_** option) after every local password change:

![pam_exec usage scenario](https://www.group-ib.com/wp-content/uploads/figure-5-pam_exec-usage-scenario-2-min.png)

Figure 5: pam_exec usage scenario.

## Leave no trace: pam_exec and SSH

As previously explained, PAM is a framework that allows each application to connect and access its various modules.

Consider a scenario where OpenSSH—a powerful suite of tools for remotely controlling networked computers and transferring data between them—is configured to use PAM.

The OpenSSH server daemon, **_sshd_**, continuously listens for connection requests from external hosts. When a request is received, **_sshd_** establishes the appropriate connection based on the client tool that is connecting.

What if a threat actor modified the PAM configuration related to SSH authentication to invoke **_pam_exec_** and execute a malicious payload?

In this case, the **_sshd_** PAM module would be altered to include a new line that executes a script named tn.sh via **_pam_exec_** during SSH authentication attempts.

![Screenshot of the sshd pam module after the alteration](https://www.group-ib.com/wp-content/uploads/pluggable-authentication-module-6-min.png)

Figure 6: Screenshot of the sshd pam module after the alteration.

This new line, declared as optional, does not affect the authentication process chain, as previously explained, and will only be executed if the authentication attempt fails.

The executed script is configured as follows:

![Script source code](https://www.group-ib.com/wp-content/uploads/pluggable-authentication-module-7-min.png)

Figure 7: Script source code.

First, the script transfers the date, username, and environment data to the remote server with IP address 10.0.0.142, redirecting the output through a pipe to the tool netcat (also known as nc) on port 1234.

![Examining lines 1 and 2 of the script source code](https://www.group-ib.com/wp-content/uploads/pluggable-authentication-module-8-min.png)

Figure 8: Examining lines 1 and 2 of the script source code (Figure 7).

Next, it sends data related to the environment variables `PAM_RHOST`, `PAM_SERVICE`, and `PAM_USER` to the remote server at IP address 10.0.0.142, redirecting the output through a pipe to the tool `netcat` on port 1234.

![Examining lines 3 and 4 of the script source code](https://www.group-ib.com/wp-content/uploads/pluggable-authentication-module-9-min.png)

Figure 9: Examining lines 3 and 4 of the script source code (Figure 7).

Finally, it sends the same data as before, but this time using the `PAM_USER` variable to define the remote server, making the use of environment variables more flexible.

![Examining line 5 of the script source code](https://www.group-ib.com/wp-content/uploads/pluggable-authentication-module-10-min.png)

Figure 10: Examining line 5 of the script source code (Figure 7).

When an external host attempts to connect via SSH, the script is automatically executed, and data is transferred to the remote host specified by the aforementioned variable, even if the login attempt fails.

![How SSH and PAM can be used to eliminate any traces of data exfiltration within system logs](https://www.group-ib.com/wp-content/uploads/figure-11-elimination-of-exfil-data-using-ssh-and-pam-2-min.png)

Figure 11: How SSH and PAM can be used to eliminate any traces of data exfiltration within system logs.

![Screenshot of data transfer](https://www.group-ib.com/wp-content/uploads/pluggable-authentication-module-12-min.png)

Figure 12: Screenshot of data transfer.

This technique ensures that no traces of data exfiltration appear in system logs, which will only show a failed login attempt. Consequently, it also makes forensic investigations more difficult.

![Screenshot of SSH logs](https://www.group-ib.com/wp-content/uploads/pluggable-authentication-module-13-min.png)

Figure 13: Screenshot of SSH logs.