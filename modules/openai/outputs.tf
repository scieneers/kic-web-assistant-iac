output "id" {
  value = azurerm_cognitive_account.this.id
}

output "name" {
  value = azurerm_cognitive_account.this.name
}

output "endpoint" {
  value = "https://${azurerm_cognitive_account.this.name}.openai.azure.com/"
}

output "primary_access_key" {
  value     = azurerm_cognitive_account.this.primary_access_key
  sensitive = true
}

output "deployments" {
  value = {
    for d in azurerm_cognitive_deployment.models : d.name => {
      name       = d.name
      model_name = d.model[0].name
    }
  }
}
