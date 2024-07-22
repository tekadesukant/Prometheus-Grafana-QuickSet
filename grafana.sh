# Install necessary dependencies
sudo apt-get install -y adduser libfontconfig1

LATEST_VERSION=11.1.0
LATEST_VERSION=

# Construct the download URL for the latest version
DOWNLOAD_URL="https://dl.grafana.com/enterprise/release/grafana-enterprise_${LATEST_VERSION}_amd64.deb"

# Download the latest version of Grafana Enterprise
wget $DOWNLOAD_URL -O grafana-enterprise_latest_amd64.deb

# Install Grafana Enterprise
sudo dpkg -i grafana-enterprise_latest_amd64.deb

# Reload systemd, enable, and start Grafana service
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server

# Check Grafana service status
sudo /bin/systemctl status grafana-server --no-pager

# Clean up downloaded .deb file
rm grafana-enterprise_latest_amd64.deb
