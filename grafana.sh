#!/bin/bash

# Make Grafana user
sudo adduser --no-create-home --disabled-login --shell /bin/false --gecos "Grafana User" grafana

# Make directories necessary for Grafana
sudo mkdir -p /etc/grafana/provisioning/datasources
sudo mkdir -p /etc/grafana/provisioning/dashboards
sudo mkdir -p /var/lib/grafana

# Set permissions for the Grafana directories
sudo chown -R grafana:grafana /etc/grafana
sudo chown -R grafana:grafana /var/lib/grafana


# Check if jq is installed, if not, install it
if ! command -v jq &> /dev/null; then
    echo "jq not found, installing..."
    sudo apt-get update && sudo apt-get install -y jq  # For Debian/Ubuntu
    # Uncomment below line for CentOS/RHEL/Fedora:
    # sudo yum install -y jq
else
    echo "jq is already installed."
fi





# Download and install Grafana
VERSION=$(curl -s https://api.github.com/repos/grafana/grafana/releases/latest | jq -r .tag_name)
wget https://dl.grafana.com/oss/release/grafana-${VERSION}.linux-amd64.tar.gz
tar -xzvf grafana-${VERSION}.linux-amd64.tar.gz

# Copy binaries to the appropriate location
sudo cp grafana-${VERSION}/bin/grafana-server /usr/sbin/
sudo cp grafana-${VERSION}/bin/grafana-cli /usr/sbin/
sudo cp -r grafana-${VERSION}/conf /etc/grafana
sudo cp -r grafana-${VERSION}/public /usr/share/grafana

# Populate configuration files (datasource and service)
cat ./grafana/datasource.yml | sudo tee /etc/grafana/provisioning/datasources/datasource.yml
cat ./grafana/grafana.service | sudo tee /etc/systemd/system/grafana.service

# Copy dashboards (Node Exporter and Blackbox Exporter)
sudo cp ./grafana/dashboards/*.json /etc/grafana/provisioning/dashboards/
# Reload systemd and enable Grafana service
sudo systemctl daemon-reload
sudo systemctl enable grafana
sudo systemctl start grafana

# Cleanup installation files
rm -rf grafana-${VERSION}.linux-amd64.tar.gz
rm -rf grafana-${VERSION}.linux-amd64

echo "Grafana installation and configuration complete!"
