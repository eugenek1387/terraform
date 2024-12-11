// Раздаем аккаунту sa права уровня k8s.admin
resource "yandex_resourcemanager_folder_iam_member" "sa-k8s-admin" {
  role      = "k8s.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "sa-iam-service-account-user" {
  role      = "iam.serviceAccounts.user"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
  folder_id = var.folder_id
}

// Раздаем аккаунту sa права уровня compute.admin
resource "yandex_resourcemanager_folder_iam_member" "sa-compute-admin" {
  role      = "compute.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
  folder_id = var.folder_id
}

// Раздаем аккаунту sa права уровня vpc.admin
resource "yandex_resourcemanager_folder_iam_member" "sa-vpc-admin" {
  role      = "vpc.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
  folder_id = var.folder_id
}

// Раздаем аккаунту sa права на управление load balancer
resource "yandex_resourcemanager_folder_iam_member" "sa-lb-admin" {
  role      = "load-balancer.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
  folder_id = var.folder_id
}

// Раздаем аккаунту sa права уровня container-registry.admin
resource "yandex_resourcemanager_folder_iam_member" "sa-cr-admin" {
  role      = "container-registry.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
  folder_id = var.folder_id
}


//==================================================================


// Создаем Kubernetes-кластер
resource "yandex_kubernetes_cluster" "k8s-cluster" {
  name               = "k8s-cluster-for-project"
  description        = "Testing cluster in Yandex.Cloud"
  network_id         = yandex_vpc_network.project-vpc.id
  service_account_id = yandex_iam_service_account.sa.id
  folder_id          = var.folder_id

  master {
    version = 1.27

    zonal {
      zone      = yandex_vpc_subnet.project-subnet.zone
      subnet_id = yandex_vpc_subnet.project-subnet.id
    }

    public_ip = true

    security_group_ids = ["${yandex_vpc_security_group.sg-allow-all.id}"]
  }

  node_service_account_id = yandex_iam_service_account.sa.id

}

// Создаем группу нод кластера (здесь - одну worker node)
resource "yandex_kubernetes_node_group" "k8s-node-group" {
  cluster_id  = yandex_kubernetes_cluster.k8s-cluster.id
  name        = "k8s-node-group"
  description = "Kubernetes worker node"

  instance_template {

    platform_id = "standard-v1"

    resources {
      memory = 8
      cores  = 2
    }

    network_interface {
      nat        = true
      subnet_ids = [yandex_vpc_subnet.project-subnet.id]
    }

    boot_disk {
      # image_id = "fd8d3no0q3mu3tjvtf5h"  # ID образа ОС
      type = "network-hdd"
      size = 40
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }
}
