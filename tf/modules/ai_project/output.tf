output "id" {
  value = azapi_resource.project.id
}

output "managed_identity_id" {
  value = azapi_resource.project.identity[0].principal_id
}