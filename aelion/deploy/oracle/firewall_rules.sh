#!/bin/bash
#!/usr/bin/env bash
set -euo pipefail

echo "Oracle firewall configuration is optional and was not requested."
echo "The local, optional Docker, Linux, and Termux workflows do not require it."

sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

echo \"Firewall rules applied.\"
