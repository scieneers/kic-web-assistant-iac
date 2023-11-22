resource "google_service_account" "kic_k8s_service_account" {
  account_id   = "${var.project_id}-k8s-sa"
  display_name = "kubernetes node pool service account"
}

resource "google_project_iam_member" "kic_k8s_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.kic_k8s_service_account.email}"
}

resource "google_project_iam_member" "kic_k8s_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.kic_k8s_service_account.email}"
}

resource "google_container_cluster" "kic_k8s_cluster" {
  name     = "${var.project_id}-k8s"
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

}

resource "google_container_node_pool" "kic_k8s_preemptible_nodepool" {
  name       = "${var.project_id}-k8s-base-nodepool"
  location   = var.zone
  cluster    = google_container_cluster.kic_k8s_cluster.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-standard-2"
    disk_size_gb = 30

    service_account = google_service_account.kic_k8s_service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
