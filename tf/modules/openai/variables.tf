variable "cognitive_account_name" {
  description = "The name of the OpenAI cognitive account."
  type        = string
}

variable "openai_location" {
  description = "The location for the OpenAI resource."
  type        = string
}


variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "openai_sku" {
  description = "The SKU for the OpenAI resource."
  type        = string
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
        sku_name = (Optional) The SKU Name for the deployment. Defaults to Standard.
      }))
  DESCRIPTION
  nullable    = false
}
