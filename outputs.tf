output "cantaloupe_service_port" {
  value = kubernetes_service.cantaloupe.spec[0].port[0].port
}

output "cantaloupe_service_name" {
  value = kubernetes_service.cantaloupe.metadata[0].name
}
