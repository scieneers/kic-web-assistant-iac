output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "container_name" {
  value = azurerm_storage_container.tfstate.name
}

output "subscription_id" {
  value = var.subscription_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "sops_key_vault_name" {
  value = azurerm_key_vault.sops.name
}

output "sops_key_dev_url" {
  value       = azurerm_key_vault_key.sops_dev.versionless_id
  description = "SOPS key URL for dev environment (without version)"
}

output "sops_key_prod_url" {
  value       = azurerm_key_vault_key.sops_prod.versionless_id
  description = "SOPS key URL for prod environment (without version)"
}
