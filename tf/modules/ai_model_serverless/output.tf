output "model_url" {
  description = "https://se-dev-Mistral-large-serverless.swedencentral.inference.ai.azure.com"
  value = "https://${azapi_resource.mistral-large.name}-serverless.${azapi_resource.mistral-large.location}.inference.ai.azure.com"
}
