# terraform-azurerm-avm-res-app-containerapp

This is a template repo for Terraform Azure Verified Container App Modules.

This module *DOES NOT* contain other Container App related resource, including `azurerm_container_app_environment`.

## Prerequisites

This repository uses Azure Verified Modules (AVM) tooling that requires Docker to be installed. If you don't have Docker installed on your Ubuntu system, you can use the provided installation script:

```bash
# Make the script executable
chmod +x install-docker-ubuntu.sh

# Run the Docker installation script
./install-docker-ubuntu.sh
```

The script supports Ubuntu 20.04, 22.04, and 24.04, and will:
- Install Docker Engine following official Docker documentation
- Add your user to the docker group
- Start and enable the Docker service
- Verify the installation

After installation, you can use the AVM tooling:
```bash
# Run AVM pre-commit checks
./avm pre-commit

# Run AVM PR checks
./avm pr-check
```
