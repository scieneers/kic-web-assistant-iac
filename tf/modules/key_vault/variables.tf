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

variable "service_principal_id" {
  type = string
}
