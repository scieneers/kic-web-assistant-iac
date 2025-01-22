variable "resource_group_name_tfstate" {
    default = "kic-chat-assistant_dev"
    type = string
}
variable "storage_account_name" {
    default = "kicwastadev"
    type = string
}
variable "environment_short" {
    default = "dev"
    type = string
}
variable "secrets_file"{
    default = "secrets.enc.yaml"
    type = string
}
variable "restapi_image_name"{
    default = "freddy/rest-api:1.7.4"
    type = string
}
variable "frontend_image_name"{
    default = "freddy/kic-frontend:1.7.4"
    type = string
}
variable "loader_image_name"{
    default = "kic-loader"
    type = string
}