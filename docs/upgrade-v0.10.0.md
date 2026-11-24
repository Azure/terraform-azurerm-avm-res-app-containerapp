# Upgrade from v0.9.0: existing AuthConfig state

The AuthConfig extraction retains the standard design: the Container App module
uses `for_each = var.auth_configs` on `module.auth_config`, and each child manages
one `azapi_resource.this`. The key moves from the resource instance into the
module instance. Terraform cannot express this transpose with a generic moved
block; the incorrect generic declaration has been removed.

For **every existing key**, move the state address without changing its resource
ID or provider reference:

```text
<caller-prefix>azapi_resource.auth_config["key"]
  -> <caller-prefix>module.auth_config["key"].azapi_resource.this
```

The prefix includes the complete path to this Container App module, including
any caller `count` or `for_each` instance selectors and the trailing dot. It is
empty when this repository is the Terraform root. Map keys are not necessarily
the AuthConfig's Azure name. Do not rename keys or Azure resources during this
procedure. Empty AuthConfig state needs no move.

## 1. Stop automation and back up the correct state

Use PowerShell 7.4 or later and the consumer's normal Terraform working directory,
backend, workspace and provider configuration. Stop concurrent plans/applies.
Confirm the workspace and account independently; do not copy these commands into
an unrelated checkout. Retain the existing provider configurations and aliases.
Initialize the upgraded configuration, but **do not apply it yet**.

Back up state before any move. State and plan files can contain secrets: protect
their permissions, keep them out of source control, and retain the original
backup until the upgrade has been reviewed.

```powershell
$ErrorActionPreference = 'Stop'

terraform workspace show
if ($LASTEXITCODE -ne 0) { throw 'Cannot identify the workspace.' }

$backupPath = Join-Path (Get-Location) 'auth-config-before-upgrade.tfstate'
if (Test-Path -LiteralPath $backupPath) {
    throw 'Backup already exists. Preserve it; select a new backup path.'
}
$state = terraform state pull
if ($LASTEXITCODE -ne 0) { throw 'State backup failed; stop.' }
[System.IO.File]::WriteAllText(
    $backupPath,
    ($state -join "`n"),
    [System.Text.UTF8Encoding]::new($false)
)
if ((Get-Item -LiteralPath $backupPath).Length -eq 0) {
    throw 'State backup is empty; stop.'
}

terraform state list
if ($LASTEXITCODE -ne 0) { throw 'Cannot inventory state; stop.' }
```

Record every old AuthConfig address and its `instances[].attributes.id` and
resource-level `provider` reference from the backup. Record unrelated resource
addresses too. Use actual addresses from this inventory, not inferred Azure
names or a guessed module prefix.

## 2. Move one verified key at a time

For example, the caller prefix below is
`module.workload["blue"].module.container_app.` and the existing keys are
`alpha` and `beta`. Replace the **complete literal addresses** with your own.
For a root-module deployment, omit that caller prefix on both sides.

Before **each** pair, inspect `terraform state list`:

| Old address | Correct destination | Action |
| --- | --- | --- |
| Present | Absent | Preview, verify the exact pair, then move. |
| Absent | Present | Possibly already moved. Compare its ID and provider reference with the original backup before skipping this pair. |
| Present | Present | Stop: destination is occupied; do not overwrite or remove either object. |
| Absent | Absent | Stop: wrong workspace/prefix/key, or unexpected state. |

Preview the first pair. `-dry-run` must identify only the intended old instance:

```powershell
terraform state mv `
    -dry-run `
    'module.workload["blue"].module.container_app.azapi_resource.auth_config["alpha"]' `
    'module.workload["blue"].module.container_app.module.auth_config["alpha"].azapi_resource.this'
if ($LASTEXITCODE -ne 0) { throw 'Alpha preview failed; stop.' }
```

After reviewing the preview and original ID/provider reference, move that pair:

```powershell
terraform state mv `
    -lock-timeout=5m `
    'module.workload["blue"].module.container_app.azapi_resource.auth_config["alpha"]' `
    'module.workload["blue"].module.container_app.module.auth_config["alpha"].azapi_resource.this'
if ($LASTEXITCODE -ne 0) { throw 'Alpha move failed; stop and inspect state.' }
```

Reinventory state and check the next pair before continuing:

```powershell
terraform state list
if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect partial progress; stop.' }

terraform state mv `
    -dry-run `
    'module.workload["blue"].module.container_app.azapi_resource.auth_config["beta"]' `
    'module.workload["blue"].module.container_app.module.auth_config["beta"].azapi_resource.this'
if ($LASTEXITCODE -ne 0) { throw 'Beta preview failed; stop.' }

terraform state mv `
    -lock-timeout=5m `
    'module.workload["blue"].module.container_app.azapi_resource.auth_config["beta"]' `
    'module.workload["blue"].module.container_app.module.auth_config["beta"].azapi_resource.this'
if ($LASTEXITCODE -ne 0) { throw 'Beta move failed; stop and inspect state.' }
```

Repeat for all remaining existing keys and Container App caller instances.
`state mv` changes state immediately; it is not an Azure deployment. Keep state
locking enabled. Do not blanket-remove state, import over existing entries,
force-push a backup, or rerun the entire sequence blindly.

On any failure or interrupted invocation, stop and pull a **separate** snapshot
without overwriting the original backup. Reconcile each pair using the table
above. Verify an already-moved destination's ID and provider reference against
the original backup before skipping it and continuing with only unmoved keys.
An unexpected ID/provider, both-present pair or missing pair requires
investigation, not a retry or state deletion.

## 3. Verify state and review the plan before applying

Pull a separate post-move snapshot. Each old keyed instance must now be at the
corresponding keyed module/singleton-child address with exactly the same ID and
provider reference. Unrelated addresses, IDs and provider references must be
unchanged. No old or incorrectly transposed
`module.auth_config.azapi_resource.this["key"]` addresses may remain.

```powershell
terraform plan `
    '-out=auth-config-upgrade.tfplan'
if ($LASTEXITCODE -ne 0) { throw 'Upgrade plan failed; stop.' }

terraform show `
    -no-color `
    auth-config-upgrade.tfplan
if ($LASTEXITCODE -ne 0) { throw 'Cannot review the saved plan; stop.' }
```

The address migration must not create, destroy or replace existing AuthConfigs.
Stop on any such action or unexpected unrelated change; do not approve it as a
normal consequence of extraction. Review other v0.10.0 changes independently,
including required `location`, telemetry permissions and Interfaces updates.
Apply only a separately reviewed plan through your normal approval process.

The regression uses mocked AzAPI resources and explicit fixture-only per-key
moves across a nested caller; local synthetic-state checks also exercise the
commands, rerun failures and provider-reference preservation. Neither proves
live Azure behavior or authorizes this agent to modify consumer state.

## Separate ACR example cleanup

The Docker-free ACR example's server-side image import is unrelated to the
AuthConfig address moves. Existing example state can still reference the old
Docker image/tag/push resources and unused push-only credentials. Normal cleanup
may require the old Docker provider and daemon. Review that example's README
and its own cleanup plan; retain registry/networking, pull credentials and
Container App state. Do not use blanket state removal to avoid cleanup.
