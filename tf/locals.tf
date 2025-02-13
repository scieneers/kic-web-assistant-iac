locals {
  #environment            = terraform.workspace == "default" ? "dev" : "prod"
  environment            = var.environment_short
  resource_prefix        = "kicwa"
  resource_group         = "kic-chat-assistant_${local.environment}"
  region                 = "germanywestcentral"
  mistral_region         = "swedencentral"
  llama_region           = "eastus"
  admin_group_id         = "2ff7599c-3c1e-419b-b5a9-70d1f33a0cdc"
  frontend_domain_prefix = "kic-frontend"
}

