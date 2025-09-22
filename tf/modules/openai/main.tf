resource "azurerm_cognitive_account" "this" {
  kind                = "OpenAI"
  location            = var.openai_location
  name                = var.cognitive_account_name
  resource_group_name = var.resource_group_name
  sku_name            = var.openai_sku
}

resource "azurerm_cognitive_deployment" "this" {
  for_each = { for each in var.openai_model_deployment : each.model_name => each }

  cognitive_account_id   = azurerm_cognitive_account.this.id
  name                   = each.value.model_name
  rai_policy_name        = each.value.rai_policy_name
  version_upgrade_option = each.value.version_upgrade_option

  model {
    format  = "OpenAI"
    name    = each.value.model_name
    version = each.value.model_version
  }

  sku {
    name     = each.value.sku_name
    tier     = each.value.scale_tier
    size     = each.value.scale_size
    family   = each.value.scale_family
    capacity = each.value.scale_capacity
  }

  lifecycle {
    ignore_changes = [
      cognitive_account_id
    ]
  }
}
