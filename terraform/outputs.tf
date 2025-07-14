output "postgres_container_name" {
  value = module.postgres.postgres_container_name
}

output "clickhouse_container_name" {
  value = module.clickhouse.clickhouse_container_name
}

output "metabase_url" {
  value = module.metabase.metabase_url
}

output "spark_master_url" {
  value = "http://localhost:${var.spark_ui_port}"
}

output "service_urls" {
  value = {
    metabase    = module.metabase.metabase_url
    spark_ui    = "http://localhost:${var.spark_ui_port}"
    clickhouse  = module.clickhouse.clickhouse_http_url
    postgres    = "postgresql://localhost:${var.postgres_port}"
    prefect     = "http://localhost:${var.prefect_ui_port}"
  }
}
