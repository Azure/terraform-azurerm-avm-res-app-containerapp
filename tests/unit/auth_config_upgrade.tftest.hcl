mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

run "auth_config_legacy_state" {
  command   = apply
  state_key = "auth_config_upgrade"

  module {
    source = "./tests/fixtures/auth-config-upgrade/before"
  }

  assert {
    condition     = toset(keys(output.ids)) == toset(["alpha", "beta"])
    error_message = "The upgrade fixture must begin with both existing AuthConfig keys."
  }
}

run "auth_config_per_key_moves_preserve_ids" {
  command   = plan
  state_key = "auth_config_upgrade"

  module {
    source = "./tests/fixtures/auth-config-upgrade/after"
  }

  plan_options {
    refresh = false
  }

  assert {
    condition     = output.ids == run.auth_config_legacy_state.ids
    error_message = "Explicit per-key moves must preserve both existing IDs through the nested caller into the real singleton AuthConfig child."
  }
}
