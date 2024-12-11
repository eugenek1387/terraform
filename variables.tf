// Определяем переменную для Cloud ID
variable "cloud_id" {
  description = "Yandex Cloud cloud_id"
  type        = string
}

// Определяем переменную для папки, в которой будем работать
variable "folder_id" {
  description = "Yandex Cloud folder_id"
  type        = string
}

# variable "service_account" {
#   description = "Service account"
#   type        = string
# }

variable "availability_zone_id" {
  description = "Availability Zone ID"
  type        = string
}

// Определяем переменную для бакетов 
variable "bucket_names" {
  description = "List of necessary buckets"
  type        = map(object({
    acl    = string
    bucket = string
  }))
}