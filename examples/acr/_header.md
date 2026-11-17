# Startup example

This deploys the module with Azure Container Registry.

Azure imports `docker.io/library/nginx:latest` into ACR as `nginx:latest`
before the Container App is created. No local Docker engine or image build is
required. The app still authenticates with the existing pull token and secret;
the registry, networking, private endpoints, and geo-replication are unchanged.

The deployment identity needs `Microsoft.ContainerRegistry/registries/importImage/action`
on the target registry, for example through the **Container Registry Data Importer
and Data Reader** role. Network-restricted registries must allow trusted services.
See [ACR image import](https://learn.microsoft.com/azure/container-registry/container-registry-import-images).

The import uses `Force` to overwrite an existing destination tag when the action
runs. Unchanged applies do not reimport; changing the request, changing/replacing
the registry, or explicitly replacing `azapi_resource_action.import_nginx` runs
the import again. The mutable upstream `latest` tag can then resolve to a newer
image. AzAPI waits for the import operation to complete and surfaces failures.
Removing the action does not delete the imported image.

Existing example states will plan removal of the local Docker image/tag/push
resources and push-only token/password. Review that cleanup before applying;
state that still references Docker may need the old provider and daemon for its
normal cleanup. Retain the registry, pull-token/password, and Container App state.
No automatic state removal or migration is performed by this example.
