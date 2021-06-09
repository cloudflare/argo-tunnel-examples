resource "kubernetes_namespace" "docker_helloworld" {
  metadata {
    name        = "docker-helloworld"
    annotations = {}
    labels      = {}
  }
}

resource "kubernetes_deployment" "docker_helloworld" {
  metadata {
    name      = "docker-helloworld"
    namespace = kubernetes_namespace.docker_helloworld.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "docker-helloworld"
      }
    }

    template {
      metadata {
        labels = {
          app = "docker-helloworld"
        }
      }

      spec {
        container {
          image = "karthequian/helloworld:latest"
          name  = "docker-helloworld"
        }
      }
    }
  }
}

resource "kubernetes_service" "docker_helloworld" {
  metadata {
    name      = "docker-helloworld"
    namespace = kubernetes_namespace.docker_helloworld.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment.docker_helloworld.spec[0].template[0].metadata[0].labels.app
    }

    port {
      protocol = "TCP"
      port     = 80
    }
  }
}

resource "kubernetes_ingress" "docker_helloworld" {
  metadata {
    name      = "docker-helloworld"
    namespace = kubernetes_namespace.docker_helloworld.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" : "nginx"

      # this is important, sets correct CNAME to the Cloudflare Tunnel record
      "external-dns.alpha.kubernetes.io/target" = cloudflare_record.gke_tunnel.hostname
    }
  }
  spec {
    rule {
      host = "docker-helloworld.${var.cloudflare_zone}"
      http {
        path {
          backend {
            service_name = kubernetes_service.docker_helloworld.metadata[0].name
            service_port = 80
          }
        }
      }
    }
  }
}
