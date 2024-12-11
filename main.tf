// Создаем сервисный аккаунт
resource "yandex_iam_service_account" "sa" {
  name      = "administrator"
  folder_id = var.folder_id
}

# // Раздаем аккаунту права уровня admin
# resource "yandex_resourcemanager_folder_iam_member" "sa-admin" {
#   role      = "storage.admin"
#   member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
#   folder_id = var.folder_id
# }


// Создаем сеть
resource "yandex_vpc_network" "project-vpc" {
  name      = "project-network"
  folder_id = var.folder_id
}

// Создаем subnet
resource "yandex_vpc_subnet" "project-subnet" {
  name           = "project-subnet-main"
  v4_cidr_blocks = ["10.2.0.0/16"]
  zone           = var.availability_zone_id
  network_id     = yandex_vpc_network.project-vpc.id
  folder_id      = var.folder_id
}

// Создаем security groups (пока одну, без ограничений)
resource "yandex_vpc_security_group" "sg-allow-all" {
  name        = "Default-SG"
  description = "Allows all incoming and outgoing traffic"
  network_id  = yandex_vpc_network.project-vpc.id
  folder_id   = var.folder_id

  labels = {
    my-label = "project-sc"
  }

  ingress {
    protocol       = "ANY"
    description    = "Allows all Incoming traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Allows all Outgoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


// Создаем container registry
resource "yandex_container_registry" "my-container-registry" {
  name      = "project-container-registry"
  folder_id = var.folder_id

  labels = {
    my-label = "project-container-registry"
  }
}

# // Шарим права 
# resource "yandex_container_registry_iam_binding" "puller" {
#   registry_id = yandex_container_registry.your-registry.id
#   role        = "container-registry.images.puller"

#   members = [
#     "system:allUsers",
#   ]
# }

// Создаем доменную зону
resource "yandex_dns_zone" "jk-lab" {
  name        = "jk-lab"
  folder_id = var.folder_id
  description = "DNS zone for my project"
  zone        = "jk-lab.ru."
  public     = true
}

// Создаем статический публичный IP-адрес
resource "yandex_vpc_address" "static_ip" {
  name = "ingress-static-ip"
  folder_id = var.folder_id
  external_ipv4_address {
    zone_id = var.availability_zone_id
  }
}

// Создаем А-запись в доменной зоне
resource "yandex_dns_recordset" "static_ip_a_record" {
  zone_id = yandex_dns_zone.jk-lab.id 
  name    = "ingress"
  type    = "A"
  ttl     = 300
  data = [yandex_vpc_address.static_ip.external_ipv4_address[0].address]
}


