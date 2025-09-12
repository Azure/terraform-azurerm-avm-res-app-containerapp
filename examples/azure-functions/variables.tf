variable "enable_telemetry" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "max_replicas" {
  type        = number
  default     = 10
  description = "The maximum number of replicas for this container."

  validation {
    condition     = var.max_replicas >= 1 && var.max_replicas <= 1000
    error_message = "The max_replicas value must be between 1 and 1000."
  }
}

variable "min_replicas" {
  type        = number
  default     = 0
  description = "The minimum number of replicas for this container."

  validation {
    condition     = var.min_replicas >= 0 && var.min_replicas <= 1000
    error_message = "The min_replicas value must be between 0 and 1000."
  }
}
