## **System** 
### `alias` – Create Command Shortcuts
The `alias` command is used to **create custom shortcuts for Linux commands**. It allows you to define a new name (alias) for a command or a sequence of commands, making frequently used or complex commands easier and faster to type.
#### Basic Usage
```bash
alias name='command'
```
- Creates an alias called `name` that runs `command`.
#### Key Features
- **Simplify long commands:** Replace lengthy or complex commands with short, memorable names.
- **Customize your shell:** Tailor your command-line environment to your workflow.
- **Temporary or permanent:** Aliases set in the terminal are temporary; add them to `~/.bashrc`, `~/.zshrc`, or similar files to make them permanent.
#### Examples
**Create a Simple Alias**
```bash
alias ll='ls -alF'
```
- Now typing `ll` will run `ls -alF`.
**Alias with Options**
```bash
alias grep='grep --color=auto'
```
- Always use colored output with `grep`.
**Remove an Alias**
```bash
unalias ll
```
- Removes the `ll` alias for the current session.
**List All Current Aliases**
```bash
alias
```
- Shows all aliases defined in the current shell.
**Make an Alias Permanent**
- Add your alias to `~/.bashrc` or `~/.zshrc`:
  ```bash
  echo "alias gs='git status'" >> ~/.bashrc
  source ~/.bashrc
  ```

**Summary:**  
The `alias` command is a powerful way to streamline your command-line experience by creating shortcuts for frequently used commands. For more, see `man bash` or your shell's documentation.

---
### `apropos` – Search Man Page Names and Descriptions
The `apropos` command is used to **search the short descriptions and names of all available man pages** for a given keyword. It helps you find relevant commands or documentation when you know what you want to do, but not the exact command name.
#### Basic Usage
```bash
apropos <keyword>
```
- Lists all man pages whose names or descriptions match `<keyword>`.
#### Key Features
- **Keyword search:** Finds commands and documentation related to a topic.
- **Broad results:** Searches both command names and their one-line descriptions.
- **Useful for discovery:** Great for exploring available tools and commands.
#### Examples
**Search for Network-Related Commands**
```bash
apropos network
```
- Lists all man pages with "network" in their name or description.

**Find All Commands Related to "disk"**
```bash
apropos disk
```
- Shows commands and documentation about disks.

**Search for File Compression Tools**
```bash
apropos compress
```
- Finds commands related to compression.
#### Advanced Example: Case-Insensitive Search
```bash
apropos -i backup
```
- Performs a case-insensitive search for "backup".

**Summary:**  
The `apropos` command is a quick way to discover Linux commands and documentation related to a specific topic or keyword. It is especially helpful when you’re unsure of the exact command name. For more, see `man apropos`.

---
### `awk` – Pattern Scanning and Processing Language
The `awk` command is a **powerful text processing tool and programming language** used for pattern scanning, data extraction, and reporting. It is especially useful for working with structured text files, such as CSVs, logs, and tables.
#### Basic Usage
```bash
awk '{print $1}' filename
```
- Prints the first field of each line in `filename` (fields are separated by whitespace by default).
#### Key Features
- **Field-based processing:** Automatically splits lines into fields (columns).
- **Pattern matching:** Perform actions only on lines matching a pattern.
- **Arithmetic and string operations:** Supports calculations and string manipulation.
- **Custom field separators:** Use `-F` to specify a different delimiter (e.g., comma, tab).
- **Scripting:** Write complex scripts for data transformation and reporting.
#### Common Examples
**Print the Second Column of a File**
```bash
awk '{print $2}' data.txt
```
**Print Lines Matching a Pattern**
```bash
awk '/error/ {print $0}' logfile.log
```
- Prints lines containing "error".
**Use a Custom Field Separator (e.g., CSV)**
```bash
awk -F, '{print $1, $3}' file.csv
```
- Prints the first and third columns from a comma-separated file.
**Sum Values in a Column**
```bash
awk '{sum += $2} END {print sum}' numbers.txt
```
- Sums the values in the second column.
**Print Lines Where a Value Exceeds a Threshold**
```bash
awk '$3 > 100 {print $1, $3}' report.txt
```
- Prints the first and third columns where the third column is greater than 100.
#### Advanced Example: Format Output
```bash
awk -F: '{printf "%-10s %s\n", $1, $3}' /etc/passwd
```
- Prints the username and user ID from `/etc/passwd`, formatted in columns.

**Summary:**  
The `awk` command is essential for extracting, transforming, and reporting on structured text data in Linux. It is widely used in scripting, data analysis, and automation. For more, see `man awk` or `man gawk`.

---
### `bc` – An Arbitrary Precision Calculator Language
The `bc` command is an **interactive, arbitrary precision calculator language**. It is used for performing mathematical calculations from the command line or within scripts, supporting floating-point arithmetic, variables, and complex expressions.
#### Basic Usage
```bash
bc
```
- Starts the interactive `bc` calculator.
**Calculate an Expression**
```bash
echo "5 * 3.2" | bc
```
- Outputs: `16.0`
#### Key Features
- **Arbitrary precision:** Supports calculations with user-defined precision.
- **Floating-point and integer math:** Handles both types of numbers.
- **Variables and functions:** Use variables, define functions, and perform complex calculations.
- **Scriptable:** Can read expressions from files or standard input.
#### Common Options
- `-l` : Load the standard math library (enables functions like `sine`, `cosine`, `sqrt`, and sets scale to 20).
- `-q` : Quiet mode (no welcome message).
- `<file>` : Read expressions from a file.
#### Examples
**Interactive Mode**
```bash
bc
```
- Type expressions and press Enter to see results.
**Set Decimal Precision**
```bash
echo "scale=4; 10/3" | bc
```
- Outputs: `3.3333`
**Use Math Library Functions**
```bash
echo "scale=5; s(1)" | bc -l
```
- Calculates the sine of 1 radian.
**Define and Use Variables**
```bash
echo "x=7; y=3; x^y" | bc
```
- Outputs: `343`
**Calculate Square Root**
```bash
echo "sqrt(2)" | bc -l
```
- Outputs: `1.41421`

**Summary:**  
The `bc` command is a powerful calculator for both simple and advanced mathematical operations, supporting scripting and interactive use. For more, see `man bc`.

___
### `bg` – Resume a Job in the Background
The `bg` command is used to **resume a suspended job in the background** in the shell. It allows you to continue a stopped process without blocking the terminal, so you can keep working while the job runs.
#### Basic Usage
```bash
bg
```
- Resumes the most recently suspended job in the background.
```bash
bg %job_number
```
- Resumes the specified job (by job number) in the background.
#### Key Features
- **Job control:** Manage multiple processes within the same shell session.
- **Non-blocking:** Lets you continue using the terminal while the job runs.
- **Works with `jobs`, `fg`, and `kill`:** Integrates with other job control commands.
#### Examples
**Suspend a Running Process**
- Press `Ctrl+Z` to suspend the current foreground process.
**Resume the Suspended Job in the Background**
```bash
bg
```
- Continues the most recent job in the background.
**List All Jobs**
```bash
jobs
```
- Shows all jobs with their job numbers.
**Resume a Specific Job**
```bash
bg %2
```
- Resumes job number 2 in the background.

**Summary:**  
The `bg` command is useful for managing jobs in the shell, allowing you to run processes in the background and keep your terminal free for other tasks. For more, see `help bg` or your shell's documentation.

___
### `blkid` – Locate and Print Block Device Attributes
The `blkid` command is a **command-line utility for locating and printing block device attributes** such as device names, UUIDs, filesystem types, and labels. It is useful for identifying disks, partitions, and their properties, especially when configuring filesystems or mounting devices.
#### Basic Usage
```bash
sudo blkid
```
- Lists all block devices and their attributes (UUID, TYPE, LABEL, PARTUUID, etc.).
#### Key Features
- **Identify devices:** Quickly find device names, UUIDs, and filesystem types.
- **Script-friendly:** Output is easy to parse for automation and scripting.
- **Works with all block devices:** Supports disks, partitions, USB drives, and more.

#### Common Options
- `-o <format>` : Specify output format (e.g., `-o list`, `-o export`).
- `-s <tag>` : Show only the specified attribute (e.g., `-s UUID`).
- `-c <file>` : Use a cache file instead of probing devices.
- `<device>` : Show attributes for a specific device (e.g., `/dev/sda1`).
#### Examples
**Show All Block Devices and Their Attributes**
```bash
sudo blkid
```
- Lists all detected block devices with their UUIDs, types, and labels.
**Show Attributes for a Specific Device**
```bash
sudo blkid /dev/sdb1
```
- Displays attributes for `/dev/sdb1` only.
**Show Only UUIDs**
```bash
sudo blkid -s UUID
```
- Lists only the UUIDs of all block devices.

**Show Output in List Format**
```bash
sudo blkid -o list
```
- Displays block device information in a table format.

**Show Output in Export Format**
```bash
sudo blkid -o export
```
- Prints device attributes as environment variable assignments (useful for scripts).

**Summary:**  
The `blkid` command is essential for identifying block devices and their attributes, making it invaluable for mounting, scripting, and system administration tasks. For more, see `man blkid`.

---
### `btop` – Advanced Resource Monitor (C++ Version of bashtop/bpytop)
The `btop` command is a **modern, interactive resource monitor** written in C++. It is the successor to `bashtop` and `bpytop`, providing a fast, feature-rich, and visually appealing terminal UI for monitoring system resources.
#### Basic Usage
```bash
btop
```
- Launches the interactive `btop` interface.
#### Key Features
- **Real-time monitoring:** CPU, memory, disks, network, and processes.
- **Graphical interface:** Colorful, responsive, and highly customizable terminal UI.
- **Process management:** View, filter, and send signals to running processes.
- **Detailed stats:** Per-core CPU usage, temperature sensors, disk I/O, network bandwidth, and more.
- **Configurable:** Change themes, update intervals, sorting, and more from within the UI or config file.
- **Cross-platform:** Works on Linux, macOS, and BSD.
#### Common Controls
- Arrow keys / Mouse: Navigate between panels and processes.
- `F2`: Open options menu.
- `F9`: Open help menu.
- `F10` or `q`: Quit `btop`.
- `m`: Toggle main menu.
- `k` / `j`: Move up/down in process list.
- `Enter`: Show detailed process info.
- `d`: Send SIGTERM to a process.
- `k`: Send SIGKILL to a process.
#### Examples
**Start btop**
```bash
btop
```
- Opens the main dashboard with live system stats.

**Change Theme or Settings**
- Press `F2` to open the options menu and customize appearance or behavior.
**Sort Processes by Memory Usage**
- Use the options menu or sort keys to change process sorting.
#### Installation
- **Debian/Ubuntu:**  
  ```bash
  sudo apt install btop
  ```
- **Fedora:**  
  ```bash
  sudo dnf install btop
  ```
- **Arch Linux:**  
  ```bash
  sudo pacman -S btop
  ```
- **macOS (Homebrew):**  
  ```bash
  brew install btop
  ```

**Summary:**  
The `btop` command is a fast, visually rich, and user-friendly resource monitor for modern Linux systems. It is ideal for real-time system monitoring and process management. For more, see [btop on GitHub](https://github.com/aristocratos/btop) or run `btop --help`.

---
### `cal` – Display a Calendar
The `cal` command is used to **display a simple calendar** in the terminal. By default, it shows the current month, but you can specify a different month and year, or display an entire year.
#### Basic Usage
```bash
cal
```
- Displays the calendar for the current month.
#### Key Features
- **Show any month or year:** View calendars for any month or year.
- **Highlight current day:** The current day is highlighted (if supported by your terminal).
- **Minimal and fast:** Simple output, ideal for quick date reference.
#### Common Options
- `cal <month> <year>` : Show the calendar for a specific month and year (e.g., `cal 7 2025`).
- `cal <year>` : Show the calendar for the entire year.
- `-3` : Show previous, current, and next month.
- `-y` : Show the calendar for the current year.
- `-m <month>` : Show the specified month of the current year.
#### Examples
**Show Calendar for July 2025**
```bash
cal 7 2025
```
**Show Calendar for the Entire Year 2024**
```bash
cal 2024
```
**Show Previous, Current, and Next Month**
```bash
cal -3
```
**Show the Current Year**
```bash
cal -y
```

**Summary:**  
The `cal` command is a quick and easy way to view calendars directly from the terminal. For more, see `man cal`.

---
### `chpasswd` – Change Passwords for Multiple User Accounts
The `chpasswd` command is used by administrators to **change the passwords of multiple user accounts at once** by reading username:password pairs from standard input or a file. It is commonly used for batch password updates and automation.
#### Basic Usage
```bash
echo "username:newpassword" | sudo chpasswd
```
- Sets the password for `username` to `newpassword`.
#### Key Features
- **Batch password changes:** Update passwords for multiple users in one command.
- **Script-friendly:** Accepts input from files or standard input.
- **Supports encrypted passwords:** Can accept already-encrypted passwords with the `-e` option.
#### Common Options
- `-e` : Input passwords are already encrypted (do not encrypt again).
- `-c` : Use the `CRAM-MD5` encryption method (rarely used).
- `--help` : Show help information.
#### Examples
**Change Passwords for Multiple Users**
```bash
echo -e "alice:password1\nbob:password2" | sudo chpasswd
```
- Sets `alice`'s password to `password1` and `bob`'s to `password2`.

**Read Username:Password Pairs from a File**
```bash
sudo chpasswd < users.txt
```
- `users.txt` should contain lines like `username:password`.

**Set Encrypted Passwords**
```bash
sudo chpasswd -e < encrypted_users.txt
```
- Updates passwords using already-encrypted values.

**Summary:**  
The `chpasswd` command is a fast and efficient way for administrators to update passwords for multiple users, especially in scripts or bulk operations. For more, see `man chpasswd`.

---
### `clear` – Clear the Terminal Screen
The `clear` command is used to **clear the terminal screen**, removing all previous output and leaving you with a blank prompt. It is useful for decluttering your workspace or preparing the terminal for new output.
#### Basic Usage
```bash
clear
```
- Clears all text from the terminal and moves the cursor to the top.
#### Key Features
- **Simple and fast:** Instantly clears the visible terminal area.
- **No options needed:** Just type `clear` and press Enter.
- **Works in all shells:** Supported in Bash, Zsh, and most other shells.
#### Examples
**Clear the Terminal**
```bash
clear
```
- Removes all previous output from view.

**Shortcut:**  
You can often use `Ctrl+L` as a keyboard shortcut to achieve the same effect as `clear`.

**Summary:**  
The `clear` command is a quick way to reset your terminal display, making it easier to focus on new tasks or output. For more, see `man clear`.

---
### `cron` – Schedule Recurring Tasks with Cron Jobs
The `cron` system is used to **schedule and automate recurring tasks** (called "cron jobs") on Linux and Unix-like systems. It allows users and administrators to run scripts, commands, or programs at specified times and intervals.
#### How It Works
- The `cron` daemon runs in the background and checks configuration files (crontabs) for scheduled jobs.
- Each user can have their own crontab file.
#### Basic Usage: Edit Your Crontab
```bash
crontab -e
```
- Opens your user’s crontab file in the default editor for editing.
#### Crontab Syntax
Each line in a crontab represents a scheduled job:
```
* * * * * command_to_run
- - - - -
| | | | |
| | | | +----- Day of the week (0-7, Sunday=0 or 7)
| | | +------- Month (1-12)
| | +--------- Day of the month (1-31)
| +----------- Hour (0-23)
+------------- Minute (0-59)
```
#### Examples
**Run a Script Every Day at 2:30 AM**
```
30 2 * * * /home/user/backup.sh
```

**Run a Command Every 5 Minutes**
```
*/5 * * * * /usr/bin/php /home/user/cronjob.php
```

**Run a Task Every Monday at 8:00 AM**
```
0 8 * * 1 /home/user/weekly_report.sh
```

**Run a Command at System Reboot**
```
@reboot /home/user/startup.sh
```
#### Common Commands
- `crontab -l` : List your current cron jobs.
- `crontab -r` : Remove your current crontab.
- `sudo crontab -e -u username` : Edit another user's crontab (as root).
#### Advanced Example: Redirect Output to a Log File
```
0 0 * * * /home/user/cleanup.sh >> /home/user/cleanup.log 2>&1
```
- Runs `cleanup.sh` every day at midnight and appends output (including errors) to `cleanup.log`.

**Summary:**  
The `cron` system is essential for automating regular tasks such as backups, updates, and maintenance. For more, see `man cron` and `man 5 crontab`.

---
### `crontab` – Schedule Commands to Run Periodically
The `crontab` command is used to **schedule commands or scripts to run automatically at specified times and intervals** using the cron daemon. Each user can have their own crontab file to automate recurring tasks like backups, updates, or reports.
#### Basic Usage
```bash
crontab -e
```
- Opens your user’s crontab file in the default editor for editing.
#### Key Features
- **Automate tasks:** Schedule scripts, commands, or programs to run at fixed times.
- **Per-user scheduling:** Each user can manage their own scheduled jobs.
- **Flexible timing:** Supports minute, hour, day of month, month, and day of week fields.
#### Crontab Syntax
```
* * * * * command_to_run
- - - - -
| | | | +----- Day of the week (0-7, Sunday=0 or 7)
| | | +------- Month (1-12)
| | +--------- Day of the month (1-31)
| +----------- Hour (0-23)
+------------- Minute (0-59)
```
#### Examples
**Run a Script Every Day at 2:30 AM**
```
30 2 * * * /home/user/backup.sh
```
**Run a Command Every 5 Minutes**
```
*/5 * * * * /usr/bin/php /home/user/cronjob.php
```
**Run a Task Every Monday at 8:00 AM**
```
0 8 * * 1 /home/user/weekly_report.sh
```
**Run a Command at System Reboot**
```
@reboot /home/user/startup.sh
```
#### Common Commands
- `crontab -l` : List your current cron jobs.
- `crontab -r` : Remove your current crontab.
- `sudo crontab -e -u username` : Edit another user's crontab (as root).
#### Advanced Example: Redirect Output to a Log File
```
0 0 * * * /home/user/cleanup.sh >> /home/user/cleanup.log 2>&1
```
- Runs `cleanup.sh` every day at midnight and appends output (including errors) to `cleanup.log`.

**Summary:**  
The `crontab` command is essential for automating recurring tasks in Linux. It provides flexible scheduling for scripts and commands, improving efficiency and reliability. For more, see `man crontab` and `man 5 crontab`.

---
### `date` – Display or Set the System Date and Time
The `date` command is used to **display the current date and time** or to set the system date and time. It can also format the output in various ways and is commonly used in scripts for timestamps.
#### Basic Usage
```bash
date
```
- Displays the current system date and time.
#### Key Features
- **Custom formatting:** Output the date/time in any format using format specifiers.
- **Set system date/time:** (Requires root privileges.)
- **Timestamps for scripts:** Useful for logging and file naming.
#### Common Options
- `+<format>` : Display the date/time in a custom format (e.g., `date "+%Y-%m-%d %H:%M:%S"`).
- `-u` : Display or set the time in UTC (Coordinated Universal Time).
- `-R` : Output date and time in RFC-5322 format.
- `-s "<string>"` : Set the system date and time (requires `sudo`).
#### Examples
**Show the Current Date and Time**
```bash
date
```
**Show Only the Date (YYYY-MM-DD)**
```bash
date "+%Y-%m-%d"
```
**Show Only the Time (HH:MM:SS)**
```bash
date "+%H:%M:%S"
```
**Show the Date in UTC**
```bash
date -u
```
**Set the System Date and Time (Requires Root)**
```bash
sudo date -s "2025-06-08 14:30:00"
```
- Sets the system date and time to June 8, 2025, 14:30:00.

**Summary:**  
The `date` command is essential for displaying and setting the system date and time, as well as formatting timestamps for scripts and logs. For more, see `man date`.

---
### `df` – Display Disk Space Usage
The `df` (disk free) command is used to **display the amount of available disk space** on the file system. It shows information about total space, used space, available space, and mount points for all mounted filesystems.
##### Basic Usage
```bash
df
```
- Shows disk space usage for all mounted filesystems in 1K blocks.
##### Common Options
- `-h` : Human-readable format (e.g., MB, GB)
- `-a` : Include pseudo, duplicate, and inaccessible filesystems
- `-T` : Show filesystem type
- `-i` : Show inode information instead of block usage
- `-t <type>` : Limit listing to filesystems of a specific type (e.g., ext4, tmpfs)
- `--total` : Produce a grand total
##### Example: Human-Readable Output
```bash
df -h
```
- Displays disk usage in a human-readable format (e.g., 2.3G, 500M).
##### Example: Show Filesystem Types
```bash
df -Th
```
- Shows disk usage along with the type of each filesystem.
##### Example: Show Inode Usage
```bash
df -i
```
- Displays inode usage instead of block usage (useful for systems with many small files).
##### Example: Show Only ext4 Filesystems
```bash
df -t ext4 -h
```
- Lists only ext4 filesystems in human-readable format.
##### Example: Show Disk Usage for a Specific Directory
```bash
df -h /home
```
- Shows disk usage for the filesystem containing `/home`.
##### Advanced Example: Combine with `grep` to Filter Output
```bash
df -h | grep '^/dev/'
```
- Shows only physical disk partitions (those starting with `/dev/`).
##### Advanced Example: Grand Total of All Filesystems
```bash
df -h --total
```
- Adds a summary line with the total disk usage across all filesystems.
**Summary:**  
The `df` command is essential for monitoring disk space usage on Linux systems. With its various options, you can get detailed, filtered, and human-friendly reports on storage utilization, filesystem types, and inode usage. For more, see `man df`.

---
### `dstat` – Versatile Resource Statistics Viewer dstat
The `dstat` command is used to **view real-time statistics for system resources** such as processes, memory, paging, disk I/O, network, CPU, and more. It combines the functionality of tools like `vmstat`, `iostat`, `netstat`, and `ifstat` into a single, flexible utility.
##### Basic Usage
```bash
dstat
```
- Displays a live summary of CPU, disk, network, paging, and system stats.
##### Common Options
- `-c` : Show CPU stats
- `-d` : Show disk stats
- `-n` : Show network stats
- `-m` : Show memory stats
- `-s` : Show swap stats
- `-t` : Show timestamps
- `-r` : Show I/O request stats
- `-p` : Show process stats
- `--top-cpu` : Show top CPU-consuming processes
- `--top-io` : Show top I/O-consuming processes
##### Example: Show CPU, Disk, and Network Stats
```bash
dstat -cdn
```
- Displays CPU, disk, and network statistics in real time.
##### Example: Show All Available Stats with Timestamps
```bash
dstat -tam
```
- Shows timestamps, all CPU, disk, and memory stats.
##### Example: Show Top CPU and I/O Processes
```bash
dstat --top-cpu --top-io
```
- Displays the processes using the most CPU and I/O resources.
##### Example: Log Output to a CSV File
```bash
dstat -cdngyt --output system_stats.csv
```
- Logs CPU, disk, network, paging, and system stats to a CSV file for later analysis.

**Summary:**  
The `dstat` command is a powerful, all-in-one tool for real-time system monitoring. It’s ideal for troubleshooting, performance analysis, and capacity planning, providing a comprehensive view of system activity. For more, see `man dstat`.

---
### `du` – Estimate File and Directory Space Usage
The `du` (disk usage) command is used to **estimate and summarize file and directory space usage**. It helps you find out how much disk space is being used by files and directories.
##### Basic Usage
```bash
du
```
- Shows the disk usage of each directory and subdirectory, in kilobytes, starting from the current directory.
##### Common Options
- `-h` : Human-readable format (e.g., KB, MB, GB)
- `-s` : Display only the total size for each argument (summary)
- `-a` : Show sizes for all files, not just directories
- `-c` : Produce a grand total
- `-d N` : Limit the depth of directory traversal to N levels
- `--max-depth=N` : Same as `-d N`, show subdirectories up to N levels deep
- `-x` : Skip directories on different filesystems
##### Human-Readable Output
```bash
du -h
```
- Displays sizes in a human-readable format (e.g., 1K, 234M, 2G).
##### Show Only the Total Size of a Directory
```bash
du -sh /var/log
```
- Shows only the total size of `/var/log` in a human-readable format.
##### Show Sizes for All Files and Directories
```bash
du -ah /etc
```
- Lists the size of every file and directory under `/etc`.
##### Limit Output to Top-Level Directories
```bash
du -h --max-depth=1 /home
```
- Shows the size of each directory directly under `/home`, but not deeper subdirectories.
#####  Grand Total of Multiple Directories
```bash
du -ch /usr /var
```
- Shows the size of `/usr` and `/var`, and prints a grand total at the end.
##### Advanced Example: Find Largest Directories
```bash
du -h --max-depth=1 / | sort -hr | head -n 10
```
- Lists the top 10 largest directories in the root filesystem.

**Summary:**  
The `du` command is essential for analyzing disk space usage by files and directories. With its options, you can get detailed, summarized, and human-friendly reports to help manage storage efficiently. For more, see `man du`.

--- 
### `env` – Run a Command in a Modified Environment
The `env` command is used to **run a command with a modified set of environment variables**. It can also display the current environment or clear all environment variables before running a command.
#### Basic Usage
```bash
env command
```
- Runs `command` with the current environment.
#### Key Features
- **Set or override environment variables:** Temporarily change variables for a single command.
- **Clear the environment:** Run a command with a completely empty environment.
- **Display environment:** Show all current environment variables.
#### Common Options
- `-i` : Start with an empty environment (ignore inherited variables).
- `VAR=value` : Set or override an environment variable for the command.
#### Examples
**Show All Environment Variables**
```bash
env
```
- Lists all current environment variables.
**Run a Command with a Temporary Variable**
```bash
env VAR=value command
```
- Runs `command` with `VAR` set to `value` for that execution only.
**Clear the Environment and Run a Command**
```bash
env -i bash
```
- Starts a new Bash shell with no environment variables set.

**Use env to Find a Command in the PATH**
```bash
env python3 --version
```
- Runs `python3` as found in the current `PATH`.

**Summary:**  
The `env` command is useful for testing, scripting, and running commands with custom or minimal environments. For more, see `man env`.

---
### `fdisk` – Manipulate the Disk Partition Table
The `fdisk` command is a **menu-driven utility for creating, deleting, resizing, and managing disk partitions** on Linux systems. It works with MBR (Master Boot Record) partition tables and is commonly used for preparing disks before formatting and mounting.
#### Basic Usage
```bash
sudo fdisk /dev/sdX
```
- Opens the partition table editor for the specified disk (replace `sdX` with your disk, e.g., `sda`).
#### Key Features
- **Create and delete partitions:** Add or remove primary and extended partitions.
- **Change partition type:** Set the partition type (e.g., Linux, swap, EFI).
- **View partition table:** List existing partitions and their details.
- **Write changes:** Save modifications to the disk.
#### Common Commands Inside `fdisk`
- `m` : Show help menu.
- `p` : Print the current partition table.
- `n` : Add a new partition.
- `d` : Delete a partition.
- `t` : Change a partition's type.
- `a` : Toggle a bootable flag.
- `w` : Write changes and exit.
- `q` : Quit without saving changes.
#### Examples
**List All Partitions on a Disk**
```bash
sudo fdisk -l /dev/sda
```
- Shows the partition table for `/dev/sda`.
**Start Partitioning a Disk**
```bash
sudo fdisk /dev/sdb
```
- Opens the interactive menu for `/dev/sdb`.

**Create a New Partition (Interactive)**
1. Run `sudo fdisk /dev/sdb`
2. Press `n` to create a new partition.
3. Follow the prompts for partition type, number, start, and end.
4. Press `w` to write changes.
**Delete a Partition (Interactive)**
5. Run `sudo fdisk /dev/sdb`
6. Press `d` and select the partition number.
7. Press `w` to save changes.
#### Advanced Example: Scripted Partition Table Listing
```bash
sudo fdisk -l
```
- Lists all disks and their partitions on the system.

**Warning:**  
Be careful when using `fdisk`—modifying partitions can result in data loss if not done correctly. Always back up important data before making changes.

**Summary:**  
The `fdisk` command is a classic tool for managing disk partitions on Linux. It is essential for disk setup, resizing, and troubleshooting. For more, see `man fdisk`.

---
### `fg` – Bring a Job to the Foreground
The `fg` command is used to **resume a suspended or background job in the foreground** in the shell. It allows you to bring a process back to the terminal, so you can interact with it directly.
#### Basic Usage
```bash
fg
```
- Brings the most recently suspended or backgrounded job to the foreground.
```bash
fg %job_number
```
- Brings the specified job (by job number) to the foreground.
#### Key Features
- **Job control:** Manage multiple processes within the same shell session.
- **Interactive:** Allows you to interact with the process as if it were started normally.
- **Works with `jobs`, `bg`, and `kill`:** Integrates with other job control commands.
#### Examples
**Suspend a Running Process**
- Press `Ctrl+Z` to suspend the current foreground process.
**Send a Job to the Background**
```bash
bg
```
- Resumes the suspended job in the background.
**Bring the Background Job to the Foreground**
```bash
fg
```
- Brings the most recent job to the foreground.

**List All Jobs**
```bash
jobs
```
- Shows all jobs with their job numbers.

**Bring a Specific Job to the Foreground**
```bash
fg %2
```
- Brings job number 2 to the foreground.

**Summary:**  
The `fg` command is useful for managing jobs in the shell, allowing you to bring background or suspended processes back to the foreground for interaction. For more, see `help fg` or your shell's documentation.
___
### `free` – Display Memory Usage
The `free` command is used to **display the amount of free and used memory** in the system, including physical RAM, swap, and buffers used by the kernel.
#### Basic Usage
```bash
free
```
- Shows memory usage in kilobytes (KB) by default.
#### Common Options
- `-h` : Human-readable format (e.g., MB, GB)
- `-m` : Show output in megabytes
- `-g` : Show output in gigabytes
- `-b` : Show output in bytes
- `-s N` : Continuously display memory usage every N seconds
- `-t` : Show a total line (sum of physical and swap)
- `-c N` : Repeat the output N times
#### Human-Readable Output
```bash
free -h
```
- Displays memory usage in a human-readable format (e.g., 1.5G, 512M).
####  Show Output in Megabytes
```bash
free -m
```
- Shows memory usage in megabytes.
####  Continuously Monitor Memory Usage
```bash
free -h -s 2
```
- Updates the memory usage every 2 seconds.
####  Show Total Memory (RAM + Swap)
```bash
free -h -t
```
- Adds a total line at the bottom for combined RAM and swap usage.
#### Advanced Example: Log Memory Usage Over Time
```bash
free -m -s 5 -c 12 > memory_log.txt
```
- Logs memory usage in megabytes every 5 seconds, 12 times, and saves the output to `memory_log.txt`.
**Summary:**  
The `free` command is essential for quickly checking system memory and swap usage. With its options, you can get detailed, human-friendly, and real-time reports to help monitor and troubleshoot memory issues. For more, see `man free`.  

---
### `Glances` – Cross-Platform Real-Time System Monitoring
`Glances` is a powerful, cross-platform monitoring tool that provides a real-time, comprehensive overview of system resources. It combines features of `top`, `htop`, and more, displaying CPU, memory, disk, network, sensors, file system, and process information in a single, interactive terminal dashboard.
#### Basic Usage
```bash
glances
```
- Launches the interactive Glances interface, updating stats in real time.
#### Key Features
- **Multi-resource monitoring:** CPU, memory, swap, disk I/O, network, file systems, sensors, and more.
- **Color-coded alerts:** Highlights resource bottlenecks and warnings.
- **Web server mode:** Monitor remotely via a web browser.
- **API/Export:** Can export stats to files, databases, or monitoring systems.
- **Cross-platform:** Works on Linux, macOS, Windows, and even in Docker.
#### Common Options
- `-w` : Start Glances in web server mode (default port 61208).
- `-C <file>` : Use a custom configuration file.
- `-t <seconds>` : Set refresh rate (default: 1 second).
- `-s` : Start in server mode for remote monitoring.
- `-c <address>` : Connect as a client to a remote Glances server.
- `--export <type>` : Export stats (CSV, InfluxDB, Prometheus, etc.).
#### Example: Start Web Server for Remote Monitoring
```bash
glances -w
```
- Access via `http://<server-ip>:61208` in a browser.
#### Example: Monitor a Remote System
On the remote server:
```bash
glances -s
```
On the client:
```bash
glances -c <server-ip>
```
#### Example: Export Stats to CSV
```bash
glances --export csv --export-csv-file /tmp/glances.csv
```
- Saves stats to a CSV file for later analysis.
#### Interactive Controls
- Press `h` for help.
- Press `q` to quit.
- Use arrow keys to scroll process list.
- Press `1` to toggle per-core CPU stats.
- Press `m`, `d`, `n`, `f`, `i`, `y` to toggle memory, disk, network, file system, sensors, and system info.
**Summary:**  
Glances is a versatile, extensible, and user-friendly system monitoring tool. It is ideal for both local and remote monitoring, providing a unified view of all major system resources. For more, see `man glances` or [Glances documentation](https://nicolargo.github.io/glances/).

---
### `groups` – Print the Groups a User Is In
The `groups` command is used to **display the group memberships for a user**. It shows all groups that the specified user (or the current user, if none is specified) belongs to.
#### Basic Usage
```bash
groups
```
- Shows all groups for the current user.
```bash
groups username
```
- Shows all groups for the specified user.
#### Key Features
- **Check group membership:** Useful for verifying permissions and access control.
- **Works for any user:** Can display groups for yourself or any other user.

#### Examples
**Show Groups for the Current User**
```bash
groups
```
- Outputs something like: `alice sudo developers`
**Show Groups for Another User**
```bash
groups bob
```
- Outputs all groups that `bob` is a member of.

**Summary:**  
The `groups` command is a quick way to check which groups a user belongs to, which is important for understanding permissions and access rights. For more, see `man groups`.

___
### `history` – View Previously Executed Commands
The `history` command is used to **display a list of commands previously entered in the current shell session**. It helps users recall, repeat, or reuse past commands, making command-line work more efficient.
#### Basic Usage
```bash
history
```
- Lists previously executed commands with line numbers.
#### Key Features
- **Recall commands:** Easily find and reuse past commands.
- **Search history:** Use keyboard shortcuts (like `Ctrl+R`) to search interactively.
- **Execute by number:** Run a previous command by its history number.
- **Clear or manage history:** Delete or edit history entries.
#### Common Options
- `-c` : Clear the command history.
- `-d <offset>` : Delete the history entry at the specified offset.
- `-a` : Append new history lines to the history file.
- `-r` : Read the history file and append its contents to the history list.
- `-w` : Write the current history to the history file.
#### Examples
**Show the Last 20 Commands**
```bash
history 20
```
- Displays the 20 most recent commands.
**Repeat a Command by Number**
```bash
!105
```
- Executes command number 105 from the history list.
**Search History Interactively**
- Press `Ctrl+R` and start typing to search backward through history.
**Clear the History**
```bash
history -c
```
- Removes all entries from the current session's history.
**Delete a Specific Entry**
```bash
history -d 42
```
- Deletes entry number 42 from the history.

**Summary:**  
The `history` command is essential for reviewing, searching, and reusing previous commands in the shell. It improves productivity and helps avoid retyping complex commands. For more, see `man history` or your shell's documentation.

---
### `hostname` – Show or Set the System’s Host Name
The `hostname` command is used to **display or set the system’s host name**. The host name is the label assigned to a device on a network and is used to identify the system.
#### Basic Usage
```bash
hostname
```
- Displays the current host name of the system.
#### Key Features
- **Show host name:** Quickly check the system’s current host name.
- **Set host name:** Change the host name (requires root privileges).
- **Display FQDN:** Show the fully qualified domain name.
#### Common Options
- `-f` : Show the fully qualified domain name (FQDN).
- `-A` : Show all FQDNs of the machine.
- `-i` : Show the IP address(es) for the host name.
- `-I` : Show all assigned network addresses.
- `-s` : Show the short host name (default).
- `-d` : Show the DNS domain name.
#### Examples
**Show the Current Host Name**
```bash
hostname
```
**Show the Fully Qualified Domain Name**
```bash
hostname -f
```
**Set the Host Name (Requires Root)**
```bash
sudo hostname new-hostname
```
- Changes the system’s host name to `new-hostname` (temporary until reboot).
**Show All Network Addresses**
```bash
hostname -I
```

**Summary:**  
The `hostname` command is useful for viewing or setting the system’s network name, which is important for identification on a network. For more, see `man hostname`.

---
### `htop` – Interactive Process Viewer and Manager
The `htop` command is an **interactive, real-time process viewer** for Unix systems. It is a more advanced and user-friendly alternative to `top`, providing a colorful, ncurses-based interface for monitoring system resources and managing processes.
##### Basic Usage
```bash
htop
```
- Launches the interactive `htop` interface, showing CPU, memory, swap usage, and a list of running processes.
##### Key Features and Controls
- Use the **arrow keys** to navigate the process list.
- Press `F3` to search for a process.
- Press `F4` to filter processes.
- Press `F5` to toggle tree view (shows process hierarchy).
- Press `F6` to sort by different columns (CPU, memory, etc.).
- Press `F9` to kill a process (select the signal to send).
- Press `F10` or `q` to quit.
- Use the mouse to select and interact with items (if supported).
##### Common Options
- `-u <user>` : Show only processes for a specific user.
- `-p <pid>` : Show only the specified process IDs.
- `-s <column>` : Sort by a specific column (e.g., `PERCENT_MEM`).
- `-d <delay>` : Set the delay between updates (in tenths of a second).
- `-C` : Start htop without color.
##### Example: Show Processes for a Specific User
```bash
htop -u username
```
- Displays only the processes owned by `username`.
##### Example: Sort by Memory Usage on Start
```bash
htop -s PERCENT_MEM
```
- Starts `htop` sorted by memory usage.
##### Example: Monitor Specific Processes
```bash
htop -p 1234,5678
```
- Shows only the processes with PIDs 1234 and 5678.

**Summary:**  
The `htop` command is a powerful, interactive tool for monitoring system performance and managing processes. It offers an intuitive interface, easy navigation, and advanced filtering and sorting options. For more, see `man htop`.

---
### `id` – Print User and Group Information
The `id` command is used to **display the user ID (UID), group ID (GID), and group memberships** for the current user or a specified username. It is useful for checking user and group identities, especially in scripts and system administration.
#### Basic Usage
```bash
id
```
- Shows the UID, GID, and all group memberships for the current user.
#### Key Features
- **Show user and group IDs:** Displays numeric and symbolic names.
- **Check group membership:** See all groups a user belongs to.
- **Specify a user:** View information for another user.
#### Examples
**Show Your Own User and Group Info**
```bash
id
```
- Outputs something like: `uid=1000(alice) gid=1000(alice) groups=1000(alice),27(sudo),1001(developers)`
**Show Info for Another User**
```bash
id bob
```
- Displays UID, GID, and groups for user `bob`.
**Show Only the User ID**
```bash
id -u
```
- Prints the numeric user ID.
**Show Only the Group ID**
```bash
id -g
```
- Prints the numeric group ID.
**Show Only Group Memberships**
```bash
id -G
```
- Prints all group IDs the user belongs to.

**Summary:**  
The `id` command is a quick way to check user and group identities and memberships, which is helpful for permissions, scripting, and troubleshooting. For more, see `man id`.

___
### `iotop` – Interactive I/O Viewer
The `iotop` command is used to **monitor disk I/O usage by processes in real time**. It provides an interactive, top-like interface that shows which processes are responsible for the most disk read and write activity.
##### Basic Usage
```bash
sudo iotop
```
- Launches the interactive `iotop` interface, displaying real-time disk I/O usage by process. (Root privileges are usually required.)
##### Common Options
- `-o` : Show only processes or threads actually doing I/O.
- `-a` : Accumulate all I/O instead of only the current speed.
- `-b` : Run in batch mode (suitable for logging or scripting).
- `-d <seconds>` : Set the delay between updates (default is 1 second).
- `-p <PID>` : Monitor only specific process IDs.
- `-u <USER>` : Show only processes for a specific user.

##### Key Features and Controls
- Use the **arrow keys** to scroll through the list of processes.
- Press `q` to quit.
- Columns include: PID, user, disk read, disk write, swapin, IO%, and command.
##### Example: Show Only Processes Doing I/O
```bash
sudo iotop -o
```
- Displays only processes currently performing disk I/O.
##### Example: Accumulate I/O Over Time
```bash
sudo iotop -a
```
- Shows total I/O usage for each process since `iotop` started.
##### Example: Monitor Specific User
```bash
sudo iotop -u username
```
- Displays I/O activity for processes owned by `username`.
##### Example: Run in Batch Mode and Save Output
```bash
sudo iotop -b -n 10 > iotop_log.txt
```
- Runs `iotop` in batch mode for 10 iterations and saves the output to a file.

**Summary:**  
The `iotop` command is a powerful, interactive tool for monitoring real-time disk I/O usage by process. It helps identify which applications are causing heavy disk activity, making it invaluable for troubleshooting performance issues. For more, see `man iotop`.

---
### `iostat` – Storage I/O Statistics
The `iostat` (input/output statistics) command is used to **monitor system input/output device loading** by observing the time the devices are active in relation to their average transfer rates. It helps identify performance issues with disks and storage subsystems.
##### Basic Usage
```bash
iostat
```
- Displays CPU statistics and I/O statistics for all devices since the last reboot.
##### Common Options
- `-d` : Display only device utilization report.
- `-k`, `-m`, `-t` : Show statistics in kilobytes, megabytes, or include a timestamp.
- `-x` : Show extended statistics (more detailed device info).
- `-p [device]` : Show statistics for partitions.
- `<interval> <count>` : Update the output every `<interval>` seconds, for `<count>` times.
##### Example: Show Extended Device Statistics
```bash
iostat -x
```
- Displays detailed statistics for each device (utilization, await, svctm, %util, etc.).
##### Example: Show Output in Megabytes
```bash
iostat -m
```
- Shows statistics in megabytes per second.
##### Example: Show Statistics Every 2 Seconds
```bash
iostat 2
```
- Continuously updates the statistics every 2 seconds.
##### Example: Show 5 Updates, 1 Second Apart
```bash
iostat 1 5
```
- Displays 5 reports, 1 second apart.
##### Example: Show Statistics for a Specific Device
```bash
iostat -p sda
```
- Shows statistics for the `sda` device and its partitions.
**Summary:**  
The `iostat` command is a valuable tool for monitoring storage I/O performance and identifying bottlenecks. It provides detailed reports on CPU and device utilization, helping with performance analysis and troubleshooting. For more, see `man iostat`.

---
### `jobs` – List Active Jobs
The `jobs` command is used to **display the status of jobs started in the current shell session**. It shows background and suspended jobs, along with their job numbers and states.
#### Basic Usage
```bash
jobs
```
- Lists all jobs associated with the current shell.
#### Key Features
- **Job control:** See which jobs are running, stopped, or in the background.
- **Job numbers:** Each job is assigned a number for use with `bg`, `fg`, or `kill`.
- **Status display:** Shows whether jobs are running, stopped, or terminated.
#### Examples
**List All Active Jobs**
```bash
jobs
```
- Shows all jobs with their status (e.g., Running, Stopped).
**List Jobs with Process IDs**
```bash
jobs -l
```
- Displays jobs with their process IDs (PIDs).

**Summary:**  
The `jobs` command is useful for managing multiple processes in the shell, especially when using job control features like `bg` and `fg`. For more, see `help jobs` or your shell's documentation.

___
### `journalctl` – Query the systemd Journal
The `journalctl` command is used to **view and query logs collected by the systemd journal** on Linux systems that use `systemd`. It provides powerful filtering, searching, and formatting options for system logs, including boot messages, service logs, kernel logs, and more.
#### Basic Usage
```bash
journalctl
```
- Displays all journal entries in chronological order.
#### Key Features
- **Unified logging:** Access logs from the kernel, services, and applications in one place.
- **Powerful filtering:** Filter logs by time, service, priority, boot, user, and more.
- **Persistent logs:** View logs from previous boots (if persistent storage is enabled).
- **Follow mode:** Monitor logs in real time.
#### Common Options
- `-b` : Show logs from the current boot.
- `-k` : Show only kernel messages.
- `-u <unit>` : Show logs for a specific systemd unit (e.g., `-u sshd`).
- `-p <priority>` : Show messages of a specific priority (e.g., `-p err`).
- `-f` : Follow new log entries (like `tail -f`).
- `--since` / `--until` : Show logs within a specific time range.
- `-o <format>` : Set output format (e.g., `short`, `json`, `cat`).
#### Examples
**Show Logs from the Current Boot**
```bash
journalctl -b
```
**Show Logs for a Specific Service**
```bash
journalctl -u nginx
```
**Show Only Error Messages**
```bash
journalctl -p err
```
**Follow Logs in Real Time**
```bash
journalctl -f
```
**Show Kernel Messages Only**
```bash
journalctl -k
```
**Show Logs Since Yesterday**
```bash
journalctl --since "yesterday"
```
**Show Logs in JSON Format**
```bash
journalctl -o json-pretty
```
#### Advanced Example: Filter by Time and Service
```bash
journalctl -u sshd --since "2025-06-01 00:00:00" --until "2025-06-08 23:59:59"
```
- Shows logs for the `sshd` service between June 1 and June 8, 2025.

**Summary:**  
The `journalctl` command is the primary tool for querying and analyzing system logs on `systemd`-based Linux systems. It supports advanced filtering, searching, and formatting for efficient troubleshooting and monitoring. For more, see `man journalctl`.

---
### `kill` – Terminate a Process
The `kill` command is used to **send signals to processes**, most commonly to terminate (kill) them. By default, it sends the `SIGTERM` signal, which gracefully asks a process to stop. You can also send other signals, such as `SIGKILL` to force termination.
#### Basic Usage
```bash
kill <PID>
```
- Sends the default `SIGTERM` signal to the process with the specified PID (process ID).
#### Key Features
- **Terminate processes:** Gracefully or forcefully stop running processes.
- **Send different signals:** Can send any signal, not just termination.
- **Works with multiple PIDs:** Can target several processes at once.
#### Common Options
- `-9` : Send `SIGKILL` (force kill, cannot be ignored).
- `-15` : Send `SIGTERM` (default, graceful termination).
- `-l` : List all available signals.
- `-s <signal>` : Specify the signal by name or number.
#### Examples
**Gracefully Terminate a Process**
```bash
kill 1234
```
- Sends `SIGTERM` to process with PID 1234.

**Forcefully Kill a Process**
```bash
kill -9 1234
```
- Sends `SIGKILL` to process 1234 (cannot be caught or ignored).

**Send a Specific Signal by Name**
```bash
kill -SIGSTOP 1234
```
- Stops (pauses) the process with PID 1234.

**Kill Multiple Processes**
```bash
kill 1234 5678 91011
```
- Sends `SIGTERM` to all listed PIDs.

**List All Signals**
```bash
kill -l
```
- Displays all available signals.

**Summary:**  
The `kill` command is essential for managing processes in Linux, allowing you to terminate or control them by sending signals. For more, see `man kill`.

---
### `killall` – Kill Processes by Name
The `killall` command is used to **send a signal to all processes running a specified command name**. It is useful for terminating multiple instances of a process at once, rather than by individual PID.
#### Basic Usage
```bash
killall processname
```
- Sends the default `SIGTERM` signal to all processes named `processname`.
#### Key Features
- **Kill by name:** No need to look up PIDs; just specify the process name.
- **Send any signal:** Can send signals other than `SIGTERM` (e.g., `SIGKILL`).
- **Target specific users:** Optionally kill only processes owned by a specific user.
- **Interactive mode:** Prompt before killing each process.
#### Common Options
- `-9` : Send `SIGKILL` (force kill).
- `-s <signal>` : Specify the signal to send (by name or number).
- `-u <user>` : Kill only processes belonging to the specified user.
- `-i` : Interactive mode; prompt before killing.
- `-v` : Verbose output; report each killed process.
- `-q` : Quiet mode; suppress output.
#### Examples
**Kill All Instances of a Process**
```bash
killall firefox
```
- Terminates all running `firefox` processes.
**Force Kill All Instances**
```bash
killall -9 python
```
- Forcefully kills all `python` processes.
**Kill Processes for a Specific User**
```bash
killall -u alice bash
```
- Kills all `bash` processes owned by user `alice`.
**Prompt Before Killing**
```bash
killall -i nginx
```
- Asks for confirmation before killing each `nginx` process.

**Summary:**  
The `killall` command is a convenient way to terminate all processes by name, with options for force, user targeting, and interactive confirmation. For more, see `man killall`.

---
### `last` – Show a Listing of Last Logged-In Users
The `last` command is used to **display a list of the most recent user logins** on a Linux system. It reads from the `/var/log/wtmp` file, which logs all logins and logouts.
##### Basic Usage
```bash
last
```
- Shows a list of recent user logins, including username, terminal, IP address, login time, and duration.
##### Common Options
- `-n <number>` : Show only the specified number of recent entries.
- `-a` : Display the hostname on the last column.
- `-x` : Show system shutdown, runlevel, and reboot entries as well.
- `-f <file>` : Use a different log file instead of `/var/log/wtmp`.
- `-R` : Suppress the display of the hostname field.
##### Show the Last 5 Logins
```bash
last -n 5
```
- Displays only the 5 most recent login sessions.
##### Show Reboot and Shutdown Events
```bash
last -x
```
- Includes system shutdown and reboot events in the output.f
#### Example: Show Logins for a Specific User

```bash
last username
```
- Shows only the login history for the specified user.
##### Show Hostnames in the Last Column
```bash
last -a
```
- Moves the hostname or IP address to the last column for easier reading.
##### Advanced Example: Use a Custom Log File
```bash
last -f /var/log/btmp
```
- Reads from the `/var/log/btmp` file, which logs failed login attempts.
**Summary:**  
The `last` command is useful for auditing user activity, monitoring logins, and tracking system reboots or shutdowns. It helps administrators review login history and detect unusual access patterns. For more, see `man last`.

---
### `logger` – Enter Messages into the System Log
The `logger` command is used to **add messages to the system log (syslog)** from the command line or scripts. It is useful for custom logging, debugging, and recording events or status messages in system logs.
#### Basic Usage
```bash
logger "This is a test message"
```
- Adds "This is a test message" to the system log.
#### Key Features
- **Custom log entries:** Send arbitrary messages to syslog.
- **Script integration:** Log events or errors from scripts and automation.
- **Specify facility and priority:** Control where and how messages are logged.
- **Tag messages:** Add a custom tag to identify the source.
#### Common Options
- `-t <tag>` : Add a tag to the log entry (e.g., `-t backup`).
- `-p <facility.priority>` : Specify syslog facility and priority (e.g., `-p user.info`).
- `-f <file>` : Log the contents of a file.
- `-i` : Log the process ID (PID) with each message.
#### Examples
**Log a Simple Message**
```bash
logger "Backup completed successfully"
```
**Log with a Custom Tag**
```bash
logger -t myscript "Script started"
```
**Log with Specific Facility and Priority**
```bash
logger -p local0.warning "Low disk space warning"
```
**Log the Contents of a File**
```bash
logger -f /var/log/custom.log
```

**Summary:**  
The `logger` command is a convenient way to write messages to the system log from the command line or scripts, aiding in monitoring, debugging, and auditing. For more, see `man logger`.

___
### `lsblk` – List Block Devices
The `lsblk` command is used to **list information about all available or the specified block devices** on your system. Block devices include hard drives, SSDs, USB drives, partitions, and LVM volumes.
#### Basic Usage
```bash
lsblk
```
- Displays a tree-like view of all block devices and their partitions.
#### Key Features
- **Device overview:** Shows device names, types, sizes, mount points, and relationships.
- **Partition mapping:** Visualizes which partitions belong to which disks.
- **LVM and RAID support:** Displays logical volumes and RAID arrays.
- **Script-friendly:** Output can be customized for use in scripts.
#### Common Options
- `-a` : Show all devices, including empty ones.
- `-f` : Show filesystem information (type, label, UUID, mountpoint).
- `-l` : List output (no tree view).
- `-o <columns>` : Specify which columns to display (e.g., `lsblk -o NAME,SIZE,TYPE,MOUNTPOINT`).
- `-p` : Print full device paths (e.g., `/dev/sda`).
- `-d` : Show only top-level devices (no partitions).
#### Examples
**Show Filesystem Info for All Devices**
```bash
lsblk -f
```
**Show Only Device Names and Sizes**
```bash
lsblk -o NAME,SIZE
```
**Show All Devices, Including Empty**
```bash
lsblk -a
```
**List Output (No Tree)**
```bash
lsblk -l
```

**Summary:**  
The `lsblk` command is essential for viewing and understanding the layout of storage devices and partitions on a Linux system. For more, see `man lsblk`.

___
### `lsof` – List Open Files and the Corresponding Processes
The `lsof` (List Open Files) command is used to **display information about files opened by processes**. In Unix-like systems, everything is a file—including regular files, directories, sockets, pipes, and devices—so `lsof` can show which processes are using which resources.
#### Basic Usage
```bash
lsof
```
- Lists all open files and the processes that opened them.
#### Key Features
- **Troubleshoot file locks:** See which process is using a file or device.
- **Network diagnostics:** List open network sockets and the processes using them.
- **Find processes using a mount:** Identify which processes are using a filesystem or device before unmounting.
- **Security and auditing:** Discover suspicious or unexpected open files.
#### Common Options
- `-i` : Show network files (e.g., `lsof -i :80` for port 80).
- `-u <user>` : Show files opened by a specific user.
- `-p <PID>` : Show files opened by a specific process ID.
- `+D <dir>` : Show files opened under a specific directory.
- `-t` : Output only process IDs (useful for scripting).
- `-n` : Do not resolve hostnames (faster output).
- `-c <command>` : Show files opened by processes with a specific command name.
#### Examples
**Show All Open Files for a User**
```bash
lsof -u alice
```
- Lists all files opened by user `alice`.
**Find Which Process is Using a Specific File**
```bash
lsof /var/log/syslog
```
- Shows which process has `/var/log/syslog` open.
**List All Open Network Connections**
```bash
lsof -i
```
- Displays all open network sockets.
**Find Processes Using a Specific Port**
```bash
sudo lsof -i :8080
```
- Shows processes using TCP or UDP port 8080.
**Show All Open Files in a Directory**
```bash
lsof +D /mnt/usb
```
- Lists all open files under `/mnt/usb`.

**Summary:**  
The `lsof` command is invaluable for troubleshooting file locks, network issues, and resource usage. It helps administrators and users understand what files and sockets are in use and by which processes. For more, see `man lsof`.

---
### `man` – Read System Reference Manual
The `man` (manual) command is used to **view the reference manual pages** for commands, programs, system calls, configuration files, and more on Unix-like systems. It is the primary source of documentation for most Linux commands and utilities.
#### Basic Usage
```bash
man <command>
```
- Opens the manual page for the specified command (e.g., `man ls`).
#### Key Features
- **Comprehensive documentation:** Covers usage, options, examples, and related commands.
- **Sectioned manuals:** Manuals are divided into sections (e.g., user commands, system calls, configuration files).
- **Searchable:** You can search within a man page or for keywords across all pages.
#### Common Options
- `man -k <keyword>` : Search for keyword in all man page descriptions (same as `apropos`).
- `man -f <command>` : Show a short description of the command (same as `whatis`).
- `man <section> <command>` : View a specific section (e.g., `man 5 passwd` for the passwd file format).
- `man -a <command>` : Show all man pages matching the command, one after another.
#### Examples
**Read the Manual for a Command**
```bash
man grep
```
- Opens the manual page for `grep`.
**Search for a Keyword in All Man Pages**
```bash
man -k network
```
- Lists all man pages related to "network".
**View a Specific Section**
```bash
man 5 passwd
```
- Shows the manual for the `passwd` file format (section 5: file formats).

**Show a Short Description**
```bash
man -f ls
```
- Displays a brief description of the `ls` command.
#### Navigation Controls
- Use the **arrow keys** or **Page Up/Page Down** to scroll.
- Press `/` to search within the page.
- Press `n` to go to the next search result.
- Press `q` to quit the manual.

**Summary:**  
The `man` command is the standard way to access detailed documentation for Linux commands and system components. It is an essential resource for learning, troubleshooting, and mastering the Linux command line. For more, see `man man`.

---
### `md5sum`, `sha1sum`, `sha256sum` – Compute and Check File Checksums
These commands are used to **generate and verify checksums (hashes) for files**. They are commonly used to ensure file integrity, verify downloads, and detect file corruption or tampering.
#### Basic Usage
```bash
md5sum filename
sha1sum filename
sha256sum filename
```
- Outputs the checksum for `filename`.
#### Key Features
- **File integrity:** Verify that files have not been altered or corrupted.
- **Multiple algorithms:** Use MD5, SHA-1, or SHA-256 depending on security needs.
- **Batch verification:** Check multiple files at once or verify against a checksum file.
#### Examples
**Generate a Checksum**
```bash
sha256sum myfile.iso
```
- Prints the SHA-256 hash of `myfile.iso`.
**Verify a File Against a Checksum**
```bash
sha256sum -c checksum.txt
```
- Checks the file(s) listed in `checksum.txt` against their expected hashes.
**Create a Checksum File**
```bash
md5sum file1.txt file2.txt > files.md5
```
- Saves the MD5 checksums of both files to `files.md5`.
**Verify All Files in a Checksum List**
```bash
md5sum -c files.md5
```
- Verifies each file listed in `files.md5`.

**Summary:**  
The `md5sum`, `sha1sum`, and `sha256sum` commands are essential for verifying file integrity and authenticity. For more, see `man md5sum`, `man sha1sum`, or `man sha256sum`.

___
### `mkfs` – Build a Linux File System
The `mkfs` (make filesystem) command is used to **create a new file system on a device or partition**. It is a front-end to various filesystem-specific commands (like `mkfs.ext4`, `mkfs.xfs`, etc.) and is essential for preparing disks or partitions for use in Linux.
#### Basic Usage
```bash
sudo mkfs -t ext4 /dev/sdX1
```
- Creates an ext4 filesystem on the specified partition (replace `/dev/sdX1` with your device).
#### Key Features
- **Supports multiple filesystems:** ext2, ext3, ext4, xfs, btrfs, vfat, ntfs, and more.
- **Flexible options:** Each filesystem type has its own set of options for tuning and configuration.
- **Device initialization:** Prepares disks, partitions, or even files for use as mountable filesystems.
#### Common Options
- `-t <type>` : Specify the filesystem type (e.g., `ext4`, `xfs`, `vfat`).
- `-L <label>` : Set a volume label for the new filesystem.
- `-n <volume-name>` : Set a volume name (for some filesystems).
- `-c` : Check the device for bad blocks before creating the filesystem.
- `-b <block-size>` : Specify block size (filesystem-dependent).
#### Examples
**Create an ext4 Filesystem**
```bash
sudo mkfs.ext4 /dev/sdb1
```
- Creates an ext4 filesystem on `/dev/sdb1`.
**Create an XFS Filesystem with a Label**
```bash
sudo mkfs.xfs -L DATA /dev/sdc1
```
- Creates an XFS filesystem labeled "DATA" on `/dev/sdc1`.

**Create a FAT32 Filesystem**
```bash
sudo mkfs.vfat -F 32 /dev/sdd1
```
- Creates a FAT32 filesystem on `/dev/sdd1`.

**Check for Bad Blocks Before Formatting**
```bash
sudo mkfs.ext4 -c /dev/sdb1
```
- Checks for bad blocks before creating the filesystem.

#### Advanced Example: Use `mkfs` with the `-t` Option
```bash
sudo mkfs -t ext4 -L mydata /dev/sdb2
```
- Uses the generic `mkfs` command to create an ext4 filesystem with the label "mydata".

**Warning:**  
Running `mkfs` will erase all data on the target device or partition. Double-check the device name before proceeding.

**Summary:**  
The `mkfs` command is essential for initializing disks and partitions with a new filesystem, making them ready for mounting and use. For more, see `man mkfs` and the manual for the specific filesystem type (e.g., `man mkfs.ext4`).

---
### `mount` / `umount` – Mount and Unmount File Systems
The `mount` command is used to **attach a file system to a directory tree**, making its contents accessible at a specific mount point. The `umount` command is used to **detach (unmount) a file system**, making it inaccessible.
#### Basic Usage
**Mount a File System**
```bash
sudo mount /dev/sdX1 /mnt/mydrive
```
- Mounts the device `/dev/sdX1` at the directory `/mnt/mydrive`.

**Unmount a File System**
```bash
sudo umount /mnt/mydrive
```
- Unmounts the file system mounted at `/mnt/mydrive`.
#### Key Features
- **Supports many file system types:** ext4, xfs, vfat, ntfs, nfs, cifs, iso9660, etc.
- **Mount options:** Control permissions, read/write mode, user access, and more.
- **Network and special filesystems:** Mount NFS, SMB/CIFS shares, ISO images, and more.
- **Temporary or permanent:** Mounts can be temporary or defined in `/etc/fstab` for automatic mounting at boot.
#### Common Options
- `-t <type>` : Specify the file system type (e.g., `-t ext4`).
- `-o <options>` : Set mount options (e.g., `-o ro` for read-only, `-o uid=1000`).
- `-a` : Mount all filesystems mentioned in `/etc/fstab`.
- `-l` : List all currently mounted file systems.
#### Examples
**Mount an ISO Image**
```bash
sudo mount -o loop disk.iso /mnt/iso
```
- Mounts `disk.iso` as a loop device at `/mnt/iso`.

**Mount a USB Drive with Specific Options**
```bash
sudo mount -t vfat -o uid=1000,gid=1000 /dev/sdb1 /media/usb
```
- Mounts a FAT32 USB drive with ownership set to user and group ID 1000.

**Unmount by Device or Mount Point**
```bash
sudo umount /dev/sdb1
sudo umount /media/usb
```
- Either command will unmount the device or the mount point.

**List All Mounted File Systems**
```bash
mount
```
or
```bash
findmnt
```
#### Advanced Example: Edit `/etc/fstab` for Automatic Mounting
Add a line to `/etc/fstab`:
```
/dev/sdb1   /mnt/data   ext4   defaults   0 2
```
- Automatically mounts `/dev/sdb1` to `/mnt/data` at boot.

**Summary:**  
The `mount` and `umount` commands are essential for managing file systems and storage devices in Linux, providing access to local, network, and virtual file systems. For more, see `man mount` and `man umount`.

---
### `ncdu` – NCurses Disk Usage
The `ncdu` (NCurses Disk Usage) command is a **disk utility for Unix systems** that provides a fast, interactive way to analyze and manage disk space usage. It is especially useful for finding large files and directories and cleaning up space.
##### Basic Usage
```bash
ncdu
```
- Launches `ncdu` in the current directory and interactively displays disk usage.
##### Common Options
- `-x` : Stay on the same filesystem (do not cross filesystem boundaries)
- `-q` : Quiet mode (minimal output)
- `-r` : Read-only mode (disable file deletion)
- `-o FILE` : Export scan results to a file
- `-f FILE` : Read scan results from a file
- `-e` : Enable extended information (show more file details)
##### Scan a Specific Directory
```bash
ncdu /var/log
```
- Analyzes disk usage in the `/var/log` directory.
##### Stay on the Same Filesystem
```bash
ncdu -x /
```
- Scans the root filesystem but does not cross into mounted filesystems.
##### Export and Import Scan Results
```bash
ncdu -o scan.json /home
ncdu -f scan.json
```
- Exports the scan results of `/home` to `scan.json` and later reads from it.
##### Read-Only Mode
```bash
ncdu -r /
```
- Prevents accidental deletion of files while browsing disk usage.
##### Advanced Example: Clean Up Large Files
1. Run `ncdu` in a directory:
```bash
   ncdu /var
```
2. Use the arrow keys to navigate and locate large files or directories.
3. Press `d` to delete unwanted files or directories directly from the interface.
**Summary:**  
The `ncdu` command is a powerful, interactive tool for analyzing and managing disk space usage. It is ideal for quickly identifying large files and directories and cleaning up space, especially on servers. For more, see `man ncdu`.

---
### `nice` – Run a Command with Modified Scheduling Priority
The `nice` command is used to **run a program with a modified scheduling priority**, allowing you to make a process run with higher or lower priority compared to others. Lower priority (higher "niceness" value) means the process will yield more CPU time to other processes.
#### Basic Usage
```bash
nice command
```
- Runs `command` with the default niceness increment (usually 10).
```bash
nice -n 5 command
```
- Runs `command` with a niceness of 5.
#### Key Features
- **Control CPU scheduling:** Adjust how much CPU time a process receives.
- **Lower impact:** Useful for running background or resource-intensive tasks without slowing down other processes.
- **Works with any command:** Can be used with scripts, binaries, or any executable.
#### Common Options
- `-n <niceness>` : Set the niceness value (from -20 [highest priority] to 19 [lowest priority]).
#### Examples
**Run a Command with Lower Priority**
```bash
nice -n 15 long_task.sh
```
- Runs `long_task.sh` with a niceness of 15 (lower priority).
**Run a Command with Higher Priority (Requires Root)**
```bash
sudo nice -n -5 backup.sh
```
- Runs `backup.sh` with a niceness of -5 (higher priority; only root can use negative values).
**Check the Niceness of a Running Process**
```bash
ps -o pid,ni,cmd -p <PID>
```
- Shows the niceness (`NI`) of the process with the given PID.

**Summary:**  
The `nice` command is useful for controlling the CPU priority of processes, helping to balance system load and responsiveness. For more, see `man nice`.

___
### `nmon` – Performance Monitor for Linux
`nmon` (Nigel's Monitor) is a fast, ncurses-based system monitor for Linux and AIX. It provides detailed, real-time statistics for CPU, memory, disks, network, NFS, processes, and more, making it a popular alternative to `top` and `htop`.
#### Basic Usage
```bash
nmon
```
- Launches the interactive nmon interface.
#### Key Features
- **Toggle views:** CPU, memory, disk, network, processes, NFS, kernel, and more.
- **Minimal resource usage:** Lightweight and efficient.
- **Data capture:** Can save stats to CSV for later analysis (for graphing with tools like Excel or nmonchart).
- **Colorful, easy-to-read interface.**
#### Interactive Controls
- Press `c` for CPU stats.
- Press `m` for memory stats.
- Press `d` for disk stats.
- Press `n` for network stats.
- Press `t` for top processes.
- Press `h` for help.
- Press `q` to quit.
- Press `l`, `j`, `k`, `v`, `g`, `r`, `b`, `f`, `V`, `N`, `A`, `D`, `X` for other resource views.

#### Example: Capture Data for Later Analysis
```bash
nmon -f -s 10 -c 60
```
- Collects stats every 10 seconds, 60 times, and saves to a `.nmon` file.

#### Example: View Only CPU and Memory
1. Start `nmon`.
2. Press `c` and `m` to toggle CPU and memory views.

**Summary:**  
`nmon` is a robust, interactive tool for real-time and historical performance monitoring. It is ideal for system administrators and performance analysts who need detailed, exportable stats. For more, see `man nmon` or [nmon documentation](http://nmon.sourceforge.net/pmwiki.php).

---
### `parted` – Create and Manipulate Partition Tables
The `parted` command is a **powerful disk partitioning tool** for creating, resizing, deleting, and managing partitions on hard drives and SSDs. Unlike `fdisk`, `parted` supports both MBR (MS-DOS) and GPT partition tables, making it suitable for modern large disks.
#### Basic Usage
```bash
sudo parted /dev/sdX
```
- Starts an interactive session on the specified disk (replace `sdX` with your device, e.g., `sda`).
#### Key Features
- **Supports MBR and GPT:** Works with both legacy and modern partition tables.
- **Create, resize, delete partitions:** Flexible management of disk space.
- **Scriptable:** Can be used non-interactively for automation.
- **Supports advanced features:** Such as aligning partitions and setting flags (boot, esp, etc.).
#### Common Commands Inside `parted`
- `print` : Show the current partition table.
- `mklabel gpt` : Create a new GPT partition table.
- `mklabel msdos` : Create a new MBR partition table.
- `mkpart` : Create a new partition.
- `rm <number>` : Remove a partition by number.
- `resizepart <number> <end>` : Resize a partition.
- `set <number> <flag> on|off` : Set or unset partition flags (e.g., boot, esp).
- `quit` : Exit parted.
#### Examples
**Show Partition Table**
```bash
sudo parted /dev/sda print
```
- Displays the partition table for `/dev/sda`.
**Create a New GPT Partition Table**
```bash
sudo parted /dev/sdb mklabel gpt
```
- Initializes `/dev/sdb` with a GPT partition table (erases all data).
**Create a New Partition**
```bash
sudo parted /dev/sdb mkpart primary ext4 1MiB 100GiB
```
- Creates a primary partition from 1MiB to 100GiB, intended for ext4.
**Resize a Partition**
```bash
sudo parted /dev/sdb resizepart 1 200GiB
```
- Resizes partition 1 to end at 200GiB.

**Set the Boot Flag**
```bash
sudo parted /dev/sdb set 1 boot on
```
- Sets the boot flag on partition 1.
#### Advanced Example: Scripted Partitioning
```bash
sudo parted -s /dev/sdc mklabel gpt mkpart primary ext4 1MiB 100%
```
- Non-interactively creates a GPT table and a single partition using the whole disk.

**Warning:**  
Partitioning operations can destroy data. Always back up important data before making changes.

**Summary:**  
The `parted` command is a modern, flexible tool for managing disk partitions, supporting both MBR and GPT. It is ideal for large disks and advanced partitioning needs. For more, see `man parted`.

--- 
### `passwd` – Change a User’s Password
The `passwd` command is used to **change a user's password** on Linux and Unix systems. It can be used by regular users to change their own password, or by the root user (or with `sudo`) to set or reset passwords for any account.
#### Basic Usage
```bash
passwd
```
- Prompts the current user to enter a new password.
```bash
sudo passwd username
```
- Allows an administrator to set or reset the password for `username`.
#### Key Features
- **Password change:** Securely updates the password for a user account.
- **Password policies:** Enforces system password complexity and expiration policies.
- **Account locking/unlocking:** Can lock or unlock user accounts
#### Common Options
- `-l` : Lock the user account (disables password login).
- `-u` : Unlock the user account.
- `-e` : Expire the password immediately (forces change on next login).
- `-d` : Delete the password (user can log in without a password, if allowed).
- `-S` : Show password status information.
#### Examples
**Change Your Own Password**
```bash
passwd
```
- Prompts you to enter your current password and then a new one.
**Change Another User’s Password (as root)**
```bash
sudo passwd bob
```
- Sets a new password for user `bob`.
**Lock a User Account**
```bash
sudo passwd -l alice
```
- Locks the account for user `alice`.
**Unlock a User Account**
```bash
sudo passwd -u alice
```
- Unlocks the account for user `alice`.
**Force Password Change on Next Login**
```bash
sudo passwd -e carol
```
- Expires `carol`'s password, requiring a change at next login.

**Summary:**  
The `passwd` command is essential for managing user authentication and security on Linux systems. For more, see `man passwd`.

---
### `pgrep` – Look Up Processes Based on Name and Other Attributes
The `pgrep` command is used to **search for processes based on name and other attributes**, returning their process IDs (PIDs). It is useful for scripting, automation, and process management, allowing you to find processes without manually parsing `ps` output.
#### Basic Usage
```bash
pgrep processname
```
- Returns the PIDs of all processes with the specified name.
#### Key Features
- **Pattern matching:** Search for processes by name (supports regular expressions).
- **Flexible filtering:** Match by user, group, terminal, parent PID, and more.
- **Script-friendly:** Outputs only PIDs, making it easy to use in scripts.
- **Inverse matching:** Find processes that do not match a pattern.
#### Common Options
- `-u <user>` : Match only processes owned by the specified user.
- `-g <group>` : Match only processes in the specified group.
- `-f` : Match against the full command line, not just the process name.
- `-l` : List the process name along with the PID.
- `-n` : Return only the newest (most recently started) matching process.
- `-o` : Return only the oldest matching process.
- `-v` : Invert the match (select non-matching processes).
#### Examples
**Find All PIDs for "nginx"**
```bash
pgrep nginx
```
**Find PIDs for a Process Owned by a Specific User**
```bash
pgrep -u alice python
```
**Find the Newest "sshd" Process**
```bash
pgrep -n sshd
```
**Find Processes by Full Command Line**
```bash
pgrep -f "python myscript.py"
```
**List PIDs and Process Names**
```bash
pgrep -l bash
```

**Summary:**  
The `pgrep` command is a fast and convenient way to look up process IDs based on names and attributes, making it ideal for scripting and process management. For more, see `man pgrep`.

---
### `pkill` – Kill Processes by Name or Other Attributes
The `pkill` command is used to **send signals to processes based on name or other attributes**. It allows you to terminate, stop, or signal multiple processes at once without needing to look up their process IDs (PIDs).
#### Basic Usage
```bash
pkill processname
```
- Sends the default `SIGTERM` signal to all processes with the specified name.
#### Key Features
- **Kill by name:** No need to know the PID; just specify the process name.
- **Flexible matching:** Can match by user, group, terminal, session, age, and more.
- **Send any signal:** Not limited to termination; can send any signal supported by `kill`.
- **Pattern matching:** Supports regular expressions for process names.
#### Common Options
- `-u <user>` : Match only processes owned by the specified user.
- `-f` : Match against the full command line, not just the process name.
- `-9` : Send `SIGKILL` (force kill).
- `-SIG<signal>` : Send a specific signal (e.g., `-SIGSTOP`, `-SIGUSR1`).
- `-n` : Only signal the newest matching process.
- `-o` : Only signal the oldest matching process.
#### Examples
**Kill All Processes Named "firefox"**
```bash
pkill firefox
```
**Force Kill All Python Processes**
```bash
pkill -9 python
```
**Kill All Processes Matching a Pattern in the Full Command Line**
```bash
pkill -f "my_script.py"
```
**Kill All Processes Owned by a Specific User**
```bash
pkill -u alice
```
**Send a Custom Signal (e.g., Stop)**
```bash
pkill -SIGSTOP myapp
```
- Suspends all `myapp` processes.

**Summary:**  
The `pkill` command is a powerful and convenient way to signal or terminate processes by name or other attributes, making process management and automation easier. For more, see `man pkill`
___
### `ps` – Display Information About Running Processes
The `ps` (process status) command is used to **display information about the currently running processes** on a Linux system. It provides a snapshot of active processes, their IDs, resource usage, and more.
#### Basic Usage
```bash
ps
```
- Shows processes running in the current shell/session.
#### Key Features
- **View all processes:** Can display all processes for all users.
- **Customizable output:** Supports selecting specific columns and formatting.
- **Snapshot:** Unlike `top` or `htop`, `ps` shows a static snapshot, not a live update.
#### Common Options
- `-e` or `-A` : Show all processes on the system.
- `-f` : Full-format listing (shows PPID, start time, etc.).
- `-u <user>` : Show processes for a specific user.
- `-x` : Show processes without a controlling terminal.
- `-o <format>` : Specify output columns (e.g., `-o pid,cmd,%mem`).
- `-aux` : Show all processes in BSD style (commonly used: `ps aux`).

#### Examples

**Show All Processes**
```bash
ps -e
```
- Lists all running processes.

**Full-Format Listing**
```bash
ps -ef
```
- Shows detailed information for all processes.

**Show Processes for a Specific User**
```bash
ps -u username
```
- Lists processes owned by `username`.

**Show All Processes in BSD Format**
```bash
ps aux
```
- Displays all processes with detailed info (user, PID, CPU, memory, command, etc.).

**Custom Output Columns**
```bash
ps -eo pid,ppid,cmd,%mem,%cpu
```
- Shows only the specified columns for all processes.

**Show Processes Without a Controlling Terminal**
```bash
ps -x
```
- Includes background and daemon processes.
#### Advanced Example: Find a Process by Name
```bash
ps aux | grep nginx
```
- Searches for all running `nginx` processes.

**Summary:**  
The `ps` command is essential for viewing and analyzing running processes on Linux. It is useful for troubleshooting, monitoring, and scripting. For more, see `man ps`.

---
### `pstree` – Display a Tree of Processes
The `pstree` command is used to **display running processes as a tree**. It visually shows the parent-child relationships between processes, making it easier to understand process hierarchies.
##### Basic Usage
```bash
pstree
```
- Displays all running processes in a tree format, starting from `init` or `systemd`.
##### Common Options
- `-p` : Show PIDs (process IDs) alongside process names
- `-u` : Show the user name for each process
- `-a` : Show command line arguments for each process
- `-n` : Sort processes by PID (numeric order)
- `-A` : Use ASCII characters for tree drawing (useful for plain text terminals)
- `-h` : Highlight the current process and its ancestors
#####  Show PIDs in the Tree
```bash
pstree -p
```
- Displays the process tree with process IDs.
##### Show User Names
```bash
pstree -u
```
- Shows which user owns each process.
##### Show Command Line Arguments
```bash
pstree -a
```
- Displays the full command line for each process.
#####  Highlight the Current Process
```bash
pstree -h
```
- Highlights the current process and its parent processes.
##### Use ASCII Characters for the Tree
```bash
pstree -A
```
- Draws the tree using ASCII characters, which is useful in some terminal environments.
##### Advanced Example: Combine Options
```bash
pstree -apu
```
- Shows the process tree with PIDs, command line arguments, and user names.

**Summary:**  
The `pstree` command is a helpful tool for visualizing process hierarchies and relationships in Linux. It is especially useful for troubleshooting, monitoring, and understanding how processes are spawned and related. For more, see `man pstree`.

---
### `renice` – Alter Priority of Running Processes
The `renice` command is used to **change the scheduling priority (niceness) of one or more running processes**. This allows you to increase or decrease the priority of processes after they have started, affecting how much CPU time they receive.
#### Basic Usage
```bash
renice -n <niceness> -p <PID>
```
- Changes the niceness of the process with the specified PID.
#### Key Features
- **Adjust running process priority:** Increase (lower priority) or decrease (raise priority, requires root) the niceness value.
- **Affects CPU scheduling:** Higher niceness means lower priority; lower niceness (including negative values) means higher priority.
- **Target by PID, user, or group:** Can change priority for specific processes, users, or groups.
#### Common Options
- `-n <niceness>` : The new niceness value (from -20 [highest priority] to 19 [lowest priority]).
- `-p <PID>` : Specify the process ID(s) to renice.
- `-u <user>` : Renice all processes owned by the specified user.
- `-g <group>` : Renice all processes belonging to the specified group.
#### Examples
**Increase Niceness (Lower Priority) of a Process**
```bash
renice -n 10 -p 1234
```
- Sets the niceness of process 1234 to 10.
**Decrease Niceness (Raise Priority, Requires Root)**
```bash
sudo renice -n -5 -p 5678
```
- Sets the niceness of process 5678 to -5 (higher priority).
**Renice All Processes for a User**
```bash
sudo renice -n 5 -u alice
```
- Sets the niceness of all processes owned by user `alice` to 5.
**Renice Multiple Processes**
```bash
renice -n 15 -p 1234 -p 5678
```
- Sets the niceness of both processes to 15.

**Summary:**  
The `renice` command is useful for dynamically adjusting the CPU priority of running processes, helping to manage system load and responsiveness. For more, see `man renice`.

___
### `sar` – System Activity Reporter
The `sar` (System Activity Reporter) command is used to **collect, report, and save system activity information** such as CPU, memory, disk, and network usage. It is part of the `sysstat` package and is valuable for performance monitoring, troubleshooting, and historical analysis.
#### Basic Usage
```bash
sar
```
- Displays CPU usage statistics collected at 10-minute intervals throughout the day.
#### Key Features
- **Historical data:** View system performance data from the past (if `sysstat` is enabled).
- **Real-time and interval reporting:** Show current stats or collect new data at specified intervals.
- **Comprehensive metrics:** CPU, memory, swap, disk I/O, network, and more.
- **Customizable output:** Filter by metric, time, or device.
#### Common Options
- `-u` : Report CPU usage.
- `-r` : Report memory usage.
- `-d` : Report block device (disk) activity.
- `-n <type>` : Report network statistics (e.g., `DEV`, `EDEV`, `SOCK`, `IP`, `TCP`, `UDP`).
- `-q` : Report load average and run queue length.
- `-f <file>` : Read data from a specific log file (default: `/var/log/sysstat/sar*`).
- `-s <time>` : Start time for the report (e.g., `-s 08:00:00`).
- `-e <time>` : End time for the report (e.g., `-e 18:00:00`).
- `-A` : Report all available statistics.
#### Examples
**Show CPU Usage for Today**
```bash
sar -u
```
- Displays CPU usage statistics for the current day.
**Show Memory Usage**
```bash
sar -r
```
- Shows memory usage statistics.
**Show Disk Activity**
```bash
sar -d
```
- Reports disk I/O statistics.
**Show Network Device Statistics**
```bash
sar -n DEV
```
- Displays network interface statistics.
**Collect Real-Time CPU Stats Every 2 Seconds for 5 Times**
```bash
sar -u 2 5
```
- Collects and displays CPU usage every 2 seconds, 5 times.
**Show All Statistics from a Specific Log File**
```bash
sar -A -f /var/log/sysstat/sa10
```
- Reports all metrics from the log file for the 10th day of the month.
#### Advanced Example: Report for a Specific Time Range
```bash
sar -u -s 09:00:00 -e 12:00:00
```
- Shows CPU usage between 9 AM and 12 PM.

**Summary:**  
The `sar` command is a powerful tool for monitoring and analyzing system performance over time. It is essential for troubleshooting, capacity planning, and historical reporting. For more, see `man sar` and the `sysstat` documentation.

---
### `sed` – Stream Editor for Text Transformation
The `sed` (stream editor) command is used to **perform basic text transformations on an input stream** (such as a file or input from a pipeline). It is widely used for searching, replacing, inserting, and deleting text in files or data streams.
#### Basic Usage
```bash
sed 's/old/new/' filename
```
- Replaces the first occurrence of "old" with "new" on each line of `filename` and prints the result.
#### Key Features
- **Search and replace:** Substitute text patterns using regular expressions.
- **In-place editing:** Modify files directly with the `-i` option.
- **Line selection:** Apply changes to specific lines or ranges.
- **Insert, append, delete lines:** Add or remove lines based on patterns or line numbers.
- **Works with pipelines:** Process data from other commands.
#### Common Examples
**Replace All Occurrences in a File (Print to Output)**
```bash
sed 's/foo/bar/g' file.txt
```
- Replaces all occurrences of "foo" with "bar" in each line and prints the result.
**Replace Text In-Place**
```bash
sed -i 's/foo/bar/g' file.txt
```
- Replaces all occurrences of "foo" with "bar" directly in `file.txt`.
**Delete Lines Matching a Pattern**
```bash
sed '/pattern/d' file.txt
```
- Deletes all lines containing "pattern".
**Print Only Specific Lines**
```bash
sed -n '5,10p' file.txt
```
- Prints lines 5 through 10 of `file.txt`.
**Insert a Line Before a Pattern**
```bash
sed '/pattern/i\This is a new line' file.txt
```
- Inserts "This is a new line" before lines matching "pattern".
**Advanced Example: Replace Only on Specific Lines**
```bash
sed '2,4s/foo/bar/g' file.txt
```
- Replaces "foo" with "bar" only on lines 2 through 4.

**Summary:**  
The `sed` command is a powerful tool for non-interactive text editing, automation, and data transformation in Linux. For more, see `man sed`.

---
### `ssh` – Secure Shell for Remote Access
The `ssh` (Secure Shell) command is used to **securely connect to remote Linux systems** over a network. It encrypts all traffic, providing secure command-line access and file transfers.
#### Basic Usage
```bash
ssh user@remote_host
```
- Connects to `remote_host` as `user`.
#### Common Options
- `-p <port>` : Specify a custom SSH port (default is 22).
- `-i <keyfile>` : Use a specific private key for authentication.
- `-X` : Enable X11 forwarding (run graphical apps remotely).
- `-L <local_port>:<remote_host>:<remote_port>` : Set up local port forwarding.
- `-C` : Enable compression.
- `-v` : Verbose/debug output.
#### Example: Connect Using a Custom Port
```bash
ssh -p 2222 user@remote_host
```
#### Example: Use an SSH Key for Authentication
```bash
ssh -i ~/.ssh/id_rsa user@remote_host
```
#### Example: Run a Remote Command
```bash
ssh user@remote_host 'uptime'
```
- Runs `uptime` on the remote host and prints the result locally.
#### Example: Enable X11 Forwarding
```bash
ssh -X user@remote_host
```
- Allows running remote graphical applications.
#### Example: Local Port Forwarding
```bash
ssh -L 8080:localhost:80 user@remote_host
```
- Forwards local port 8080 to remote port 80.
**Summary:**  
The `ssh` command is the standard for secure, encrypted remote access to Linux systems. It supports interactive shells, remote command execution, file transfers, port forwarding, and more. For further details, see `man ssh`.

---
### `sleep` – Suspend Program Execution for a Specified Time
The `sleep` command is used to **pause or delay the execution of a script or command for a specified amount of time**. It is commonly used in shell scripts to introduce delays between commands or to wait for a resource to become available.
#### Basic Usage
```bash
sleep <duration>
```
- Suspends execution for the specified duration (in seconds by default).
#### Key Features
- **Simple time delays:** Pause scripts or commands for seconds, minutes, hours, or days.
- **Supports fractional seconds:** On most systems, you can use decimal values (e.g., `sleep 0.5`).
- **Multiple time units:** Use `s` (seconds), `m` (minutes), `h` (hours), or `d` (days).
#### Examples
**Pause for 5 Seconds**
```bash
sleep 5
```
- Waits for 5 seconds before continuing.

**Pause for 2 Minutes**
```bash
sleep 2m
```
- Waits for 2 minutes.

**Pause for 1.5 Seconds**
```bash
sleep 1.5
```
- Waits for 1.5 seconds (if supported).

**Pause for 1 Hour**
```bash
sleep 1h
```
- Waits for 1 hour.

**Use in a Script to Delay Actions**
```bash
echo "Starting process..."
sleep 10
echo "Process started after 10 seconds."
```

**Summary:**  
The `sleep` command is a simple but essential tool for adding delays in scripts or command sequences. For more, see `man sleep`.

---
### `sudo` – Execute Commands with Administrative Privileges
The `sudo` (superuser do) command allows a permitted user to **execute a command as the superuser (root) or another user**, as specified by the security policy. It is the standard way to perform administrative tasks on Linux systems without logging in as root.
#### Basic Usage
```bash
sudo command
```
- Runs `command` with root privileges.
#### Key Features
- **Privilege escalation:** Temporarily grants administrative rights for a single command.
- **Audit trail:** Logs all commands run with `sudo` for security auditing.
- **Fine-grained control:** Access is managed via the `/etc/sudoers` file, allowing specific users or groups to run specific commands.
#### Common Options
- `-u <user>` : Run the command as a different user (default is root).
- `-k` : Invalidate the user's cached credentials (forces password prompt next time).
- `-l` : List the allowed (and forbidden) commands for the current user.
- `-v` : Extend the sudo timeout for the current session.
- `-s` : Run a shell with root privileges.
- `-i` : Run a login shell as root.
#### Example: Update Package Index
```bash
sudo apt update
```
- Runs the package update command with root privileges.
#### Example: Edit a System File as Root
```bash
sudo nano /etc/hosts
```
- Opens the `/etc/hosts` file in the nano editor with root permissions.
#### Example: Run a Command as Another User
```bash
sudo -u www-data ls /var/www
```
- Lists files in `/var/www` as the `www-data` user.
#### Example: Start a Root Shell
```bash
sudo -i
```
- Opens a root login shell.
#### Example: List Allowed Commands for Your User
```bash
sudo -l
```
- Shows which commands you are permitted to run with `sudo`.
#### Advanced Example: Run a Script with Root Privileges
```bash
sudo bash myscript.sh
```
- Executes the entire script as root.
**Summary:**  
The `sudo` command is essential for safely performing administrative tasks on Linux. It provides controlled, auditable access to privileged operations, reducing the need to log in directly as root. For more, see `man sudo` and `man sudoers`.

---
### `systemctl` – Control the systemd System and Service Manager
The `systemctl` command is the **central management tool for controlling the systemd init system** on modern Linux distributions. It is used to manage system services (daemons), control the system state (reboot, shutdown), and inspect system status.
#### Basic Usage
```bash
systemctl <command> <unit>
```
- `<command>` is an action (e.g., `start`, `stop`, `restart`, `status`, `enable`, `disable`).
- `<unit>` is a service or other systemd unit (e.g., `nginx.service`, `sshd.service`).
#### Key Features
- **Start/stop/restart services:** Manage system daemons and background services.
- **Enable/disable services:** Control which services start at boot.
- **View status:** Check the status and logs of services.
- **System state control:** Reboot, power off, suspend, hibernate, etc.
- **List units:** Show all loaded or active services, sockets, targets, etc.
#### Common Commands
**Start, Stop, Restart, and Check Status of a Service**
```bash
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx
sudo systemctl status nginx
```
**Enable or Disable a Service at Boot**
```bash
sudo systemctl enable sshd
sudo systemctl disable apache2
```
**List All Active Services**
```bash
systemctl list-units --type=service
```
**Show All Failed Services**
```bash
systemctl --failed
```
**Reload All Unit Files (after editing service files)**
```bash
sudo systemctl daemon-reload
```
**Reboot or Power Off the System**
```bash
sudo systemctl reboot
sudo systemctl poweroff
```
**Show System Logs for a Service**
```bash
journalctl -u nginx
```
#### Advanced Example: Mask a Service (Prevent It from Starting)
```bash
sudo systemctl mask bluetooth
```
- Prevents the `bluetooth` service from being started manually or automatically.

**Summary:**  
The `systemctl` command is the main interface for managing services and system state on systemd-based Linux systems. It is essential for service administration, troubleshooting, and automation. For more, see `man systemctl`.

---
### `time` – Run Programs and Summarize System Resource Usage
The `time` command is used to **measure how long a command takes to run** and to report resource usage statistics such as real (wall clock) time, user CPU time, and system CPU time. It is useful for benchmarking, profiling, and optimizing scripts or commands.
#### Basic Usage
```bash
time command
```
- Runs `command` and prints a summary of the time and resources used.
#### Key Features
- **Wall clock time:** Total elapsed time from start to finish.
- **User and system CPU time:** Time spent in user mode and kernel mode.
- **Resource usage:** Optionally reports memory, I/O, and other statistics (with `/usr/bin/time`).
#### Examples
**Measure the Time to List a Directory**
```bash
time ls -lR /
```
- Shows how long it takes to recursively list all files from the root directory.
**Measure a Script’s Execution Time**
```bash
time ./myscript.sh
```
**Use the Full-Featured `/usr/bin/time` for More Stats**
```bash
/usr/bin/time -v ./myscript.sh
```
- Prints detailed resource usage, including memory, context switches, and I/O.
#### Output Example
```
real    0m2.345s
user    0m0.123s
sys     0m0.456s
```
- `real`: Total elapsed (wall clock) time.
- `user`: Time spent in user mode.
- `sys`: Time spent in kernel mode.

**Summary:**  
The `time` command is a simple and effective tool for measuring the duration and resource usage of commands and scripts. For more, see `man time`.

___
### `tldr` – Collaborative Cheat Sheets for Console Commands
The `tldr` command provides **community-driven, simplified, and example-focused cheat sheets** for common console commands. It is designed to give you quick, practical command usage examples without reading lengthy man pages.
#### Basic Usage
```bash
tldr <command>
```
- Shows a concise, example-based help page for `<command>` (e.g., `tldr tar`).
#### Key Features
- **Simplified explanations:** Focuses on practical examples and common use cases.
- **Community maintained:** Pages are contributed and updated by users worldwide.
- **Fast and offline:** Most clients cache pages locally for instant, offline access.
- **Cross-platform:** Available for Linux, macOS, and Windows.
#### Examples
**Show Cheat Sheet for `ls`**
```bash
tldr ls
```
**Show Cheat Sheet for `tar`**
```bash
tldr tar
```
**Update Local Cache**
```bash
tldr -u
```
- Updates the local cache of tldr pages.
**Show a Cheat Sheet for a Command in a Specific Platform**
```bash
tldr --platform=linux find
```
- Shows the Linux-specific page for `find`.
#### Installation
- On most systems, you can install with a package manager:
  - **Debian/Ubuntu:** `sudo apt install tldr`
  - **macOS (Homebrew):** `brew install tldr`
  - **Python (pip):** `pip install tldr`

**Summary:**  
The `tldr` command is a quick reference tool for learning and recalling command-line usage, with clear, example-based explanations. For more, see [tldr.sh](https://tldr.sh) or run `tldr --help`.

---
### `tmux` – Terminal Multiplexer
The `tmux` command is a **terminal multiplexer** that allows you to manage multiple terminal sessions within a single window. It is similar to `screen` but offers more advanced features and a modern interface. With `tmux`, you can detach from a session and reattach later, keep processes running after disconnecting, and split your terminal into multiple panes.
#### Basic Usage
```bash
tmux
```
- Starts a new tmux session.
#### Key Features
- **Persistent sessions:** Detach and reattach to sessions, keeping processes running in the background.
- **Multiple windows and panes:** Split your terminal into multiple windows and panes for multitasking.
- **Session management:** Easily create, rename, and switch between sessions.
- **Customizable:** Highly configurable with key bindings and scripts.
#### Common Commands (Inside tmux)
- `Ctrl+b c` : Create a new window
- `Ctrl+b n` : Next window
- `Ctrl+b p` : Previous window
- `Ctrl+b "` : Split pane horizontally
- `Ctrl+b %` : Split pane vertically
- `Ctrl+b d` : Detach from the session
- `Ctrl+b [` : Enter copy/scrollback mode
- `Ctrl+b x` : Kill the current pane
#### Examples
**Start a Named Session**
```bash
tmux new -s mysession
```
- Starts a new session named `mysession`.

**List All Sessions**
```bash
tmux ls
```
- Lists all running tmux sessions.

**Attach to a Detached Session**
```bash
tmux attach -t mysession
```
- Reattaches to the session named `mysession`.

**Kill a Session**
```bash
tmux kill-session -t mysession
```
- Terminates the session named `mysession`.
#### Advanced Example: Split Panes and Run Commands
1. Start tmux: `tmux`
2. Split horizontally: `Ctrl+b "`
3. Split vertically: `Ctrl+b %`
4. Switch panes: `Ctrl+b` then arrow keys

**Summary:**  
The `tmux` command is a powerful tool for managing persistent, multi-pane terminal sessions. It is ideal for multitasking, remote work, and keeping long-running processes alive. For more, see `man tmux` or [tmux documentation](https://github.com/tmux/tmux/wiki).

---
### `top` – Shows an Overall System View
The `top` command is used to **display real-time information about system processes, resource usage, and overall system performance**. It provides a dynamic, continuously updated view of CPU, memory, and process activity.
##### Basic Usage
```bash
top
```
- Launches the interactive `top` interface, showing running processes and system resource usage.
##### Common Features and Controls
- Press `q` to quit.
- Press `P` to sort by CPU usage.
- Press `M` to sort by memory usage.
- Press `k` to kill a process (enter PID when prompted).
- Press `u` to filter by a specific user.
- Press `h` or `?` for help.
##### Common Options
- `-u <user>` : Show only processes for a specific user.
- `-p <pid>` : Monitor specific process IDs.
- `-n <number>` : Set the number of iterations before exiting.
- `-b` : Batch mode (output is suitable for parsing or logging).
##### Show Processes for a Specific User
```bash
top -u username
```
- Displays only the processes owned by `username`.
##### Run in Batch Mode and Save Output
```bash
top -b -n 1 > top_output.txt
```
- Runs `top` in batch mode for one iteration and saves the output to a file.
##### Monitor Specific Processes
```bash
top -p 1234,5678
```
- Monitors only the processes with PIDs 1234 and 5678.
#### Advanced Example: Sort by Memory Usage
While running `top`, press `M` to sort the process list by memory usage.

**Summary:**  
The `top` command is an essential tool for monitoring system performance and managing processes in real time. It helps identify resource hogs, troubleshoot issues, and keep an eye on overall system health. For more, see `man top`

---
### `uptime` – Show System Uptime and Load Average
The `uptime` command is used to **display how long the system has been running**, how many users are currently logged on, and the system load averages for the past 1, 5, and 15 minutes.
##### Basic Usage
```bash
uptime
```
- Shows the current time, how long the system has been running, number of users, and load averages.
##### Example Output
```
14:23:01 up 5 days,  3:17,  2 users,  load average: 0.15, 0.10, 0.05
```
- `14:23:01` – Current system time
- `up 5 days, 3:17` – System uptime (5 days, 3 hours, 17 minutes)
- `2 users` – Number of users currently logged in
- `load average: 0.15, 0.10, 0.05` – System load averages for the last 1, 5, and 15 minutes
##### Common Options
- `-p` : Show uptime in a pretty (human-readable) format
- `-s` : Show the system boot time
- `-V` : Show version information
##### Pretty Format
```bash
uptime -p
```
- Displays uptime in a human-friendly format, e.g., `up 5 days, 3 hours, 17 minutes`.
##### Show Boot Time
```bash
uptime -s
```
- Shows the exact date and time when the system was last booted.
##### Advanced Example: Combine with `watch` to Monitor Uptime
```bash
watch -n 10 uptime
```
- Continuously displays the uptime every 10 seconds.
**Summary:**  
The `uptime` command is a quick way to check how long your system has been running and to view system load averages. It’s useful for monitoring system stability and performance. For more, see `man uptime`.

---
### `w` – Show a List of Currently Logged-In User Sessions
The `w` command is used to **display information about currently logged-in users** and their running processes. It provides a quick overview of who is logged in, what they are doing, and system load.
##### Basic Usage
```bash
w
```
- Shows a summary of logged-in users, their terminals, login times, idle times, originating IPs, and the command they are running.
##### Example Output
```
 14:23:01 up 5 days,  3:17,  2 users,  load average: 0.15, 0.10, 0.05
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
alice    pts/0    192.168.1.5      08:12    1:23m  0.10s  0.10s -bash
bob      pts/1    192.168.1.6      09:45    2:01   0.20s  0.20s vim notes.txt
```
##### Common Options
- `-h` : Suppress the header.
- `-s` : Short format (less information).
- `-f` : Show from (remote host) field (default, but can be toggled off).
- `-u` : Ignore the username when figuring out the current process.
##### Example: Show Output Without Header
```bash
w -h
```
- Displays the user session list without the header line.
##### Example: Short Format
```bash
w -s
```
- Shows a condensed version of the output.
##### Example: Show Only Local Sessions
```bash
w | grep 'tty'
```
- Filters the output to show only local (non-remote) sessions.
**Summary:**  
The `w` command is a quick way to see who is logged in and what they are doing on a Linux system. It’s useful for monitoring user activity and troubleshooting. For more, see `man w`.

---
### `watch` – Execute a Program Periodically and Display Output
The `watch` command is used to **run a command or script repeatedly at regular intervals**, displaying the output full-screen in the terminal. It is especially useful for monitoring the output of commands that change over time, such as system stats, disk usage, or process lists.
#### Basic Usage
```bash
watch <command>
```
- Runs `<command>` every 2 seconds (default) and displays the output.
#### Key Features
- **Live monitoring:** See updated output from commands in real time.
- **Custom intervals:** Change how often the command is run.
- **Highlight changes:** Optionally highlight differences between updates.
- **Full-screen display:** Clears the terminal and shows only the latest output.
#### Common Options
- `-n <seconds>` : Set the interval between executions (default is 2 seconds).
- `-d` : Highlight differences between updates.
- `-t` : Turn off the header showing interval, time, and command.
- `-c` : Interpret ANSI color and formatting codes in the output.
#### Examples
**Monitor Disk Usage Every 5 Seconds**
```bash
watch -n 5 df -h
```
- Updates the disk usage display every 5 seconds.
**Watch for New Processes**
```bash
watch 'ps aux | grep myprocess'
```
- Repeats the `ps` command and filters for "myprocess".
**Highlight Changes in Output**
```bash
watch -d free -h
```
- Highlights changes in memory usage between updates.
**Remove the Header**
```bash
watch -t date
```
- Displays the current date and time without the watch header.

**Summary:**  
The `watch` command is ideal for real-time monitoring of command output, making it easy to track changes and trends. For more, see `man watch`.

---
### `who` – Show Who Is Logged On
The `who` command is used to **display information about users currently logged into the system**. It shows details such as username, terminal, login time, and originating IP or hostname.
#### Basic Usage
```bash
who
```
- Lists all users currently logged in.
#### Key Features
- **User sessions:** Shows all active login sessions.
- **Terminal info:** Displays the terminal or device each user is using.
- **Login time:** Shows when each user logged in.
- **Remote host:** Shows the remote host or IP address if the user is connected remotely.
#### Common Options
- `-a` : Show all available information.
- `-H` : Print column headers.
- `-q` : Quick mode; shows only usernames and the total number of users.
- `-u` : Show idle time for each user.
- `-b` : Show last system boot time.
#### Examples
**Show All Logged-In Users**
```bash
who
```
**Show with Column Headers**
```bash
who -H
```
**Show Only Usernames and Count**
```bash
who -q
```
**Show Last System Boot Time**
```bash
who -b
```

**Summary:**  
The `who` command is a quick way to see who is currently logged into the system and from where. For more, see `man who`.

---
### `whoami` – Print Effective Username of Current User
The `whoami` command is used to **display the effective username of the current user**. It is useful for quickly checking which user account is being used, especially in scripts or when working with `sudo` or switched users.
#### Basic Usage
```bash
whoami
```
- Prints the username of the current user.
#### Key Features
- **Simple and fast:** Outputs only the username.
- **Useful in scripts:** Helps verify user context or permissions.
- **Works in all shells:** Available on all Unix-like systems.
#### Examples
**Show Your Username**
```bash
whoami
```
- Outputs something like `alice` or `root`.
**Check User After Switching with `sudo`**
```bash
sudo whoami
```
- Outputs `root` if run with `sudo`.
**Use in a Script to Display the Current User**
```bash
echo "Running as user: $(whoami)"
```

**Summary:**  
The `whoami` command is a quick way to check your current effective username, which is helpful for troubleshooting, scripting, and verifying permissions. For more, see `man whoami`.

____
### `vmstat` – Report Virtual Memory Statistics
The `vmstat` (virtual memory statistics) command is used to **report information about system memory, processes, interrupts, paging, block I/O, and CPU activity**. It provides a concise summary of system performance and resource usage.
##### Basic Usage
```bash
vmstat
```
- Displays a summary of system memory, processes, paging, block I/O, and CPU activity since the last reboot.
##### Common Options
- `-s` : Display event counters and memory statistics in a readable format.
- `-a` : Show active and inactive memory.
- `-m` : Show slabinfo (kernel memory caches).
- `-d` : Show disk statistics.
- `-t` : Add a timestamp to each line of output.
- `<delay> <count>` : Update the output every `<delay>` seconds, for `<count>` times.
##### Example: Show Statistics Every 2 Seconds
```bash
vmstat 2
```
- Continuously updates the statistics every 2 seconds.
##### Example: Show 5 Updates, 1 Second Apart
```bash
vmstat 1 5
```
- Displays 5 reports, 1 second apart.
##### Example: Show Memory Statistics in Readable Format
```bash
vmstat -s
```
- Prints a summary of memory statistics and event counters.
##### Example: Show Disk Statistics
```bash
vmstat -d
```
- Displays statistics about disk activity.
##### Example: Add Timestamps to Output
```bash
vmstat -t 2 3
```
- Shows 3 updates, every 2 seconds, with timestamps.

**Summary:**  
The `vmstat` command is a powerful tool for monitoring system performance, especially memory, CPU, and I/O activity. It’s useful for troubleshooting performance issues and understanding system resource usage over time. For more, see `man vmstat`.

--- 
## **File System** 
### `ar` – Create, Modify, and Extract from Archives
The `ar` command is used to **create, modify, and extract files from archive libraries**, most commonly static libraries (`.a` files) used in software development. It is primarily used to manage collections of object files for linking with programs.
#### Basic Usage
```bash
ar rcs libfoo.a file1.o file2.o
```
- Creates a new archive `libfoo.a` containing `file1.o` and `file2.o`.
#### Key Features
- **Create static libraries:** Bundle object files for linking.
- **Extract files:** Retrieve individual files from an archive.
- **List contents:** See which files are in an archive.
- **Replace or delete members:** Update or remove files in an archive.
#### Common Options
- `r` : Insert or replace files in the archive.
- `c` : Create the archive if it does not exist.
- `t` : List the contents of the archive.
- `x` : Extract files from the archive.
- `d` : Delete files from the archive.
- `s` : Create an index (symbol table) for faster linking.
- `v` : Verbose output.
#### Examples
**Create a Static Library**
```bash
ar rcs libmath.a add.o sub.o mul.o div.o
```
- Creates `libmath.a` from the object files.
**List Contents of an Archive**
```bash
ar t libmath.a
```
- Lists all object files in `libmath.a`.
**Extract All Files from an Archive**
```bash
ar x libmath.a
```
- Extracts all files from `libmath.a` into the current directory.
**Delete a File from an Archive**
```bash
ar d libmath.a sub.o
```
- Removes `sub.o` from `libmath.a`.

**Summary:**  
The `ar` command is essential for managing static libraries in software development, especially when working with C/C++ projects. For more, see `man ar`.

---
### `basename` – Strip Directory and Suffix from Filenames
The `basename` command is used to **extract the filename from a path**, optionally removing a specified suffix. It is useful in scripts for processing file paths and names.
#### Basic Usage
```bash
basename /path/to/file.txt
```
- Outputs: `file.txt`
#### Key Features
- **Removes directory path:** Returns only the filename portion.
- **Optional suffix removal:** Can strip a file extension or suffix from the result.
- **Script-friendly:** Commonly used in shell scripts for file manipulation.
#### Examples
**Get the Filename from a Path**
```bash
basename /home/user/data/report.pdf
```
- Outputs: `report.pdf`
**Remove a File Extension**
```bash
basename /home/user/data/report.pdf .pdf
```
- Outputs: `report`
**Use with Command Substitution**
```bash
filename=$(basename /var/log/syslog)
echo $filename
```
- Sets `filename` to `syslog`.
**Process Multiple Files in a Script**
```bash
for file in /path/to/*.txt; do
  echo "$(basename "$file" .txt)"
done
```
- Prints the base name (without `.txt`) for each `.txt` file.

**Summary:**  
The `basename` command is a simple but essential tool for extracting filenames and removing suffixes in scripts and command-line operations. For more, see `man basename`.

---
### `Bash Scripts` – Automate Tasks with Shell Scripts
Bash scripts are plain text files containing a series of commands that are executed by the Bash shell. They are used to **automate repetitive tasks, system administration, and complex workflows** on Linux systems.
#### Basic Usage
```bash
./bashscript.sh
```
- Runs the Bash script named `bashscript.sh` in the current directory (must be executable).
#### Key Features
- **Automate tasks:** Run multiple commands in sequence.
- **Variables and logic:** Use variables, loops, conditionals, and functions.
- **Reusable:** Scripts can be reused and shared across systems.

#### Creating and Running a Bash Script
**1. Create a Script File**
```bash
nano myscript.sh
```
- Opens a new file in the nano editor.

**2. Add the Shebang and Commands**
```bash
#!/bin/bash
echo "Hello, world!"
date
```
- The first line (`#!/bin/bash`) tells the system to use Bash to run the script.

**3. Make the Script Executable**
```bash
chmod +x myscript.sh
```
- Grants execute permission to the script.

**4. Run the Script**
```bash
./myscript.sh
```
- Executes the script in the current directory.
#### Advanced Example: Bash Script with Variables and a Loop
```bash
#!/bin/bash
for file in *.txt; do
  echo "Processing $file"
  wc -l "$file"
done
```
- Loops through all `.txt` files and prints the line count for each.
#### Passing Arguments to a Script
```bash
#!/bin/bash
echo "First argument: $1"
echo "Second argument: $2"
```
- `$1`, `$2`, etc., represent arguments passed to the script.

**Run with arguments:**
```bash
./myscript.sh arg1 arg2
```
**Summary:**  
Bash scripts are essential for automating tasks, managing systems, and simplifying complex command sequences in Linux. For more, see `man bash` or online Bash scripting tutorials.

---
### `bzip2` – High-Quality File Compression and Decompression
The `bzip2` command is used to **compress and decompress files** in Linux, similar to `gzip`, but it uses the Burrows-Wheeler compression algorithm, which often achieves better compression ratios (smaller files), though it may be slower.
#### Basic Usage
```bash
bzip2 filename
```
- Compresses `filename` and replaces it with `filename.bz2`.
#### Key Features
- **High compression ratio:** Often produces smaller files than `gzip`.
- **Decompression:** Use `bunzip2` or `bzip2 -d` to decompress `.bz2` files.
- **Works with pipes:** Can compress or decompress data streams.
- **Preserves timestamps:** Keeps original file modification times.
#### Common Options
- `-d` : Decompress a `.bz2` file (same as `bunzip2`).
- `-k` : Keep the original file after compression or decompression.
- `-c` : Write output to standard output (useful for piping).
- `-v` : Verbose mode; show compression progress.
- `-z` : Compress (default behavior).
- `-1` to `-9` : Set compression level (1 = fastest, 9 = best compression; default is 9).
- `-t` : Test the integrity of a compressed file.
#### Examples
**Compress a File**
```bash
bzip2 data.txt
```
- Compresses `data.txt` to `data.txt.bz2` and removes the original file.

**Decompress a File**
```bash
bzip2 -d data.txt.bz2
```
- Decompresses `data.txt.bz2` back to `data.txt`.

**Keep the Original File When Compressing**
```bash
bzip2 -k report.log
```
- Compresses `report.log` to `report.log.bz2` and keeps the original file.

**Compress Output from Another Command**
```bash
cat largefile | bzip2 > largefile.bz2
```
- Compresses the output of `cat largefile` and writes it to `largefile.bz2`.

**Test the Integrity of a Compressed File**
```bash
bzip2 -t archive.tar.bz2
```
- Checks if `archive.tar.bz2` is valid and uncorrupted.

#### Advanced Example: Decompress to Standard Output and Extract with tar
```bash
bzip2 -dc archive.tar.bz2 | tar xvf -
```
- Decompresses `archive.tar.bz2` and extracts its contents with `tar`.

**Summary:**  
The `bzip2` command is a reliable tool for compressing and decompressing files with high compression ratios. It is ideal for backups and archiving where file size matters. For more, see `man bzip2`.

---
### `cat` – Display File Contents
The `cat` (concatenate) command is used to **display the contents of files** on the terminal, combine multiple files, or create new files. It is one of the most basic and frequently used commands for viewing and manipulating text files in Linux.
#### Basic Usage
```bash
cat filename
```
- Displays the contents of `filename` on the terminal.
#### Key Features
- **View file contents:** Quickly print the contents of one or more files.
- **Concatenate files:** Combine multiple files and output the result.
- **Create new files:** Redirect output to create or overwrite files.
- **Number lines:** Optionally display line numbers.
#### Common Options
- `-n` : Number all output lines.
- `-b` : Number non-blank output lines.
- `-s` : Squeeze multiple blank lines into one.
- `-E` : Show `$` at the end of each line.
- `-T` : Show tab characters as `^I`.
- `-A` : Show all non-printing characters (equivalent to `-vET`).
#### Examples
**Display a File**
```bash
cat /etc/hosts
```
- Prints the contents of `/etc/hosts`.
**Display Multiple Files**
```bash
cat file1.txt file2.txt
```
- Prints the contents of both files, one after the other.
**Number All Lines**
```bash
cat -n script.sh
```
- Displays `script.sh` with line numbers.
**Create a New File**
```bash
cat > newfile.txt
```
- Allows you to type text into `newfile.txt` (press `Ctrl+D` to save and exit).
**Concatenate Files into a New File**
```bash
cat file1.txt file2.txt > combined.txt
```
- Combines `file1.txt` and `file2.txt` into `combined.txt`.
**Show Tabs and End of Lines**
```bash
cat -T -E file.txt
```
- Displays tab characters as `^I` and shows `$` at the end of each line.
**Summary:**  
The `cat` command is a fundamental tool for viewing, combining, and creating files in Linux. It is fast, simple, and supports useful options for formatting output. For more, see `man cat`.

---
### `cd` – Change Directory (Directory Navigation)
The `cd` (change directory) command is used to **navigate between directories** in the Linux file system. It is one of the most fundamental commands for moving around the directory tree in the terminal.
#### Basic Usage
```bash
cd /path/to/directory
```
- Changes the current working directory to `/path/to/directory`.
#### Key Features
- **Relative and absolute paths:** You can use both absolute (`/home/user/docs`) and relative (`../docs`) paths.
- **Special shortcuts:** `cd` supports shortcuts for home, previous, and parent directories.
#### Common Examples
**Go to the Home Directory**
```bash
cd
```
or
```bash
cd ~
```
- Takes you to your user's home directory (e.g., `/home/username`).
**Go Up One Directory Level**
```bash
cd ..
```
- Moves up to the parent directory.
**Go to the Previous Directory**
```bash
cd -
```
- Switches to the last directory you were in.
**Go to the Root Directory**
```bash
cd /
```
- Takes you to the root of the filesystem.
**Navigate Using Relative Paths**
```bash
cd ../sibling_folder
```
- Moves up one level, then into `sibling_folder`.
#### Advanced Example: Chain Navigation
```bash
cd ~/projects/linux/scripts
```
- Quickly jumps to a deeply nested directory using an absolute or tilde (`~`) path.#### Tips
- Use `pwd` to print your current directory.
- Tab completion helps auto-complete directory names.
**Summary:**  
The `cd` command is essential for navigating the Linux file system from the command line. Mastering its shortcuts and path options makes moving around directories fast and efficient. For more, see `man cd` (as a shell builtin, check your shell's documentation).

---
### `chattr` – Change File Attributes on a Linux File System
The `chattr` command is used to **change special file attributes** on Linux file systems, especially ext2, ext3, and ext4. These attributes can make files immutable, append-only, undeletable, and more, providing an extra layer of protection or control.
#### Basic Usage
```bash
sudo chattr +i filename
```
- Sets the immutable attribute on `filename` (cannot be changed, deleted, or renamed).
#### Key Features
- **Set or remove special attributes:** Control file behaviors beyond standard permissions.
- **Works on files and directories:** Can apply attributes recursively.
- **Security and protection:** Prevent accidental or unauthorized changes.
#### Common Options
- `+i` : Set immutable (file cannot be modified, deleted, or renamed).
- `-i` : Remove immutable.
- `+a` : Set append-only (file can only be added to, not modified or deleted).
- `-a` : Remove append-only.
- `-R` : Apply changes recursively to directories and their contents.
- `+e` / `-e` : Enable/disable extents (for ext4).
- `+A` / `-A` : Disable/enable atime updates.
#### Examples
**Make a File Immutable**
```bash
sudo chattr +i important.txt
```
- Prevents any changes or deletion of `important.txt` until the attribute is removed.
**Remove the Immutable Attribute**
```bash
sudo chattr -i important.txt
```
- Allows changes or deletion again.
**Set Append-Only Attribute**
```bash
sudo chattr +a logfile.log
```
- Only allows appending to `logfile.log`; cannot overwrite or delete content.
**Apply Attribute Recursively to a Directory**
```bash
sudo chattr -R +i /var/secure_data/
```
- Makes all files and subdirectories in `/var/secure_data/` immutable.
#### List Current Attributes
Use `lsattr` to view current attributes:
```bash
lsattr filename
```

**Summary:**  
The `chattr` command is essential for setting advanced file attributes, adding extra protection or control over files and directories on Linux file systems. For more, see `man chattr`.

___
### `cheat` – Interactive Command-Line Cheat Sheets
The `cheat` command allows you to **create, view, and share interactive cheat sheets** directly from the command line. It is designed to provide quick, concise help for Linux commands, scripts, and workflows without leaving your terminal.
#### Basic Usage
```bash
cheat <command>
```
- Displays the cheat sheet for the specified command (e.g., `cheat tar`).
#### Key Features
- **Community-driven:** Access a large collection of community-maintained cheat sheets.
- **Custom sheets:** Create your own personal or team-specific cheat sheets.
- **Searchable:** Quickly search for commands or keywords within cheat sheets.
- **Syntax highlighting:** Colorful, easy-to-read formatting for code and examples.
- **Offline access:** Cheat sheets are available even without an internet connection.
#### Common Examples
**View a Cheat Sheet for a Command**
```bash
cheat ls
```
- Shows the cheat sheet for the `ls` command.
**Search for a Keyword Across All Cheat Sheets**
```bash
cheat -s "find file"
```
- Searches all cheat sheets for the phrase "find file".
**Edit or Create a Custom Cheat Sheet**
```bash
cheat -e myscript
```
- Opens your editor to create or modify a cheat sheet named `myscript`.
**List All Available Cheat Sheets**
```bash
cheat -l
```
- Lists all cheat sheets available on your system.
#### Advanced Example: Add a New Cheat Sheet
```bash
cheat -e git-aliases
```
- Create a custom cheat sheet for your favorite Git aliases and workflows.
#### Configuration
- You can configure the cheat directory and sources in `~/.config/cheat/conf.yml`.
- Supports integration with community repositories for up-to-date sheets.

**Summary:**  
The `cheat` command is a powerful productivity tool for Linux users, sysadmins, and developers. It provides instant access to helpful command examples and documentation, making it easier to remember complex syntax and workflows. For more, see [cheat.sh](https://github.com/cheat/cheat) or run `cheat -h`.

---
### `chmod` – Change File and Directory Permissions
The `chmod` (change mode) command is used to **change the access permissions of files and directories** in Linux. Permissions control who can read, write, or execute a file or directory.
#### Basic Usage
```bash
chmod <permissions> <file>
```
- Changes the permissions of `<file>` to the specified mode.
#### Key Features
- **Symbolic and numeric modes:** Set permissions using symbolic notation (e.g., `u+x`) or octal numbers (e.g., `755`).
- **Recursive changes:** Apply permissions to directories and their contents.
- **Fine-grained control:** Set permissions for user (owner), group, and others.
#### Permission Structure
- **r** = read (4)
- **w** = write (2)
- **x** = execute (1)
**Order:** user (u), group (g), others (o)
#### Numeric (Octal) Examples
- `7` = read, write, execute
- `6` = read, write
- `5` = read, execute
- `4` = read

**Common Permission Sets:**
- `755` = rwxr-xr-x (owner can read/write/execute; group/others can read/execute)
- `644` = rw-r--r-- (owner can read/write; group/others can read)
#### Symbolic Examples
- `u+x` : Add execute permission for the user (owner)
- `g-w` : Remove write permission for the group
- `o=r` : Set others’ permissions to read only
#### Examples
**Set Permissions Using Octal Notation**
```bash
chmod 755 script.sh
```
- Sets `rwxr-xr-x` permissions on `script.sh`.
**Add Execute Permission for the Owner**
```bash
chmod u+x myfile
```
- Adds execute permission for the file owner.
**Remove Write Permission for Group**
```bash
chmod g-w notes.txt
```
- Removes write permission from the group for `notes.txt`.
**Set Read-Only for Everyone**
```bash
chmod 444 document.txt
```
- Sets read-only permissions for all users.
**Change Permissions Recursively**
```bash
chmod -R 700 myfolder/
```
- Sets `rwx------` on `myfolder` and all its contents.
#### Advanced Example: Set Permissions for Multiple Classes
```bash
chmod ug+rw,o-rwx file.txt
```
- Gives read/write to user and group, removes all permissions for others.
**Summary:**  
The `chmod` command is essential for managing file and directory permissions, ensuring proper access control and security. For more, see `man chmod`.

---
### `chown` – Change File Owner and Group
The `chown` (change owner) command is used to **change the owner and/or group of files and directories** in Linux. This is essential for managing file permissions and access control, especially in multi-user environments.
#### Basic Usage
```bash
chown <owner> <file>
```
- Changes the owner of `<file>` to `<owner>`.
```bash
chown <owner>:<group> <file>
```
- Changes both the owner and group of `<file>`.
#### Key Features
- **Change ownership recursively:** Apply changes to all files and subdirectories.
- **Set owner, group, or both:** Specify just the owner, just the group, or both.
- **Works on files and directories:** Can be used for single files, multiple files, or entire directories.
#### Common Options
- `-R` : Recursively change ownership for all files and subdirectories.
- `-c` : Report only when a change is made.
- `-v` : Verbose mode; show files as ownership is changed.
- `--reference=<ref_file>` : Use the owner and group of `<ref_file>`.
#### Examples
**Change Owner of a File**
```bash
sudo chown alice file.txt
```
- Sets the owner of `file.txt` to `alice`.
**Change Owner and Group**
```bash
sudo chown alice:staff file.txt
```
- Sets the owner to `alice` and the group to `staff`.
**Change Group Only**
```bash
sudo chown :developers script.sh
```
- Changes only the group of `script.sh` to `developers`.
**Recursively Change Ownership of a Directory**
```bash
sudo chown -R bob:users /var/www/
```
- Changes the owner to `bob` and group to `users` for `/var/www/` and all its contents.
**Set Ownership Based on Another File**
```bash
sudo chown --reference=ref.txt target.txt
```
- Sets the owner and group of `target.txt` to match `ref.txt`.
**Summary:**  
The `chown` command is essential for managing file and directory ownership, ensuring proper access control and security on Linux systems. For more, see `man chown`.

---
### `chroot` – Run Command or Shell with a Special Root Directory
The `chroot` command is used to **run a command or interactive shell with a different root directory**. This creates a "chroot jail," isolating the process and its children from the rest of the filesystem. It is commonly used for system recovery, testing, or enhancing security.
#### Basic Usage
```bash
sudo chroot /new/root /bin/bash
```
- Starts a Bash shell with `/new/root` as the root directory.
#### Key Features
- **Filesystem isolation:** Restricts the process to a specific directory tree.
- **System recovery:** Useful for repairing systems by mounting the root filesystem elsewhere and chrooting into it.
- **Testing and development:** Run software in a controlled environment.
- **Security:** Limit the view and access of processes (not a full security solution).
#### Common Options
- `<directory>` : The new root directory for the command or shell.
- `<command>` : The command to run inside the chroot (default is `/bin/sh`).
#### Examples
**Start a Shell in a Chroot Jail**
```bash
sudo chroot /mnt/recovery
```
- Opens a shell with `/mnt/recovery` as the root directory.
**Run a Specific Command in Chroot**
```bash
sudo chroot /mnt/test /usr/bin/python3 script.py
```
- Runs `script.py` using Python 3 inside the `/mnt/test` chroot.
**Typical System Recovery Workflow**
1. Boot from live media.
2. Mount the root filesystem:
   ```bash
   sudo mount /dev/sda1 /mnt
   ```
3. Mount necessary filesystems:
   ```bash
   sudo mount --bind /dev /mnt/dev
   sudo mount --bind /proc /mnt/proc
   sudo mount --bind /sys /mnt/sys
   ```
4. Enter the chroot:
   ```bash
   sudo chroot /mnt
   ```
**Summary:**  
The `chroot` command is a powerful tool for isolating processes, performing system recovery, and testing in a controlled environment. For more, see `man chroot`.

---
### `compress` / `uncompress` – Compress or Expand Files
The `compress` command is used to **compress files**, reducing their size and saving disk space. The `uncompress` command is used to **expand files** that were previously compressed with `compress`. These utilities use the `.Z` file extension and are common on older Unix systems, but are still available on many Linux distributions.

#### Basic Usage
**Compress a File**
```bash
compress filename
```
- Compresses `filename` to `filename.Z` and removes the original file.
**Uncompress a File**
```bash
uncompress filename.Z
```
- Expands `filename.Z` back to `filename`.
#### Key Features
- **Simple compression:** Reduces file size for storage or transfer.
- **Legacy compatibility:** Useful for working with older Unix systems and archives.
- **Works with single files:** Does not support compressing directories (use with `tar` for archives).
#### Common Options
- `-c` : Write output to standard output (useful for piping).
- `-f` : Force compression or expansion, even if the file already exists.
- `-v` : Verbose mode; show compression ratio or progress.

#### Examples
**Compress a File and Keep the Original**
```bash
compress -c file.txt > file.txt.Z
```
- Compresses `file.txt` and writes the output to `file.txt.Z`, keeping the original.
**Uncompress to Standard Output**
```bash
uncompress -c file.txt.Z > file.txt
```
- Expands `file.txt.Z` and writes the result to `file.txt`.
**Compress All `.log` Files in a Directory**
```bash
compress *.log
```
- Compresses all `.log` files, creating `.log.Z` files.

**Summary:**  
The `compress` and `uncompress` commands provide basic file compression and expansion, mainly for compatibility with older systems and archives. For more modern compression, use `gzip`, `bzip2`, or `xz`. For more, see `man compress` and `man uncompress`.

---
### `cp` – Copy Files and Directories
The `cp` (copy) command is used to **copy files and directories** from one location to another in Linux. It is one of the most fundamental file management commands.
#### Basic Usage
```bash
cp source_file destination_file
```
- Copies `source_file` to `destination_file`.
#### Key Features
- **Copy multiple files:** Supports copying several files at once to a directory.
- **Recursive copy:** Can copy entire directories and their contents.
- **Preserve attributes:** Can preserve file permissions, timestamps, and ownership.
#### Common Options
- `-r` or `-R` : Copy directories recursively (required for copying folders).
- `-i` : Prompt before overwriting existing files.
- `-u` : Copy only when the source file is newer than the destination or when the destination file is missing.
- `-v` : Verbose mode; show files as they are copied.
- `-p` : Preserve file attributes (mode, ownership, timestamps).
- `-a` : Archive mode (same as `-rp` plus preserve links, devices, etc.).
#### Examples
**Copy a File**
```bash
cp file.txt /home/user/backup.txt
```
- Copies `file.txt` to `/home/user/backup.txt`.

**Copy Multiple Files to a Directory**
```bash
cp file1.txt file2.txt /home/user/backup/
```
- Copies both files into the `/home/user/backup/` directory.

**Copy a Directory Recursively**
```bash
cp -r myfolder /home/user/backup/
```
- Copies the entire `myfolder` directory and its contents.

**Prompt Before Overwriting**
```bash
cp -i file.txt /home/user/backup.txt
```
- Asks for confirmation before overwriting `backup.txt`.

**Preserve File Attributes**
```bash
cp -p file.txt /home/user/backup.txt
```
- Copies the file and preserves its permissions, timestamps, and ownership.

**Archive Mode (Best for Backups)**
```bash
cp -a myfolder /mnt/backup/
```
- Recursively copies `myfolder` and preserves all attributes.
#### Advanced Example: Verbose Recursive Copy
```bash
cp -rv myfolder /mnt/backup/
```
- Recursively copies `myfolder` and prints each file as it is copied.
**Summary:**  
The `cp` command is essential for copying files and directories in Linux. With its options, you can control overwriting, preserve attributes, and handle complex directory structures. For more, see `man cp`.

---
### `cpio` – Copy Files to and from Archives
The `cpio` command is used to **create, extract, and list files from archive files**. It is commonly used for backups, restoring files, and transferring files between systems. Unlike `tar`, `cpio` reads file lists from standard input, making it flexible for use with `find` and other commands.
#### Basic Usage
**Create an Archive**
```bash
find . -type f | cpio -ov > archive.cpio
```
- Archives all files in the current directory and its subdirectories into `archive.cpio`.

**Extract an Archive**
```bash
cpio -idv < archive.cpio
```
- Extracts files from `archive.cpio` into the current directory.

**List Contents of an Archive**
```bash
cpio -it < archive.cpio
```
- Lists the files contained in `archive.cpio`.
#### Key Features
- **Flexible input:** Reads file lists from standard input (e.g., from `find`).
- **Multiple archive formats:** Supports several archive formats (`bin`, `odc`, `newc`, `ustar`, etc.).
- **Preserves file attributes:** Maintains permissions, ownership, and timestamps.
- **Works with pipes:** Easily integrates with other commands for advanced workflows.
#### Common Options
- `-o` : Create an archive (copy-out mode).
- `-i` : Extract files from an archive (copy-in mode).
- `-t` : List the contents of an archive.
- `-v` : Verbose output; list files processed.
- `-d` : Create directories as needed when extracting.
- `-u` : Overwrite existing files when extracting.
- `-A` : Append files to an existing archive.
- `-F <archive>` : Specify the archive file to use.
#### Examples
**Backup All `.conf` Files**
```bash
find /etc -name "*.conf" | cpio -ov > conf_backup.cpio
```
**Restore Files from an Archive**
```bash
cpio -idv < conf_backup.cpio
```
**Append Files to an Existing Archive**
```bash
find morefiles/ | cpio -oA -F archive.cpio
```

**Summary:**  
The `cpio` command is a versatile tool for creating, extracting, and managing file archives, especially in combination with `find` and other commands. For more, see `man cpio`.

---
### `curl` – Transfer Data Using Various Network Protocols
The `curl` command is a **versatile tool for transferring data to or from a server** using a wide range of supported protocols, including HTTP, HTTPS, FTP, FTPS, SCP, SFTP, LDAP, and more. It is commonly used for downloading files, testing APIs, and automating web requests.
#### Basic Usage
```bash
curl <URL>
```
- Fetches the content at the specified URL and prints it to standard output.
#### Key Features
- **Supports many protocols:** HTTP, HTTPS, FTP, FTPS, SFTP, SCP, LDAP, and more.
- **Download and upload:** Can both download and upload files.
- **Custom headers and authentication:** Supports setting headers, cookies, and various authentication methods.
- **API testing:** Easily send GET, POST, PUT, DELETE, and other HTTP requests.
- **Save output to file:** Download files directly to disk.
#### Common Options
- `-o <file>` : Write output to a file instead of stdout.
- `-O` : Save with the remote file name.
- `-L` : Follow HTTP redirects.
- `-I` : Fetch only the HTTP headers.
- `-d <data>` : Send data in a POST request.
- `-X <method>` : Specify the HTTP request method (GET, POST, PUT, DELETE, etc.).
- `-u <user:pass>` : Use basic authentication.
- `-H <header>` : Add custom headers.
- `-k` : Allow insecure SSL connections.
- `-s` : Silent mode (no progress or error messages).
- `-v` : Verbose output (debugging).
#### Examples
**Download a File**
```bash
curl -O https://example.com/file.zip
```
- Downloads `file.zip` and saves it with the same name.
**Save Output to a Specific File**
```bash
curl -o mypage.html https://example.com
```
- Saves the downloaded page as `mypage.html`.
**Follow Redirects**
```bash
curl -L http://example.com
```
- Follows HTTP redirects to the final destination.
**Send a POST Request with Data**
```bash
curl -d "username=admin&password=secret" -X POST https://example.com/login
```
- Sends a POST request with form data.
**Add Custom HTTP Headers**
```bash
curl -H "Authorization: Bearer TOKEN" https://api.example.com/data
```
- Adds an HTTP header for authentication.
**Show Only HTTP Headers**
```bash
curl -I https://example.com
```
- Fetches only the HTTP headers.
**Download a File via FTP**
```bash
curl -u user:pass -O ftp://ftp.example.com/file.txt
```
- Downloads a file from an FTP server using authentication.
#### Advanced Example: Download Multiple Files
```bash
curl -O https://example.com/file1.txt -O https://example.com/file2.txt
```
- Downloads both files in one command.

**Summary:**  
The `curl` command is a powerful and flexible tool for transferring data, testing APIs, and automating web requests. It is essential for developers, sysadmins, and anyone working with networked resources. For more, see `man curl`.

---
### `cut` – Remove Sections from Each Line of Files
The `cut` command is used to **extract specific sections (fields or columns) from each line of a file or input stream**. It is commonly used for processing delimited text files, such as CSVs or logs.
#### Basic Usage
```bash
cut -d',' -f1 file.csv
```
- Extracts the first field from each line of `file.csv`, using a comma as the delimiter.
#### Key Features
- **Field extraction:** Select specific fields based on a delimiter.
- **Character extraction:** Select specific character positions from each line.
- **Works with standard input:** Can be used in pipelines.
#### Common Options
- `-d <delimiter>` : Specify the field delimiter (default is TAB).
- `-f <fields>` : Select only these fields (e.g., `-f1,3` for fields 1 and 3).
- `-c <positions>` : Select only these character positions (e.g., `-c1-5` for the first five characters).
- `--complement` : Invert the selection (show all except specified fields/characters).
- `-s` : Suppress lines with no delimiter.
#### Examples
**Extract the Second Field from a Colon-Delimited File**
```bash
cut -d':' -f2 /etc/passwd
```
**Extract the First 10 Characters of Each Line**
```bash
cut -c1-10 file.txt
```
**Extract Multiple Fields**
```bash
cut -d',' -f1,3,5 data.csv
```
**Use with a Pipeline**
```bash
ps aux | cut -c1-20
```
- Shows only the first 20 characters of each line from `ps aux`.

**Summary:**  
The `cut` command is a fast and efficient tool for extracting columns or character ranges from text files and command output. For more, see `man cut`.

___
### `dd` – Convert and Copy Files
The `dd` command is a **low-level utility for copying and converting files and data streams**. It is commonly used for tasks such as creating disk images, cloning drives, backing up partitions, and writing ISO files to USB drives.
#### Basic Usage
```bash
dd if=<input_file> of=<output_file>
```
- Copies data from `<input_file>` to `<output_file>`.
#### Key Features
- **Block-level copying:** Reads and writes data in blocks, making it suitable for raw device operations.
- **Conversion:** Can convert data formats (e.g., ASCII to EBCDIC, upper to lower case).
- **Backup and restore:** Used for disk cloning, partition backup, and recovery.
- **Data wiping:** Can overwrite disks with random or zero data for secure erasure.
#### Common Options
- `if=` : Input file or device (e.g., `if=/dev/sda`).
- `of=` : Output file or device (e.g., `of=/dev/sdb`).
- `bs=` : Block size (e.g., `bs=4M` for 4 megabytes).
- `count=` : Number of blocks to copy.
- `skip=` : Skip a number of blocks at the start of input.
- `seek=` : Skip a number of blocks at the start of output.
- `conv=` : Specify conversions (e.g., `noerror`, `sync`, `ucase`, `lcase`).
#### Examples
**Create a Disk Image**
```bash
dd if=/dev/sda of=/home/user/sda.img bs=4M status=progress
```
- Creates an image of the entire `/dev/sda` disk.
**Write an ISO Image to a USB Drive**
```bash
sudo dd if=linux.iso of=/dev/sdX bs=4M status=progress
```
- Writes `linux.iso` to the USB device `/dev/sdX` (replace `sdX` with your USB device).
**Clone One Disk to Another**
```bash
sudo dd if=/dev/sda of=/dev/sdb bs=64K conv=noerror,sync status=progress
```
- Clones `/dev/sda` to `/dev/sdb`, continuing on read errors and syncing blocks.
**Wipe a Disk with Zeros**
```bash
sudo dd if=/dev/zero of=/dev/sdX bs=1M status=progress
```
- Overwrites the entire disk with zeros (data destruction).
#### Advanced Example: Backup and Restore MBR (Master Boot Record)
**Backup MBR:**
```bash
sudo dd if=/dev/sda of=mbr_backup.img bs=512 count=1
```
**Restore MBR:**
```bash
sudo dd if=mbr_backup.img of=/dev/sda bs=512 count=1
```

**Warning:**  
`dd` is a powerful tool—**a small mistake can result in data loss**. Always double-check your input and output paths before running.

**Summary:**  
The `dd` command is essential for low-level copying, imaging, and conversion tasks in Linux. It is widely used for backups, cloning, and system recovery. For more, see `man dd`.

---
### `diff` – Compare Files Line by Line
The `diff` command is used to **compare two files line by line** and display the differences between them. It is especially useful for comparing text files such as scripts, configuration files, or source code to identify changes or discrepancies.
#### Basic Usage
```bash
diff file1.txt file2.txt
```
- Compares `file1.txt` and `file2.txt`, showing the differences.
#### Key Features
- **Line-by-line comparison:** Highlights added, removed, or changed lines.
- **Multiple output formats:** Unified, context, and normal diff formats.
- **Patch creation:** Output can be used to create patch files for updating other files.
- **Directory comparison:** Can compare entire directories recursively.
#### Common Options
- `-u` : Unified format (shows a few lines of context; commonly used for patches).
- `-c` : Context format (shows more context around changes).
- `-i` : Ignore case differences.
- `-w` : Ignore all whitespace.
- `-r` : Recursively compare directories.
- `--color=auto` : Colorize the output for easier reading.
#### Examples
**Show Differences in Unified Format**
```bash
diff -u old.conf new.conf
```
- Displays differences with a few lines of context (good for code reviews and patches).
**Ignore Whitespace and Case**
```bash
diff -iw file1.txt file2.txt
```
- Ignores differences in whitespace and case.
**Compare Two Directories Recursively**
```bash
diff -r dir1/ dir2/
```
- Compares all files in `dir1` and `dir2` recursively.
**Create a Patch File**
```bash
diff -u original.txt updated.txt > changes.patch
```
- Saves the differences to `changes.patch` for later use with `patch`.

**Summary:**  
The `diff` command is essential for finding and reviewing differences between files or directories. It is widely used in development, configuration management, and troubleshooting. For more, see `man diff`.

---
### `dirname` – Strip Last Component from File Name
The `dirname` command is used to **extract the directory path from a full file path**, removing the last component (usually the filename). It is useful in scripts for processing and manipulating file paths.
#### Basic Usage
```bash
dirname /path/to/file.txt
```
- Outputs: `/path/to`
#### Key Features
- **Removes filename:** Returns only the directory portion of a path.
- **Script-friendly:** Commonly used in shell scripts for path manipulation.
- **Works with relative and absolute paths.**
#### Examples
**Get the Directory Path from a Full Path**
```bash
dirname /home/user/data/report.pdf
```
- Outputs: `/home/user/data`
**Use with Command Substitution**
```bash
dirpath=$(dirname /var/log/syslog)
echo $dirpath
```
- Sets `dirpath` to `/var/log`.
**Process Multiple Paths in a Script**
```bash
for file in /path/to/*.txt; do
  echo "$(dirname "$file")"
done
```
- Prints the directory path for each `.txt` file.

**Summary:**  
The `dirname` command is a simple but essential tool for extracting directory paths from file paths in scripts and command-line operations. For more, see `man dirname`.

---
### `dmesg` – Print Kernel Ring Buffer Messages
The `dmesg` command is used to **display the message buffer of the Linux kernel** (the "kernel ring buffer"). It shows system messages related to hardware, drivers, kernel events, and boot diagnostics. This is especially useful for troubleshooting hardware issues, driver problems, and system startup.
#### Basic Usage
```bash
dmesg
```
- Prints all kernel messages since the last boot.
#### Key Features
- **View hardware and driver messages:** See logs from device initialization, driver loading, and kernel events.
- **Troubleshoot boot and hardware issues:** Quickly spot errors or warnings from the kernel.
- **Filter and search:** Combine with `grep` to find specific messages.
- **Timestamped output:** Optionally show human-readable timestamps.
#### Common Options
- `-T` : Show human-readable timestamps.
- `-H` : Enable a pager for easier reading (interactive mode).
- `-l <level>` : Show only messages of a specific log level (e.g., `err`, `warn`, `info`).
- `-f <facility>` : Show only messages from a specific facility (e.g., `kern`, `usb`).
#### Examples
**Show Kernel Messages with Human-Readable Timestamps**
```bash
dmesg -T
```
**Filter for USB Events**
```bash
dmesg | grep usb
```
**Show Only Error Messages**
```bash
dmesg --level=err
```
**Interactively Browse Kernel Messages**
```bash
dmesg -H
```
**Summary:**  
The `dmesg` command is essential for viewing kernel and hardware-related messages, making it invaluable for troubleshooting and diagnostics. For more, see `man dmesg`.

---
### `expr` – Evaluate Expressions
The `expr` command is used to **evaluate expressions** in the shell, including arithmetic calculations, string operations, and logical comparisons. It is commonly used in shell scripts for simple math and text processing.
#### Basic Usage
```bash
expr 5 + 3
```
- Outputs: `8`
#### Key Features
- **Arithmetic operations:** Addition, subtraction, multiplication, division, modulus.
- **String operations:** Find length, extract substrings, search for patterns.
- **Logical comparisons:** Compare numbers or strings.
#### Examples
**Arithmetic Calculation**
```bash
expr 10 \* 2
```
- Outputs: `20` (Note: `*` must be escaped or quoted.)
**String Length**
```bash
expr length "hello"
```
- Outputs: `5`
**Substring Extraction**
```bash
expr substr "abcdef" 2 3
```
- Outputs: `bcd` (start at position 2, length 3)
**String Comparison**
```bash
expr "abc" = "abc"
```
- Outputs: `1` (true)
**In a Shell Script**
```bash
count=$(expr $count + 1)
```
- Increments the value of `count` by 1.

**Summary:**  
The `expr` command is a simple tool for performing calculations and string operations in shell scripts. For more, see `man expr`.

---
### `file` – Determine File Type
The `file` command is used to **identify the type of a file** by examining its contents rather than its name or extension. It can distinguish between text, binary, executable, image, archive, and many other file types.
#### Basic Usage
```bash
file filename
```
- Outputs the type of `filename` (e.g., ASCII text, PNG image, ELF executable).
#### Key Features
- **Content-based detection:** Analyzes file headers and data, not just extensions.
- **Multiple files:** Can check several files at once.
- **Script-friendly:** Useful in scripts to verify file types before processing.
#### Examples
**Check the Type of a Single File**
```bash
file myscript.sh
```
- Might output: `myscript.sh: Bourne-Again shell script, ASCII text executable`
**Check Multiple Files**
```bash
file *.jpg
```
- Lists the type of each `.jpg` file in the directory.
**Check a File with No Extension**
```bash
file backup_2025_06_08
```
- Identifies the file type even if there is no extension.

**Summary:**  
The `file` command is a quick and reliable way to determine the actual type of a file, regardless of its name or extension. For more, see `man file`.

---
### `find` – Locate Files Based on Criteria
The `find` command is used to **search for files and directories** in a directory hierarchy based on user-specified criteria such as name, type, size, modification time, permissions, and more.
##### Basic Usage
```bash
find /path/to/search -name "filename"
```
- Searches for files named `filename` under `/path/to/search`.
##### Common Options
- `-name` : Search for files by name (supports wildcards, e.g., `*.txt`)
- `-type` : Search by file type (`f` for files, `d` for directories, `l` for symlinks)
- `-size` : Search by file size (e.g., `+100M` for files larger than 100MB)
- `-mtime` : Search by modification time (e.g., `-mtime -7` for files modified in the last 7 days)
- `-user` : Search for files owned by a specific user
- `-perm` : Search by file permissions (e.g., `-perm 644`)
- `-exec` : Execute a command on each found file
- `-delete` : Delete found files (use with caution)
##### Find All `.log` Files
```bash
find /var/log -name "*.log"
```
- Lists all files ending with `.log` under `/var/log`.
##### Find Files Larger Than 500MB
```bash
find /home -type f -size +500M
```
- Finds files larger than 500MB in `/home`.
##### Find Files Modified in the Last 2 Days
```bash
find . -mtime -2
```
- Finds files in the current directory modified in the last 2 days.
##### Find and Delete All `.tmp` Files
```bash
find /tmp -name "*.tmp" -delete
```
- Deletes all `.tmp` files in `/tmp`.
##### Find Files and Execute a Command
```bash
find /var/www -type f -name "*.php" -exec chmod 644 {} \;
```
- Changes permissions of all `.php` files under `/var/www` to `644`.
##### Advanced Example: Find Empty Directories
```bash
find /home -type d -empty
```
- Lists all empty directories under `/home`.

**Summary:**  
The `find` command is a powerful tool for locating files and directories based on a wide range of criteria. It supports complex searches and can execute actions on found items. For more, see `man find`.

---
### `findmnt` – Find a Filesystem
The `findmnt` command is used to **display information about mounted filesystems** or search for a filesystem. It provides a tree view of all mount points, their source devices, filesystem types, and mount options.
#### Basic Usage
```bash
findmnt
```
- Shows a tree of all currently mounted filesystems.
#### Key Features
- **Tree or list view:** Visualize mount points and their relationships.
- **Search by device, mount point, or filesystem type.**
- **Show mount options, source, and target.**
- **Script-friendly output:** Supports custom columns and output formats.
#### Common Options
- `-l` : List output (no tree view).
- `-t <type>` : Filter by filesystem type (e.g., `-t ext4`).
- `-S <source>` : Search by source device (e.g., `/dev/sda1`).
- `-T <target>` : Search by mount point (e.g., `/home`).
- `-o <columns>` : Specify output columns (e.g., `-o TARGET,SOURCE,FSTYPE,OPTIONS`).
- `-n` : Suppress the header line.
#### Examples
**Show All Mounted Filesystems**
```bash
findmnt
```
**List Only ext4 Filesystems**
```bash
findmnt -t ext4
```
**Find the Mount Point for a Device**
```bash
findmnt -S /dev/sdb1
```
**Find the Source Device for a Mount Point**
```bash
findmnt -T /home
```
**Show Custom Columns**
```bash
findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS
```
**Summary:**  
The `findmnt` command is a modern tool for viewing and searching mounted filesystems, making it easy to find mount points, devices, and filesystem types. For more, see `man findmnt`.

___
### `fsck` – Check and Repair File System Consistency
The `fsck` (file system check) command is used to **check and repair Linux file systems** for errors and inconsistencies. It scans the specified device or partition and attempts to fix detected problems, helping to maintain file system integrity.
#### Basic Usage
```bash
sudo fsck /dev/sdX1
```
- Checks and repairs the file system on the specified device or partition (replace `/dev/sdX1` with your device).
#### Key Features
- **Supports multiple file systems:** Works with ext2, ext3, ext4, xfs, btrfs, vfat, and more.
- **Automatic or interactive repair:** Can automatically fix errors or prompt for confirmation.
- **Essential for recovery:** Used when a file system is corrupted or after improper shutdowns.
#### Common Options
- `-A` : Check all filesystems listed in `/etc/fstab`.
- `-N` : Show what would be done, but do not execute.
- `-a` : Automatically repair the file system without prompting (deprecated; use `-y`).
- `-y` : Assume "yes" to all prompts (repair all detected problems).
- `-n` : Assume "no" to all prompts (do not make any changes).
- `-C` : Show progress bar (if supported by the filesystem checker).
#### Examples
**Check and Repair a Partition**
```bash
sudo fsck -y /dev/sdb1
```
- Checks and automatically repairs `/dev/sdb1`.

**Check All File Systems in fstab**
```bash
sudo fsck -A
```
- Checks all file systems listed in `/etc/fstab`.

**Show What Would Be Done (Dry Run)**
```bash
sudo fsck -N /dev/sdb1
```
- Displays the actions that would be taken, but does not perform them.

**Check a File System Without Making Changes**
```bash
sudo fsck -n /dev/sdb1
```
- Checks for errors but does not attempt to fix them.
#### Advanced Example: Check and Repair on Next Boot
```bash
sudo touch /forcefsck
```
- Forces a full file system check on the next system reboot.
**Warning:**  
Always unmount the file system or run `fsck` in single-user/recovery mode to avoid data corruption. Never run `fsck` on a mounted, read-write file system.

**Summary:**  
The `fsck` command is essential for maintaining file system health and recovering from disk errors. For more, see `man fsck` and the manual for your specific file system type (e.g., `man e2fsck`).

---
### `grep` – Search a File for a Pattern of Characters
The `grep` command is used to **search for lines in files that match a specified pattern**. It prints all matching lines and is one of the most powerful tools for searching and filtering text.
##### Basic Usage
```bash
grep "pattern" filename
```
- Searches for `"pattern"` in `filename` and displays all matching lines.
##### Common Options
- `-i` : Ignore case distinctions in patterns and data.
- `-r` or `-R` : Recursively search subdirectories.
- `-v` : Invert match (show lines that do **not** match the pattern).
- `-n` : Show line numbers of matching lines.
- `-l` : List only filenames with matches.
- `-c` : Count the number of matching lines.
- `-A N` : Show N lines **after** each match.
- `-B N` : Show N lines **before** each match.
- `-C N` : Show N lines **before and after** each match.
- `-E` : Use extended regular expressions (same as `egrep`).
##### Example: Case-Insensitive Search
```bash
grep -i "error" /var/log/syslog
```
- Finds all lines containing "error" (case-insensitive) in `/var/log/syslog`.
##### Example: Recursive Search in All Files
```bash
grep -r "TODO" ~/projects/
```
- Searches for "TODO" in all files under `~/projects/` recursively.
##### Example: Show Line Numbers
```bash
grep -n "main" program.c
```
- Shows line numbers for each match of "main" in `program.c`.
##### Example: Invert Match
```bash
grep -v "^#" config.conf
```
- Shows all lines in `config.conf` that do **not** start with `#` (ignoring comments).
##### Example: Count Matches
```bash
grep -c "session" /var/log/auth.log
```
- Counts the number of lines containing "session" in the file.
##### Advanced Example: Show Context Around Matches
```bash
grep -C 3 "fail" /var/log/messages
```
- Shows 3 lines before and after each match of "fail".
**Summary:**  
The `grep` command is essential for searching and filtering text in files or output. It supports regular expressions, recursive search, context display, and much more. For more, see `man grep`.

---
### `gzip` – File Compression and Decompression
The `gzip` (GNU zip) command is used to **compress and decompress files** in Linux. It is commonly used to reduce the size of files for storage or transfer, and is often used in combination with `tar` for archiving.
#### Basic Usage
```bash
gzip filename
```
- Compresses `filename` and replaces it with `filename.gz`.
#### Key Features
- **Efficient compression:** Reduces file size using the DEFLATE algorithm.
- **Decompression:** Can decompress `.gz` files back to their original form.
- **Works with pipes:** Can compress or decompress data streams.
- **Preserves timestamps:** Keeps original file modification times.
#### Common Options
- `-d` : Decompress a `.gz` file (same as `gunzip`).
- `-k` : Keep the original file after compression or decompression.
- `-c` : Write output to standard output (useful for piping).
- `-r` : Recursively compress files in directories.
- `-l` : List compression statistics for a `.gz` file.
- `-1` to `-9` : Set compression level (1 = fastest, 9 = best compression).
#### Examples
**Compress a File**
```bash
gzip report.txt
```
- Compresses `report.txt` to `report.txt.gz` and removes the original file.

**Decompress a File**
```bash
gzip -d report.txt.gz
```
- Decompresses `report.txt.gz` back to `report.txt`.

**Keep the Original File When Compressing**
```bash
gzip -k data.csv
```
- Compresses `data.csv` to `data.csv.gz` and keeps the original file.

**Compress All Files in a Directory Recursively**
```bash
gzip -r logs/
```
- Compresses all files in the `logs/` directory and its subdirectories.

**View Compression Statistics**
```bash
gzip -l archive.tar.gz
```
- Shows the original and compressed sizes, compression ratio, and uncompressed name.

**Compress Output from Another Command**
```bash
cat largefile | gzip > largefile.gz
```
- Compresses the output of `cat largefile` and writes it to `largefile.gz`.
#### Advanced Example: Decompress to Standard Output
```bash
gzip -dc archive.tar.gz | tar xvf -
```
- Decompresses `archive.tar.gz` and extracts its contents with `tar`.

**Summary:**  
The `gzip` command is a standard tool for compressing and decompressing files in Linux. It is fast, efficient, and widely supported, making it ideal for backups, transfers, and reducing storage usage. For more, see `man gzip`.

---
### `head` – Output the First Part of Files
The `head` command is used to **display the first part of files**, typically the first 10 lines. It is useful for quickly viewing the beginning of a file, such as configuration files, logs, or data files.
#### Basic Usage
```bash
head filename
```
- Shows the first 10 lines of `filename`.
#### Key Features
- **Preview files:** Quickly view the start of large files.
- **Custom line count:** Show a specific number of lines from the top.
- **Works with standard input:** Can be used in pipelines.
#### Common Options
- `-n <N>` : Show the first N lines (e.g., `head -n 20 file.txt`).
- `-c <N>` : Show the first N bytes (e.g., `head -c 100 file.txt`).
- `-q` : Never print headers with multiple files.
- `-v` : Always print headers with multiple files.
#### Examples
**Show the First 20 Lines of a File**
```bash
head -n 20 /var/log/syslog
```
**Show the First 100 Bytes of a File**
```bash
head -c 100 file.txt
```
**Use with a Pipeline**
```bash
ls -l | head
```
- Shows the first 10 lines of the `ls -l` output.

**Summary:**  
The `head` command is a simple and efficient way to preview the beginning of files or command output. For more, see `man head`.

---
### `join` – Join Lines of Two Files on a Common Field
The `join` command is used to **combine lines from two files based on a common field (usually the first field)**. It is useful for merging related data from separate files, similar to a database join operation.
#### Basic Usage
```bash
join file1.txt file2.txt
```
- Joins lines from `file1.txt` and `file2.txt` where the first field matches.
#### Key Features
- **Field-based merging:** Combines lines with matching fields from two files.
- **Custom field selection:** Specify which fields to join on.
- **Custom delimiters:** Use different field separators (default is space or tab).
- **Works with sorted files:** Input files must be sorted on the join field.
#### Common Options
- `-1 <field>` : Join on the specified field in the first file.
- `-2 <field>` : Join on the specified field in the second file.
- `-t <char>` : Use a custom field delimiter.
- `-o <list>` : Specify which fields to output.
- `-a <file_number>` : Print unpairable lines from file 1 or 2.
- `-e <string>` : Replace missing input fields with a string.
#### Examples
**Join Two Files on the First Field**
```bash
join file1.txt file2.txt
```
**Join on a Different Field**
```bash
join -1 2 -2 1 file1.txt file2.txt
```
- Joins on the second field of `file1.txt` and the first field of `file2.txt`.
**Use a Custom Delimiter (e.g., Comma)**
```bash
join -t, file1.csv file2.csv
```
**Output Only Specific Fields**
```bash
join -o 1.1,2.2 file1.txt file2.txt
```
- Outputs the first field from file1 and the second field from file2.
**Include Unmatched Lines**
```bash
join -a 1 -a 2 file1.txt file2.txt
```
- Includes lines from both files that do not have a match.

**Summary:**  
The `join` command is a powerful tool for merging files based on common fields, making it ideal for data processing and reporting. For more, see `man join`.

___
### `less` – View File Contents with Advanced Paging Features
The `less` command is a **powerful pager for viewing the contents of files one screen at a time**, similar to `more`, but with additional features such as backward navigation, searching, and better performance with large files.
#### Basic Usage
```bash
less filename
```
- Opens `filename` for viewing, allowing both forward and backward navigation.
#### Key Features
- **Bidirectional navigation:** Scroll forward and backward through files.
- **Search:** Use `/pattern` to search forward, `?pattern` to search backward.
- **Efficient with large files:** Loads files as you scroll, not all at once.
- **Works with pipes:** Can page output from other commands (e.g., `ls -l | less`).
- **Line numbers:** Display line numbers with the `-N` option.
- **Highlight search results:** Use `-i` for case-insensitive search, `-I` for always ignore case.
#### Common Controls
- `Space` : Next page
- `b` : Previous page
- `Enter` : Next line
- `k` / `j` : Up/down one line (like `vi`)
- `/pattern` : Search forward for a pattern
- `?pattern` : Search backward for a pattern
- `n` / `N` : Next/previous search result
- `g` : Go to the beginning of the file
- `G` : Go to the end of the file
- `q` : Quit
#### Examples
**View a File**
```bash
less /var/log/syslog
```
- Opens the system log for interactive viewing.

**Page Through Command Output**
```bash
ps aux | less
```
- Views the output of `ps aux` one screen at a time.

**Show Line Numbers**
```bash
less -N filename
```
- Displays line numbers alongside file contents.

**Search for a Word**
- While in `less`, type `/error` and press `Enter` to search for "error".

**Summary:**  
The `less` command is a feature-rich pager for viewing text files and command output. It is preferred over `more` for its advanced navigation, search, and performance capabilities. For more, see `man less`.

---
### `ln` – Make Links Between Files
The `ln` command is used to **create links between files** in Linux. By creating a link, you can access the same file by more than one path. There are two types of links: **hard links** and **symbolic (soft) links**.
#### Basic Usage
**Create a Hard Link**
```bash
ln source_file link_name
```
- Creates a hard link named `link_name` that points to `source_file`.
**Create a Symbolic (Soft) Link**
```bash
ln -s source_file symlink_name
```
- Creates a symbolic link named `symlink_name` that points to `source_file`.
#### Key Features
- **Hard links:** Point directly to the file’s data on disk; multiple filenames for the same file content.
- **Symbolic links:** Point to another file or directory by path; can link across filesystems and to directories.
- **Flexible access:** Access the same file from multiple locations or names.
#### Common Options
- `-s` : Create a symbolic (soft) link.
- `-f` : Force creation by removing existing destination files.
- `-n` : Do not dereference symbolic links (treat link as a file).
- `-v` : Verbose output; print what is being done.
- `-T` : Treat the destination as a normal file, not a directory.
#### Examples
**Create a Hard Link**
```bash
ln file.txt file_hardlink.txt
```
- Both `file.txt` and `file_hardlink.txt` now refer to the same data.
**Create a Symbolic Link**
```bash
ln -s /etc/nginx/nginx.conf nginx.conf.link
```
- Creates a symlink to the Nginx config file in the current directory.
**Create a Symbolic Link to a Directory**
```bash
ln -s /var/log logs
```
- Creates a symlink named `logs` pointing to `/var/log`.
**Force Overwrite an Existing Link**
```bash
ln -sf /new/target symlink_name
```
- Overwrites `symlink_name` if it already exists.
#### Advanced Example: Relative Symlink
```bash
ln -s ../shared/config.cfg config.cfg
```
- Creates a symlink using a relative path.

**Summary:**  
The `ln` command is essential for creating both hard and symbolic links, allowing flexible file access and organization. For more, see `man ln`.

---
### `locate` – Quickly Search for Files by Name
The `locate` command is used to **quickly find files and directories by name** on Linux systems. It searches a pre-built database of file paths, making it much faster than searching the filesystem in real time.
#### Basic Usage
```bash
locate filename
```
- Lists all paths containing `filename`.
#### Key Features
- **Very fast:** Uses a regularly updated database (`mlocate.db`) for instant results.
- **Wildcard support:** Supports partial names and wildcards.
- **Case-insensitive search:** Can ignore case when searching.
- **Updated with `updatedb`:** The database is refreshed periodically (or manually with `sudo updatedb`).
#### Common Options
- `-i` : Ignore case distinctions in the search.
- `-c` : Only print the number of matching entries.
- `-r <regex>` : Use a regular expression for matching.
- `-l <number>` : Limit the number of results shown.
#### Examples
**Find All Files Named "passwd"**
```bash
locate passwd
```
- Lists all files and paths containing "passwd".

**Case-Insensitive Search**
```bash
locate -i readme
```
- Finds files like `README`, `readme.txt`, etc.

**Count the Number of Matches**
```bash
locate -c .jpg
```
- Shows how many `.jpg` files are indexed.

**Limit the Number of Results**
```bash
locate -l 5 log
```
- Shows only the first 5 matches for "log".

**Use a Regular Expression**
```bash
locate -r '\.conf$'
```
- Finds all files ending with `.conf`.
#### Update the Database (as root)
```bash
sudo updatedb
```
- Refreshes the file database so new files can be found.

**Summary:**  
The `locate` command is the fastest way to search for files by name on Linux. It is ideal for quickly finding files anywhere on the system. For more, see `man locate`.

---
### `ls` – list directory contents. 
The `ls` command in Linux is used to **list directory contents**. It is one of the most frequently used commands for navigating and viewing files and directories in the terminal.
##### Common Options
- `-l` : Long listing format (shows permissions, owner, size, date, etc.)
- `-a` : Show all files, including hidden files (those starting with `.`)
- `-h` : Human-readable sizes (e.g., KB, MB) when used with `-l`
- `-R` : List subdirectories recursively
- `-S` : Sort by file size
- `-t` : Sort by modification time (newest first)
- `-r` : Reverse the order of the sort
- `-F` : Append indicator (e.g., `/` for directories, `*` for executables)
- `--color=auto` : Colorize the output for easier reading
###### List All Files, Including Hidden, with Details and Human-Readable Sizes
````bash
ls -alh
````
###### Sort Files by Modification Time (Newest First)
````bash
ls -lt
````
###### 3. List Only Directories
````bash
ls -l | grep "^d"
````
###### List Files Recursively in All Subdirectories
````bash
ls -R
````
###### List Files with File Type Indicators (e.g., `/` for directories)
````bash
ls -F
````
##### List Files Sorted by Size (Largest First)
````bash
ls -lS
````
###### List Files with Colorized Output
````bash
ls --color=auto
````
###### List Files in Reverse Order
````bash
ls -lr
````
###### List Only Filenames (One Per Line)
````bash
ls -1
````
###### List Files with Inode Numbers
````bash
ls -li
````

---
### `lsattr` – List File Attributes on a Linux Second Extended File System
The `lsattr` command is used to **display the attributes of files and directories** on Linux file systems, especially ext2, ext3, and ext4. File attributes control certain behaviors, such as whether a file can be deleted, modified, or renamed.
#### Basic Usage
```bash
lsattr filename
```
- Shows the attributes of `filename`.
#### Key Features
- **View special file flags:** See if files are immutable, append-only, undeletable, etc.
- **Works on directories:** Can list attributes for all files in a directory.
- **Useful for troubleshooting:** Helps diagnose issues with files that cannot be deleted or modified.
#### Common Options
- `-a` : List all files, including hidden files.
- `-R` : Recursively list attributes of directories and their contents.
- `-d` : List directory attributes, not contents.
- `-v` : Display the file's version/generation number.
#### Examples
**Show Attributes of All Files in a Directory**
```bash
lsattr /var/log/*
```
**Show Attributes Recursively**
```bash
lsattr -R /home/user/
```
**Show Attributes Including Hidden Files**
```bash
lsattr -a /etc/
```
**Show Only the Directory’s Attributes**
```bash
lsattr -d /tmp
```
#### Common Attribute Flags
- `i` : Immutable (cannot be changed, deleted, or renamed)
- `a` : Append-only (can only be added to)
- `d` : No dump (excluded from backups with `dump`)
- `e` : Extents (file is using extents for mapping blocks)
- `A` : No atime updates

**Summary:**  
The `lsattr` command is essential for viewing special file attributes on ext2/3/4 file systems, helping with security, troubleshooting, and system administration. For more, see `man lsattr`.
___
### `lspci` – List All PCI Devices
The `lspci` command is used to **list all PCI (Peripheral Component Interconnect) devices** on your system. It provides detailed information about hardware components connected via the PCI bus, such as graphics cards, network adapters, USB controllers, and more.
#### Basic Usage
```bash
lspci
```
- Lists all detected PCI devices with a brief description.
#### Key Features
- **Hardware diagnostics:** Identify and troubleshoot hardware components and drivers.
- **Detailed output:** Shows vendor, device IDs, and device descriptions.
- **Verbose and domain info:** Can display more detailed or domain-specific information.
- **Useful for driver matching:** Helps match hardware with the correct drivers.
#### Common Options
- `-v` : Verbose output (more details about each device).
- `-vv` : Even more verbose output.
- `-nn` : Show numeric device and vendor IDs.
- `-k` : Show kernel drivers handling each device.
- `-d <vendor>:<device>` : Show only devices with specified vendor and device IDs.
#### Examples
**Show All PCI Devices with Vendor and Device IDs**
```bash
lspci -nn
```
**Show Verbose Output**
```bash
lspci -v
```
**Show Kernel Drivers in Use**
```bash
lspci -k
```
**Find a Specific Device (e.g., Network Controller)**
```bash
lspci | grep -i network
```

**Summary:**  
The `lspci` command is invaluable for diagnosing hardware and system problems related to PCI devices. It helps identify installed hardware, troubleshoot issues, and verify driver usage. For more, see `man lspci`.

---
### `lsusb` – List USB Devices
The `lsusb` command is used to **list all USB (Universal Serial Bus) devices** connected to your system. It provides information about each USB device, including vendor and product IDs, device class, and a brief description.
#### Basic Usage
```bash
lsusb
```
- Lists all detected USB devices with their bus and device numbers, IDs, and descriptions.
#### Key Features
- **Hardware diagnostics:** Identify and troubleshoot USB devices and connections.
- **Detailed output:** Shows vendor and product IDs, device class, and manufacturer/product strings.
- **Useful for driver matching:** Helps match USB hardware with the correct drivers.
- **Verbose mode:** Provides more detailed information about each device.
#### Common Options
- `-v` : Verbose output (detailed information about each device).
- `-t` : Show a tree view of devices and their hierarchy.
- `-d <vendor>:<product>` : Show only devices with the specified vendor and product IDs.
- `-s <bus>:<device>` : Show only the specified device.
- `-D <device file>` : Show detailed info for a specific device file (e.g., `/dev/bus/usb/001/002`).
#### Example
**Show All USB Devices**
```bash
lsusb
```
**Show Detailed Information for All Devices**
```bash
lsusb -v
```
**Show Devices in a Tree View**
```bash
lsusb -t
```
**Find a Specific Device by Vendor/Product ID**
```bash
lsusb -d 046d:c534
```
- Shows only the device with vendor ID `046d` and product ID `c534`.

**Summary:**  
The `lsusb` command is invaluable for diagnosing hardware and system problems related to USB devices. It helps identify connected USB hardware, troubleshoot issues, and verify driver usage. For more, see `man lsusb`.

---
### `mkdir` – Create New Directories
The `mkdir` (make directory) command is used to **create new directories** in the Linux file system. It is a basic and essential command for organizing files and folders.
#### Basic Usage
```bash
mkdir new_folder
```
- Creates a directory named `new_folder` in the current location.
#### Key Features
- **Create multiple directories:** Can create several directories at once.
- **Create parent directories:** Can create nested directories in a single command.
- **Set permissions:** Can specify permissions for new directories at creation.
#### Common Options
- `-p` : Create parent directories as needed (no error if existing).
- `-v` : Verbose mode; print a message for each created directory.
- `-m <mode>` : Set permissions (mode) for the new directory (e.g., `-m 755`).
#### Examples
**Create Multiple Directories**
```bash
mkdir dir1 dir2 dir3
```
- Creates three directories: `dir1`, `dir2`, and `dir3`.
**Create Nested Directories**
```bash
mkdir -p projects/2025/june
```
- Creates the entire directory path, including any necessary parent directories.
**Set Permissions When Creating**
```bash
mkdir -m 700 private_folder
```
- Creates `private_folder` with permissions set to `700` (owner only).
**Verbose Output**
```bash
mkdir -pv a/b/c
```
- Creates nested directories and prints each step.
#### Advanced Example: Create Multiple Nested Directories
```bash
mkdir -p ~/work/{reports,logs,archive/2025/june}
```
- Uses brace expansion to create several directories and subdirectories at once.

**Summary:**  
The `mkdir` command is fundamental for creating directories in Linux. With its options, you can efficiently build complex directory structures and control permissions. For more, see `man mkdir`.

---
### `more` – Display File Contents One Screen at a Time
The `more` command is used to **view the contents of a file one screen (page) at a time** in the terminal. It is useful for reading long files that do not fit on a single screen.
#### Basic Usage
```bash
more filename
```
- Displays the contents of `filename` page by page.
#### Key Features
- **Paginated viewing:** Scroll through large files interactively.
- **Forward navigation:** Press `Space` to go to the next page, `Enter` for the next line.
- **Search:** Use `/pattern` to search for text within the file.
- **Works with pipes:** Can be used to page output from other commands.
#### Common Controls
- `Space` : Next page
- `Enter` : Next line
- `b` : Back one page
- `/pattern` : Search forward for a pattern
- `q` : Quit
#### Examples
**View a Long File**
```bash
more /var/log/syslog
```
- Opens the system log for paginated viewing.

**Page Through Command Output**
```bash
ls -l /etc | more
```
- Views the output of `ls -l /etc` one screen at a time.

**Search for a Word**
- While in `more`, type `/error` to search for the word "error".

**Summary:**  
The `more` command is a simple pager for viewing text files and command output one screen at a time. For more, see `man more`.

---
### `mv` – Move (or Rename) Files and Directories
The `mv` (move) command is used to **move or rename files and directories** in Linux. It can move files from one location to another, or simply rename them within the same directory.
#### Basic Usage
```bash
mv source_file destination_file
```
- Moves (or renames) `source_file` to `destination_file`.
#### Key Features
- **Move files/directories:** Relocates files or directories to a new location.
- **Rename:** Changes the name of a file or directory.
- **Overwrite protection:** Can prompt before overwriting existing files.
#### Common Options
- `-i` : Prompt before overwriting an existing file.
- `-u` : Move only when the source file is newer than the destination or when the destination file is missing.
- `-v` : Verbose mode; show files as they are moved.
- `-n` : Do not overwrite an existing file.
#### Examples
**Rename a File**
```bash
mv oldname.txt newname.txt
```
- Renames `oldname.txt` to `newname.txt`.
**Move a File to Another Directory**
```bash
mv file.txt /home/user/Documents/
```
- Moves `file.txt` into the `/home/user/Documents/` directory.
**Move Multiple Files**
```bash
mv file1.txt file2.txt /home/user/backup/
```
- Moves both files into the `/home/user/backup/` directory.
**Prompt Before Overwriting**
```bash
mv -i file.txt /home/user/backup.txt
```
- Asks for confirmation before overwriting `backup.txt`.
**Verbose Move**
```bash
mv -v *.log /var/log/archive/
```
- Moves all `.log` files to `/var/log/archive/` and prints each move.#### Advanced Example: Move All Files Except One
```bash
mv !(important.txt) /backup/
```
- Moves all files except `important.txt` to `/backup/` (requires extglob enabled in bash).

**Summary:**  
The `mv` command is essential for organizing files and directories in Linux. It efficiently handles both moving and renaming, with options for safety and verbosity. For more, see `man mv`.

---
### `newgrp` – Log In to a New Group
The `newgrp` command is used to **log in to a new group by changing the current group ID during a shell session**. This is useful when you want to execute commands or create files as a member of a different group without logging out and back in.
#### Basic Usage
```bash
newgrp groupname
```
- Starts a new shell with the primary group set to `groupname`.
#### Key Features
- **Change effective group:** Temporarily switch your primary group for the current shell session.
- **Affects file creation:** Files created in the new shell will have the new group as their group owner.
- **No need to log out:** Switch groups without ending your session.
#### Examples
**Switch to the "developers" Group**
```bash
newgrp developers
```
- Opens a new shell with `developers` as the primary group.
**Return to the Previous Group**
- Type `exit` to leave the new shell and return to your previous group.
**Summary:**  
The `newgrp` command is useful for temporarily changing your primary group, especially when working in shared directories or collaborative environments. For more, see `man newgrp`.
___
### `nl` – Number Lines of Files
The `nl` command is used to **number the lines of files** and write the result to standard output. It is useful for adding line numbers to text files or command output, making it easier to reference specific lines.
#### Basic Usage
```bash
nl filename
```
- Outputs the contents of `filename` with line numbers added.
#### Key Features
- **Customizable numbering:** Choose which lines to number and the numbering format.
- **Works with standard input:** Can be used in pipelines.
- **Flexible formatting:** Control line number width, separator, and starting number.
#### Common Options
- `-b <style>` : Specify which lines to number (`a` for all, `t` for non-empty, `n` for none).
- `-n <format>` : Set line number format (`ln` for left, `rn` for right, `rz` for right zero-padded).
- `-s <string>` : Set the line number separator (default is a tab).
- `-w <number>` : Set the width of the line number field.
- `-v <number>` : Set the starting line number.
#### Examples
**Number All Lines in a File**
```bash
nl -b a file.txt
```
**Number Only Non-Empty Lines (Default)**
```bash
nl file.txt
```
**Use a Custom Separator and Width**
```bash
nl -s ". " -w 3 file.txt
```
- Numbers are 3 digits wide, followed by a dot and a space.
**Pipe Output to nl**
```bash
cat script.sh | nl
```
- Adds line numbers to the output of `cat script.sh`.

**Summary:**  
The `nl` command is a simple tool for adding line numbers to files or command output, useful for code reviews, debugging, and documentation. For more, see `man nl`.

___
### `nohup` – Run Commands in the Background
The `nohup` (no hang up) command is used to **run another command or script in the background**, immune to hangups and logouts. It is especially useful for running long-running processes on remote systems, as it allows the process to continue even after you disconnect.
#### Basic Usage
```bash
nohup command &
```
- Runs `command` in the background and ignores hangup signals.
#### Key Features
- **Ignores SIGHUP:** The process will not terminate when the terminal closes or the user logs out.
- **Output redirection:** By default, output is redirected to `nohup.out` if not otherwise specified.
- **Works with scripts and commands:** Can be used with any executable or script.
#### Examples
**Run a Script in the Background**
```bash
nohup ./long_script.sh &
```
- Runs `long_script.sh` in the background, immune to hangups.

**Redirect Output to a File**
```bash
nohup python myapp.py > myapp.log 2>&1 &
```
- Runs `myapp.py` in the background, sending all output (stdout and stderr) to `myapp.log`.

**Check Running Jobs**
```bash
jobs
```
- Lists background jobs in the current shell.

**Disown a Job (Optional)**
```bash
disown %1
```
- Removes job 1 from the shell's job table, so it won't be affected by shell exit.

**Summary:**  
The `nohup` command is essential for running persistent background processes, especially on remote servers or when you need to log out. For more, see `man nohup`.

---
### `paste` – Merge Lines of Files
The `paste` command is used to **merge lines of multiple files side by side**, joining corresponding lines with a delimiter (default is a tab). It is useful for combining columns from different files or creating simple tables.
#### Basic Usage
```bash
paste file1 file2
```
- Merges lines from `file1` and `file2` side by side, separated by a tab.
#### Key Features
- **Column merging:** Combine lines from multiple files into columns.
- **Custom delimiters:** Use the `-d` option to specify a different delimiter.
- **Works with standard input:** Can merge data from pipelines.
#### Common Options
- `-d <delimiters>` : Use specified delimiters instead of tabs (e.g., `-d,` for commas).
- `-s` : Serial mode; paste one file at a time instead of parallel merging.
#### Examples
**Combine Two Files Side by Side**
```bash
paste names.txt scores.txt
```
- Merges each line from `names.txt` and `scores.txt` into columns.
**Use a Comma as the Delimiter**
```bash
paste -d, file1 file2
```
- Joins lines with a comma instead of a tab.
**Merge Three Files with Custom Delimiters**
```bash
paste -d':|' file1 file2 file3
```
- Uses `:` between the first and second file, and `|` between the second and third.
**Serial Mode (Concatenate All Lines from Each File)**
```bash
paste -s file1 file2
```
- Outputs all lines from `file1` on one line, then all lines from `file2` on the next.

**Summary:**  
The `paste` command is a simple and effective tool for merging lines from multiple files into columns, making it useful for quick data manipulation and report generation. For more, see `man paste`.

___
### `pwd` – Print Working Directory
The `pwd` (print working directory) command is used to **display the full absolute path of your current directory** in the terminal. It is a fundamental command for orientation and scripting in Linux and Unix-like systems.
#### Basic Usage
```bash
pwd
```
- Prints the absolute path of the current working directory.
#### Key Features
- **Absolute path:** Always shows the full path, starting from the root (`/`).
- **Useful in scripts:** Helps scripts determine or verify the current directory context.
- **Works in all shells:** Built into most shells (bash, zsh, etc.).
#### Common Examples
**Show Current Directory**
```bash
pwd
```
- Outputs something like `/home/username/projects`.
**Use in Scripts**
```bash
#!/bin/bash
echo "You are in: $(pwd)"
```
- Prints the current directory when the script runs.
#### Advanced Example: Combine with Other Commands
```bash
echo "Current directory: $(pwd)"; ls
```
- Prints the current directory and then lists its contents.
#### Options
- `-L` : Show the logical path (default; follows symbolic links).
- `-P` : Show the physical path (resolves all symbolic links).

**Show Physical Path (No Symlinks)**
```bash
pwd -P
```
- Displays the actual physical directory, resolving any symlinks.

**Summary:**  
The `pwd` command is essential for knowing your current location in the filesystem, especially when navigating complex directory structures or writing scripts. For more, see `man pwd`.

---
### `rev` – Reverse Lines Characterwise
The `rev` command is used to **reverse the order of characters in each line of a file or input stream**. It is useful for simple text transformations, such as reversing strings or preparing data for further processing.
#### Basic Usage
```bash
rev filename
```
- Reverses each line in `filename` and prints the result.
#### Key Features
- **Line-by-line reversal:** Each line is reversed independently.
- **Works with standard input:** Can be used in pipelines or with interactive input.
- **Simple and fast:** No options needed for basic use.
#### Examples
**Reverse Each Line in a File**
```bash
rev myfile.txt
```
- Prints each line of `myfile.txt` with characters in reverse order.
**Reverse Output from Another Command**
```bash
echo "hello world" | rev
```
- Outputs: `dlrow olleh`
**Reverse Lines in a Pipeline**
```bash
cat data.txt | rev | sort | rev
```
- Reverses lines, sorts them, then reverses them back.

**Summary:**  
The `rev` command is a simple utility for reversing the characters in each line of input. It is useful for text manipulation and scripting. For more, see `man rev`.

___
### `rm` – Remove Files and Directories
The `rm` (remove) command is used to **delete files and directories** from the filesystem in Linux. It is a powerful command and should be used with caution, as deleted files are not moved to a trash or recycle bin—they are permanently removed.
#### Basic Usage
```bash
rm filename
```
- Deletes the file named `filename`.
#### Key Features
- **Delete multiple files:** Can remove several files at once.
- **Recursive deletion:** Can delete entire directories and their contents.
- **Force deletion:** Can remove files without prompting, even if they are write-protected.
#### Common Options
- `-r` or `-R` : Recursively delete directories and their contents.
- `-f` : Force deletion; ignore nonexistent files and never prompt.
- `-i` : Prompt before every removal.
- `-I` : Prompt once before removing more than three files or when removing recursively.
- `-v` : Verbose mode; show files as they are removed.
#### Examples
**Remove a Single File**
```bash
rm file.txt
```
- Deletes `file.txt`.
**Remove Multiple Files**
```bash
rm file1.txt file2.txt
```
- Deletes both files.
**Remove a Directory and Its Contents**
```bash
rm -r myfolder/
```
- Recursively deletes `myfolder` and everything inside it.
**Force Remove Without Prompting**
```bash
rm -rf /tmp/old_logs/
```
- Forcefully and recursively deletes `/tmp/old_logs/` without any confirmation.
**Prompt Before Deleting Each File**
```bash
rm -i *.log
```
- Asks for confirmation before deleting each `.log` file.
#### Advanced Example: Verbose Recursive Deletion
```bash
rm -rv /var/tmp/old_backups/
```
- Recursively deletes the directory and prints each file as it is removed.
**Warning:**  
Be extremely careful with `rm -rf`, especially as root. Double-check your command before executing, as mistakes can lead to irreversible data loss.

**Summary:**  
The `rm` command is essential for deleting files and directories in Linux. Use its options for safety and control, and always verify your targets before running destructive operations. For more, see `man rm`.

---
### `stat` – Display File or File System Status
The `stat` command is used to **display detailed information about files or file systems**, including size, permissions, timestamps, ownership, and more. It is useful for troubleshooting, scripting, and auditing file attributes.
#### Basic Usage
```bash
stat filename
```
- Shows detailed status information for `filename`.
#### Key Features
- **File metadata:** Displays permissions, owner, group, size, and timestamps (access, modify, change).
- **Filesystem info:** Can show information about the file system containing the file.
- **Custom formatting:** Output can be customized for scripts.
#### Common Options
- `-c <format>` : Use a custom format for output (see `man stat` for format sequences).
- `-f` : Display file system status instead of file status.
- `--printf=<format>` : Print using a specified format string.
#### Examples
**Show Detailed Info for a File**
```bash
stat /etc/passwd
```
**Show Only the File Size**
```bash
stat -c %s myfile.txt
```
- Outputs the size of `myfile.txt` in bytes.
**Show File System Status**
```bash
stat -f /
```
- Displays information about the root file system.
**Custom Output: Permissions and Owner**
```bash
stat -c "%A %U %s" file.txt
```
- Shows permissions, owner, and size.
**Summary:**  
The `stat` command is a powerful tool for viewing file and file system metadata, useful for scripting, troubleshooting, and auditing. For more, see `man stat`.

____
### `split` – Split a File into Pieces
The `split` command is used to **divide a large file into smaller pieces**, which can be useful for transferring, archiving, or processing large files in manageable chunks.
#### Basic Usage
```bash
split largefile.txt
```
- Splits `largefile.txt` into 1000-line pieces named `xaa`, `xab`, etc.
#### Key Features
- **Custom piece size:** Split by number of lines, bytes, or kilobytes.
- **Custom file names:** Specify a prefix for output files.
- **Works with any file type:** Can split text or binary files.
#### Common Options
- `-l <lines>` : Split into files with the specified number of lines (e.g., `-l 500`).
- `-b <size>` : Split into files of the specified size (e.g., `-b 10M` for 10 megabytes).
- `-d` : Use numeric suffixes instead of alphabetic.
- `--additional-suffix=<suffix>` : Add a custom suffix to output files.
#### Examples
**Split a File into 500-Line Pieces**
```bash
split -l 500 data.txt chunk_
```
- Creates files named `chunk_aa`, `chunk_ab`, etc., each with 500 lines.
**Split a File into 10MB Pieces**
```bash
split -b 10M bigfile.iso part_
```
- Creates files named `part_aa`, `part_ab`, etc., each 10 megabytes.
**Split Using Numeric Suffixes**
```bash
split -d -l 1000 logfile.log logpart_
```
- Output files will be named `logpart_00`, `logpart_01`, etc.
**Recombine Split Files**
```bash
cat part_* > originalfile
```
- Joins the split files back into the original file.

**Summary:**  
The `split` command is a handy tool for breaking up large files into smaller, more manageable pieces for storage, transfer, or processing. For more, see `man split`.

___
### `sort` – Sort Lines of Text Files
The `sort` command is used to **sort lines of text files** in various ways, such as alphabetically, numerically, or by specific fields. It is commonly used for organizing data, removing duplicates (with `uniq`), and preparing files for further processing.
#### Basic Usage
```bash
sort filename
```
- Sorts the lines of `filename` in ascending (alphabetical) order.
#### Key Features
- **Alphabetical and numerical sorting:** Sort text or numbers.
- **Custom field sorting:** Sort by specific columns or fields.
- **Reverse order:** Sort in descending order.
- **Case-insensitive sorting:** Ignore case differences.
- **Unique lines:** Combine with `uniq` to remove duplicates.
#### Common Options
- `-n` : Sort numerically.
- `-r` : Reverse the sort order (descending).
- `-k <N>` : Sort by the Nth field (e.g., `-k 2` for the second column).
- `-t <char>` : Use a custom field delimiter (default is whitespace).
- `-u` : Output only the first of an equal run (unique lines).
- `-f` : Ignore case when sorting.
- `-o <file>` : Write output to a file.
#### Examples
**Sort a File Numerically**
```bash
sort -n numbers.txt
```
**Sort by the Second Column (Field)**
```bash
sort -k 2 data.txt
```
**Sort in Reverse Order**
```bash
sort -r names.txt
```
**Sort a CSV File by the Third Column**
```bash
sort -t, -k3 file.csv
```
**Sort and Remove Duplicate Lines**
```bash
sort file.txt | uniq
```

**Summary:**  
The `sort` command is a versatile tool for organizing and processing text data in Linux. It supports a wide range of sorting options for different data types and formats. For more, see `man sort`.

___
### `strings` – Display Printable Strings in a Binary File
The `strings` command is used to **extract and display printable character sequences from binary files**. It is useful for inspecting executables, object files, or any binary data to find embedded text, error messages, or other readable content.
#### Basic Usage
```bash
strings filename
```
- Prints all printable strings found in `filename`.
#### Key Features
- **Binary inspection:** Reveals human-readable text inside binaries, libraries, or data files.
- **Malware analysis:** Useful for reverse engineering and security analysis.
- **Custom minimum length:** Set the minimum string length to display.
#### Common Options
- `-n <number>` or `-<number>` : Set the minimum string length (default is 4).
- `-t <format>` : Print the offset of each string (in octal, decimal, or hexadecimal).
- `-e <encoding>` : Specify character encoding (e.g., `s` for single-7-bit-byte, `S` for 16-bit Unicode).

#### Examples
**Show All Printable Strings in a Binary**
```bash
strings /usr/bin/ls
```
**Set Minimum String Length to 8**
```bash
strings -n 8 myfile.bin
```
**Show Offsets in Hexadecimal**
```bash
strings -t x program.exe
```
**Extract Strings from a Core Dump**
```bash
strings core.1234
```

**Summary:**  
The `strings` command is a quick way to extract readable text from binary files, useful for debugging, forensics, and reverse engineering. For more, see `man strings`.

___
### `tac` – Output File Contents in Reverse
The `tac` command is used to **display the contents of a file in reverse order**, printing the last line first and the first line last. It is the opposite of the `cat` command.
#### Basic Usage
```bash
tac filename
```
- Prints the contents of `filename` with lines in reverse order.
#### Key Features
- **Reverse line order:** Useful for viewing logs or files from the end to the beginning.
- **Works with standard input:** Can be used in pipelines.
#### Examples
**Display a File in Reverse**
```bash
tac /var/log/syslog
```
- Shows the last line of the log file first.

**Reverse the Output of Another Command**
```bash
ls -1 | tac
```
- Lists files in the current directory in reverse order.

**Reverse Only a Portion of a File**
```bash
head -n 20 file.txt | tac
```
- Shows the first 20 lines of `file.txt` in reverse order.

**Summary:**  
The `tac` command is a simple but handy tool for reversing the line order of files or command output. For more, see `man tac`.

---
### `tail` – Display the End of a File
The `tail` command is used to **display the last part (tail) of a text file or piped data**. By default, it shows the last 10 lines, but you can specify any number of lines or even follow a file as it grows (useful for monitoring logs).
#### Basic Usage
```bash
tail filename
```
- Shows the last 10 lines of `filename`.
#### Key Features
- **View the end of files:** Quickly see recent entries in logs or output files.
- **Follow mode:** Monitor files in real time as new lines are added.
- **Custom line/byte count:** Show a specific number of lines or bytes from the end.
#### Common Options
- `-n <N>` : Show the last N lines (e.g., `-n 20` for 20 lines).
- `-f` : Follow the file as it grows (real-time monitoring).
- `-F` : Like `-f`, but also reopens the file if it is rotated or recreated.
- `-c <N>` : Show the last N bytes instead of lines.
- `--pid=<PID>` : With `-f`, terminate when the specified process ID dies.

#### Examples
**Show the Last 20 Lines of a File**
```bash
tail -n 20 /var/log/syslog
```
- Displays the last 20 lines of the system log.

**Follow a Log File in Real Time**
```bash
tail -f /var/log/messages
```
- Continuously displays new lines as they are added to the file.

**Follow and Reopen a Rotated Log File**
```bash
tail -F /var/log/app.log
```
- Follows the file and reopens it if it is rotated (useful for log files).

**Show the Last 100 Bytes of a File**
```bash
tail -c 100 file.txt
```
- Displays the last 100 bytes of `file.txt`.

**Monitor Output from Another Command**
```bash
journalctl -f | tail -n 5
```
- Shows the last 5 lines of real-time journal output.

**Summary:**  
The `tail` command is essential for viewing the most recent lines of files, especially logs. Its follow mode is invaluable for real-time monitoring. For more, see `man tail`.

---
### `tar` – Archiving Utility
The `tar` (tape archive) command is used to **create, extract, and manage archive files** (commonly called tarballs) in Linux. It is widely used for packaging multiple files and directories into a single file, often for backup or distribution.
#### Basic Usage
```bash
tar -cf archive.tar file1 file2 dir1
```
- Creates an archive named `archive.tar` containing `file1`, `file2`, and `dir1`.
#### Key Features
- **Archive multiple files/directories:** Combine many files and folders into one archive.
- **Compression support:** Integrates with gzip (`.tar.gz`), bzip2 (`.tar.bz2`), and xz (`.tar.xz`) for compressed archives.
- **Preserve permissions and metadata:** Maintains file permissions, ownership, and timestamps.
#### Common Options
- `-c` : Create a new archive.
- `-x` : Extract files from an archive.
- `-t` : List the contents of an archive.
- `-f <file>` : Specify the archive file name.
- `-v` : Verbose mode; show files as they are processed.
- `-z` : Use gzip compression.
- `-j` : Use bzip2 compression.
- `-J` : Use xz compression.
- `-p` : Preserve permissions.
#### Examples
**Create a Tar Archive**
```bash
tar -cvf backup.tar /home/user/docs
```
- Creates `backup.tar` from the `/home/user/docs` directory, showing progress.

**Create a Compressed Archive (gzip)**
```bash
tar -czvf backup.tar.gz /home/user/docs
```
- Creates a gzip-compressed archive.

**Extract an Archive**
```bash
tar -xvf backup.tar
```
- Extracts the contents of `backup.tar` into the current directory.

**Extract a Compressed Archive**
```bash
tar -xzvf backup.tar.gz
```
- Extracts a gzip-compressed archive.

**List Contents of an Archive**
```bash
tar -tvf backup.tar
```
- Lists the files inside `backup.tar` without extracting.

**Extract to a Specific Directory**
```bash
tar -xvf backup.tar -C /tmp/extract_here
```
- Extracts the archive to `/tmp/extract_here`.
#### Advanced Example: Create a Compressed Archive with Exclusions
```bash
tar -czvf project.tar.gz project/ --exclude='*.log' --exclude='tmp/'
```
- Archives the `project` directory, excluding all `.log` files and the `tmp/` directory.

**Summary:**  
The `tar` command is the standard tool for archiving and compressing files in Linux. It supports flexible options for creating, extracting, and managing archives, making it essential for backups, transfers, and packaging. For more, see `man tar`.

---
### `tee` – Read from Standard Input and Write to Standard Output and Files
The `tee` command is used to **read from standard input and write the input to both standard output and one or more files**. It is commonly used in pipelines to save the output of a command to a file while still displaying it on the terminal.
#### Basic Usage
```bash
command | tee output.txt
```
- Writes the output of `command` to both the terminal and `output.txt`.
#### Key Features
- **Duplicate output:** Send command output to a file and the screen at the same time.
- **Append mode:** Add output to the end of a file instead of overwriting.
- **Multiple files:** Write output to several files at once.
- **Works in pipelines:** Useful for logging or debugging scripts.
#### Common Options
- `-a` : Append to the given file(s), rather than overwriting.
- `-i` : Ignore interrupt signals.
#### Examples
**Save and Display Output**
```bash
ls -l | tee files.txt
```
- Lists files, displays the output, and saves it to `files.txt`.
**Append Output to a File**
```bash
echo "New entry" | tee -a log.txt
```
- Adds "New entry" to the end of `log.txt` and prints it.
**Write Output to Multiple Files**
```bash
echo "Backup complete" | tee log1.txt log2.txt
```
- Writes the message to both `log1.txt` and `log2.txt`.
**Use in a Pipeline**
```bash
cat data.txt | grep "error" | tee errors.txt | sort
```
- Saves lines containing "error" to `errors.txt` and sorts them for display.

**Summary:**  
The `tee` command is a handy tool for capturing and duplicating command output in Linux, especially in scripts and pipelines. For more, see `man tee`.

___
### `touch` – Update File Timestamps or Create Empty Files
The `touch` command is used to **update the access and modification timestamps** of a file or directory. If the specified file does not exist, `touch` will create an empty file with that name.
#### Basic Usage
```bash
touch filename
```
- Updates the timestamps of `filename` or creates it if it does not exist.
#### Key Features
- **Create empty files:** Quickly create new, empty files.
- **Update timestamps:** Change the access and modification times of existing files.
- **Set custom times:** Specify a particular date and time for the file.
#### Common Options
- `-c` : Do not create any files; only update timestamps if the file exists.
- `-a` : Change only the access time.
- `-m` : Change only the modification time.
- `-t [[CC]YY]MMDDhhmm[.ss]` : Set the time and date explicitly.
- `-r <ref_file>` : Use the timestamp from another file.
#### Examples
**Create an Empty File**
```bash
touch newfile.txt
```
- Creates `newfile.txt` if it does not exist.

**Update Timestamps of Multiple Files**
```bash
touch file1.txt file2.txt
```
- Updates the timestamps of both files.

**Set a Specific Timestamp**
```bash
touch -t 202506071200.00 report.txt
```
- Sets the modification and access time of `report.txt` to June 7, 2025, 12:00:00.

**Match Timestamp of Another File**
```bash
touch -r reference.txt target.txt
```
- Sets the timestamp of `target.txt` to match `reference.txt`.

**Do Not Create New Files**
```bash
touch -c missing.txt
```
- Does nothing if `missing.txt` does not exist.

**Summary:**  
The `touch` command is useful for creating empty files, updating timestamps, and scripting file management tasks. For more, see `man touch`.

---
### `tr` – Translate or Delete Characters
The `tr` command is used to **translate (replace) or delete characters** from standard input, writing the result to standard output. It is commonly used for simple text transformations, such as changing case, removing characters, or replacing sets of characters.
#### Basic Usage
```bash
tr SET1 SET2
```
- Replaces each character in `SET1` with the corresponding character in `SET2`.
#### Key Features
- **Character translation:** Replace one set of characters with another.
- **Delete characters:** Remove specified characters from the input.
- **Squeeze repeats:** Replace sequences of repeated characters with a single character.
- **Works in pipelines:** Processes data from other commands.
#### Common Options
- `-d` : Delete characters in SET1 from the input.
- `-s` : Squeeze repeated characters in SET1 into a single character.
- `-c` : Complement SET1 (operate on all except the specified characters).
#### Examples
**Convert Lowercase to Uppercase**
```bash
echo "hello world" | tr 'a-z' 'A-Z'
```
- Outputs: `HELLO WORLD`
**Delete Digits from Input**
```bash
echo "abc123def456" | tr -d '0-9'
```
- Outputs: `abcdef`
**Squeeze Repeated Spaces**
```bash
echo "a    b   c" | tr -s ' '
```
- Outputs: `a b c`
**Replace Tabs with Spaces**
```bash
tr '\t' ' ' < file.txt
```
- Replaces all tabs with spaces in `file.txt`.
**Complement: Remove All Except Letters**
```bash
tr -cd 'a-zA-Z' < file.txt
```
- Removes all characters except letters.

**Summary:**  
The `tr` command is a simple and efficient tool for character-level text transformations in Linux. For more, see `man tr`.

___
### `umask` – Set File Mode Creation Mask
The `umask` command is used to **set or display the default permission mask** for newly created files and directories in Linux. The mask determines which permission bits will *not* be set on new files and directories, effectively controlling their default permissions.
#### Basic Usage
```bash
umask
```
- Displays the current mask in octal notation (e.g., `0022`).
```bash
umask 027
```
- Sets the mask so that new files are not writable by group or others, and not readable/executable by others.
#### Key Features
- **Controls default permissions:** Affects all files and directories created by the shell or processes started from it.
- **Session-based:** The mask applies to the current shell session and its children.
- **Can be set system-wide or per-user:** Set in shell configuration files (e.g., `.bashrc`, `/etc/profile`).
#### How It Works
- The mask is subtracted from the system default permissions (666 for files, 777 for directories).
- For example, with `umask 022`:
  - New files: `666 - 022 = 644` (`rw-r--r--`)
  - New directories: `777 - 022 = 755` (`rwxr-xr-x`)
#### Common Examples
**Show the Current umask**
```bash
umask
```
- Prints the current mask (e.g., `0022`).
**Set a Restrictive umask**
```bash
umask 077
```
- New files/directories are only accessible by the owner.
**Set a Less Restrictive umask**
```bash
umask 002
```
- New files/directories are group-writable (common for collaborative environments).
#### Advanced Example: Set umask in a Script
```bash
#!/bin/bash
umask 027
touch securefile.txt
```
- `securefile.txt` will be created with permissions `640` (`rw-r-----`).
**Summary:**  
The `umask` command is essential for controlling default file and directory permissions, improving security and collaboration. For more, see `man umask`.

---
### `uniq` – Report or Omit Repeated Lines
The `uniq` command is used to **filter out or report repeated lines in a file or input stream**. It is commonly used in combination with `sort` to process sorted data and remove or highlight duplicate lines.
#### Basic Usage
```bash
uniq filename
```
- Removes consecutive duplicate lines from `filename`.
#### Key Features
- **Remove duplicates:** Only unique lines are output (consecutive duplicates are removed).
- **Count occurrences:** Show how many times each line occurs.
- **Show only duplicates or only unique lines:** Filter output as needed.
- **Works with standard input:** Can be used in pipelines.
#### Common Options
- `-c` : Prefix lines by the number of occurrences.
- `-d` : Only print duplicate lines (one for each group).
- `-u` : Only print unique lines (lines that are not repeated).
- `-i` : Ignore case when comparing lines.
- `-f N` : Skip the first N fields when comparing.
- `-s N` : Skip the first N characters when comparing.
#### Examples
**Remove Consecutive Duplicate Lines**
```bash
sort file.txt | uniq
```
- Sorts and removes all duplicate lines from `file.txt`.
**Show Only Duplicate Lines**
```bash
uniq -d sorted.txt
```
- Prints only lines that are repeated (must be consecutive).
**Show Only Unique Lines**
```bash
uniq -u sorted.txt
```
- Prints only lines that are not repeated.
**Count Occurrences of Each Line**
```bash
sort file.txt | uniq -c
```
- Shows each unique line with the number of times it appears.
**Ignore Case When Comparing**
```bash
uniq -i file.txt
```
- Treats lines as duplicates even if they differ in case.

**Summary:**  
The `uniq` command is a simple but powerful tool for filtering or reporting duplicate lines in sorted data. It is often used with `sort` for data cleanup and analysis. For more, see `man uniq`.

___
### `useradd` – Create a New User or Update Default New User Information
The `useradd` command is used to **create new user accounts** or update default settings for new users on Linux systems. It is a low-level utility for adding users, typically used by system administrators.
#### Basic Usage
```bash
sudo useradd username
```
- Creates a new user account named `username`.
#### Key Features
- **Custom home directory:** Specify a custom home directory location.
- **Set shell:** Choose the user's default login shell.
- **Assign groups:** Add the user to one or more groups.
- **Set user information:** Define user ID (UID), group ID (GID), and more.
- **Update defaults:** Change default settings for future new users.
#### Common Options
- `-m` : Create the user's home directory if it does not exist.
- `-d <dir>` : Specify the user's home directory.
- `-s <shell>` : Set the user's login shell.
- `-G <groups>` : Add the user to additional groups (comma-separated).
- `-u <uid>` : Specify the user ID.
- `-c <comment>` : Add a comment (usually the user's full name).
- `-e <expire_date>` : Set account expiration date (YYYY-MM-DD).
- `-k` : Copy files from `/etc/skel` to the home directory.
- `-D` : Show or update default values for new users.
#### Examples
**Create a User with a Home Directory**
```bash
sudo useradd -m alice
```
- Adds user `alice` and creates `/home/alice`.
**Create a User with a Specific Shell**
```bash
sudo useradd -m -s /bin/zsh bob
```
- Adds user `bob` with `/bin/zsh` as the default shell.
**Add a User to Multiple Groups**
```bash
sudo useradd -m -G sudo,developers carol
```
- Adds `carol` to the `sudo` and `developers` groups.
**Set a Custom Home Directory**
```bash
sudo useradd -m -d /srv/users/dave dave
```
- Creates user `dave` with home directory `/srv/users/dave`.
**Update Default New User Settings**
```bash
sudo useradd -D -s /bin/bash
```
- Sets `/bin/bash` as the default shell for future new users.

**Summary:**  
The `useradd` command is a fundamental tool for adding and configuring user accounts on Linux. For more, see `man useradd`.

---
### `userdel` – Delete a User Account and Related Files
The `userdel` command is used to **delete a user account** from a Linux system. It can also remove the user's home directory and mail spool, making it useful for cleaning up after a user is no longer needed.
#### Basic Usage
```bash
sudo userdel username
```
- Deletes the user account named `username` (but leaves the home directory and files by default).
#### Key Features
- **Remove user accounts:** Deletes the specified user from the system.
- **Optionally remove home directory and mail spool:** Cleans up user data.
- **Safe deletion:** Prevents deletion if the user is currently logged in.
#### Common Options
- `-r` : Remove the user's home directory and mail spool.
- `-f` : Force removal of the user account, even if the user is logged in.
- `--help` : Show help information.
#### Examples
**Delete a User Account (Keep Home Directory)**
```bash
sudo userdel alice
```
- Removes the user `alice` but keeps `/home/alice` and files.
**Delete a User and Their Home Directory**
```bash
sudo userdel -r bob
```
- Removes the user `bob` and deletes `/home/bob` and their mail spool.
**Force Delete a User**
```bash
sudo userdel -f carol
```
- Forces deletion of `carol` even if logged in (use with caution).
**Summary:**  
The `userdel` command is essential for removing user accounts and optionally cleaning up their files. Always double-check before using `-r` or `-f` to avoid accidental data loss. For more, see `man userdel`.

---
### `usermod` – Modify or Change Attributes of an Existing User Account
The `usermod` command is used to **modify or change attributes of an existing user account** on Linux systems. It allows administrators to update user details such as group membership, home directory, login shell, username, and more.
#### Basic Usage
```bash
sudo usermod [options] username
```
- Modifies the specified user account according to the given options.
#### Key Features
- **Change user’s primary group or add to supplementary groups**
- **Change home directory and move files**
- **Change login shell**
- **Lock or unlock user accounts**
- **Change username or user ID (UID)**
- **Set account expiration date**
#### Common Options
- `-aG <groups>` : Add the user to supplementary groups (use with `-G`)
- `-G <groups>` : Set the list of supplementary groups
- `-g <group>` : Change the user’s primary group
- `-d <dir>` : Change the user’s home directory
- `-m` : Move the contents of the home directory to the new location
- `-s <shell>` : Change the user’s login shell
- `-l <newname>` : Change the username
- `-u <uid>` : Change the user ID
- `-L` : Lock the user account
- `-U` : Unlock the user account
- `-e <expire_date>` : Set account expiration date (YYYY-MM-DD)
- `-c <comment>` : Change the comment (usually the full name)
#### Examples
**Add a User to the `sudo` and `docker` Groups**
```bash
sudo usermod -aG sudo,docker alice
```
- Adds `alice` to the `sudo` and `docker` groups.
**Change a User’s Home Directory and Move Files**
```bash
sudo usermod -d /srv/users/bob -m bob
```
- Changes `bob`'s home directory and moves existing files.
**Change a User’s Login Shell**
```bash
sudo usermod -s /bin/zsh carol
```
- Sets `/bin/zsh` as the default shell for `carol`.
**Change a Username**
```bash
sudo usermod -l newname oldname
```
- Changes the username from `oldname` to `newname`.
**Lock or Unlock a User Account**
```bash
sudo usermod -L dave   # Lock
sudo usermod -U dave   # Unlock
```
**Set Account Expiration Date**
```bash
sudo usermod -e 2025-12-31 alice
```
- Sets `alice`'s account to expire on December 31, 2025.

**Summary:**  
The `usermod` command is essential for updating user account settings and attributes. Always use caution when changing usernames, UIDs, or home directories. For more, see `man usermod`.

---
### `wait` – Suspend Script Execution Until Background Jobs Finish
The `wait` command is used in shell scripts to **pause execution until all background jobs have completed**. It ensures that the script does not proceed until specified background processes are finished.
#### Basic Usage
```bash
command1 &
command2 &
wait
echo "All background jobs are done."
```
- Runs `command1` and `command2` in the background, then waits for both to finish before continuing.
#### Key Features
- **Synchronize scripts:** Ensures that subsequent commands run only after background jobs complete.
- **Wait for specific PID:** Can wait for a particular process ID.
- **Returns exit status:** Returns the exit status of the waited-for job.
#### Examples
**Wait for All Background Jobs**
```bash
sleep 5 &
sleep 10 &
wait
echo "Both sleeps are done."
```
- Waits for both `sleep` commands to finish.

**Wait for a Specific Job**
```bash
long_task &
pid=$!
# Do something else
wait $pid
echo "long_task is finished."
```
- Waits only for the process with PID stored in `$pid`.

**Summary:**  
The `wait` command is essential for synchronizing background processes in shell scripts, ensuring proper sequencing and resource management. For more, see `help wait` or your shell's documentation.

---
### `wc` – Print Newline, Word, and Byte Counts for Each File
The `wc` (word count) command is used to **count the number of lines, words, and bytes (or characters) in files**. It is useful for quickly summarizing the size or content of text files and is often used in scripts and pipelines.

#### Basic Usage
```bash
wc filename
```
- Prints the number of lines, words, and bytes in `filename`.

#### Key Features
- **Counts lines, words, bytes, and characters:** Flexible reporting with options.
- **Works with multiple files:** Shows counts for each file and a total.
- **Works with standard input:** Can be used in pipelines.

#### Common Options
- `-l` : Print only the number of lines.
- `-w` : Print only the number of words.
- `-c` : Print only the number of bytes.
- `-m` : Print only the number of characters.
- `-L` : Print the length of the longest line.

#### Examples

**Count Lines, Words, and Bytes in a File**
```bash
wc myfile.txt
```
- Outputs: lines, words, bytes, and filename.

**Count Only Lines**
```bash
wc -l myfile.txt
```

**Count Only Words**
```bash
wc -w myfile.txt
```

**Count Only Bytes**
```bash
wc -c myfile.txt
```

**Count Lines in All `.log` Files**
```bash
wc -l *.log
```
- Shows line counts for each `.log` file and a total.

**Use with a Pipeline**
```bash
cat myfile.txt | wc -w
```
- Counts the number of words in `myfile.txt`.

**Summary:**  
The `wc` command is a simple and efficient tool for counting lines, words, and bytes in files or input streams. For more, see `man wc`.

___
### `vi` – Text Editor
The `vi` command launches **Vi**, a classic, powerful text editor available on nearly all Unix and Linux systems. It is lightweight, fast, and works entirely in the terminal, making it ideal for editing configuration files, scripts, and code on remote systems.
#### Basic Usage
```bash
vi filename
```
- Opens `filename` in the Vi editor. If the file does not exist, it will be created.
#### Key Features
- **Modes:** Vi has two main modes: *normal* (command) mode and *insert* (editing) mode.
- **Efficient navigation:** Move quickly through text using keyboard shortcuts.
- **Search and replace:** Powerful pattern matching and substitution.
- **Works in any terminal:** No GUI required.
#### Common Commands
**Switch to Insert Mode (for editing)**
- Press `i` to insert before the cursor.
- Press `a` to insert after the cursor.
- Press `o` to open a new line below.
**Save and Exit**
- Press `Esc` to return to normal mode.
- Type `:w` and press `Enter` to save.
- Type `:q` and press `Enter` to quit.
- Type `:wq` or `:x` to save and quit.
- Type `:q!` to quit without saving.
**Navigation**
- Arrow keys or `h` (left), `j` (down), `k` (up), `l` (right)
- `gg` to go to the top, `G` to go to the bottom
- `/pattern` to search for text
**Delete, Copy, and Paste**
- `dd` : Delete (cut) a line
- `yy` : Copy (yank) a line
- `p`  : Paste below the cursor
#### Example: Open and Edit a File
```bash
vi /etc/hosts
```
- Opens the `/etc/hosts` file for editing.

**Summary:**  
The `vi` editor is a fundamental tool for editing text files on Linux and Unix systems. Mastering its basic commands is essential for system administration and development. For more, see `man vi` or search for "Vi cheat sheet".

---
### `xargs` – Build and Execute Command Lines from Standard Input
The `xargs` command is used to **build and execute command lines from standard input**. It reads items from input (such as the output of `find` or `grep`) and executes a specified command using those items as arguments. This is especially useful for processing lists of files or arguments that are too long for a single command line.
#### Basic Usage
```bash
command | xargs <other_command>
```
- Passes the output of `command` as arguments to `<other_command>`.
#### Key Features
- **Efficient argument handling:** Handles large numbers of arguments that might exceed shell limits.
- **Flexible input parsing:** Can process input separated by spaces, newlines, or custom delimiters.
- **Parallel execution:** Can run commands in parallel with the `-P` option.
- **Interactive prompts:** Optionally prompt before running each command.
#### Common Options
- `-n <N>` : Use at most N arguments per command line.
- `-d <delimiter>` : Use a custom input delimiter.
- `-0` : Input items are separated by a null character (useful with `find -print0`).
- `-p` : Prompt before executing each command.
- `-I {}` : Replace `{}` with the input item(s) in the command.
- `-P <N>` : Run up to N processes in parallel.
#### Examples
**Delete All `.tmp` Files Found by `find`**
```bash
find . -name "*.tmp" | xargs rm
```
**Move Files to a Directory, One at a Time**
```bash
ls *.log | xargs -n 1 mv -t /backup/logs/
```
**Use Null-Delimited Input (Safe for Spaces in Filenames)**
```bash
find . -type f -print0 | xargs -0 rm
```
**Replace Placeholder in Command**
```bash
echo -e "file1\nfile2" | xargs -I {} cp {} /backup/
```
- Copies `file1` and `file2` to `/backup/`.
**Run Commands in Parallel**
```bash
cat files.txt | xargs -n 1 -P 4 gzip
```
- Compresses files listed in `files.txt` using up to 4 parallel processes.

**Summary:**  
The `xargs` command is a powerful tool for building and executing commands from input, especially when working with large lists of files or arguments. For more, see `man xargs`.

___
### `xz` – Compress or Decompress .xz Files
The `xz` command is used to **compress and decompress files using the .xz format**, which provides high compression ratios and is commonly used for distributing software packages and large archives.
#### Basic Usage
```bash
xz filename
```
- Compresses `filename` to `filename.xz` and removes the original file.
```bash
xz -d filename.xz
```
- Decompresses `filename.xz` back to `filename`.
#### Key Features
- **High compression ratio:** Often better than `gzip` or `bzip2`.
- **Decompression:** Use `xz -d` or the `unxz` command.
- **Works with pipes:** Can compress or decompress data streams.
- **Preserves timestamps:** Keeps original file modification times.
#### Common Options
- `-d` : Decompress (same as `unxz`).
- `-k` : Keep the original file after compression or decompression.
- `-c` : Write output to standard output (useful for piping).
- `-v` : Verbose mode; show compression progress.
- `-T <n>` : Use multithreading with `<n>` threads for compression.
- `-z` : Compress (default behavior).
- `-l` : List information about .xz files.
#### Examples
**Compress a File**
```bash
xz data.txt
```
- Compresses `data.txt` to `data.txt.xz` and removes the original.
**Decompress a File**
```bash
xz -d archive.tar.xz
```
- Decompresses `archive.tar.xz` to `archive.tar`.
**Keep the Original File When Compressing**
```bash
xz -k report.log
```
- Compresses `report.log` to `report.log.xz` and keeps the original file.
**Compress Output from Another Command**
```bash
cat largefile | xz > largefile.xz
```
- Compresses the output of `cat largefile` and writes it to `largefile.xz`.
**Decompress to Standard Output**
```bash
xz -dc archive.tar.xz | tar xvf -
```
- Decompresses `archive.tar.xz` and extracts its contents with `tar`.
**Use Multiple Threads for Faster Compression**
```bash
xz -T4 bigfile.iso
```
- Compresses `bigfile.iso` using 4 threads.

**Summary:**  
The `xz` command is a modern tool for compressing and decompressing files with high efficiency. It is widely used for packaging and distributing large files. For more, see `man xz`.

---
### `yes` – Output a String Repeatedly Until Killed
The `yes` command is used to **output a string (or "y" by default) repeatedly to standard output** until it is stopped (usually with `Ctrl+C`). It is often used to automate responses to prompts in scripts or commands that require user confirmation.
#### Basic Usage
```bash
yes
```
- Repeatedly outputs `y` followed by a newline.

```bash
yes [string]
```
- Repeatedly outputs the specified string.
#### Key Features
- **Automate confirmations:** Pipe `yes` into commands that prompt for user input.
- **Custom output:** Specify any string to repeat.
- **Simple and fast:** Runs until interrupted.
#### Examples
**Automatically Answer "yes" to All Prompts**
```bash
yes | rm -i *.txt
```
- Automatically answers "y" to every prompt from `rm -i`.
**Repeat a Custom String**
```bash
yes "I agree"
```
- Prints "I agree" endlessly.
**Limit Output with `head`**
```bash
yes | head -n 5
```
- Prints "y" five times.

**Summary:**  
The `yes` command is a simple utility for generating repeated output, often used to automate command-line interactions. For more, see `man yes`.

___

### `zip` – Package and Compress Files into Archives
The `zip` command is used to **package and compress multiple files and directories into a single archive file** (with a `.zip` extension). It is widely used for creating portable, compressed archives that are compatible across different operating systems.
#### Basic Usage
```bash
zip archive.zip file1 file2 dir1
```
- Compresses `file1`, `file2`, and the contents of `dir1` into `archive.zip`.
#### Key Features
- **Cross-platform compatibility:** `.zip` files can be opened on Linux, Windows, and macOS.
- **Compression and packaging:** Combines and compresses multiple files/directories.
- **Password protection:** Supports encrypting archives with a password.
- **Selective compression:** Can exclude files or directories from the archive.
#### Common Options
- `-r` : Recursively add directories and their contents.
- `-e` : Encrypt the archive with a password.
- `-9` : Use the highest compression level.
- `-x <pattern>` : Exclude files matching the pattern.
- `-u` : Update existing entries in the archive if newer on disk.
- `-d` : Delete entries from the archive.
#### Examples
**Create a Zip Archive from Multiple Files**
```bash
zip myfiles.zip file1.txt file2.txt
```
- Creates `myfiles.zip` containing `file1.txt` and `file2.txt`.

**Compress a Directory Recursively**
```bash
zip -r project.zip project_folder/
```
- Compresses the entire `project_folder` directory and its contents.

**Create a Password-Protected Archive**
```bash
zip -e secrets.zip secret1.txt secret2.txt
```
- Prompts for a password and creates an encrypted archive.

**Exclude Specific Files from the Archive**
```bash
zip -r backup.zip /home/user --exclude=*.tmp
```
- Archives `/home/user` but skips all `.tmp` files.

**Update an Existing Archive with Newer Files**
```bash
zip -u archive.zip updated_file.txt
```
- Updates `archive.zip` with `updated_file.txt` if it is newer.
#### Advanced Example: Maximum Compression and Exclude Patterns
```bash
zip -r -9 backup.zip /data -x "*.log" "*.tmp"
```
- Recursively compresses `/data` with maximum compression, excluding `.log` and `.tmp` files.

**Summary:**  
The `zip` command is a standard tool for creating compressed archives on Linux. It is ideal for packaging files for transfer, backup, or sharing across platforms. For more, see `man zip`.

---
## **Network** 
### `arp` – Manipulate the System ARP Cache
The `arp` command is used to **view and modify the system's ARP (Address Resolution Protocol) cache**, which maps IP addresses to MAC (hardware) addresses on a local network. It is useful for troubleshooting network connectivity and diagnosing address resolution issues.
#### Basic Usage
```bash
arp
```
- Displays the current ARP table.
#### Key Features
- **View ARP entries:** See which IP addresses are mapped to which MAC addresses.
- **Add or delete entries:** Manually add or remove ARP entries (requires root).
- **Troubleshoot networking:** Diagnose issues with local network communication.
#### Common Options
- `-a` : Display all ARP entries in a readable format.
- `-n` : Show numeric IP addresses and MAC addresses (do not resolve hostnames).
- `-d <hostname>` : Delete an ARP entry for the specified host.
- `-s <hostname> <hw_addr>` : Add a static ARP entry for a host.
- `-v` : Verbose output.
#### Examples
**Show the ARP Table**
```bash
arp -a
```
- Lists all current ARP entries.

**Add a Static ARP Entry**
```bash
sudo arp -s 192.168.1.10 00:11:22:33:44:55
```
- Maps IP `192.168.1.10` to MAC address `00:11:22:33:44:55`.
**Delete an ARP Entry**
```bash
sudo arp -d 192.168.1.10
```
- Removes the ARP entry for `192.168.1.10`.
**Show ARP Table Without Hostname Resolution**
```bash
arp -an
```
- Displays ARP entries with numeric addresses only.

**Summary:**  
The `arp` command is useful for viewing and managing the ARP cache, which is important for local network troubleshooting and diagnostics. Note: On modern Linux systems, `ip neigh` is often preferred. For more, see `man arp`.
___
### `atop` – Advanced System & Process Monitor
The `atop` command is a powerful, interactive tool for **monitoring Linux system performance**. It provides detailed, real-time reports on CPU, memory, disk, and network usage for the entire system and for individual processes. Unlike `top` or `htop`, `atop` also logs resource usage for later analysis and highlights resource bottlenecks.
##### Basic Usage
```bash
sudo atop
```
- Launches the interactive `atop` interface, updating every 10 seconds by default. (Root privileges recommended for full details.
##### Key Features
- **Resource bottleneck highlighting** (CPU, memory, disk, network)
- **Per-process resource usage** (including disk and network I/O)
- **Historical logging and playback** of system activity
- **Color-coded output** for quick identification of issues
##### Common Options
- `-a` : Show all processes, even those that are idle.
- `-c` : Show command line per process.
- `-d` : Show disk-related process activity.
- `-m` : Show memory-related process activity.
- `-n` : Show network-related process activity.
- `-s <seconds>` : Set the interval between updates (default: 10 seconds).
- `-w <file>` : Write system activity to a raw log file.
- `-r <file>` : Read and display data from a raw log file (playback mode).
##### Example: Monitor All Resources with 2-Second Updates
```bash
sudo atop -a -s 2
```
- Shows all processes and updates every 2 seconds.
##### Example: Log System Activity for Later Analysis
```bash
sudo atop -w /var/log/atop.log 60
```
- Records system activity to `/var/log/atop.log` every 60 seconds.
##### Example: Playback a Log File
```bash
sudo atop -r /var/log/atop.log
```
- Replays the recorded system activity for post-mortem analysis.
##### Example: Show Only Disk Activity
```bash
sudo atop -d
```
- Focuses on disk-related process activity.
##### Example: Show Only Network Activity
```bash
sudo atop -n
```
- Focuses on network-related process activity.
##### Advanced Example: Analyze a Specific Time Range from a Log
```bash
sudo atop -r /var/log/atop.log -b 12:00 -e 13:00
```
- Shows system activity between 12:00 and 13:00 from the log file.
##### Interactive Controls
- Press `h` for help.
- Press `q` to quit.
- Press `m`, `d`, `n`, `c` to toggle memory, disk, network, or command line views.
- Use arrow keys to scroll.
**Summary:**  
The `atop` command is an advanced, all-in-one performance monitoring tool for Linux servers. It provides detailed, historical, and real-time insights into system and process resource usage, making it invaluable for troubleshooting, capacity planning, and post-incident analysis. For more, see `man atop`.

---
### `dig` – DNS Lookup Utility
The `dig` (Domain Information Groper) command is a **powerful DNS lookup tool** used to query DNS name servers for information about host addresses, mail exchanges, nameservers, and related information. It is widely used for troubleshooting DNS problems and for obtaining detailed DNS information.
#### Basic Usage
```bash
dig example.com
```
- Retrieves the A record (IPv4 address) for `example.com`.
#### Key Features
- **Query any DNS record type:** A, AAAA, MX, TXT, NS, CNAME, SOA, etc.
- **Query specific DNS servers:** Specify which DNS server to use for the query.
- **Detailed output:** Shows question, answer, authority, and additional sections.
- **Batch mode:** Query multiple domains at once.
#### Common Options
- `@server` : Specify the DNS server to query (e.g., `@8.8.8.8`).
- `-t <type>` : Specify the record type (e.g., `-t MX`).
- `+short` : Display only the answer section (compact output).
- `+noall +answer` : Show only the answer section.
- `-x <ip>` : Perform a reverse DNS lookup.
- `+trace` : Trace the delegation path from the root servers.
#### Examples
**Query for an MX Record**
```bash
dig gmail.com MX
```
- Retrieves the mail exchange records for `gmail.com`.
**Query a Specific DNS Server**
```bash
dig @1.1.1.1 example.com
```
- Uses Cloudflare’s DNS server to resolve `example.com`.
**Show Only the Answer Section**
```bash
dig +short example.com
```
- Displays just the IP address(es) for `example.com`.
**Reverse DNS Lookup**
```bash
dig -x 8.8.8.8
```
- Finds the domain name associated with the IP address 8.8.8.8.
**Trace the DNS Resolution Path**
```bash
dig +trace example.com
```
- Shows each step in the DNS resolution process from the root servers down.
#### Advanced Example: Query Multiple Record Types
```bash
dig example.com A AAAA MX TXT
```
- Retrieves A, AAAA, MX, and TXT records for `example.com`.

**Summary:**  
The `dig` command is a flexible and detailed DNS query tool, ideal for troubleshooting, verifying, and analyzing DNS records and server responses. For more, see `man dig`.

---
### `ethtool` – Query and Control Network Interface Settings
The `ethtool` command is used to **query and control network interface card (NIC) settings** on Linux systems. It provides detailed information about Ethernet devices and allows you to change parameters such as speed, duplex mode, auto-negotiation, and more.
#### Basic Usage
```bash
sudo ethtool eth0
```
- Displays detailed information about the `eth0` network interface.
#### Key Features
- **View NIC capabilities:** See supported speeds, duplex modes, and features.
- **Change speed and duplex:** Set the speed (e.g., 1000Mb/s) and duplex mode (full/half).
- **Enable/disable features:** Control offloading, auto-negotiation, Wake-on-LAN, etc.
- **Diagnostics:** Run cable tests and view statistics.
#### Common Options
- `<interface>` : Specify the network interface (e.g., `eth0`, `enp3s0`).
- `-i` : Show driver information.
- `-S` : Show NIC statistics.
- `-s` : Change speed, duplex, or auto-negotiation settings.
- `-p` : Identify (blink) the NIC’s LED.
- `-g` : Show or set ring buffer sizes.
- `-k` : Show or change offload parameters.
- `-d` : Dump EEPROM or register data.
#### Examples
**Show Information About an Interface**
```bash
sudo ethtool eth0
```
- Displays speed, duplex, link status, and supported features.
**Show Driver Information**
```bash
sudo ethtool -i eth0
```
- Shows the driver, version, firmware, and bus info.
**Show Interface Statistics**
```bash
sudo ethtool -S eth0
```
- Displays detailed statistics for the interface.
**Set Speed and Duplex (Requires Root)**
```bash
sudo ethtool -s eth0 speed 100 duplex full autoneg off
```
- Sets `eth0` to 100Mb/s, full duplex, with auto-negotiation disabled.
**Enable Wake-on-LAN**
```bash
sudo ethtool -s eth0 wol g
```
- Enables Wake-on-LAN using the "magic packet".
**Identify the NIC (Blink LED)**
```bash
sudo ethtool -p eth0 10
```
- Blinks the NIC’s LED for 10 seconds.

**Summary:**  
The `ethtool` command is essential for viewing and configuring Ethernet device settings, troubleshooting network issues, and optimizing performance. For more, see `man ethtool`.

___
### `host` – Perform DNS Lookups in Linux
The `host` command is a simple utility for **performing DNS lookups**. It is used to convert domain names to IP addresses and vice versa, as well as to query specific DNS record types.
#### Basic Usage
```bash
host example.com
```
- Returns the IP address(es) for `example.com`.
```bash
host 8.8.8.8
```
- Performs a reverse lookup to find the domain name for the IP address.
#### Key Features
- **Forward and reverse lookups:** Convert domain names to IPs and IPs to domain names.
- **Query specific DNS record types:** A, AAAA, MX, TXT, NS, CNAME, etc.
- **Specify DNS server:** Query using a particular DNS server.
#### Common Options
- `-t <type>` : Specify the DNS record type to query (e.g., `-t MX` for mail records).
- `-a` : Query all record types (same as `ANY`).
- `-C` : Query for SOA records and display the entire chain of authority.
- `-4` / `-6` : Use IPv4 or IPv6 only.
- `-W <timeout>` : Set the timeout for waiting for a reply (in seconds).
#### Examples
**Query for an MX Record**
```bash
host -t MX gmail.com
```
- Shows the mail exchange servers for `gmail.com`.
**Query a Specific DNS Server**
```bash
host example.com 1.1.1.1
```
- Looks up `example.com` using Cloudflare’s DNS server.

**Query for a TXT Record**
```bash
host -t TXT example.com
```
- Retrieves TXT records for `example.com`.
**Query All Record Types**
```bash
host -a example.com
```
- Shows all available DNS records for `example.com`.
#### Advanced Example: Reverse Lookup for an IP Address
```bash
host 93.184.216.34
```
- Returns the domain name associated with the IP address.
**Summary:**  
The `host` command is a fast and straightforward tool for DNS lookups, supporting both forward and reverse queries, as well as specific record types. For more, see `man host`.

---
### `ifconfig` – Configure Network Interfaces (Deprecated, but Still Common)
The `ifconfig` command is used to **view and configure network interfaces** on Linux systems. While it has been largely replaced by the `ip` command in modern distributions, `ifconfig` is still widely used for basic network management and troubleshooting.
#### Basic Usage
```bash
ifconfig
```
- Displays information about all active network interfaces.
#### Key Features
- **View interface status:** Shows IP addresses, MAC addresses, MTU, and more.
- **Enable or disable interfaces:** Bring network interfaces up or down.
- **Assign IP addresses:** Set or change the IP address of an interface.
- **Configure network parameters:** Set netmask, broadcast address, etc.
#### Common Options
- `<interface>` : Show or configure a specific interface (e.g., `eth0`, `wlan0`).
- `up` / `down` : Enable or disable an interface.
- `inet <address>` : Assign an IPv4 address.
- `netmask <mask>` : Set the subnet mask.
- `broadcast <address>` : Set the broadcast address.
- `hw ether <MAC>` : Set the hardware (MAC) address.
#### Examples
**Show All Network Interfaces**
```bash
ifconfig -a
```
**Bring an Interface Up**
```bash
sudo ifconfig eth0 up
```
**Bring an Interface Down**
```bash
sudo ifconfig eth0 down
```
**Assign an IP Address**
```bash
sudo ifconfig eth0 192.168.1.100 netmask 255.255.255.0
```
**Change the MAC Address**
```bash
sudo ifconfig eth0 hw ether 00:11:22:33:44:55
```

**Summary:**  
The `ifconfig` command is a classic tool for network interface configuration and troubleshooting. While it is deprecated in favor of the `ip` command, it remains useful and familiar to many users. For more, see `man ifconfig`.
___
### `iftop` – Real-Time Network Traffic Viewer
The `iftop` command is used to **display bandwidth usage on an interface by host pairs in real time**. It provides a top-like, ncurses-based interface for monitoring network traffic, showing which connections are using the most bandwidth.
##### Basic Usage
```bash
sudo iftop
```
- Launches the interactive `iftop` interface for the default network interface. (Root privileges are usually required.)
##### Common Options
- `-i <interface>` : Specify which network interface to monitor (e.g., `-i eth0`).
- `-B` : Show bandwidth in bytes instead of bits.
- `-n` : Show IP addresses instead of resolving hostnames.
- `-N` : Show port numbers instead of resolving service names.
- `-P` : Show both port numbers and hostnames.
- `-F <filter>` : Show only traffic to/from a specific network (e.g., `-F 192.168.1.0/24`).
##### Key Features and Controls
- Use the **arrow keys** to scroll through the list of connections.
- Press `h` for help.
- Press `t` to toggle display of text bar graphs.
- Press `s` to sort by source, `d` to sort by destination.
- Press `b` to toggle between bit and byte display.
- Press `q` to quit.
##### Example: Monitor a Specific Interface
```bash
sudo iftop -i eth0
```
- Monitors traffic on the `eth0` interface.
##### Example: Show IPs and Ports Only
```bash
sudo iftop -nNP
```
- Displays IP addresses and port numbers, without resolving hostnames or service names.
##### Example: Filter Traffic to a Subnet
```bash
sudo iftop -F 10.0.0.0/8
```
- Shows only traffic to and from the `10.0.0.0/8` network.
**Summary:**  
The `iftop` command is a powerful, interactive tool for monitoring real-time network bandwidth usage by connection. It helps identify which hosts and services are consuming the most bandwidth, making it invaluable for troubleshooting and network analysis. For more, see `man iftop`.
####  `ip`– **Iproute2** 
Is a suite of command-line utilities used for managing networking, routing, and traffic control in Linux systems. It replaces many older networking tools (like `ifconfig`, `route`, and `arp`) with more powerful and flexible commands.
##### Key Utilities in Iproute2
- **ip**: The main tool for network interface configuration, routing, and tunnels.
- **tc**: Used for advanced traffic control and shaping.
##### Common `ip` Command Examples
###### 1. Show Network Interfaces
````bash
ip addr show
````
##### 2. Bring an Interface Up or Down
````bash
sudo ip link set eth0 up
sudo ip link set eth0 down
````
##### 3. Add or Delete an IP Address
````bash
sudo ip addr add 192.168.1.10/24 dev eth0
sudo ip addr del 192.168.1.10/24 dev eth0
````
##### 4. Show Routing Table
````bash
ip route show
````
##### 5. Add a Route
````bash
sudo ip route add 10.0.0.0/24 via 192.168.1.1
````
##### Common `tc` Command Example
##### 6. Limit Bandwidth on an Interface
````bash
sudo tc qdisc add dev eth0 root tbf rate 1mbit burst 32kbit latency 400ms
````
##### 7.Create a VLAN Interface
```bash
sudo ip link add link eth0 name eth0.100 type vlan id 100
sudo ip addr add 192.168.100.2/24 dev eth0.100
sudo ip link set eth0.100 up`
```
##### 8. Set Up Policy-Based Routing
```bash
# Add a new routing table
echo "200 custom" | sudo tee -a /etc/iproute2/rt_tables

# Add a rule to use the new table for traffic from 192.168.1.50
sudo ip rule add from 192.168.1.50/32 table custom

# Add a route in the custom table
sudo ip route add default via 192.168.1.1 dev eth0 table custom
```
##### 9. Show All Network Namespaces
```bash
ip netns list
```
##### 10. Create and Use a Network Namespace
```bash
sudo ip netns add testns
sudo ip link add veth0 type veth peer name veth1
sudo ip link set veth1 netns testns
sudo ip addr add 10.0.0.1/24 dev veth0
sudo ip link set veth0 up
sudo ip netns exec testns ip addr add 10.0.0.2/24 dev veth1
sudo ip netns exec testns ip link set veth1 up
```
##### Summary
Iproute2 provides modern, scriptable tools for network configuration and management. The `ip` command is especially useful for viewing and changing network settings, while `tc` is used for controlling network traffic.

---
### `iwconfig` – Configure Wireless Network Interfaces
The `iwconfig` command is used to **view and configure wireless network interfaces** on Linux systems. It is similar to `ifconfig`, but specifically for wireless devices, allowing you to set parameters such as SSID, mode, frequency, encryption keys, and more.
#### Basic Usage
```bash
iwconfig
```
- Displays wireless interface information and settings.
#### Key Features
- **View wireless status:** Shows current SSID, signal strength, frequency, and more.
- **Set wireless parameters:** Configure SSID, mode (managed/ad-hoc), frequency/channel, and encryption keys.
- **Troubleshoot Wi-Fi:** Diagnose connection issues and monitor signal quality.
#### Common Options
- `<interface>` : Specify the wireless interface (e.g., `wlan0`).
- `essid <name>` : Set the network name (SSID).
- `mode <mode>` : Set the mode (e.g., `managed`, `ad-hoc`, `monitor`).
- `freq <frequency>` or `channel <channel>` : Set the frequency or channel.
- `key <key>` : Set the WEP/WPA key.
- `rate <rate>` : Set the bit rate.
- `ap <address>` : Set the access point MAC address.
- `txpower <dBm>` : Set transmit power.
#### Examples
**Show Wireless Interface Status**
```bash
iwconfig
```
**Set SSID for an Interface**
```bash
sudo iwconfig wlan0 essid "MyNetwork"
```
**Set Wireless Mode to Managed**
```bash
sudo iwconfig wlan0 mode managed
```
**Set Frequency or Channel**
```bash
sudo iwconfig wlan0 freq 2.437G
sudo iwconfig wlan0 channel 6
```
**Set WEP Key**
```bash
sudo iwconfig wlan0 key s:mywepkey
```
**Show Signal Strength and Quality**
```bash
iwconfig wlan0
```
- Look for `Link Quality` and `Signal level` in the output.

**Summary:**  
The `iwconfig` command is useful for configuring and troubleshooting wireless network interfaces on Linux. For more, see `man iwconfig`.
___
### `ping` – Send ICMP ECHO_REQUEST to Network Hosts
The `ping` command is used to **test network connectivity between your system and another host** by sending ICMP ECHO_REQUEST packets and measuring the response time. It is a fundamental tool for diagnosing network issues and checking if a remote host is reachable.
#### Basic Usage
```bash
ping <hostname or IP>
```
- Sends ICMP echo requests to the specified host (e.g., `ping google.com`).
#### Key Features
- **Connectivity check:** Verifies if a host is reachable over the network.
- **Round-trip time:** Measures the time it takes for packets to travel to the host and back.
- **Packet loss:** Reports the percentage of lost packets.
- **Continuous or limited pings:** By default, runs until stopped; can limit the number of packets sent.
#### Common Options
- `-c <count>` : Send only the specified number of packets.
- `-i <interval>` : Set the interval (in seconds) between packets.
- `-t <ttl>` : Set the Time To Live for packets.
- `-s <size>` : Specify the number of data bytes to send.
- `-q` : Quiet output (summary only).
- `-f` : Flood ping (send packets as fast as possible; root only).
#### Examples
**Ping a Host Until Stopped**
```bash
ping 8.8.8.8
```
- Continuously pings Google DNS until you press `Ctrl+C`.

**Send a Specific Number of Pings**
```bash
ping -c 4 example.com
```
- Sends 4 ICMP echo requests to `example.com`.

**Set the Interval Between Pings**
```bash
ping -i 2 8.8.4.4
```
- Sends a ping every 2 seconds.

**Set Packet Size**
```bash
ping -s 1024 example.com
```
- Sends packets with 1024 bytes of data.

**Quiet Output (Summary Only)**
```bash
ping -c 5 -q example.com
```
- Sends 5 pings and only displays the summary.
#### Advanced Example: Set TTL and Interval
```bash
ping -t 10 -i 0.5 192.168.1.1
```
- Sends pings with a TTL of 10 every half second.

**Summary:**  
The `ping` command is essential for testing network connectivity, measuring latency, and diagnosing network problems. For more, see `man ping`.

---
### `mtr` – Network Diagnostic Tool (Combines `ping` and `traceroute`)
The `mtr` (My Traceroute) command is a **real-time network diagnostic tool** that combines the functionality of `ping` and `traceroute`. It continuously displays the route packets take to a destination and provides live statistics for each hop, making it ideal for diagnosing network issues.
#### Basic Usage
```bash
mtr <hostname or IP>
```
- Starts a real-time trace to the specified host (e.g., `mtr google.com`).
#### Key Features
- **Live, continuous output:** Updates statistics for each hop in real time.
- **Packet loss and latency:** Shows packet loss percentage and round-trip times for each hop.
- **Interactive interface:** Allows sorting, pausing, and customizing the display.
- **Combines ping and traceroute:** Provides both route and performance data in one tool.
#### Common Options
- `-r` : Report mode (prints results once and exits; suitable for scripts).
- `-c <count>` : Number of pings to send to each hop.
- `-n` : Show IP addresses only (do not resolve hostnames).
- `-w` : Wide output (more columns).
- `-i <interval>` : Set the interval between ICMP requests (in seconds).
- `-p` : Use TCP SYN packets instead of ICMP (may require root).
#### Examples
**Run mtr with Default Settings**
```bash
mtr example.com
```
- Starts an interactive, real-time trace to `example.com`.

**Show Only IP Addresses**
```bash
mtr -n 8.8.8.8
```
- Displays only IP addresses for each hop.

**Run in Report Mode with 10 Pings per Hop**
```bash
mtr -r -c 10 example.com
```
- Prints a summary report after sending 10 pings to each hop.

**Increase the Interval Between Pings**
```bash
mtr -i 2 example.com
```
- Sends a probe every 2 seconds.
#### Advanced Example: Save a Report to a File
```bash
mtr -r -c 20 google.com > mtr_report.txt
```
- Runs 20 pings per hop to `google.com` and saves the report to `mtr_report.txt`.

**Summary:**  
The `mtr` command is a powerful tool for real-time network diagnostics, combining the best features of `ping` and `traceroute`. It is invaluable for troubleshooting connectivity issues and identifying network bottlenecks. For more, see `man mtr`.

---
### `nc` – Command-Line Networking Utility (Netcat)
The `nc` (netcat) command is a **versatile networking utility** for reading from and writing to network connections using TCP or UDP. It is often called the "Swiss Army knife" of networking because it can be used for port scanning, transferring files, banner grabbing, setting up simple servers, and more.
#### Basic Usage
```bash
nc <host> <port>
```
- Connects to the specified host and port (e.g., `nc example.com 80`).
#### Key Features
- **TCP and UDP support:** Can connect to or listen on both protocols.
- **Port scanning:** Check which ports are open on a host.
- **File transfer:** Send or receive files over the network.
- **Simple server/client:** Set up basic network servers or clients for testing.
- **Banner grabbing:** Retrieve service banners for identification.
#### Common Options
- `-l` : Listen for incoming connections (server mode).
- `-p <port>` : Specify local port to use.
- `-u` : Use UDP instead of TCP.
- `-v` : Verbose output.
- `-z` : Zero-I/O mode (useful for port scanning).
- `-w <seconds>` : Set timeout for connects and final net reads.
#### Examples
**Connect to a Web Server (TCP)**
```bash
nc example.com 80
```
- Opens a TCP connection to port 80 on `example.com`.
**Listen for Incoming Connections on Port 1234**
```bash
nc -l 1234
```
- Waits for a connection on TCP port 1234.
**Transfer a File (Sender)**
```bash
nc -l 1234 > received_file.txt
```
**Transfer a File (Receiver)**
```bash
nc host.example.com 1234 < file_to_send.txt
```
- Sends `file_to_send.txt` to the listening host.
**Port Scan a Host**
```bash
nc -zv 192.168.1.1 20-80
```
- Scans ports 20 through 80 on `192.168.1.1` and shows which are open.
**UDP Listener**
```bash
nc -u -l 5000
```
- Listens for UDP packets on port 5000.
#### Advanced Example: Simple Chat
On one terminal:
```bash
nc -l 5555
```
On another terminal:
```bash
nc localhost 5555
```
- Type messages back and forth for a simple chat.

**Summary:**  
The `nc` (netcat) command is a powerful tool for network troubleshooting, scripting, and testing. It is widely used for debugging, file transfers, and network exploration. For more, see `man nc` or `man netcat`.

---
### `nload` – Simple Command-Line Network Interface Monitor
The `nload` command is a **real-time, console-based network traffic monitor** for Linux. It provides a simple, graphical display of incoming and outgoing traffic on a selected network interface.
#### Basic Usage
```bash
sudo nload
```
- Launches the interactive `nload` interface, showing traffic for the default network interface.
#### Key Features
- **Live bandwidth graphs:** Visualizes incoming and outgoing traffic separately.
- **Multiple interfaces:** Easily switch between network interfaces.
- **Traffic statistics:** Shows current, average, minimum, and maximum transfer rates, plus total data transferred.
- **Minimal dependencies:** Lightweight and easy to use.
#### Common Controls
- Arrow keys: Switch between network interfaces.
- `q`: Quit `nload`.
- `h`: Show help screen.
#### Common Options
- `-u h` : Show traffic rates in human-readable format (e.g., KB/s, MB/s).
- `-t` : Set refresh interval in milliseconds (e.g., `-t 500` for 0.5s).
- `-i <iface>` : Start monitoring a specific interface (e.g., `-i eth0`).
- `-m` : Show all interfaces at once (split screen).
#### Examples
**Monitor a Specific Interface**
```bash
sudo nload -i eth0
```
- Monitors the `eth0` interface.

**Show All Interfaces in Split View**
```bash
sudo nload -m
```
- Displays all detected interfaces at once.

**Set Refresh Interval and Human-Readable Units**
```bash
sudo nload -t 500 -u h
```
- Updates every 0.5 seconds and shows rates in human-friendly units.

**Summary:**  
The `nload` command is a quick and easy way to visualize network traffic in real time from the terminal. It is ideal for monitoring bandwidth usage on servers and desktops. For more, see `man nload`.

---
### `netstat` – Network Statistics and Connections
The `netstat` (network statistics) command is a classic tool used to **display network connections, routing tables, interface statistics, masquerade connections, and multicast memberships**. It is invaluable for troubleshooting and monitoring network activity on Linux systems.

> **Note:** On modern Linux systems, `ss` is recommended as a faster, more feature-rich replacement for `netstat`. However, `netstat` is still widely used and available on many distributions.
#### Basic Usage
```bash
netstat
```
- Shows a list of open sockets (both incoming and outgoing connections).
#### Common Options
- `-t` : Show TCP connections.
- `-u` : Show UDP connections.
- `-l` : Show only listening sockets.
- `-a` : Show all sockets (listening and non-listening).
- `-n` : Show numerical addresses instead of resolving hostnames.
- `-p` : Show the PID and name of the program to which each socket belongs.
- `-r` : Display the kernel routing table.
- `-i` : Show network interface statistics.
- `-s` : Show summary statistics for each protocol.
- `-c` : Continuously display the selected information every second.
#### Examples
**Show All Listening TCP and UDP Ports**
```bash
netstat -tuln
```
- Lists all listening TCP and UDP ports with numerical addresses.

**Show All Connections with Process Information**
```bash
sudo netstat -tunap
```
- Lists all TCP and UDP connections with associated process names and PIDs.

**Show Routing Table**
```bash
netstat -r
```
- Displays the kernel IP routing table (similar to `route -n`).

**Show Network Interface Statistics**
```bash
netstat -i
```
- Shows statistics for each network interface (packets, errors, dropped, etc.).

**Show Protocol Statistics**
```bash
netstat -s
```
- Displays summary statistics for each network protocol (TCP, UDP, ICMP, etc.).

#### Advanced Examples

**Continuously Monitor Network Connections**
```bash
watch -n 2 'netstat -tunap'
```
- Updates the list of network connections every 2 seconds.

**Find Which Process is Using a Specific Port**
```bash
sudo netstat -tulpn | grep :80
```
- Shows which process is listening on port 80.

**Show Only Established TCP Connections**
```bash
netstat -tn | grep ESTABLISHED
```
- Lists all currently established TCP connections.

**Show Multicast Group Memberships**
```bash
netstat -g
```
- Displays multicast group memberships for each interface.

**Summary:**  
The `netstat` command is a versatile and essential tool for viewing network connections, routing tables, and interface statistics. It is useful for troubleshooting network issues, monitoring open ports, and identifying active connections and the processes using them. For more details, see `man netstat`.

---
### `nethogs` – Real-Time Network Traffic Analyzer by Process
The `nethogs` command is used to **monitor network bandwidth usage per process** in real time. Unlike tools that show usage by connection or interface, `nethogs` groups bandwidth by process, making it easy to see which programs are using the network.
##### Basic Usage
```bash
sudo nethogs
```
- Launches the interactive `nethogs` interface, showing network usage by process and interface. (Root privileges are required.)
##### Common Options
- `-d <seconds>` : Set the refresh rate (default is 1 second).
- `-t` : Text mode (for logging or scripting).
- `-p` : Show ports.
- `-v` : Show version information.
- `<interface>` : Monitor a specific network interface (e.g., `eth0`, `wlan0`).
##### Key Features and Controls
- Use the **arrow keys** to scroll through the list of processes.
- Press `m` to switch between total and per-interface mode.
- Press `r` to sort by received traffic, `s` to sort by sent traffic.
- Press `q` to quit.
##### Example: Monitor a Specific Interface
```bash
sudo nethogs eth0
```
- Monitors network usage on the `eth0` interface.
##### Example: Set Refresh Rate to 5 Seconds
```bash
sudo nethogs -d 5
```
- Updates the display every 5 seconds.
##### Example: Run in Text Mode for Logging
```bash
sudo nethogs -t > nethogs_log.txt
```
- Outputs results in plain text, suitable for logging or further processing.

**Summary:**  
The `nethogs` command is a powerful, interactive tool for monitoring real-time network bandwidth usage by process. It helps quickly identify which applications are consuming network resources, making it invaluable for troubleshooting and network analysis. For more, see `man nethogs`.

---
### `nmap` – Network Exploration Tool and Security/Port Scanner
The `nmap` (Network Mapper) command is a **powerful tool for network discovery, security auditing, and port scanning**. It can quickly scan large networks to identify live hosts, open ports, running services, and even operating system details.
#### Basic Usage
```bash
nmap target
```
- Scans the target host or IP address for open ports.
#### Key Features
- **Port scanning:** Detects open TCP/UDP ports on hosts.
- **Service/version detection:** Identifies services and their versions running on open ports.
- **OS detection:** Attempts to determine the operating system of remote hosts.
- **Network mapping:** Discovers hosts and devices on a network.
- **Scriptable:** Supports advanced scripting for vulnerability detection and automation.
#### Common Options
- `-sS` : TCP SYN (stealth) scan (default and most common).
- `-sU` : UDP scan.
- `-O` : Enable OS detection.
- `-sV` : Detect service versions.
- `-A` : Enable OS detection, version detection, script scanning, and traceroute.
- `-p <ports>` : Specify ports to scan (e.g., `-p 22,80,443`).
- `-T<0-5>` : Set timing template (higher is faster, but more detectable).
- `-Pn` : Treat all hosts as online (skip host discovery).
- `-iL <file>` : Read targets from a file.
#### Examples
**Scan a Single Host for Open Ports**
```bash
nmap 192.168.1.1
```
**Scan Multiple Ports**
```bash
nmap -p 22,80,443 example.com
```
**Aggressive Scan with OS and Service Detection**
```bash
nmap -A example.com
```
**Scan an Entire Subnet**
```bash
nmap 192.168.1.0/24
```
**Detect Service Versions**
```bash
nmap -sV example.com
```
**Save Scan Results to a File**
```bash
nmap -oN scan_results.txt example.com
```
**Summary:**  
The `nmap` command is an essential tool for network administrators and security professionals, providing comprehensive network discovery and security auditing capabilities. For more, see `man nmap` or [nmap.org](https://nmap.org/).

___
### `nmcli` – Command-Line Tool for NetworkManager
The `nmcli` command is a **command-line interface for controlling NetworkManager**, which manages network connections on many modern Linux distributions. It allows you to create, display, edit, delete, activate, and deactivate network connections, as well as control and display network device status.
#### Basic Usage
```bash
nmcli
```
- Shows a summary of NetworkManager status and active connections.
#### Key Features
- **Manage connections:** Add, modify, delete, and activate/deactivate network connections (wired, wireless, VPN, etc.).
- **Device management:** Show and control the status of network interfaces.
- **Scriptable:** Suitable for automation and scripting network configuration.
- **Display status:** View connection details, device status, and overall network state.
#### Common Commands
**Show All Network Devices**
```bash
nmcli device status
```
- Lists all network interfaces and their current state.

**Show All Network Connections**
```bash
nmcli connection show
```
- Lists all saved network connections.

**Connect to a Wi-Fi Network**
```bash
nmcli device wifi connect "SSID" password "your_password"
```
- Connects to the specified Wi-Fi network.

**Disconnect a Device**
```bash
nmcli device disconnect eth0
```
- Disconnects the `eth0` network interface.

**Add a Static IP Address to a Wired Connection**
```bash
nmcli connection modify "Wired connection 1" ipv4.addresses 192.168.1.100/24 ipv4.gateway 192.168.1.1 ipv4.dns 8.8.8.8 ipv4.method manual
nmcli connection up "Wired connection 1"
```
- Sets a static IP, gateway, and DNS for the connection and brings it up.

**Create a New Ethernet Connection**
```bash
nmcli connection add type ethernet ifname eth1 con-name my-eth1
```
- Adds a new Ethernet connection for interface `eth1`.

**Delete a Connection**
```bash
nmcli connection delete my-eth1
```
- Removes the connection named `my-eth1`.
#### Advanced Example: List Available Wi-Fi Networks
```bash
nmcli device wifi list
```
- Scans and displays all available Wi-Fi networks.

**Summary:**  
The `nmcli` command is a powerful tool for managing network connections and devices from the command line. It is ideal for scripting, automation, and headless server environments. For more, see `man nmcli` or [NetworkManager documentation](https://developer.gnome.org/NetworkManager/stable/nmcli.html).

---
### `nslookup` – Query Internet Name Servers Interactively
The `nslookup` command is used to **query Internet domain name servers (DNS)** for information about hostnames, IP addresses, or other DNS records. It is a valuable tool for troubleshooting DNS issues and verifying DNS configurations.
#### Basic Usage
```bash
nslookup <hostname>
```
- Looks up the IP address for the specified hostname.
```bash
nslookup <IP_address>
```
- Performs a reverse lookup to find the hostname for the given IP address.
#### Key Features
- **Interactive mode:** Enter `nslookup` without arguments to use an interactive prompt for multiple queries.
- **Query specific DNS servers:** Specify a DNS server to use for the query.
- **Retrieve different record types:** Query for A, AAAA, MX, TXT, NS, CNAME, and other DNS records.
#### Common Options and Usage
**Query a Specific DNS Server**
```bash
nslookup example.com 8.8.8.8
```
- Queries `example.com` using Google’s public DNS server (8.8.8.8).

**Interactive Mode**
```bash
nslookup
```
- Enter interactive mode. Type a domain or IP to query, or use commands like `set type=MX` to change the record type.

**Query for a Specific Record Type**
```bash
nslookup -type=MX gmail.com
```
- Retrieves the mail exchange (MX) records for `gmail.com`.
**Reverse DNS Lookup**
```bash
nslookup 8.8.8.8
```
- Finds the hostname associated with the IP address 8.8.8.8.
#### Advanced Example: Query for TXT Records
```bash
nslookup -type=TXT example.com
```
- Retrieves TXT records for `example.com`.
**Summary:**  
The `nslookup` command is a versatile tool for querying DNS records, troubleshooting name resolution, and verifying DNS configurations. For more, see `man nslookup`.

---
### `route` – Show/Manipulate the IP Routing Table
The `route` command is used to **display and modify the IP routing table** on Linux systems. It shows how network traffic is directed and allows you to add, delete, or change routes. While `route` is considered deprecated in favor of `ip route`, it is still widely used and available.
#### Basic Usage
```bash
route
```
- Displays the current routing table.
#### Key Features
- **View routing table:** See how network traffic is routed.
- **Add or delete routes:** Manually configure network routes.
- **Troubleshoot networking:** Diagnose routing and connectivity issues.
#### Common Options
- `-n` : Show numerical addresses instead of resolving hostnames.
- `add` : Add a new route.
- `del` : Delete a route.
#### Examples
**Show the Routing Table**
```bash
route -n
```
- Displays the routing table with numeric IP addresses.
**Add a Default Gateway**
```bash
sudo route add default gw 192.168.1.1
```
- Sets the default gateway to `192.168.1.1`.
**Delete a Route**
```bash
sudo route del -net 10.0.0.0/8
```
- Removes the route to the `10.0.0.0/8` network.

**Summary:**  
The `route` command is useful for viewing and managing the system's routing table. For modern systems, prefer `ip route` for more features and flexibility. For more, see `man route`.

___
### `scp` – Secure Copy Files Over SSH
The `scp` (secure copy) command is used to **securely transfer files and directories between hosts on a network**. It uses SSH for data transfer and provides the same authentication and security as SSH.
#### Basic Usage
```bash
scp source_file user@remote_host:/path/to/destination/
```
- Copies `source_file` from the local machine to the specified path on the remote host.
- ##### Common Options
- `-r` : Recursively copy entire directories
- `-P` : Specify the SSH port (default is 22)
- `-i` : Specify an identity (private key) file for authentication
- `-C` : Enable compression
- `-v` : Verbose mode (for debugging)
- `-p` : Preserve modification times, access times, and modes
##### Copy a File to a Remote Server
```bash
scp file.txt user@192.168.1.10:/home/user/
```
- Copies `file.txt` to the `/home/user/` directory on the remote server.
#####  Copy a File from a Remote Server
```bash
scp user@192.168.1.10:/home/user/file.txt /local/directory/
```
- Copies `file.txt` from the remote server to the local directory.
##### Copy a Directory Recursively
```bash
scp -r myfolder user@remote_host:/home/user/
```
- Copies the entire `myfolder` directory to the remote host.
##### Use a Different SSH Port
```bash
scp -P 2222 file.txt user@remote_host:/home/user/
```
- Uses port 2222 instead of the default SSH port.
#####  Use an SSH Key for Authentication
```bash
scp -i ~/.ssh/id_rsa file.txt user@remote_host:/home/user/
```
- Uses the specified private key for authentication.
##### Advanced Example: Enable Compression and Verbose Output
```bash
scp -C -v file.txt user@remote_host:/home/user/
```
- Enables compression and prints detailed debug information.

**Summary:**  
The `scp` command is a secure and convenient way to transfer files and directories between Linux systems over a network. It supports recursive copying, custom ports, SSH keys, and more. For further details, see `man scp`.

---
#### `rsync`: Remote File Synchronization Tool
`rsync` (remote sync) synchronizes files and directories between locations while preserving permissions, ownership, timestamps, symbolic links, etc.  
It uses a "delta-transfer" algorithm to efficiently transfer only changes.
##### Syntax Structure
```bash
rsync [options] source destination
```
###### Common Options
*-a (--archive):* Preserves permissions, ownerships, timestamps, and recursively transfers directories (equivalent to -rlptgoD).
*-v (--verbose)*: Shows detailed progress messages.
*--delete:* Deletes files in the destination directory that don't exist in source (use cautiously).
Basic Commands
Local Sync:
```bash
rsync -av /source/path/ user@host:/destination/path/
Remote to Remote:
```

```bash
rsync --rsh=ssh -av user1@host1:/src_dir user2@host2:/dest_dir
```
Advanced Usage Examples Preserve permissions & timestamps (dry run):
```bash
rsync -av --perms --times --modify-time --group --owner --links --verbose /local/src/ user@remote:/remote/dest/
```
Delete extra files at destination:
```bash
rsync -av --delete /local/src/ user@remote:/remote/dest/
Sync via SSH without password (pre-shared keys):
```
Ensure you've set up SSH key-based authentication first
```bash
rsync -avz -e 'ssh -i ~/.ssh/id_rsa' local_dir/ user@remote:/sync_dir/
```
 Or if using passwordless rsync config:
```bash
rsync -avz --rsync-path='rsync --password-file=/path/to/passfile' /src/ user@host:/dest/
```
Key Features
`Delta Transfer`: Calculates differences between source and destination to minimize data sent.
`Compression Support`: -z enables compression during transfer (client-server only).
`Partial Transfers:` -p allows restarting interrupted transfers.
Security Notes
Avoid using --password-file in scripts unless secured properly.
Prefer SSH configuration over password credentials.

---
### `screen` – Terminal Multiplexer and Persistent Sessions
The `screen` command is a **terminal multiplexer** that allows you to start a shell session that will remain active even if you disconnect (e.g., from SSH). It is widely used to keep long-running processes alive on remote servers and to manage multiple terminal windows within a single session.
#### Basic Usage
```bash
screen
```
- Starts a new screen session.
#### Key Features
- **Persistent sessions:** Detach and reattach to sessions, keeping processes running in the background.
- **Multiple windows:** Create and switch between multiple terminal windows in one session.
- **Session sharing:** Share your session with other users for collaboration.
- **Scrollback buffer:** Review output history even after it has scrolled off the screen.
#### Common Commands (Inside a Screen Session)
- `Ctrl+a c` : Create a new window
- `Ctrl+a n` : Next window
- `Ctrl+a p` : Previous window
- `Ctrl+a d` : Detach from the session (leave it running in the background)
- `Ctrl+a "` : List all windows
- `Ctrl+a k` : Kill the current window
- `Ctrl+a [` : Enter copy/scrollback mode
#### Examples
**Start a New Session and Run a Command**
```bash
screen -S mysession
```
- Starts a new session named `mysession`.
**Detach from a Session**
- Press `Ctrl+a` then `d`
**List All Screen Sessions**
```bash
screen -ls
```
- Shows all running screen sessions.

**Reattach to a Detached Session**
```bash
screen -r mysession
```
- Reattaches to the session named `mysession`.

**Kill a Screen Session**
```bash
screen -X -S mysession quit
```
- Terminates the session named `mysession`.
#### Advanced Example: Run a Command in a Detached Session
```bash
screen -dmS updater ./update_script.sh
```
- Runs `update_script.sh` in a new, detached session named `updater`.

**Summary:**  
The `screen` command is essential for running persistent, multi-window terminal sessions—especially on remote servers. It is ideal for long-running tasks, remote work, and session management. For more, see `man screen`.

---
### `snmpd` (SNMP Agent) and `snmp` Utilities – Network Monitoring with SNMP
The **SNMP (Simple Network Management Protocol)** tools allow you to **monitor and manage system performance and resources over a network**. The `snmpd` daemon acts as the SNMP agent, while the `snmp*` utilities (`snmpget`, `snmpwalk`, `snmpset`, etc.) are used to query or modify SNMP-enabled devices.
##### `snmpd` – SNMP Agent Daemon
The `snmpd` service runs in the background, exposing system information to SNMP managers for monitoring and management.

**Start the SNMP Agent**
```bash
sudo systemctl start snmpd
```
- Starts the SNMP agent daemon.
**Configuration File**
- `/etc/snmp/snmpd.conf` – Main configuration file for controlling access and what data is exposed.
##### `snmp` Utilities – Query and Manage SNMP Devices
- **`snmpget`**: Retrieve a specific value from an SNMP agent.
- **`snmpwalk`**: Retrieve a subtree of management values.
- **`snmpset`**: Set a value on an SNMP agent.
- **`snmptrap`**: Send SNMP trap messages.
**Common Options**
- `-v <version>` : SNMP version (1, 2c, or 3)
- `-c <community>` : Community string (like a password, e.g., `public`)
- `<host>` : Target device (hostname or IP)
- `<OID>` : Object Identifier (what to query or set)
**Get System Uptime**
```bash
snmpget -v2c -c public localhost SNMPv2-MIB::sysUpTime.0
```
**Walk All System Information**
```bash
snmpwalk -v2c -c public localhost
```
**Set a Value (Requires Write Access)**
```bash
snmpset -v2c -c private localhost SNMPv2-MIB::sysContact.0 s "admin@example.com"
```
#### Key Features
- **Remote monitoring:** Collect CPU, memory, disk, network, and other stats over the network.
- **Automation:** Integrate with monitoring systems (Nagios, Zabbix, Cacti, etc.).
- **Standard protocol:** Works with most network devices and servers.

**Summary:**  
The `snmpd` daemon and `snmp` utilities are essential for network-based monitoring and management of Linux systems and devices. For more, see `man snmpd`, `man snmpget`, `man snmpwalk`, and SNMP documentation.

___
### `ss`: Socket Statistics Utility
The ss command-line utility provides detailed information about network sockets. It's designed to replace older tools like netstat but offers more efficient and comprehensive socket reporting.

View TCP Sockets:
```bash
ss -t  # Show only TCP sockets (short format)
```
Display Listening Ports:
```bash
sudo ss -ltnp  # Show listening TCP/UDP ports with process info
```
Filter by State:
```bash
ss -o state established 'tcp_est' | grep ESTAB  # List established connections only
```
Advanced Filtering & Analysis Connection Tracking Statistics:
```bash
sudo ss -s  # Show socket statistics for all protocols
```
Example output:
```bash
Total Sockets = 83 (0 stalled)
TCP:   IP Packet forwarding: disabled, TCP상태 Listen(대기Recv) очереди: len=1000fd/80496bdb (sysctl net.core.max_conntracks)
```
Filter by Process User:
```bash
ss -pe user=john  # Show sockets owned by user 'john'
```
Monitor UDP Traffic:
```bash
ss -u state all    # List all UDP socket states
```
Network Troubleshooting Examples Check for TIME_WAIT connections:
```bash
sudo ss -o state time-wait  # Find sockets in TIME_WAIT state
```
Track Open File Descriptors:
```bash
sudo lsof | ss -iU '*'      # Cross-reference with lsof to see file/socket associations
```
Extended Options Matrix:  
`-t (TCP)`	Show TCP sockets	Basic network monitoring
`-u (UDP)`	Show UDP sockets	Protocol-specific analysis
`-w (RAW`)	Show raw socket info	Advanced packet inspection
`-x (UNIX)`	Show UNIX domain sockets	Local IPC debugging
Comparison with netstat
```bash
# Equivalent to 'netstat -tupn' but faster and more detailed
ss -tupwns all         # Show network statistics with process/user info
```

```bash
# List top 10 consuming ports (like netstat's top connections)
sudo ss -ms | sort -nrk4   # Sort by memory usage (-MBytes per socket)
```
Special Cases & Edge Scenarios Multicast Socket Monitoring:
```bash
ss -m type=dgram        # Filter for multicast-capable UDP sockets
```
Socket Pair Analysis:
```bash
sudo ss --socket-pair    # Show socket pairs (client-server connections)
```
 ###### Conclusion
` ss` offers powerful network socket inspection capabilities. 

---
### `telnet` – User Interface to the TELNET Protocol
The `telnet` command is used to **connect to remote hosts using the TELNET protocol**, which provides a text-based interface for communication with remote systems. While largely replaced by SSH for secure connections, `telnet` is still useful for testing network services and troubleshooting.
#### Basic Usage
```bash
telnet <hostname> <port>
```
- Connects to the specified host and port (e.g., `telnet example.com 80`).

#### Key Features
- **Remote login:** Access remote systems (not secure; use SSH for encrypted connections).
- **Test network services:** Check if a port is open or a service is responding.
- **Interactive session:** Send commands and receive responses from the remote host.
#### Common Options
- `<hostname>` : The remote host to connect to.
- `<port>` : The port number to connect to (default is 23 for TELNET).
- `-l <user>` : Specify a user name for login (if supported by the server).
- `-e <char>` : Set the escape character.
#### Examples
**Connect to a Remote Host on Default Port**
```bash
telnet example.com
```
- Connects to `example.com` on port 23.
**Test a Web Server on Port 80**
```bash
telnet example.com 80
```
- Opens a connection to the web server; you can type HTTP commands manually.
**Specify an Escape Character**
```bash
telnet -e ^C example.com
```
- Sets `Ctrl+C` as the escape character.

**Summary:**  
The `telnet` command is useful for testing network connectivity and interacting with text-based network services. It is not secure for remote logins and should be avoided for sensitive tasks. For more, see `man telnet`.
___
### `traceroute` – Check the Route Packets Take to a Host
The `traceroute` command is used to **display the path that packets take from your system to a specified network host**. It helps diagnose network routing issues by showing each hop (router or gateway) along the way and the time taken for each hop.
#### Basic Usage
```bash
traceroute <hostname or IP>
```
- Traces the route to the specified host (e.g., `traceroute google.com`).
#### Key Features
- **Hop-by-hop analysis:** Shows each router/gateway between your system and the destination.
- **Round-trip times:** Displays the time taken for packets to reach each hop.
- **Diagnose network issues:** Helps identify where delays or failures occur in the network path.
#### Common Options
- `-n` : Show IP addresses only (do not resolve hostnames).
- `-m <max_ttl>` : Set the maximum number of hops (default is 30).
- `-w <timeout>` : Set the timeout (in seconds) for each probe.
- `-q <nprobes>` : Number of probe packets per hop (default is 3).
- `-I` : Use ICMP ECHO instead of UDP packets (like Windows `tracert`).
#### Examples
**Trace the Route to a Host**
```bash
traceroute example.com
```
- Shows the path packets take to `example.com`.

**Show Only IP Addresses**
```bash
traceroute -n 8.8.8.8
```
- Displays only IP addresses for each hop.

**Limit the Number of Hops**
```bash
traceroute -m 15 example.com
```
- Limits the trace to 15 hops.

**Use ICMP Echo Requests**
```bash
sudo traceroute -I google.com
```
- Uses ICMP ECHO (like Windows `tracert`), may require root privileges.
#### Advanced Example: Increase Timeout and Probes
```bash
traceroute -w 5 -q 5 example.com
```
- Waits up to 5 seconds per probe and sends 5 probes per hop.

**Summary:**  
The `traceroute` command is essential for diagnosing network routing problems and understanding the path packets take to reach a destination. For more, see `man traceroute`.

---
### `whois` – Client for the WHOIS Directory Service
The `whois` command is a **client for querying the WHOIS directory service**, which provides information about domain names, IP addresses, and autonomous systems. It is commonly used to find out domain ownership, registration details, and contact information.
#### Basic Usage
```bash
whois example.com
```
- Retrieves WHOIS information for the domain `example.com`.
#### Key Features
- **Domain lookup:** Shows registrar, registration dates, status, and contact info for domains.
- **IP address lookup:** Provides information about IP address allocations and owners.
- **Supports multiple TLDs:** Works with most domain extensions (e.g., .com, .net, .org, country codes).
- **No authentication required:** Publicly accessible information.
#### Common Options
- `-h <host>` : Query a specific WHOIS server.
- `--verbose` : Show detailed output.
- `--help` : Display help information.
#### Examples
**Lookup a Domain Name**
```bash
whois linux.org
```
- Shows registration and contact details for `linux.org`.
**Lookup an IP Address**
```bash
whois 8.8.8.8
```
- Displays the organization and allocation info for the IP address.
**Query a Specific WHOIS Server**
```bash
whois -h whois.nic.io example.io
```
- Uses the specified WHOIS server for the query.
#### Advanced Example: Save Output to a File
```bash
whois example.com > whois_example.txt
```
- Saves the WHOIS information to a text file.

**Summary:**  
The `whois` command is a simple and effective tool for retrieving domain and IP registration details, useful for network troubleshooting, security, and research. For more, see `man whois`.

--- 
### `wget` – Retrieve Files Over HTTP, HTTPS, FTP, and FTPS
The `wget` command is a **non-interactive network downloader** used to retrieve files from the web via HTTP, HTTPS, FTP, and FTPS protocols. It is especially useful for downloading files in scripts or from the command line, as it can run in the background and resume interrupted downloads.
#### Basic Usage
```bash
wget <URL>
```
- Downloads the file at the specified URL to the current directory.
#### Key Features
- **Supports HTTP, HTTPS, FTP, FTPS:** Download files from a wide range of sources.
- **Resume downloads:** Can continue partially downloaded files.
- **Recursive download:** Download entire websites or directories.
- **Background operation:** Runs without user interaction.
- **Proxy support:** Works with HTTP and FTP proxies.
- **User agent and headers:** Customize requests for advanced use.
#### Common Options
- `-c` : Resume a partially downloaded file.
- `-O <filename>` : Save the download with a specific filename.
- `-r` : Download files recursively (entire directories or websites).
- `-np` : Do not ascend to parent directories when downloading recursively.
- `-P <directory>` : Save files to the specified directory.
- `--limit-rate=<rate>` : Limit download speed (e.g., `--limit-rate=200k`).
- `--user=<user> --password=<pass>` : Use HTTP or FTP authentication.
#### Examples
**Download a Single File**
```bash
wget https://example.com/file.zip
```
- Downloads `file.zip` from the specified URL.
**Resume an Interrupted Download**
```bash
wget -c https://example.com/largefile.iso
```
- Continues downloading `largefile.iso` from where it left off.
**Download and Save with a Different Name**
```bash
wget -O newname.tar.gz https://example.com/archive.tar.gz
```
- Saves the downloaded file as `newname.tar.gz`.
**Download an Entire Website Recursively**
```bash
wget -r -np https://example.com/docs/
```
- Downloads all files under `/docs/` without ascending to parent directories.
**Limit Download Speed**
```bash
wget --limit-rate=500k https://example.com/bigfile.iso
```
- Limits the download speed to 500 KB/s.
#### Advanced Example: Download to a Specific Directory
```bash
wget -P /tmp/downloads https://example.com/file.txt
```
- Saves `file.txt` to `/tmp/downloads`.

**Summary:**  
The `wget` command is a robust and flexible tool for downloading files and entire websites from the internet. It is ideal for automation, scripting, and unattended downloads. For more, see `man wget`.

---
  
  
  

  

.  
 
  
   

 
  

  





 
 
  




---



---

