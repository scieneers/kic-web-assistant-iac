data "azurerm_client_config" "current" {}

data "sops_file" "secrets" {
  source_file = "${path.module}/${local.environment}/secrets.enc.yaml"
}
