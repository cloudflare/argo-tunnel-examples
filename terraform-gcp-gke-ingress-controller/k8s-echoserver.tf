resource "kubernetes_namespace" "echoserver" {
  metadata {
    name        = "echoserver"
    annotations = {}
    labels      = {}
  }
}

resource "kubernetes_deployment" "echoserver" {
  metadata {
    name      = "echoserver"
    namespace = kubernetes_namespace.echoserver.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "echoserver"
      }
    }

    template {
      metadata {
        labels = {
          app = "echoserver"
        }
      }

      spec {
        container {
          image = "k8s.gcr.io/echoserver:1.4"
          name  = "echoserver"
        }
      }
    }
  }
}

resource "kubernetes_service" "echoserver" {
  metadata {
    name      = "echoserver"
    namespace = kubernetes_namespace.echoserver.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment.echoserver.spec[0].template[0].metadata[0].labels.app
    }

    port {
      protocol = "TCP"
      port     = 8080
    }
  }
}

resource "kubernetes_ingress" "echoserver" {
  metadata {
    name      = "echoserver"
    namespace = kubernetes_namespace.echoserver.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" : "nginx"

      # this is important, sets correct CNAME to the Cloudflare Tunnel record
      "external-dns.alpha.kubernetes.io/target" = cloudflare_record.gke_tunnel.hostname
    }
  }
  spec {
    rule {
      host = "echoserver.${var.cloudflare_zone}"
      http {
        path {
          backend {
            service_name = kubernetes_service.echoserver.metadata[0].name
            service_port = 8080
          }
        }
      }
    }
  }
}
