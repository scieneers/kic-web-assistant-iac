variable "resource_group_name_tfstate" {
    default = "kic-chat-assistant_dev"
    type = string
}
variable "storage_account_name" {
    default = "kicwastadev"
    type = string
}
variable "environment_short" {
    default = "dev"
    type = string
}
variable "secrets_file"{
    default = "secrets.enc.yaml"
    type = string
}
variable "restapi_image_name"{
    default = "rest-api:1.8.7"
    type = string
}
variable "frontend_image_name"{
    default = "kic-frontend:1.8.1"
    type = string
}
variable "loader_image_name"{
    default = "kic-loader"
    type = string
}
variable "openai_sku" {
  type        = string
  description = "Specifies the SKU Name for the Cognitive Service Account"
  default     = "S0"
  validation {
    condition     = can(regex("F0|F1|S0|S|S1|S2|S3|S4|S5|S6|P0|P1|P2|E0|DC0", var.openai_sku))
    error_message = "Err: Valid options are F0, F1, S0, S, S1, S2, S3, S4, S5, S6, P0, P1, P2, E0 and DC0."
  }
}
variable "openai_model_deployment" {
  type = list(object({
    model_name             = string
    model_version          = string
    scale_tier             = optional(string)
    scale_size             = optional(number)
    scale_family           = optional(string)
    scale_capacity         = optional(number)
    rai_policy_name        = optional(string)
    version_upgrade_option = optional(string)
    sku_name               = optional(string, "Standard")
  }))
  default     = []
  description = <<-DESCRIPTION
      type = list(object({
        model_name = {
          model_name    = (Required) The name of the Deployment model. Changing this forces a new resource to be created.
          model_version = (Required) The version of Deployment model.
        }
        scale = {
          scale_tier     = (Optional) Possible values are Free, Basic, Standard, Premium, Enterprise. Changing this forces a new resource to be created.
          scale_size     = (Optional) The SKU size. When the name field is the combination of tier and some other value, this would be the standalone code. Changing this forces a new resource to be created.
          scale_family   = (Optional) If the service has different generations of hardware, for the same SKU, then that can be captured here. Changing this forces a new resource to be created.
          scale_capacity = (Optional) Tokens-per-Minute in thousands (TPM). If the SKU supports scale out/in then the capacity integer should be included. If scale out/in is not possible for the resource this may be omitted. Default value is 1. Changing this forces a new resource to be created.
        }
        rai_policy_name = (Optional) The name of RAI policy. Changing this forces a new resource to be created.
        version_upgrade_option = (Optional )Deployment model version upgrade option. Possible values are OnceNewDefaultVersionAvailable, OnceCurrentVersionExpired, and NoAutoUpgrade. Defaults to OnceNewDefaultVersionAvailable.
      }))
  DESCRIPTION
  nullable    = false
}
