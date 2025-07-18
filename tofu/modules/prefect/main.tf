terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}
resource "docker_image" "prefect" {
  name = "prefecthq/prefect:3-latest"
}

resource "docker_container" "prefect_server" {
  name    = "joyst-prefect-${var.env}"
  image   = docker_image.prefect.name
  restart = "unless-stopped"

  ports {
    internal = 4200
    external = var.ui_port
  }

  command = [
    "prefect", "server", "start", "--host", "0.0.0.0"
  ]

  networks_advanced {
    name = var.network_name
  }

  # optional: clean previous on redeploy
  must_run = true
}
