variable "resource_prefix" {
  description = "provide a 2-13 character prefix for all resources."
  type        = string
  default     = "kicwa"
}

variable "resource_group" {
  default = "kic-chat-assistant" # TODO Change to kic-chat-assistant_${local.environment}
  type    = string
}

variable "region" {
  default = "germanywestcentral"
  type    = string
}