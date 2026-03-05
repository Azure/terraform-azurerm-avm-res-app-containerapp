# Revision Suffix Example

This example demonstrates the revision suffix HasChange guard that prevents
the "revision with suffix already exists" error when updating a Container App.

## Test Scenarios

### 1. First apply (Create with suffix "test-v1")

```bash
terraform apply -var 'revision_suffix=test-v1'
```

### 2. Change image only, keep the same suffix

```bash
terraform apply -var 'revision_suffix=test-v1' -var 'container_image=mcr.microsoft.com/k8se/quickstart:latest'
```

The revision suffix should **not** be re-sent because it has not changed.

### 3. Change both image and suffix

```bash
terraform apply -var 'revision_suffix=test-v2' -var 'container_image=mcr.microsoft.com/k8se/quickstart:latest'
```

A new revision with suffix `test-v2` should be created.

### 4. Set suffix to null (Azure auto-generates)

```bash
terraform apply -var 'revision_suffix='
```

Or remove the `revision_suffix` variable from your tfvars file.
