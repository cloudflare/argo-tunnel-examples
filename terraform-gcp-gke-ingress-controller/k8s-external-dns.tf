resource "kubernetes_namespace" "external_dns" {
  metadata {
    name        = "external-dns"
    annotations = {}
    labels      = {}
  }
}

resource "helm_release" "external_dns" {
  name = "external-dns"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"

  namespace = kubernetes_namespace.external_dns.metadata[0].name

  set {
    name  = "provider"
    value = "cloudflare"
  }

  set {
    name  = "cloudflare.secretName"
    value = kubernetes_secret.external_dns.metadata[0].name
  }

  set {
    name  = "zoneIdFilters.${local.cloudflare_zone_id}"
    value = local.cloudflare_zone_id
  }

  set {
    name  = "policy"
    value = "sync"
  }
}

resource "kubernetes_secret" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = kubernetes_namespace.external_dns.metadata[0].name
  }

  data = {
    "cloudflare_api_token" = cloudflare_api_token.zone_dns_edit.value
  }

  type = "kubernetes.io/secret"
}
