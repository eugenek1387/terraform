output "static_ip_address" {
  value = yandex_vpc_address.static_ip.external_ipv4_address[0].address
}