variable "env" {
  type = string
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

variable "port" {
  type    = number
  default = 5432
}

variable "network_name" {
  type = string
}
