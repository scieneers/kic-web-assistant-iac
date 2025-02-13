

resource "azurerm_key_vault_secret" "this" {
  for_each = var.secrets
  # replace name from underscore to hyphen because env variables are with _ but key vault secrets only allow -
  name         = replace(each.key, "_", "-")
  value        = each.value
  key_vault_id = var.key_vault_id
}

