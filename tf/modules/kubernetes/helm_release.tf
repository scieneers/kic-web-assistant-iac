resource "helm_release" "qdrant" {
  name        = "qdrant"
  chart       = "qdrant"
  repository  = "https://qdrant.github.io/qdrant-helm"
  namespace   = "kicwa"
  values = [
    file("${path.module}/values.yaml")
      ]

  max_history = 3
  create_namespace = true
  wait             = true
  reset_values     = true
}

resource "helm_release" "kicwa-frontend" {
  name        = "kicwa-frontend"
  chart       = "kicwa-frontend"
  repository  = "../../charts"
  namespace   = "kicwa"
  max_history = 3
  create_namespace = true
  wait             = true
  reset_values     = true
}