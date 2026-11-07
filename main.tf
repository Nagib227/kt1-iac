# 1. Спецификация требуемых провайдеров (плагинов)
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {}

# 2. Входные переменные: внешние порты и имена контейнеров
variable "web_port" {
  description = "Внешний порт для веб-сервера Nginx"
  type        = number
  default     = 8080
}

variable "web_container_name" {
  description = "Имя контейнера Nginx"
  type        = string
  default     = "my_first_iac_server"
}

variable "db_port" {
  description = "Внешний порт для Apache CouchDB"
  type        = number
  default     = 5984
}

variable "db_container_name" {
  description = "Имя контейнера CouchDB"
  type        = string
  default     = "student_database"
}

# 3. Образ и контейнер веб-сервера Nginx
resource "docker_image" "nginx_image" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx_server" {
  image = docker_image.nginx_image.image_id
  name  = var.web_container_name

  ports {
    internal = 80
    external = var.web_port
  }
}

# 4. Образ и контейнер базы данных Apache CouchDB
resource "docker_image" "couchdb_image" {
  name         = "couchdb:3.3"
  keep_locally = false
}

resource "docker_container" "couchdb_server" {
  image = docker_image.couchdb_image.image_id
  name  = var.db_container_name

  ports {
    internal = 5984
    external = var.db_port
  }

  env = [
    "COUCHDB_USER=admin",
    "COUCHDB_PASSWORD=password_student"
  ]
}

# 5. Выходные данные: готовые URL после развёртывания
output "web_server_url" {
  description = "Ссылка на веб-интерфейс Nginx"
  value       = "http://localhost:${var.web_port}"
}

output "couchdb_admin_url" {
  description = "Ссылка на админ-панель CouchDB"
  value       = "http://localhost:${var.db_port}/_utils/"
}
