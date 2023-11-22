variable "project_id" {
  default = "kic-chat-assistant"
  type    = string
}

variable "zone" {
  default = "europe-west3-b"
  type    = string
}

variable "region" {
  default = "europe-west3"
  type    = string
}

variable "services" {
  type = list(string)
  default = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "cloudkms.googleapis.com",
  ]
}
