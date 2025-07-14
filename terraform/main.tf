module "network" {
  source = "./modules/network"
  env    = var.env

  providers = {
    docker = docker
  }
}

module "postgres" {
  source            = "./modules/postgres"
  env               = var.env
  network_name      = module.network.network_name
  postgres_user     = var.postgres_user
  postgres_password = var.postgres_password
  postgres_db       = var.postgres_db
  port              = var.postgres_port

  providers = {
    docker = docker
  }
}

module "prefect" {
  source       = "./modules/prefect"
  env          = var.env
  network_name = module.network.network_name
  ui_port      = var.prefect_ui_port

  providers = {
    docker = docker
  }
}

module "spark" {
  source          = "./modules/spark"
  env             = var.env
  network_name    = module.network.network_name
  ui_port         = var.spark_ui_port
  master_rpc_port = var.spark_rpc_port

  providers = {
    docker = docker
  }
}

module "clickhouse" {
  source              = "./modules/clickhouse"
  env                 = var.env
  network_name        = module.network.network_name
  clickhouse_user     = var.clickhouse_user
  clickhouse_password = var.clickhouse_password
  clickhouse_db       = var.clickhouse_db
  http_port           = var.clickhouse_http_port
  native_port         = var.clickhouse_native_port

  providers = {
    docker = docker
  }
}

module "metabase" {
  source                    = "./modules/metabase"
  env                       = var.env
  network_name              = module.network.network_name
  port                      = var.metabase_port
  metabase_secret_key       = var.metabase_secret_key
  postgres_container_name   = module.postgres.postgres_container_name
  clickhouse_container_name = module.clickhouse.clickhouse_container_name

  providers = {
    docker = docker
  }
}
