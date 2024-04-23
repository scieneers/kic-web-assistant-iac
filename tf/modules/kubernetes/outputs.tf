resource "local_file" "kubeconfig" {
  filename     = "./kubeconfig"
  content      = azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config_raw
  depends_on   = [azurerm_kubernetes_cluster.kic_k8s_cluster]
}

output "k8s_agentpool_mi" {
  value = azurerm_kubernetes_cluster.kic_k8s_cluster.kubelet_identity[0].object_id
  depends_on   = [azurerm_kubernetes_cluster.kic_k8s_cluster]
}