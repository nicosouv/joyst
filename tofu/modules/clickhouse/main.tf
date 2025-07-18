terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "clickhouse" {
  name = "clickhouse/clickhouse-server:25.3"
}

resource "docker_container" "clickhouse" {
  name  = "joyst-clickhouse-${var.env}"
  image = docker_image.clickhouse.name

  env = [
    "CLICKHOUSE_DB=${var.clickhouse_db}",
    "CLICKHOUSE_USER=${var.clickhouse_user}",
    "CLICKHOUSE_PASSWORD=${var.clickhouse_password}",
    "CLICKHOUSE_DEFAULT_ACCESS_MANAGEMENT=1"
  ]

  ports {
    internal = 8123
    external = var.http_port
  }

  ports {
    internal = 9000
    external = var.native_port
  }

  networks_advanced {
    name = var.network_name
  }

  volumes {
    container_path = "/docker-entrypoint-initdb.d/"
    host_path      = abspath("${path.root}/../sql/clickhouse")
    read_only      = true
  }

  volumes {
    container_path = "/var/lib/clickhouse"
    host_path      = abspath("${path.root}/clickhouse-data")
  }

  restart = "unless-stopped"

  # Health check
  healthcheck {
    test     = ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8123/ping"]
    interval = "30s"
    timeout  = "5s"
    retries  = 3
  }
}