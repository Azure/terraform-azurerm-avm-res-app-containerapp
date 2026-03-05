variable "location" {
  type    = string
  default = "eastus"
}

variable "revision_suffix" {
  type        = string
  default     = "test-v1"
  description = "Revision suffix for the container app. Set to null to let Azure auto-generate."
}

variable "container_image" {
  type        = string
  default     = "mcr.microsoft.com/k8se/quickstart:latest"
  description = "Container image to deploy."
}
