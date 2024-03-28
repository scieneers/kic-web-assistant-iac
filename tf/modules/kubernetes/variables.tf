variable "resource_group" {
  type = string
}

variable "region" {
  type = string
}

variable "service_principal_id" {
  type = string
}

variable "service_principal_secret" {
  sensitive = true
  type = string
}
