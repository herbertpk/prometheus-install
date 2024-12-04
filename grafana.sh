#!/bin/bash

# Check if jq is installed, if not, install it
if ! command -v jq &> /dev/null; then
    echo "jq not found, installing..."
    sudo apt-get update && sudo apt-get install -y jq  # For Debian/Ubuntu
    # Uncomment below line for CentOS/RHEL/Fedora:
    # sudo yum install -y jq
else
    echo "jq is already installed."
fi

# Fetch the latest Grafana release version using GitHub API and remove the leading "v"
VERSION=$(curl -s https://api.github.com/repos/grafana/grafana/releases/latest | jq -r .tag_name | sed 's/^v//')

# Make Grafana user
sudo adduser --no-create-home --disabled-login --shell /bin/false --gecos "Grafana User" grafana

# Make directories necessary for Grafana
sudo mkdir -p /etc/grafana/provisioning/datasources
sudo mkdir -p /etc/grafana/provisioning/dashboards
sudo mkdir -p /var/lib/grafana

# Set permissions for the Grafana directories
sudo chown -R grafana:grafana /etc/grafana
sudo chown -R grafana:grafana /var/lib/grafana

# Download and install Grafana (Enterprise)
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_${VERSION}_amd64.deb

# Install the .deb package
sudo dpkg -i grafana-enterprise_${VERSION}_amd64.deb
sudo apt-get install -f  # Fix any missing dependencies, if required

# Populate configuration files (datasource and service)
cat ./grafana/datasource.yml | sudo tee /etc/grafana/provisioning/datasources/datasource.yml
cat ./grafana/grafana.service | sudo tee /etc/systemd/system/grafana.service

# Copy all dashboards from the 'grafana/dashboards/' folder to the provisioning directory
sudo cp ./grafana/dashboards/*.json /etc/grafana/provisioning/dashboards/

# Reload systemd and enable Grafana service
sudo systemctl daemon-reload
sudo systemctl enable grafana
sudo systemctl start grafana

# Cleanup installation files
rm -rf grafana-enterprise_${VERSION}_amd64.deb

echo "Grafana installation and configuration complete!"
