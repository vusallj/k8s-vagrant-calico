#!/bin/bash

# --- SELF-HEALING CRLF FIX ---
# If the script contains Windows CRLF, convert itself to LF and re-run
if grep -q $'\r' "$0"; then
    echo "Fixing Windows CRLF line endings..."
    sed -i 's/\r$//' "$0"
    exec bash "$0" "$@"
fi

set -e

echo "Updating packages..."
sudo apt-get update

echo "Installing dependencies..."
sudo apt-get install -y ca-certificates curl gnupg lsb-release

echo "Creating keyring directory..."
sudo mkdir -p /etc/apt/keyrings

echo "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Updating package index..."
sudo apt-get update

echo "Installing containerd..."
sudo apt-get install -y containerd.io

echo "Generating containerd config..."
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

echo "Enabling systemd cgroup driver..."
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

echo "Restarting containerd..."
sudo systemctl restart containerd
sudo systemctl enable containerd

echo "Containerd installation complete."
