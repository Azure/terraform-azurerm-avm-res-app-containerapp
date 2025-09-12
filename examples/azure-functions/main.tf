terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "0.8.2"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}

## Section to get naming module for resource names
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

## Section to create resource group
resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

## Section to create log analytics workspace
resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
}

## Section to create container app environment
resource "azurerm_container_app_environment" "this" {
  location                   = azurerm_resource_group.this.location
  name                       = module.naming.container_app_environment.name_unique
  resource_group_name        = azurerm_resource_group.this.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
}

## Section to call the container app module
# This is the module call to create the container app
module "container_app" {
  source = "../../"

  # Basic configuration
  container_app_environment_resource_id = azurerm_container_app_environment.this.id
  name                                  = module.naming.container_app.name_unique
  resource_group_name                   = azurerm_resource_group.this.name
  # Container configuration for Azure Functions
  template = {
    containers = [{
      image  = "mcr.microsoft.com/azure-functions/dotnet8-quickstart-demo:1.0"
      name   = "azure-functions-demo"
      cpu    = "0.5"
      memory = "1Gi"
    }]

    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
  }
  # Enable telemetry for AVM compliance
  enable_telemetry = var.enable_telemetry
  # Ingress configuration for external access
  ingress = {
    external_enabled = true
    target_port      = 80
    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }
  # Enable Azure Functions hosting model
  kind = "functionapp"
}
