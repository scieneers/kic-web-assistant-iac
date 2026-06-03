variable "subscription_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "resource_prefix" {
  type    = string
  default = "kic"
}

variable "location" {
  type    = string
  default = "germanywestcentral"
}

variable "allowed_ip_ranges" {
  type        = list(string)
  default     = []
  description = "Public IP ranges allowed to access the Terraform state storage account"
}

variable "admin_group_id" {
  type        = string
  description = "Object ID of the Azure AD admin group for SOPS Key Vault access"
}
