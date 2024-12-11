// Раздаем аккаунту sa права уровня storage.admin
resource "yandex_resourcemanager_folder_iam_member" "sa-storage-admin" {
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
  folder_id = var.folder_id
}

// Создаем static access key для бакетов
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

// Создаем бакеты
resource "yandex_storage_bucket" "project-bucket" {
  for_each = var.bucket_names

  bucket = each.value.bucket
  acl    = each.value.acl
  
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key

  folder_id = var.folder_id

#   versioning {
#     enabled = true
#   }
}
