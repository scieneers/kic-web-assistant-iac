variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "allowed_ip_ranges" {
  type        = list(string)
  default     = []
  description = "Public IP ranges allowed through the storage firewall"
}

variable "vnet_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Subnet IDs allowed via service endpoints"
}
