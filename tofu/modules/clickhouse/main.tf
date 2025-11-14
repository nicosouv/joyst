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

# Execute ClickHouse SQL files after container is healthy
resource "null_resource" "clickhouse_init" {
  depends_on = [docker_container.clickhouse]

  # Trigger re-run when SQL files change
  triggers = {
    schema_checksum = filemd5("${path.root}/../sql/clickhouse/03_clickhouse_schema.sql")
    seed_checksum   = filemd5("${path.root}/../sql/clickhouse/04_clickhouse_seed_data.sql")
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for ClickHouse to be ready..."
      timeout=60
      while ! curl -f -s http://localhost:${var.http_port}/ping > /dev/null 2>&1; do
        sleep 2
        timeout=$((timeout-2))
        if [ $timeout -le 0 ]; then
          echo "ClickHouse did not start within expected time"
          exit 1
        fi
      done
      
      echo "ClickHouse is ready, executing schema..."
      curl -X POST "http://localhost:${var.http_port}" \
        --data-binary @${path.root}/../sql/clickhouse/03_clickhouse_schema.sql \
        -H "Content-Type: text/plain"
      
      echo "Executing seed data..."
      curl -X POST "http://localhost:${var.http_port}" \
        --data-binary @${path.root}/../sql/clickhouse/04_clickhouse_seed_data.sql \
        -H "Content-Type: text/plain"
      
      echo "ClickHouse initialization complete"
    EOT
  }
}