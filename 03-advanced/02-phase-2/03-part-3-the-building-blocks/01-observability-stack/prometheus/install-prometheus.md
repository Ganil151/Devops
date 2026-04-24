# Create prometheus user
```bash
# - The `useradd` command creates a new system user named `prometheus`.
# - Flags:
#   --system: Creates a system user (not intended for interactive login).
#   --no-create-home: Prevents the creation of a home directory for this user.
#   --shell /bin/false: Disables shell access for this user (enhances security).
sudo useradd --system --no-create-home --shell /bin/false prometheus

# Download Prometheus
# - The `wget` command downloads the Prometheus binary archive from the official GitHub release page.
# - The version specified here is v2.47.1 (replace with the desired version if needed).
wget https://github.com/prometheus/prometheus/releases/download/v2.47.1/prometheus-2.47.1.linux-amd64.tar.gz  

# Extract the downloaded archive
# - The `tar` command extracts the contents of the `.tar.gz` file.
# - `-xvf` flags:
#   - `-x`: Extract the files.
#   - `-v`: Verbose mode (shows the progress of extraction).
#   - `-f`: Specifies the file to extract.
tar -xvf prometheus-2.47.1.linux-amd64.tar.gz

# Create necessary directories
# - The `mkdir -p` command creates two directories:
#   - `/data`: Used to store Prometheus time-series data (TSDB).
#   - `/etc/prometheus`: Used to store configuration files and console libraries.
sudo mkdir -p /data /etc/prometheus

# Change directory to the extracted Prometheus folder
# - This ensures subsequent commands are executed in the correct location.
cd prometheus-2.47.1.linux-amd64/

# Move binaries, console libraries, and configs
# - The `mv` command moves the Prometheus binaries (`prometheus` and `promtool`) to `/usr/local/bin/`, a standard location for executables.
sudo mv prometheus promtool /usr/local/bin/
# - Moves the `consoles` and `console_libraries` directories to `/etc/prometheus/` for use by Prometheus.
sudo mv consoles/ console_libraries/ /etc/prometheus/
# - Moves the `prometheus.yml` configuration file to `/etc/prometheus/prometheus.yml`.
sudo mv prometheus.yml /etc/prometheus/prometheus.yml

# Set ownership and permissions
# - The `chown` command sets the ownership of the `/etc/prometheus/` and `/data/` directories to the `prometheus` user and group.
sudo chown -R prometheus:prometheus /etc/prometheus/ /data/
# - The `chmod` command sets the permissions for these directories to `775`:
#   - Owner (`prometheus`) has read, write, and execute permissions.
#   - Group members have read and execute permissions.
#   - Others have read and execute permissions.
sudo chmod -R 775 /etc/prometheus/ /data/

# Clean up
# - The `cd ~` command changes back to the home directory.
cd ~
# - The `rm` command removes the extracted folder and the downloaded `.tar.gz` file to free up space.
# - `-rf`: Recursively and forcefully delete files and directories.
rm -rf prometheus-2.47.1.linux-amd64 prometheus-2.47.1.linux-amd64.tar.gz

# Create systemd service for Prometheus
# - The `tee` command creates a systemd service file at `/etc/systemd/system/prometheus.service`.
# - This file defines how the Prometheus service should behave (e.g., start on boot, run as a specific user).
sudo tee /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /data \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon
# - The `daemon-reload` command reloads systemd to recognize the new service file.
sudo systemctl daemon-reload

# Start Prometheus
# - The `start` command starts the Prometheus service immediately.
sudo systemctl start prometheus

# Enable Prometheus to start on boot
# - The `enable` command ensures the Prometheus service starts automatically during system boot.
sudo systemctl enable prometheus
```