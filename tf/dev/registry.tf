resource "google_artifact_registry_repository" "kic_assistant" {
  location      = var.region
  repository_id = "docker-registry"
  description   = "Docker registry for all KIC Chat Assistant images"
  format        = "DOCKER"
}