variable "env" {
  description = "Environment (e.g., local, dev, prod)"
  type        = string
}

variable "network_name" {
  description = "Docker network name"
  type        = string
}

variable "port" {
  description = "External port for Metabase web interface"
  type        = number
  default     = 3000
}

variable "metabase_secret_key" {
  description = "Secret key for Metabase encryption"
  type        = string
  sensitive   = true
  default     = "your-secret-key-here-change-me"
}

variable "postgres_container_name" {
  description = "PostgreSQL container name for dependency"
  type        = string
}

variable "clickhouse_container_name" {
  description = "ClickHouse container name for dependency"
  type        = string
}