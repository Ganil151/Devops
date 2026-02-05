
### Step 1: Downloading the CentOS 9 Stream ISO
- The first step is to download the CentOS 9 Stream ISO from the [**Official CentOS website**](https://centos.org/download).
- Navigate to the CentOS 9 Stream download page: CentOS 9 Stream ISO
- Select the appropriate ISO file based on your system architecture (x86_64 for most modern systems).
- Download the **[ISO](https://mirrors.centos.org/mirrorlist?path=/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-dvd1.iso&redirect=1&protocol=https)** file to your local machine.

[![CentOS 9 Stream GUI](https://infotechys.com/wp-content/uploads/2025/03/CentOS9_download_page.webp)](https://centos.org/download)

Photo by [admingeek](https://infotechys.com/centos-9-stream-gui) from [Infotechys](https://infotechys.com/)

|   |
|---|
|#### Creating a Bootable USB Drive|

Once you have the CentOS 9 Stream ISO, you need to create a bootable USB drive. Here’s how to do it:

|   |
|---|
|##### For Windows|

- Download and install a tool like **[Rufus](https://rufus.ie/)**.
- Open Rufus and select your USB device.
- Choose the CentOS 9 Stream ISO you downloaded earlier.
- Select the “MBR” partition scheme for BIOS or UEFI.
- Click “Start” to create the bootable USB.

|   |
|---|
|##### For Linux (using dd command):|

```aspnet
sudo dd if=CentOS-Stream-9-x86_64-dvd1.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Copy

**Note:** Replace `/dev/sdX` with your actual USB device path.

|   |
|---|
|#### Installing CentOS 9 Stream|

- Plug the bootable USB drive into your computer and reboot the system.
- Enter the BIOS/UEFI settings and set the USB drive as the first boot device.
- The CentOS installation menu will appear. Select “**Install CentOS Stream 9″**.

![CentOS 9 Stream GUI](https://infotechys.com/wp-content/uploads/2025/03/centos9_stream_exhibit_A.webp)

Photo by [admingeek](https://infotechys.com/centos-9-stream-gui) from [Infotechys](https://infotechys.com/)

- Follow the on-screen instructions to configure the language, timezone, and keyboard layout.

![CentOS 9 Stream GUI: Keyboard, Timezone, etc](https://infotechys.com/wp-content/uploads/2025/03/centos9_stream_exhibit_B.webp)

Photo by [admingeek](https://infotechys.com/centos-9-stream-gui) from [Infotechys](https://infotechys.com/)

- Choose the installation destination (usually your main hard drive) and set up partitioning.

![CentOS 9 Stream GUI: Installation, Disk Partition](https://infotechys.com/wp-content/uploads/2025/03/centos9_stream_exhibit_C.webp)

Photo by [admingeek](https://infotechys.com/centos-9-stream-gui) from [Infotechys](https://infotechys.com/)

- You can also choose whether to have the installation wizard automatically partition your hard drive or to partition it manually yourself.

![Automatic Vs. Manual Partition Page](https://infotechys.com/wp-content/uploads/2025/03/centos9_stream_exhibit_D.webp)

Photo by [admingeek](https://infotechys.com/centos-9-stream-gui) from [Infotechys](https://infotechys.com/)

- Set up the root password and create a user account.

![CentOS 9 Stream GUI: root user password](https://infotechys.com/wp-content/uploads/2025/03/centos9_stream_exhibit_E.webp)

root user password

![CentOS 9 Stream GUI: user account password](https://infotechys.com/wp-content/uploads/2025/03/centos9_stream_exhibit_F.webp)

administrative user password

Photo by [admingeek](https://infotechys.com/centos-9-stream-gui) from [Infotechys](https://infotechys.com/)

- Select **Begin Installation** to start the installation process.

![Begin Installation Process - CentOS Stream 9](https://infotechys.com/wp-content/uploads/2025/03/centos9_stream_exhibit_H.webp)

Photo by [admingeek](https://infotechys.com/centos-9-stream-gui) from [Infotechys](https://infotechys.com/)

The system will install **CentOS Stream 9**, and upon completion, you can reboot the system and remove the USB drive.

![Installation Progress - Continued.](https://infotechys.com/wp-content/uploads/2025/03/centos9_stream_exhibit_G.webp)

Photo by [admingeek](https://infotechys.com/centos-9-stream-gui) from [Infotechys](https://infotechys.com/)

|   |
|---|
|### Step 2: Installing GUI on CentOS 9 Stream|

By default, the “**Server with GUI**” option is selected so after the **CentOS Stream 9** installation, you’ll have the GNOME layout as your base environment.

![Default Settings: Base environment settings window: Choosing which Install to run](https://infotechys.com/wp-content/uploads/2025/03/centos9_stream_exhibit_I.webp)

Photo by [admingeek](https://infotechys.com/centos-9-stream-gui) from [Infotechys](https://infotechys.com/)

However, if you selected the **“Minimal”** or **“Server”** option and you want to install a graphical desktop, you can do so easily via the command line.

|   |
|---|
|#### Choosing the Right Desktop Environment|

CentOS Stream 9 supports various desktop environments. Two popular choices are:

- **GNOME:** The default desktop environment for CentOS 9 Stream, known for its simplicity and modern look.
- **KDE Plasma:** A feature-rich, highly customizable desktop environment.

For this guide, we’ll cover the installation of both GNOME and KDE.

#### Installing GNOME Desktop Environment

To install GNOME, run the following command:

```aspnet
sudo dnf groupinstall "Server with GUI" -y
```

Copy

This will install GNOME along with necessary packages for a complete desktop experience. Once the installation is complete, set GNOME as the default graphical target:

```aspnet
sudo systemctl set-default graphical.target
```

Copy

Reboot the system to boot into GNOME.

```aspnet
sudo systemctl reboot
```

Copy

|   |
|---|
|#### Installing KDE Plasma Desktop Environment|

If you prefer KDE Plasma, you can install it using:

```aspnet
sudo dnf groupinstall "KDE Plasma Workspaces" -y
```

Copy

After the installation, switch the default target to graphical mode:

```aspnet
sudo systemctl set-default graphical.target
```

Copy

Reboot the system to start KDE Plasma:

```aspnet
sudo reboot
```

Copy

|   |
|---|
|### Step 3: Post-Installation Setup|

Once you have CentOS 9 Stream with GUI up and running, there are several steps you should follow to make your system fully functional.

|   |
|---|
|#### Configuring Network Settings|

If you’re connected to the internet via Ethernet or Wi-Fi, you can configure network settings via the GNOME or KDE network manager.

- **For GNOME:** Click the network icon in the top-right corner, select your network, and enter the credentials if necessary.
- **For KDE:** Click the network icon in the system tray, select your network, and enter the Wi-Fi password.

![Configure Network Settings - CentOS Stream 9](https://infotechys.com/wp-content/uploads/2025/03/centos9_stream_exhibit_J.webp)

Photo by [admingeek](https://infotechys.com/centos-9-stream-gui) from [Infotechys](https://infotechys.com/)

|   |
|---|
|####  Installing Essential Applications|

After the installation, you might need a few additional applications for daily use. You can install them via the command line using dnf. For example:

```aspnet
sudo dnf install firefox libreoffice vlc gimp
```

Copy

This command installs Firefox (web browser), LibreOffice (office suite), VLC (media player), and GIMP (image editor).

|   |
|---|
|#### Enabling Firewall and SELinux|

CentOS 9 Stream comes with a default firewall (firewalld) and SELinux (Security-Enhanced Linux) for added security. Ensure these are enabled by running:

```aspnet
sudo systemctl enable --now firewalld && sudo setenforce 1
```

Copy

|   |
|---|
|## Troubleshooting Tips|

Sometimes things might not go as planned. Here are a few common troubleshooting steps:

|   |
|---|
|#### No GUI after booting?|

Ensure the graphical target is set as the default:

```aspnet
sudo systemctl set-default graphical.target && sudo systemctl reboot
```

Copy

|   |
|---|
|#### Network connection issues?|

Try restarting the network service:

```aspnet
sudo systemctl restart NetworkManager
```

Copy

|   |
|---|
|#### Failed to install packages?|

Run the following to clean up DNF:

```aspnet
sudo dnf clean all && sudo dnf update -y
```

Copy

## Conclusion