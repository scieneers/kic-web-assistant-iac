resource "local_file" "kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.kic_k8s_cluster]
  filename     = "./kubeconfig"
  content      = azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config_raw
}