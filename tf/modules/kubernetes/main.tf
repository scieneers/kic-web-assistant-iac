data "azurerm_client_config" "current" {}

resource "azurerm_kubernetes_cluster" "kic_k8s_cluster" {
  name                = "${var.resource_group}-k8s"
  location            = var.region
  resource_group_name = var.resource_group
  dns_prefix          = "${var.resource_group}-k8s"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  service_principal {
    client_id     = var.service_principal_id
    client_secret = var.service_principal_secret
  }

}

resource "azurerm_kubernetes_cluster_node_pool" "kic_k8s_preemptible_nodepool" {
  name                  = "kicnodepool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.kic_k8s_cluster.id
  vm_size               = "Standard_DS2_v2"
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = 3
  node_count            = 1
  node_labels           = {
    "preemptible" = "true"
  }
  os_disk_size_gb       = 30
}
