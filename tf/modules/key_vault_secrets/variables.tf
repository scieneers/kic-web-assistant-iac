variable "key_vault_id" {
  description = "The id of the key vault"
  type = string
}

variable "secrets" {
  description = "The secrets to store in the key vault"
  type = map(string)
}