locals {
  environment            = terraform.workspace == "default" ? "dev" : "prod"
  resource_prefix        = "kicwa"
  resource_group         = "kic-chat-assistant_${local.environment}"
  region                 = "germanywestcentral"
  mistral_region         = "swedencentral"
  llama_region           = "eastus"
  admin_group_id         = "0640cd39-6e11-4243-a723-bf040f966b32"
  frontend_domain_prefix = "kic-frontend"
}