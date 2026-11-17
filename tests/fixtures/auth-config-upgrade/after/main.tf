terraform {
  required_providers {
    # tflint-ignore: terraform_unused_required_providers
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
  }
}

module "workload" {
  source   = "../workload"
  for_each = toset(["blue"])

  legacy = false
}

moved {
  from = module.workload["blue"].module.container_app.azapi_resource.auth_config["alpha"]
  to   = module.workload["blue"].module.container_app.module.auth_config["alpha"].azapi_resource.this
}

moved {
  from = module.workload["blue"].module.container_app.azapi_resource.auth_config["beta"]
  to   = module.workload["blue"].module.container_app.module.auth_config["beta"].azapi_resource.this
}

output "ids" {
  value = module.workload["blue"].ids
}
