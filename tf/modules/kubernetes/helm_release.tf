locals {
    location                  = "westeurope"
    namespace                 = "kicwa"
    ingressClass              = "nginx"
    hostname                  = "kicwa"
    ssl_cert_owner_email      = "sebastian.drewke@scieneers.de"
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = local.namespace
  }

  depends_on = [azurerm_kubernetes_cluster.kic_k8s_cluster]
}

resource "helm_release" "qdrant" {
  name        = "qdrant"
  chart       = "qdrant"
  repository  = "https://qdrant.github.io/qdrant-helm"
  namespace   = "${local.namespace}"
  values = [
    file("${path.module}/charts/qdrant/values.yaml")
      ]

  max_history = 3
  create_namespace = true
  wait             = true
  reset_values     = true
}

resource "helm_release" "kicwa-frontend" {
  name        = "kicwa-frontend"
  chart       = "${path.module}/charts/kicwa-frontend"
  namespace   = "${local.namespace}"
  create_namespace = true

  values = [
    file("${path.module}/charts/kicwa-frontend/values.yaml")
  ]
}

resource "helm_release" "nginx-ingress" {
  name        = "nginx-ingress"
  chart       = "ingress-nginx"
  repository  = "https://kubernetes.github.io/ingress-nginx"
  namespace   = "${local.namespace}"
  force_update = "true"
  version      = "4.7.1"

  set {
    name = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.replicaCount"
    value = 2
  }

  set {
    name = "controller.ingressClassResource.name"
    value = "${local.ingressClass}"
  }
  
  set {
    name  = "controller.ingressClassResource.default"
    value = "true"
  }

  set {
    name  = "service.beta.kubernetes.io/azure-dns-label-name"
    value = "${local.hostname}"
  }

  # set {
  #   name  = "nginx.ingress.kubernetes.io/use-regex"
  #   value = "true"
  # }

  # set {
  #   name  = "nginx.ingress.kubernetes.io/affinity"
  #   value = "cookie"
  # }

  # set {
  #   name  = "nginx.ingress.kubernetes.io/session-cookie-name"
  #   value = "route"
  # }

  # set {
  #   name  = "nginx.ingress.kubernetes.io/session-cookie-hash"
  #   value = "sha1"
  # }

  # set {
  #   name  = "nginx.ingress.kubernetes.io/session-cookie-expires"
  #   value = "172800"
  # }

  # set {
  #   name  = "nginx.ingress.kubernetes.io/session-cookie-max-age"
  #   value = "172800"
  # }

  # set {
  #   name  = "nginx.ingress.kubernetes.io/proxy-connect-timeout"
  #   value = "360"
  # }

  # set {
  #   name  = "nginx.ingress.kubernetes.io/proxy-send-timeout"
  #   value = "360"
  # }

  # set {
  #   name  = "nginx.ingress.kubernetes.io/proxy-read-timeout"
  #   value = "360"
  # }

  # set {
  #   name  = "nginx.ingress.kubernetes.io/proxy-body-size"
  #   value = "2000m"
  # }

  # set {
  #   name  = "nginx.ingress.kubernetes.io/proxy-buffer-size"
  #   value = "32k"
  # }

  # set {
  #   name  = "nginx.ingress.kubernetes.io/ssl-redirect"
  #   value = "true"
  # }

  # set {
  #   name  = "nginx.ingress.kubernetes.io/auth-url"
  #   value = "https://kicwa.westeurope.cloudapp.azure.com/oauth2/auth"
  # }

  # set {
  #   name  = "nginx.ingress.kubernetes.io/auth-signin"
  #   value = "https://kicwa.westeurope.cloudapp.azure.com/oauth2/start?rd=https://kicwa.westeurope.cloudapp.azure.com/oauth2/callback"
  # }

  # set {
  #   name  = "nginx.ingress.kubernetes.io/auth-response-headers"
  #   value = "Authorization,X-Auth-Request-Email,X-Auth-Request-User,X-Forwarded-Access-Token"
  # }

  depends_on = [
    kubernetes_namespace.ns
  ]
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.14.4"
  namespace  = "${local.namespace}"
  
  set {
    name  = "installCRDs"
    value = true
  }

  depends_on = [
    helm_release.nginx-ingress
  ]
}

resource "kubectl_manifest" "ca_issuer" {
  wait = true
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: "${local.namespace}"
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: "${local.ssl_cert_owner_email}"
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: "${local.ingressClass}"
  YAML
  depends_on = [
    helm_release.cert_manager
  ]
}