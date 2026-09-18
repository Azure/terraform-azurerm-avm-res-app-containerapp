variable "container_image" {
  type        = string
  default     = "mcr.microsoft.com/k8se/quickstart:latest"
  description = "Container image to deploy."
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "revision_suffix" {
  type        = string
  default     = "test-v1"
  description = "Revision suffix for the container app. Set to null to let Azure auto-generate."
}

variable "enable_telemetry" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}
