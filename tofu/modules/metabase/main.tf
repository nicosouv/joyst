terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "metabase" {
  name = "metabase/metabase:v0.55.x"
}

resource "docker_container" "metabase" {
  name  = "joyst-metabase-${var.env}"
  image = docker_image.metabase.name

  env = [
    "MB_DB_TYPE=h2",
    "MB_DB_FILE=/metabase-data/metabase.db",
    "MB_ENCRYPTION_SECRET_KEY=${var.metabase_secret_key}",
    "JAVA_OPTS=-Xmx1g"
  ]

  ports {
    internal = 3000
    external = var.port
  }

  networks_advanced {
    name = var.network_name
  }

  volumes {
    container_path = "/metabase-data"
    host_path      = abspath("${path.root}/metabase-data")
  }

  restart = "unless-stopped"

  # Health check
  healthcheck {
    test         = ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
    interval     = "30s"
    timeout      = "10s"
    retries      = 5
    start_period = "60s"
  }

  # Wait for databases to be ready
  depends_on = [var.postgres_container_name, var.clickhouse_container_name]
}