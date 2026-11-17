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

  legacy = true
}

output "ids" {
  value = module.workload["blue"].ids
}
