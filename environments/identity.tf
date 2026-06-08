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

# Durable Functions on managed-identity storage needs Blob + Queue + Table data access
# (control queues, history/instances tables, lease blobs). Applied in dev + prod since the
# loader Function App now runs in both environments.
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
