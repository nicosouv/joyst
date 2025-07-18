terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_network" "joyst_net" {
  name = "joyst-${var.env}-net"
}

output "network_name" {
  value = docker_network.joyst_net.name
}
