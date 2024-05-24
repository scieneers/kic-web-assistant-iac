resource "azurerm_kubernetes_cluster" "kic_k8s_cluster" {
  name                = "${var.resource_prefix}-k8s-${local.environment}"
  location            = var.region
  resource_group_name = var.resource_group
  dns_prefix          = "${var.resource_prefix}-k8s-${local.environment}"
  
  default_node_pool {
    name       = "${local.environment}pool"
    vm_size    = "Standard_DS4_v2"
    upgrade_settings {
      max_surge = "10%"
    }
    min_count             = 1
    max_count             = 3
    node_count            = 1
    os_disk_size_gb       = 30
    enable_auto_scaling   = true
    temporary_name_for_rotation = "${local.environment}temp"

  }

  identity {
    identity_ids = [azurerm_user_assigned_identity.uai.id]
    type = "UserAssigned"
}

  key_vault_secrets_provider {
   # update the secrets on a regular basis
   secret_rotation_enabled = true
  }
}

resource "azurerm_role_assignment" "aks_k8s_mi" {
  scope                = azurerm_container_registry.kic_assistant.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.kic_k8s_cluster.kubelet_identity[0].object_id
}