terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "postgres" {
  name = "postgres:17"
}

resource "docker_container" "postgres" {
  name  = "joyst-postgres-${var.env}"
  image = docker_image.postgres.name
  env = [
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "POSTGRES_DB=${var.postgres_db}"
  ]
  ports {
    internal = 5432
    external = var.port
  }

  networks_advanced {
    name = var.network_name
  }

  volumes {
    container_path = "/docker-entrypoint-initdb.d/"
    host_path      = abspath("${path.root}/../sql/postgres")
    read_only      = true
  }

  restart = "unless-stopped"
}
