locals {
  environment     = terraform.workspace == "default" ? "dev" : terraform.workspace
  resource_prefix = "kic"
  resource_group  = "kic-aichat-${local.environment}"
  region          = "germanywestcentral"
}
