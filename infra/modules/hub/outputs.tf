output "hub_vnet_id" {
  value = module.hub_vnet.vnet_id
}

output "hub_vnet_name" {
  value = module.hub_vnet.vnet_name
}

output "hub_rg_name" {
  value = azurerm_resource_group.hub_rg.name
}

output "vm_private_ip_address" {
  value = module.hub_vm.private_ip_address
}

output "fw_vip" {
  value = module.hub_fw.fw_vip
}

output "privatelink_storageblob_dns_zone_name" {
  value = module.hub_dns.privatelink_storageblob_dns_zone_name
}