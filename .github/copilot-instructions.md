# GitHub Copilot Instructions for Azure Container Apps AVM Module

## Module Overview
This is an Azure Verified Module (AVM) for Azure Container Apps that uses the AzAPI provider exclusively while maintaining interface compatibility with the equivalent azurerm module. The module follows AVM design principles and Azure best practices.

## Key Design Principles

### 1. AVM Compliance
- Follow all Azure Verified Module (AVM) specifications and patterns
- Maintain consistent naming conventions using snake_case for variables
- Include comprehensive variable validation and descriptions
- Provide complete examples and documentation

### 2. AzAPI Focus
- Use `azapi_resource` exclusively for Container Apps resource creation
- Map snake_case input variables to camelCase Azure API properties
- Leverage AzAPI's native Azure ARM template structure
- Maintain schema validation where possible

### 3. Interface Compatibility
- Preserve compatibility with azurerm Container Apps module interfaces
- Allow variable additions for new Azure features not in azurerm
- Maintain existing variable structure and naming conventions
- Support all azurerm module capabilities through AzAPI

## Code Generation Guidelines

### Variable Structure
- Use `optional()` for non-required fields with appropriate defaults
- Provide comprehensive descriptions with EOT heredoc syntax
- Include validation blocks for constrained values
- Group related variables logically (e.g., ingress, template, dapr)

### Resource Mapping
When mapping variables to AzAPI body structure:
```terraform
# Snake case input (azurerm style)
var.ingress.allow_insecure_connections

# Maps to camelCase AzAPI body
allowInsecure = var.ingress.allow_insecure_connections
```

### Authentication Patterns
For scale rules and other auth blocks, use consistent patterns:
```terraform
auth = rule.azure_queue.auth != null ? [
  for auth in rule.azure_queue.auth : {
    secretRef        = auth.secret_name
    triggerParameter = auth.trigger_parameter
  }
] : null
```

### Conditional Logic
Use consistent null checking patterns:
```terraform
property = var.config != null ? {
  # configuration
} : null
```

### Complex Mapping Patterns
For complex transformations that combine multiple input arrays into single API structures, use locals blocks:

#### Scale Rules Pattern
```terraform
locals {
  # Combine separate azurerm-style scale rule variables into single API rules array
  scale_rules = setunion(
    var.template.azure_queue_scale_rules != null ? [
      for rule in var.template.azure_queue_scale_rules : {
        name = rule.name
        azureQueue = {
          accountName = rule.account_name
          queueName   = rule.queue_name
          queueLength = rule.queue_length
        }
        custom = null
        http   = null
        tcp    = null
      }
    ] : [],
    var.template.custom_scale_rules != null ? [...] : [],
    # ... other scale rule types
  )
}
```

#### Per-Container Mapping Pattern
```terraform
locals {
  # Create container-specific mappings for properties that belong to individual containers
  container_probes = {
    for cont in var.template.containers : cont.name => setunion(
      try(cont.liveness_probes, []) != null ? [
        for probe in try(cont.liveness_probes, []) : {
          type = "Liveness"
          # ... probe configuration
        }
      ] : [],
      try(cont.readiness_probes, []) != null ? [...] : [],
      try(cont.startup_probes, []) != null ? [...] : []
    )
  }
}
```

## Azure Container Apps Specific Guidance

### Scale Rules
Support all scale rule types with unified API mapping:
- `azureQueue` - Azure Storage Queue scaling
- `custom` - Custom KEDA scalers
- `http` - HTTP concurrent requests
- `tcp` - TCP concurrent connections

Use locals to combine separate azurerm-style scale rule variables into the single API rules array:
```terraform
locals {
  scale_rules = setunion(
    var.template.azure_queue_scale_rules != null ? [for rule in ...] : [],
    var.template.custom_scale_rules != null ? [for rule in ...] : [],
    var.template.http_scale_rules != null ? [for rule in ...] : [],
    var.template.tcp_scale_rules != null ? [for rule in ...] : []
  )
}
```

### Probe Configuration
Handle three probe types with per-container mapping:
- Liveness probes - health checking
- Readiness probes - traffic routing decisions
- Startup probes - initial container startup

Use locals to create container-specific probe mappings:
```terraform
locals {
  container_probes = {
    for cont in var.template.containers : cont.name => setunion(
      # Combine all probe types for this container
    )
  }
}
```

### Volume Management
Support volume types:
- `AzureFile` - Azure Files integration
- `EmptyDir` - Temporary storage
- `Secret` - Secret-based volumes

Map `secret_name` (azurerm style) to `secretRef` (API style) for consistency.

## Testing and Validation

### Required Tests
- Basic deployment scenarios
- Complex multi-container deployments
- Scale rule configurations
- Volume mount scenarios
- Ingress and traffic management
- DAPR integration

### Validation Patterns
- Use `nullable = false` for required variables
- Include validation blocks for enum-style values
- Validate resource references and dependencies

## Documentation Standards

### Variable Documentation
Each variable must include:
- Clear description of purpose
- All possible values for constrained fields
- Default values and their rationale
- Cross-references to related variables
- Use `secret_name` for consistency with azurerm (maps to `secretRef` in API)

### Complex Transformation Documentation
For complex mappings using locals:
- Document the azurerm-style input structure
- Explain the API output structure
- Show the transformation pattern used
- Include examples of the mapping logic

### Example Structure
Provide examples for:
- Basic single container deployment
- Multi-container with volumes
- Scale rules configuration
- Complex ingress scenarios
- DAPR-enabled applications

## File Organization

### Core Files
- `main.tf` - Primary resource definitions
- `variables.tf` - Input variable definitions
- `outputs.tf` - Module outputs
- `versions.tf` - Provider requirements
- `locals.tf` - Local value calculations for complex mappings

### Locals Files for Complex Mappings
- `local.scale_rules.tf` - Scale rule transformations
- `locals.probes.tf` - Container probe mappings
- Use separate locals files for readability when transformations are complex

### Variable Files
- `variables.containerapps.tf` - Container Apps specific variables
- Group related variables by Azure service integration

## Azure Best Practices Integration

### Security
- Use managed identities where possible
- Implement proper RBAC assignments
- Secure secret management patterns
- Network security considerations

### Performance
- Appropriate resource sizing
- Efficient scaling configurations
- Optimal probe configurations
- Volume performance considerations

### Reliability
- Health check configurations
- Graceful shutdown handling
- Retry and timeout patterns
- Multi-region deployment support

## Common Patterns

### Identity Management
```terraform
dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned
    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }
```

### Resource Locking
```terraform
resource "azurerm_management_lock" "this" {
  count = var.lock.kind != "None" ? 1 : 0
  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = azapi_resource.container_app.id
}
```

### Role Assignments
```terraform
resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments
  principal_id         = each.value.principal_id
  scope               = azapi_resource.container_app.id
  role_definition_id  = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
}
```

## Error Handling

### Common Issues
- Handle optional nested objects carefully using `try()` function
- Validate array structures before iteration
- Check for null values in complex objects using conditional logic
- Ensure proper type conversion between providers
- Use locals for complex mappings to avoid inline complexity

### Debugging Tips
- Use `schema_validation_enabled = true` for AzAPI resources
- Leverage `response_export_values` for output extraction
- Implement proper lifecycle rules for revision management
- Pre-compute complex transformations in locals for better error isolation

### Complex Mapping Best Practices
- Use `setunion()` to combine multiple arrays into single API structures
- Create container-specific maps for per-container properties
- Validate transformations in locals before using in main resource
- Keep azurerm-style variable names while mapping to camelCase API properties

## Maintenance Notes

### Version Management
- Pin AzAPI provider versions appropriately
- Test against Azure API version updates
- Maintain backward compatibility where possible

### Feature Additions
- New Azure Container Apps features should be added as optional variables
- Maintain existing variable structure
- Update examples and documentation
- Add appropriate validation

This module represents a bridge between azurerm and native Azure API usage while maintaining AVM compliance and Azure best practices.
