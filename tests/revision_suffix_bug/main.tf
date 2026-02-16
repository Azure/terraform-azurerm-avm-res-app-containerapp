# Reproduction test for Issue #115:
# "Field template.revisionsuffix is invalid; revision with suffix already exists"
#
# Bug scenario (before fix):
#   1. terraform apply  → creates container app with revision_suffix "test-v1" ✓
#   2. terraform apply  → re-sends revisionSuffix "test-v1" → Azure rejects with
#      "revision with suffix already exists" ✗
#
# After fix:
#   revisionSuffix is no longer sent to Azure. Azure auto-generates a unique
#   suffix, so consecutive applies never conflict.

resource "random_id" "rg_name" {
  byte_length = 8
}

resource "random_id" "container_name" {
  byte_length = 4
}

resource "azurerm_resource_group" "test" {
  location = "eastus"
  name     = "rg-revision-suffix-bug-${random_id.rg_name.hex}"
}

resource "azurerm_container_app_environment" "test" {
  location            = azurerm_resource_group.test.location
  name                = "env-revision-suffix-bug"
  resource_group_name = azurerm_resource_group.test.name
}

module "container_app" {
  source = "../.."

  container_app_environment_resource_id = azurerm_container_app_environment.test.id
  name                                  = "app-suffix-bug-${random_id.container_name.hex}"
  resource_group_name                   = azurerm_resource_group.test.name
  revision_mode                         = "Single"
  enable_telemetry                      = false

  template = {
    # Setting revision_suffix triggers the bug on the second apply.
    # Before the fix, Azure rejects this because "test-v1" already exists.
    # After the fix, this value is ignored — Azure auto-generates unique suffixes.
    revision_suffix = "test-v1"

    containers = [
      {
        name   = "hello"
        memory = "0.5Gi"
        cpu    = 0.25
        image  = "mcr.microsoft.com/k8se/quickstart:latest"
        env = [
          {
            name  = "PORT"
            value = "80"
          }
        ]
      },
    ]
  }

  ingress = {
    target_port      = 80
    external_enabled = true
    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }

  depends_on = [azurerm_resource_group.test]
}
