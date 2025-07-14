variable "env" {
  type    = string
  default = "local"
}

variable "postgres_user" {
  type = string
}

variable "postgres_password" {
  type = string
}

variable "postgres_db" {
  type = string
}

variable "postgres_port" {
  type    = number
  default = 5432
}

variable "prefect_ui_port" {
  type    = number
  default = 4200
}
variable "spark_ui_port" {
  type    = number
  default = 8080
}

variable "spark_rpc_port" {
  type    = number
  default = 7077
}

variable "clickhouse_user" {
  type        = string
  description = "ClickHouse username"
  default     = "default"
}

variable "clickhouse_password" {
  type        = string
  description = "ClickHouse password"
  sensitive   = true
}

variable "clickhouse_db" {
  type        = string
  description = "ClickHouse database name"
  default     = "gaming_analytics"
}

variable "clickhouse_http_port" {
  type        = number
  description = "ClickHouse HTTP interface port"
  default     = 8123
}

variable "clickhouse_native_port" {
  type        = number
  description = "ClickHouse native TCP port"
  default     = 9000
}
