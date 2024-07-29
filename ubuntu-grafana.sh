#!/bin/bash
sudo apt-get update

# Fetch the latest Grafana version
LATEST_VERSION=11.1.0 

# Install necessary dependencies
sudo apt-get install -y adduser libfontconfig1

# Construct the download URL for the latest version
DOWNLOAD_URL="https://dl.grafana.com/enterprise/release/grafana-enterprise_${LATEST_VERSION}_amd64.deb"

# Download the latest version of Grafana Enterprise
wget $DOWNLOAD_URL -O grafana-enterprise_latest_amd64.deb

# Check if the download was successful
if [ $? -ne 0 ]; then
    echo "Failed to download Grafana Enterprise. Please check the URL or network connection."
    exit 1
fi

# Install Grafana Enterprise
sudo dpkg -i grafana-enterprise_latest_amd64.deb

# Check if the installation was successful
if [ $? -ne 0 ]; then
    echo "Failed to install Grafana Enterprise. Attempting to fix dependencies."
    sudo apt-get install -f -y
    sudo dpkg -i grafana-enterprise_latest_amd64.deb
    if [ $? -ne 0 ]; then
        echo "Failed to install Grafana Enterprise after fixing dependencies."
        exit 1
    fi
fi

# Reload systemd, enable, and start Grafana service
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server

# Check Grafana service status
sudo /bin/systemctl status grafana-server --no-pager

if [ $? -eq 0 ]; then
    echo "Grafana Enterprise is running successfully."
else
    echo "There was an issue starting the Grafana Enterprise service."
fi

# Clean up downloaded .deb file
rm grafana-enterprise_latest_amd64.deb
