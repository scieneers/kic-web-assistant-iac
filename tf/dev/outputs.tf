resource "local_file" "kubeconfig" {
  filename     = "./kubeconfig-${local.environment}"
  content      = azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config_raw
  depends_on   = [azurerm_kubernetes_cluster.kic_k8s_cluster]
}