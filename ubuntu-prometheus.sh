#!/bin/bash

# Fetched Latest Prometheus Version
LATEST_VERSION=2.53.1

# Check if wget is installed, if not, install it
if ! command -v wget &> /dev/null; then
    echo "wget could not be found, installing it..."
    sudo apt-get update
    sudo apt-get install -y wget
fi 

# Construct the download URL
DOWNLOAD_URL="https://github.com/prometheus/prometheus/releases/download/v${LATEST_VERSION}/prometheus-${LATEST_VERSION}.linux-amd64.tar.gz"

# Download the latest version of Prometheus
wget $DOWNLOAD_URL

# Extract the downloaded tarball
tar -xf prometheus-${LATEST_VERSION}.linux-amd64.tar.gz

# Move the binaries to /usr/local/bin
sudo mv prometheus-${LATEST_VERSION}.linux-amd64/prometheus prometheus-${LATEST_VERSION}.linux-amd64/promtool /usr/local/bin

# Create directories for configuration files and other Prometheus data
sudo mkdir -p /etc/prometheus /var/lib/prometheus

# Move console libraries
sudo mv prometheus-${LATEST_VERSION}.linux-amd64/console_libraries /etc/prometheus

# Clean up the extracted files
sudo rm -rvf prometheus-${LATEST_VERSION}.linux-amd64*

# Create Prometheus configuration file
sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus_metrics'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter_metrics'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100','worker-1:9100','worker-2:9100']
EOF

# Create Prometheus user
sudo useradd -rs /bin/false prometheus

# Change ownership of the directories
sudo chown -R prometheus: /etc/prometheus /var/lib/prometheus

# Create systemd service file for Prometheus
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable Prometheus service
sudo systemctl daemon-reload
sudo systemctl enable prometheus

# Start Prometheus service and check status
sudo systemctl start prometheus
sudo systemctl status prometheus --no-pager
