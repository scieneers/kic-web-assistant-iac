locals {
  environment = terraform.workspace == "default" ? "dev" : "prod"
  resource_prefix = "kicwa"
  resource_group = "kic-chat-assistant_${local.environment}"
  resource_group_nodes = "kic-chat-assistant_${local.environment}_nodes"
  region = "germanywestcentral"
  mistral_region = "swedencentral"
  llama_region = "eastus"
}