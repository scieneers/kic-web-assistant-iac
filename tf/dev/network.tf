resource "azurerm_public_ip" "kicwa-pip" {
  name                = "${local.resource_prefix}-pip-${local.environment}"
  resource_group_name = local.resource_group_nodes
  location            = azurerm_resource_group.kic_web_assistant_rg.location
  allocation_method   = "Static"
  domain_name_label   = "${local.resource_prefix}"
  sku                 = "Standard"

  depends_on = [ azurerm_kubernetes_cluster.kic_k8s_cluster ]
}