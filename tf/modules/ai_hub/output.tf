output "id" {
  value = azapi_resource.hub.id
}

output "managed_identity_id" {
  value = azapi_resource.hub.identity[0].principal_id
}