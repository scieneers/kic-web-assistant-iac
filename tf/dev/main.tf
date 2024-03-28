module "kic-kubernetes-dev" {
 source     = "../modules/kubernetes"
 resource_group = azurerm_resource_group.kic_web_assistant_rg.name
 region       = var.region
 service_principal_id = azuread_service_principal.kic_k8s_service_principal.client_id
 service_principal_secret = azuread_service_principal_password.kic_k8s_service_principal_pw.value
}

module "sops" {
  source        = "../modules/key_vault"
  resource_group = azurerm_resource_group.kic_web_assistant_rg.name
  region        = var.region
  key_vault_name = var.key_vault_name
  key_names     = ["sops"]
  service_principal_id = azuread_service_principal.kic_k8s_service_principal.client_id
}