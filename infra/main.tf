terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.67.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "crgar-aca-terraform-rg"
    storage_account_name = "crgaracaterraformstor"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
}

locals {
  weu_hub_ars_bgp_peer_asn = 65111
  eus_hub_ars_bgp_peer_asn = 65222
}

#################################
#           hub-eus
#################################
module "hub-eus" {
  source          = "./modules/hub"
  prefix          = "${var.prefix}-eus-hub"
  location        = "eastus"
  ip_second_octet = "222"
  ssh_username    = var.SSH_USERNAME
  ssh_password    = var.SSH_PASSWORD
}

#################################
#           Spoke-EUS
#################################
module "spoke_eus_s1" {
  source                                = "./modules/spoke"
  prefix                                = "${var.prefix}-eus-s1"
  location                              = "eastus"
  ip_second_octet                       = "223"
  hub_vnet_name                         = module.hub-eus.hub_vnet_name
  hub_vnet_id                           = module.hub-eus.hub_vnet_id
  hub_rg_name                           = module.hub-eus.hub_rg_name
  ssh_username                          = var.SSH_USERNAME
  ssh_password                          = var.SSH_PASSWORD
  fw_vip                                = module.hub-eus.fw_vip
  privatelink_storageblob_dns_zone_name = module.hub-eus.privatelink_storageblob_dns_zone_name
  depends_on = [
    module.hub-eus
  ]
}


#################################
#           Hub Peerings
#################################

# resource "azurerm_virtual_network_peering" "hub-hubweu" {
#   name                      = "hub-hubweu"
#   resource_group_name       = module.hub-eus.hub_rg_name
#   virtual_network_name      = module.hub-eus.hub_vnet_name
#   remote_virtual_network_id = module.hub_weu.hub_vnet_id
# }

# resource "azurerm_virtual_network_peering" "hubweu-hub" {
#   name                      = "hubweu-hub"
#   resource_group_name       = module.hub_weu.hub_rg_name
#   virtual_network_name      = module.hub_weu.hub_vnet_name
#   remote_virtual_network_id = module.hub-eus.hub_vnet_id
# }
