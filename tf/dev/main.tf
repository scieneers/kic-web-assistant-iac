module "kic-kubernetes-dev" {
  source     = "../modules/kubernetes"
  project_id = var.project_id
  zone       = var.zone
}
