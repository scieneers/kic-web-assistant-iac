module "kic-kubernetes-dev" {
 source         = "../modules/kubernetes"
 resource_group = azurerm_resource_group.kic_web_assistant_rg.name
 region         = var.region
 uai_id         = azurerm_user_assigned_identity.uai.id
 acr_id         = azurerm_container_registry.kic_assistant.id
}

module "sops" {
  source            = "../modules/key_vault"
  resource_group   = azurerm_resource_group.kic_web_assistant_rg.name
  region           = var.region
  key_vault_name   = var.key_vault_name
  key_names        = ["sops"]
  uai_principal_id = azurerm_user_assigned_identity.uai.principal_id
  k8s_agentpool_mi = module.kic-kubernetes-dev.k8s_agentpool_mi
}