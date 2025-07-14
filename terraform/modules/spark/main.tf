terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "spark" {
  name = "ghcr.io/nicosouv/joyst-spark:latest"
}

resource "docker_container" "spark_master" {
  name  = "joyst-spark-master-${var.env}"
  image = docker_image.spark.name

  command = ["/opt/spark/bin/spark-class", "org.apache.spark.deploy.master.Master"]

  ports {
    internal = 8080
    external = var.ui_port
  }

  ports {
    internal = 7077
    external = var.master_rpc_port
  }

  networks_advanced {
    name = var.network_name
  }

  restart = "unless-stopped"
}

resource "docker_container" "spark_worker" {
  name  = "joyst-spark-worker-1-${var.env}"
  image = docker_image.spark.name

  command = [
    "/opt/spark/bin/spark-class",
    "org.apache.spark.deploy.worker.Worker",
    "spark://joyst-spark-master-${var.env}:7077"
  ]

  env = [
    "SPARK_WORKER_MEMORY=4g"
  ]

  networks_advanced {
    name = var.network_name
  }

  memory      = 4294967296
  memory_swap = 4294967296

  restart = "unless-stopped"

  depends_on = [docker_container.spark_master]
}
