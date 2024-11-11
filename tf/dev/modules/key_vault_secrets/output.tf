output "secrets" {
    value = {
        for secret in azurerm_key_vault_secret.this : replace(secret.name, "-", "_") => secret.value
    }
    sensitive = true
}