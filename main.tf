terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

provider "docker" {}

# Pull Nginx Image
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

# Pull PostgreSQL Image
resource "docker_image" "postgres" {
  name         = "postgres:15"
  keep_locally = false
}

# Volume for PostgreSQL
resource "docker_volume" "postgres_data" {}

# Run Nginx Container
resource "docker_container" "nginx" {
  image = docker_image.nginx.name
  name  = "terraform-nginx"
  ports {
    internal = 80
    external = 8080
  }
  mounts {
    type   = "bind"
    source = "/Users/jcalvosu/Desktop/html"
    target = "/usr/share/nginx/html"
  }
}

# Run PostgreSQL Container
resource "docker_container" "postgres" {
  image = docker_image.postgres.name
  name  = "terraform-postgres"
  env = [
    "POSTGRES_USER=terraform",
    "POSTGRES_PASSWORD=terraform",
    "POSTGRES_DB=terraformdb"
  ]
  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }
  ports {
    internal = 5432
    external = 5432
  }
}
