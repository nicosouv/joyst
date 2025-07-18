variable "env" {
  description = "Environnement (ex: local, preprod, prod)"
  type        = string
}

variable "network_name" {
  description = "Nom du réseau Docker"
  type        = string
}

variable "ui_port" {
  description = "Port externe de l'UI Spark (8080)"
  type        = number
  default     = 8080
}

variable "master_rpc_port" {
  description = "Port RPC Spark Master (7077)"
  type        = number
  default     = 7077
}
