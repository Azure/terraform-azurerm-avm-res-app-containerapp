#!/usr/bin/env bash

# Docker Installation Script for Ubuntu Systems
# This script installs Docker Engine on Ubuntu systems following the official Docker documentation
# Compatible with Ubuntu 20.04, 22.04, and 24.04

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root. Please run as a regular user."
        print_info "The script will use sudo when necessary."
        exit 1
    fi
}

# Function to check Ubuntu version
check_ubuntu() {
    if [[ ! -f /etc/os-release ]]; then
        print_error "Cannot determine OS version. This script is designed for Ubuntu systems."
        exit 1
    fi
    
    source /etc/os-release
    
    if [[ "$ID" != "ubuntu" ]]; then
        print_error "This script is designed for Ubuntu systems. Detected: $ID"
        exit 1
    fi
    
    print_info "Detected Ubuntu $VERSION_ID"
    
    # Check if Ubuntu version is supported
    case "$VERSION_ID" in
        "20.04"|"22.04"|"24.04")
            print_info "Ubuntu $VERSION_ID is supported."
            ;;
        *)
            print_warning "Ubuntu $VERSION_ID might not be officially supported by Docker."
            print_info "Continuing with installation..."
            ;;
    esac
}

# Function to check if Docker is already installed
check_docker_installed() {
    if command -v docker &> /dev/null; then
        print_info "Docker is already installed."
        docker --version
        
        # Check if current user is in docker group
        if groups "$USER" | grep -q docker; then
            print_success "User $USER is already in the docker group."
            print_info "You can run Docker commands without sudo."
            return 0
        else
            print_warning "User $USER is not in the docker group."
            print_info "You'll need to add the user to the docker group or run Docker with sudo."
            return 1
        fi
    fi
    return 1
}

# Function to update package index
update_package_index() {
    print_info "Updating package index..."
    sudo apt-get update
}

# Function to install prerequisites
install_prerequisites() {
    print_info "Installing prerequisites..."
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
}

# Function to add Docker GPG key
add_docker_gpg_key() {
    print_info "Adding Docker's official GPG key..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
}

# Function to add Docker repository
add_docker_repository() {
    print_info "Adding Docker repository..."
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
}

# Function to install Docker Engine
install_docker() {
    print_info "Installing Docker Engine..."
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# Function to add user to docker group
add_user_to_docker_group() {
    print_info "Adding user $USER to docker group..."
    sudo usermod -aG docker "$USER"
    print_success "User $USER added to docker group."
    print_warning "You need to log out and log back in (or restart your session) for the group changes to take effect."
}

# Function to start and enable Docker service
start_docker_service() {
    print_info "Starting and enabling Docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker
    print_success "Docker service started and enabled."
}

# Function to verify Docker installation
verify_installation() {
    print_info "Verifying Docker installation..."
    
    if sudo docker run hello-world &> /dev/null; then
        print_success "Docker installation verified successfully!"
    else
        print_error "Docker installation verification failed."
        return 1
    fi
    
    print_info "Docker version:"
    docker --version
    
    print_info "Docker Compose version:"
    docker compose version
}

# Function to display post-installation instructions
display_post_install_instructions() {
    print_success "Docker installation completed!"
    echo
    print_info "Post-installation steps:"
    echo "1. Log out and log back in to refresh your group membership"
    echo "2. Or run: newgrp docker"
    echo "3. Test Docker without sudo: docker run hello-world"
    echo
    print_info "For this Azure Verified Modules (AVM) repository:"
    echo "- You can now run: ./avm pre-commit"
    echo "- Or: ./avm pr-check"
    echo "- The AVM tooling uses Docker container: mcr.microsoft.com/azterraform:avm-latest"
    echo
    print_info "Useful Docker commands:"
    echo "- docker --version          # Check Docker version"
    echo "- docker images             # List Docker images"
    echo "- docker ps                 # List running containers"
    echo "- docker system prune       # Clean up unused Docker resources"
}

# Function to clean up on error
cleanup_on_error() {
    print_error "Installation failed. Cleaning up..."
    # Remove Docker repository if it was added
    if [[ -f /etc/apt/sources.list.d/docker.list ]]; then
        sudo rm -f /etc/apt/sources.list.d/docker.list
    fi
    # Remove GPG key if it was added
    if [[ -f /etc/apt/keyrings/docker.gpg ]]; then
        sudo rm -f /etc/apt/keyrings/docker.gpg
    fi
}

# Main installation function
main() {
    print_info "Starting Docker installation for Ubuntu..."
    echo
    
    # Set up error handling
    trap cleanup_on_error ERR
    
    # Perform checks
    check_root
    check_ubuntu
    
    # Check if Docker is already installed
    if check_docker_installed; then
        print_info "Docker is already properly installed and configured."
        exit 0
    fi
    
    # Perform installation steps
    update_package_index
    install_prerequisites
    add_docker_gpg_key
    add_docker_repository
    install_docker
    add_user_to_docker_group
    start_docker_service
    verify_installation
    
    # Display final instructions
    display_post_install_instructions
    
    print_success "Docker installation script completed successfully!"
}

# Show usage information
show_usage() {
    echo "Docker Installation Script for Ubuntu"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --version  Show script version"
    echo
    echo "This script installs Docker Engine on Ubuntu systems."
    echo "It follows the official Docker installation documentation."
    echo
    echo "Supported Ubuntu versions: 20.04, 22.04, 24.04"
    echo
    echo "Note: Do not run this script as root. It will use sudo when necessary."
}

# Handle command line arguments
case "${1:-}" in
    -h|--help)
        show_usage
        exit 0
        ;;
    -v|--version)
        echo "Docker Installation Script v1.0.0"
        exit 0
        ;;
    "")
        # No arguments, proceed with installation
        ;;
    *)
        print_error "Unknown option: $1"
        show_usage
        exit 1
        ;;
esac

# Run main function
main "$@"