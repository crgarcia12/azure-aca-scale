resource "azurerm_resource_group" "spoke_rg" {
  name     = "${var.prefix}-rg"
  location = "westeurope"
}

module "spoke_vnet" {
  source              = "./vnet"
  prefix              = var.prefix
  location            = var.location
  ip_second_octet     = var.ip_second_octet
  resource_group_name = azurerm_resource_group.spoke_rg.name
  hub_vnet_rg_name    = var.hub_rg_name
  hub_vnet_id         = var.hub_vnet_id
  hub_vnet_name       = var.hub_vnet_name
  fw_vip              = var.fw_vip
}

module "spoke_vm" {
  count               = 0
  source              = "./vm"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke_rg.name
  subnet_id           = module.spoke_vnet.vnet_vm_subnet_id
  ssh_username        = var.ssh_username
  ssh_password        = var.ssh_password
}

module "aks" {
  count               = 0
  source              = "./aks"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke_rg.name
  resource_group_id   = azurerm_resource_group.spoke_rg.id
  subnet_id           = module.spoke_vnet.vnet_aks_subnet_id
  network_plugin_mode = var.aks_network_plugin_mode
  ebpf_data_plane     = var.aks_ebpf_data_plane
}

module "appinsights" {
  source              = "./appinsights"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke_rg.name
}

module "storage" {
  source                                = "./storage"
  prefix                                = var.prefix
  location                              = var.location
  resource_group_name                   = azurerm_resource_group.spoke_rg.name
  subnet_id                             = module.spoke_vnet.vnet_stor_subnet_id
  privatelink_storageblob_dns_zone_name = var.privatelink_storageblob_dns_zone_name
  storage_dns_zone_rg                   = var.hub_rg_name
}

module "acr" {
  source              = "./acr"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke_rg.name
}

module "aca" {
  source                       = "./aca"
  prefix                       = var.prefix
  location                     = var.location
  resource_group_name          = azurerm_resource_group.spoke_rg.name
  storage_name                 = module.storage.storage_name
  storage_key                  = module.storage.storage_key
  storage_queue_url            = module.storage.storage_queue_url
  storage_id                   = module.storage.storage_id
  appinsights_key              = module.appinsights.instrumentation_key
  appinsights_connectionstring = module.appinsights.connection_string
  acr_id                       = module.acr.acr_id
  acr_url                      = module.acr.acr_url
  acr_username                 = module.acr.acr_username
  acr_password                 = module.acr.acr_password
  loganalytics_id              = module.appinsights.loganalytics_id
  subnet_id                    = module.spoke_vnet.vnet_aca_subnet_id

}