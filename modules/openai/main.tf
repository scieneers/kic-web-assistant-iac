resource "azurerm_cognitive_account" "this" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  kind                       = "AIServices"
  sku_name                   = "S0"
  custom_subdomain_name      = var.name
  dynamic_throttling_enabled = false

  network_acls {
    default_action = "Allow"
    ip_rules       = []
  }

  provisioner "local-exec" {
    when = destroy
    # When recreating the resource, it takes azure more time than it reports to delete the resource.
    command = "sleep 60"
  }
}

resource "azurerm_cognitive_deployment" "models" {
  for_each = { for m in var.model_deployments : m.name => m }

  cognitive_account_id = azurerm_cognitive_account.this.id
  name                 = each.value.name

  model {
    format  = "OpenAI"
    name    = each.value.model_name
    version = each.value.model_version
  }

  sku {
    name     = each.value.sku_name
    capacity = each.value.capacity
  }
}
