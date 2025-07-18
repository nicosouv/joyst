output "postgres_container_name" {
  description = "Name of the PostgreSQL container"
  value       = docker_container.postgres.name
}

output "postgres_connection_url" {
  description = "PostgreSQL connection URL"
  value       = "postgresql://${var.postgres_user}:${var.postgres_password}@localhost:${var.port}/${var.postgres_db}"
  sensitive   = true
}

output "postgres_internal_url" {
  description = "Internal PostgreSQL connection URL for container-to-container communication"
  value       = "postgresql://${var.postgres_user}:${var.postgres_password}@${docker_container.postgres.name}:5432/${var.postgres_db}"
  sensitive   = true
}
