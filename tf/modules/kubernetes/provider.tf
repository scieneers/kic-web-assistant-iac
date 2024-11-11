terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.96"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.18.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.8.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.13"
    }    
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.host
  username               = azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.username
  password               = azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.cluster_ca_certificate)
}
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.host
    username               = azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.username
    password               = azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.password
    client_certificate     = base64decode(azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.cluster_ca_certificate)
  }
}
provider "kubectl" {
  host                   = azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.host
  username               = azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.username
  password               = azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.kic_k8s_cluster.kube_config.0.cluster_ca_certificate)
  load_config_file       = false
}
