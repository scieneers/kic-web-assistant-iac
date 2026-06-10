output "id" {
  value = azurerm_search_service.this.id
}

output "name" {
  value = azurerm_search_service.this.name
}

output "endpoint" {
  value = "https://${azurerm_search_service.this.name}.search.windows.net"
}

output "principal_id" {
  value       = azurerm_search_service.this.identity[0].principal_id
  description = "Principal ID of the service's system-assigned identity (e.g. for granting it access to Azure OpenAI for integrated vectorization)"
}
