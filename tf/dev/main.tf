module "kic-kubernetes-dev" {
  source     = "../modules/kubernetes"
  project_id = var.project_id
  zone       = var.zone
}

module "sops" {
  source        = "../modules/key_ring"
  project_id    = var.project_id
  region        = var.region
  key_ring_name = "sops"
  key_names     = ["sops"]

  depends_on = [google_project_service.services["cloudkms.googleapis.com"]]
}