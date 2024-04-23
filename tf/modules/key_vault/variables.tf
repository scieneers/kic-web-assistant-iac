variable "resource_group" {
  type = string
}

variable "region" {
  type = string
}

variable "key_vault_name" {
  type = string
}

variable "key_names" {
  type = list(string)
}

variable "uai_principal_id" {
  type = string
}

variable "k8s_agentpool_mi" {
  type = string  
}