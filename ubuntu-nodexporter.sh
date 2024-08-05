#!/bin/bash

# Fetch the latest Node Exporter version
LATEST_VERSION=1.8.2

# Check if wget is installed, if not, install it
if ! command -v wget &> /dev/null; then
    echo "wget could not be found, installing it..."
    sudo apt-get update
    sudo apt-get install -y wget
fi

# Construct the download URL using the latest version
DOWNLOAD_URL="https://github.com/prometheus/node_exporter/releases/download/v${LATEST_VERSION}/node_exporter-${LATEST_VERSION}.linux-amd64.tar.gz"

# Download and extract Node Exporter
wget $DOWNLOAD_URL -O node_exporter.tar.gz

if [ $? -ne 0 ]; then
    echo "Failed to download Node Exporter. Please check the URL or network connection."
    exit 1
fi

tar -xf node_exporter.tar.gz
sudo mv node_exporter-${LATEST_VERSION}.linux-amd64/node_exporter /usr/local/bin

# Clean up downloaded and extracted files
rm -rv node_exporter-${LATEST_VERSION}.linux-amd64* node_exporter.tar.gz

# Create a system user for Node Exporter
if ! id "node_exporter" &>/dev/null; then
    sudo useradd -rs /bin/false node_exporter
fi

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

# Check the status of the Node Exporter service
sudo systemctl status node_exporter.service --no-pager

if [ $? -eq 0 ]; then
    echo "Node Exporter is running successfully."
else
    echo "There was an issue starting the Node Exporter service."
fi
