output "clickhouse_container_name" {
  description = "Name of the ClickHouse container"
  value       = docker_container.clickhouse.name
}

output "clickhouse_http_url" {
  description = "ClickHouse HTTP interface URL"
  value       = "http://localhost:${var.http_port}"
}

output "clickhouse_native_url" {
  description = "ClickHouse native TCP connection"
  value       = "clickhouse://localhost:${var.native_port}/${var.clickhouse_db}"
}

output "clickhouse_internal_http_url" {
  description = "Internal HTTP URL for container-to-container communication"
  value       = "http://${docker_container.clickhouse.name}:8123"
}

output "clickhouse_internal_native_url" {
  description = "Internal native TCP URL for container-to-container communication"
  value       = "clickhouse://${docker_container.clickhouse.name}:9000/${var.clickhouse_db}"
}