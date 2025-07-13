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
