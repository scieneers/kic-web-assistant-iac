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

variable "qdrant_image_tag" {
  type        = string
  default     = "v1.18.2"
  description = "Qdrant image tag to import into ACR for reproducible deployments"
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
