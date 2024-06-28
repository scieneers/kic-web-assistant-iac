locals {
  environment = terraform.workspace == "default" ? "dev" : "prod"
  resource_prefix = "kicwa"
  resource_group = "kic-chat-assistant_${local.environment}"
  region = "germanywestcentral"
  mistral_region = "swedencentral"
  llama_region = "eastus"
  admin_group_id = "0640cd39-6e11-4243-a723-bf040f966b32"
  ad_app_id = "41ad5548-6e6c-433b-b465-4a35e3ba07cc"
  frontend_domain_prefix = "kic-frontend"
}