# Azure Functions example

This example demonstrates how to deploy an Azure Functions-enabled Container App using the `kind` property. This configuration creates a Container App with the Azure Functions hosting model, which provides native Azure Functions runtime support within Container Apps.

The example uses the official Azure Functions demo image and configures the Container App with:
- `kind = "workflowapp"` to enable Azure Functions hosting
- External ingress for HTTP-triggered functions
- Appropriate resource allocation for Azure Functions workloads
