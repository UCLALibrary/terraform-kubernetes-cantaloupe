resource "kubernetes_deployment" "cantaloupe" {
  metadata {
    name = var.cantaloupe_deployment_name
    namespace = var.cantaloupe_deployment_namespace
    labels = var.cantaloupe_deployment_labels
  }

  spec {
    replicas = var.cantaloupe_deployment_replicas

    selector {
      match_labels = var.cantaloupe_deployment_labels
    }

    template {
      metadata {
        labels = var.cantaloupe_deployment_labels
      }

      spec {
        image_pull_secrets {
          name = var.image_pull_secrets
        }

        container {
          command = ["docker-entrypoint.sh"]
          args = ["sh", "-c", "java -Dcantaloupe.config=$CONFIG_FILE -jar /usr/local/cantaloupe/cantaloupe-*.war"]
          image = local.cantaloupe_deployment_container_image_full_url
          name  = var.cantaloupe_deployment_container_name
          image_pull_policy = var.cantaloupe_deployment_container_image_pull_policy

          resources {
            limits {
              cpu = var.cantaloupe_deployment_cpu_limit
              memory = var.cantaloupe_deployment_memory_limit
            }
            requests {
              cpu = var.cantaloupe_deployment_cpu_request
              memory = var.cantaloupe_deployment_memory_request
            }
          }

          port {
            container_port = var.cantaloupe_deployment_container_port
          }

          dynamic "env" {
            for_each = var.cantaloupe_deployment_container_env

            content {
              name = env.key
              value = env.value
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.cantaloupe_env_secrets.metadata[0].name != null ? kubernetes_secret.cantaloupe_env_secrets.metadata[0].name : null
            }
          }

          liveness_probe {
            http_get {
              path = "/iiif/2"
              port = var.cantaloupe_deployment_container_port
            }

            initial_delay_seconds = 15
            period_seconds        = 20
          }

          readiness_probe {
            tcp_socket {
              port = var.cantaloupe_deployment_container_port
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
}
