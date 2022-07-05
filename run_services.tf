terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "2.17.0"
    }
  }
}

resource "docker_image" "mysql" {
  name = "mysql:5.7"
}

resource "docker_image" "web_demo" {
  name = "mmmakarets/web-demo:1.0.2"
}

resource "docker_network" "web_demo" {
  name   = "web-demo-net"
  driver = "bridge"
}

resource "docker_container" "web" {
  image = "${docker_image.web_demo.latest}"
  name  = "web"
  restart = "always"
  networks_advanced {
    name = docker_network.web_demo.name
    aliases = ["web-demo-net"]
}
  ports {
    internal = 80
    external = 80
  }
}

resource "docker_container" "mysql" {
  name = "mysql"
  image = "${docker_image.mysql.latest}"
  env =["MYSQL_ROOT_PASSWORD=Admin1234%", "MYSQL_DATABASE=web_db"]
  mounts {
    source = "/home/mmmakarets/demo/apache-server/dump"
    target = "/docker-entrypoint-initdb.d"
    type = "bind"
  }
  networks_advanced {
    name = docker_network.web_demo.name
    aliases = ["web-demo-net"]
}
  ports {
    internal = 3306
    external = 3306
  }
}
