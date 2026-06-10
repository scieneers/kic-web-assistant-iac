variable "name" {
  type        = string
  description = "Name of the Azure AI Search service (2-60 chars, lowercase letters, digits and dashes)"
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  type        = string
  default     = "basic"
  description = "Search service SKU. 'basic' or higher is required for Private Link / private endpoints ('free' does not support it)."
}

variable "replica_count" {
  type        = number
  default     = 1
  description = "Number of replicas (query throughput / high availability)"
}

variable "partition_count" {
  type        = number
  default     = 1
  description = "Number of partitions (index size / scale)"
}

variable "semantic_search_sku" {
  type        = string
  default     = null
  description = "Semantic ranking tier ('free' or 'standard'). null disables semantic search."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Whether the service is reachable from the public internet. Kept false so all traffic flows through the private endpoint."
}

variable "local_authentication_enabled" {
  type        = bool
  default     = true
  description = "Allow API-key (admin/query key) auth in addition to Entra ID RBAC. Set false to enforce RBAC-only."
}

variable "network_rule_bypass_option" {
  type        = string
  default     = "AzureServices"
  description = "Whether trusted Azure services may bypass the network rules ('AzureServices' or 'None')."
}

variable "allowed_ips" {
  type        = list(string)
  default     = []
  description = "Public IPs/CIDRs allowed through the firewall. Only relevant when public_network_access_enabled = true."
}

variable "vnet_id" {
  type        = string
  description = "ID of the virtual network the private DNS zone is linked to"
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "ID of the subnet that hosts the private endpoint (must have private_endpoint_network_policies disabled and no delegation)"
}
