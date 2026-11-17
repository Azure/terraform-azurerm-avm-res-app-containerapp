terraform {
  required_providers {
    # tflint-ignore: terraform_unused_required_providers
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
  }
}

module "container_app" {
  source = "../caller"

  legacy = var.legacy
}

output "ids" {
  value = module.container_app.ids
}
