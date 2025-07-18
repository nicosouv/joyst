variable "env" {
  description = "Environment (e.g., local, dev, prod)"
  type        = string
}

variable "network_name" {
  description = "Docker network name"
  type        = string
}

variable "clickhouse_user" {
  description = "ClickHouse username"
  type        = string
  default     = "default"
}

variable "clickhouse_password" {
  description = "ClickHouse password"
  type        = string
  sensitive   = true
}

variable "clickhouse_db" {
  description = "ClickHouse database name"
  type        = string
  default     = "gaming_analytics"
}

variable "http_port" {
  description = "HTTP interface port (8123)"
  type        = number
  default     = 8123
}

variable "native_port" {
  description = "Native TCP port (9000)"
  type        = number
  default     = 9000
}