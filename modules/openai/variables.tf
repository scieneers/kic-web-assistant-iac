variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "swedencentral"
}

variable "model_deployments" {
  type = list(object({
    name          = string
    model_name    = string
    model_version = string
    sku_name      = optional(string, "Standard")
    capacity      = optional(number, 10)
  }))
  default = []
}
