variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "admin_group_id" {
  type        = string
  description = "Azure AD Group ID for Key Vault admin access"
}

variable "restapi_image_name" {
  type    = string
  default = "rest-api:1.8.1"
}

variable "frontend_image_name" {
  type    = string
  default = "kic-frontend:1.8.1"
}

variable "loader_image_name" {
  type    = string
  default = "loader:latest"
}

variable "allowed_ip_ranges" {
  type        = list(string)
  default     = []
  description = "Public IP ranges allowed through Storage and Key Vault firewalls"
}

variable "service_plan_sku" {
  type    = string
  default = "P1v3"
}

variable "search_sku" {
  type        = string
  default     = "basic"
  description = "Azure AI Search SKU. 'basic' or higher is required for the private endpoint ('free' does not support Private Link)."
}

variable "search_semantic_sku" {
  type        = string
  default     = null
  description = "Semantic ranking tier for Azure AI Search ('free' or 'standard'). null disables semantic search."
}

variable "frontend_password" {
  type        = string
  sensitive   = true
  description = "Basic-auth password for the frontend app"
}

variable "debug_mode" {
  type        = bool
  default     = false
  description = "Enables DEBUG_MODE on the REST API"
}

variable "enable_socratic" {
  type        = bool
  default     = true
  description = "Enables ENABLE_SOCRATIC on the REST API"
}
