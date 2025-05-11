output "service_public_ip" {
  value = azurerm_public_ip.app_lb.ip_address
}
