# Install Node Exporter
```bash
# Step 1: Create a system user for Node Exporter
# - The `useradd` command creates a new user named `node_exporter`.
# - Flags:
#   --system: Creates a system user (not intended for interactive login).
#   --no-create-home: Prevents the creation of a home directory for this user.
#   --shell /bin/false: Disables shell access for this user (enhances security).
sudo useradd --system --no-create-home --shell /bin/false node_exporter

# Step 2: Download the Node Exporter binary
# - The `wget` command downloads the Node Exporter release from the official GitHub repository.
# - Replace `v1.6.1` with the desired version if needed.
# - The file downloaded is a `.tar.gz` archive containing the Node Exporter binary.
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz

# Step 3: Extract the downloaded archive
# - The `tar` command extracts the contents of the `.tar.gz` file.
# - `-xvf` flags:
#   - `-x`: Extract the files.
#   - `-v`: Verbose mode (shows the progress of extraction).
#   - `-f`: Specifies the file to extract.
tar -xvf node_exporter-1.6.1.linux-amd64.tar.gz

# Step 4: Move the Node Exporter binary to a system-wide directory
# - The `mv` command moves the `node_exporter` binary to `/usr/local/bin/`, a standard location for executable binaries.
# - `/usr/local/bin/` ensures the binary is accessible system-wide.
sudo mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/

# Step 5: Clean up unnecessary files
# - The `rm` command removes the extracted directory and the downloaded `.tar.gz` file to free up space.
# - `-rf`: Recursively and forcefully delete files and directories.
rm -rf node_exporter-1.6.1.linux-amd64 node_exporter-1.6.1.linux-amd64.tar.gz

# Step 6: Verify the installation
# - The `--version` flag checks the installed version of Node Exporter to confirm it was installed correctly.
node_exporter --version

# Step 7: Create a systemd service file for Node Exporter
# - The `tee` command creates a systemd service file at `/etc/systemd/system/node_exporter.service`.
# - This file defines how the Node Exporter service should behave (e.g., start on boot, run as a specific user).
sudo tee /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter --collector.logind

[Install]
WantedBy=multi-user.target
EOF

# Step 8: Reload systemd daemon
# - The `daemon-reload` command reloads systemd to recognize the new service file.
sudo systemctl daemon-reload

# Step 9: Start the Node Exporter service
# - The `start` command starts the Node Exporter service.
sudo systemctl start node_exporter

# Step 10: Enable the Node Exporter service to start on boot
# - The `enable` command ensures the Node Exporter service starts automatically after a system reboot.
sudo systemctl enable node_exporter
```