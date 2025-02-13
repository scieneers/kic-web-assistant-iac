output "model_url" {
  description = "https://se-dev-Mistral-large-2411.swedencentral.models.ai.azure.com"
  value = "https://${azapi_resource.mistral-large.name}.${azapi_resource.mistral-large.location}.models.ai.azure.com"
}
