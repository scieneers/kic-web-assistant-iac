resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "tfstate" {
  name                            = "${var.resource_prefix}tfstate${terraform.workspace == "default" ? "dev" : terraform.workspace}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = var.allowed_ip_ranges
  }
}

resource "azurerm_storage_container" "tfstate" {
  name               = "tfstate"
  storage_account_id = azurerm_storage_account.tfstate.id
}

#########################################
# SOPS Key Vault
#########################################

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "sops" {
  name                       = "${var.resource_prefix}-sops-keyvault"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.allowed_ip_ranges
  }
}

resource "azurerm_key_vault_access_policy" "sops_admin" {
  key_vault_id = azurerm_key_vault.sops.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.admin_group_id

  key_permissions = [
    "Get",
    "List",
    "Create",
    "Delete",
    "Encrypt",
    "Decrypt",
    "Purge",
    "GetRotationPolicy",
    "SetRotationPolicy",
  ]
}

resource "azurerm_key_vault_access_policy" "sops_deployer" {
  key_vault_id = azurerm_key_vault.sops.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
    "List",
    "Create",
    "Delete",
    "Encrypt",
    "Decrypt",
    "Purge",
    "GetRotationPolicy",
    "SetRotationPolicy",
  ]
}

resource "azurerm_key_vault_key" "sops_dev" {
  name         = "sops-key-dev"
  key_vault_id = azurerm_key_vault.sops.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
  ]

  depends_on = [
    azurerm_key_vault_access_policy.sops_admin,
    azurerm_key_vault_access_policy.sops_deployer,
  ]
}

resource "azurerm_key_vault_key" "sops_prod" {
  name         = "sops-key-prod"
  key_vault_id = azurerm_key_vault.sops.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
  ]

  depends_on = [
    azurerm_key_vault_access_policy.sops_admin,
    azurerm_key_vault_access_policy.sops_deployer,
  ]
}
