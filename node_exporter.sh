#!/bin/bash

# Fetched Latest Node Exporter Version 


# Fetch the latest version of Node Exporter from GitHub releases
latest_version=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')

# Convert the latest version to uppercase
latest_version_upper=$(echo $latest_version | tr '[:lower:]' '[:upper:]')

# Construct the download URL using the latest version
download_url="https://github.com/prometheus/node_exporter/releases/download/${latest_version}/node_exporter-${latest_version}.linux-amd64.tar.gz"

# Download and extract Node Exporter
wget $download_url -O node_exporter.tar.gz
tar -xf node_exporter.tar.gz
sudo mv node_exporter-${latest_version}.linux-amd


