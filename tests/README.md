# Tests

Create tests in the provided subdirectories.

`unit/auth_config_upgrade.tftest.hcl` is collected by `avm test unit`. Its two
runs share mock state, retain two keys across a nested caller, and exercise the
real AuthConfig child after explicit fixture-only per-key moves. These moves
model the endpoints in `docs/upgrade-v0.10.0.md`; they are not a generic migration
inside the published module and never access consumer state or Azure.
Keep the wrappers' provider requirements: Terraform needs them to bind the
AzAPI test mock even when a wrapper contains only module calls.
