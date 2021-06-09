resource "kubernetes_namespace" "httpbin" {
  metadata {
    name        = "httpbin"
    annotations = {}
    labels      = {}
  }
}

resource "kubernetes_deployment" "httpbin" {
  metadata {
    name      = "httpbin"
    namespace = kubernetes_namespace.httpbin.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "httpbin"
      }
    }

    template {
      metadata {
        labels = {
          app = "httpbin"
        }
      }

      spec {
        container {
          image = "kennethreitz/httpbin:latest"
          name  = "httpbin"
        }
      }
    }
  }
}

resource "kubernetes_service" "httpbin" {
  metadata {
    name      = "httpbin"
    namespace = kubernetes_namespace.httpbin.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment.httpbin.spec[0].template[0].metadata[0].labels.app
    }

    port {
      protocol = "TCP"
      port     = 80
    }
  }
}

resource "kubernetes_ingress" "httpbin" {
  metadata {
    name      = "httpbin"
    namespace = kubernetes_namespace.httpbin.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" : "nginx"

      # this is important, sets correct CNAME to the Cloudflare Tunnel record
      "external-dns.alpha.kubernetes.io/target" = cloudflare_record.gke_tunnel.hostname
    }
  }
  spec {
    rule {
      host = "httpbin.${var.cloudflare_zone}"
      http {
        path {
          backend {
            service_name = kubernetes_service.httpbin.metadata[0].name
            service_port = 80
          }
        }
      }
    }
  }
}
