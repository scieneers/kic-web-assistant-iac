resource "azurerm_user_assigned_identity" "main" {
  name                = "${local.resource_prefix}-uai-${local.environment}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

resource "azurerm_role_assignment" "storage_blob" {
  scope                = module.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

resource "azurerm_role_assignment" "storage_queue" {
  scope                = module.storage.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

resource "azurerm_role_assignment" "storage_table" {
  scope                = module.storage.id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

# Manage indexes / service configuration on Azure AI Search via managed identity
resource "azurerm_role_assignment" "search_service_contributor" {
  scope                = module.ai_search.id
  role_definition_name = "Search Service Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

# Read/write documents in the search indexes via managed identity
resource "azurerm_role_assignment" "search_index_data_contributor" {
  scope                = module.ai_search.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

# Admin group: manage indexes and documents locally via `az login` (RBAC-only, no keys)
resource "azurerm_role_assignment" "search_service_contributor_admins" {
  scope                = module.ai_search.id
  role_definition_name = "Search Service Contributor"
  principal_id         = var.admin_group_id
}

resource "azurerm_role_assignment" "search_index_data_contributor_admins" {
  scope                = module.ai_search.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = var.admin_group_id
}
