output "metabase_container_name" {
  description = "Name of the Metabase container"
  value       = docker_container.metabase.name
}

output "metabase_url" {
  description = "Metabase web interface URL"
  value       = "http://localhost:${var.port}"
}

output "metabase_internal_url" {
  description = "Internal Metabase URL for container-to-container communication"
  value       = "http://${docker_container.metabase.name}:3000"
}