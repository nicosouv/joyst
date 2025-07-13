output "spark_master_name" {
  value = docker_container.spark_master.name
}

output "spark_worker_name" {
  value = docker_container.spark_worker.name
}

output "spark_ui_url" {
  value = "http://localhost:${var.ui_port}"
}
