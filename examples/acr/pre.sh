#!/bin/bash

# Docker Installation Script for Ubuntu
# This script installs Docker Engine on Ubuntu systems

set -e  # Exit on any error

echo "Starting Docker installation for Ubuntu..."

# Function to check if command exists
command_exists() {
    command -v "$@" > /dev/null 2>&1
}

# Function to get Ubuntu version
get_ubuntu_version() {
    lsb_release -rs 2>/dev/null || echo "unknown"
}

# Check if running on Ubuntu
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    echo "Error: This script is designed for Ubuntu systems only."
    exit 1
fi

echo "Detected Ubuntu $(get_ubuntu_version)"

# Check if Docker is already installed
if command_exists docker; then
    echo "Docker is already installed:"
    docker --version
    echo "Skipping installation..."
    exit 0
fi

# Update package index
echo "Updating package index..."
sudo apt-get update

# Install required packages
echo "Installing required packages..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Create directory for Docker's GPG key
sudo mkdir -p /etc/apt/keyrings

# Add Docker's official GPG key
echo "Adding Docker's GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the Docker repository
echo "Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
echo "Updating package index with Docker repository..."
sudo apt-get update

# Install Docker Engine, CLI, and containerd
echo "Installing Docker Engine..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker service
echo "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to docker group (optional, requires logout/login to take effect)
if [ "$EUID" -ne 0 ]; then
    echo "Adding current user to docker group..."
    sudo usermod -aG docker $USER
    echo "Note: You may need to log out and back in for group changes to take effect."
fi

# Verify Docker installation
echo "Verifying Docker installation..."
sudo docker run hello-world

echo "Docker installation completed successfully!"
echo "Docker version:"
docker --version
