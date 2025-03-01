#!/bin/bash

# Fetched Latest Node Exporter Version 
LATEST_VERSION=1.9.0

# Construct the download URL using the latest version
download_url="https://github.com/prometheus/node_exporter/releases/download/v${latest_version}/node_exporter-${latest_version}.linux-amd64.tar.gz"

# Download and extract Node Exporter
wget $download_url -O node_exporter.tar.gz
tar -xf node_exporter.tar.gz
sudo mv node_exporter-${latest_version}.linux-amd64/node_exporter /usr/local/bin
rm -rv node_exporter-${latest_version}.linux-amd64* node_exporter.tar.gz

# Create a system user for Node Exporter
sudo useradd -rs /bin/false node_exporter

# Create the systemd service file for Node Exporter
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start Node Exporter
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter.service
sudo systemctl status node_exporter.service --no-pager
