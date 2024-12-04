#!/bin/bash

# Install prerequisite packages
sudo apt-get install -y apt-transport-https software-properties-common wget

# Import the Grafana GPG key
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

# Add the repository for stable releases
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Optionally, add the repository for beta releases (if you want to install beta releases)
# echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com beta main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Update the list of available packages
sudo apt-get update

# Install the latest stable Grafana OSS release
sudo apt-get install -y grafana

# If you want to install the Enterprise version instead, uncomment the following line:
# sudo apt-get install -y grafana-enterprise

# Enable and start Grafana service
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# Installation cleanup (optional)
# sudo rm -f grafana_11.3.1_amd64.deb

echo "Grafana installation complete."
echo "Grafana should now be running on http://localhost:3000"
echo "You can access Grafana using the default credentials: admin/admin"