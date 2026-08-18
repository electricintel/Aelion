#!/bin/bash
echo \"Configuring Oracle Cloud firewall...\"

sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

echo \"Firewall rules applied.\"
