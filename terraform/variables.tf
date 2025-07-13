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
  default = 8080
}

variable "spark_rpc_port" {
  default = 7077
}
