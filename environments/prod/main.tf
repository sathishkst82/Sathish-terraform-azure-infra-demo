terraform {
  backend "azurerm" {
    resource_group_name  = "rg-opella-tfstate"
    storage_account_name = "stopellatfstate001"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
}

locals {
  org = "opella"
  env = "prod"
  location = "eastus"
  common_tags = {
    Environment = local.env
    Project     = local.org
    ManagedBy   = "Terraform"
    Owner       = "PlatformTeam"
    Region      = local.location
    CostCenter  = "CC-1001"
  }
  names = {
    rg   = "rg-${local.org}-${local.env}-eastus"
    vnet = "vnet-${local.org}-${local.env}-eastus"
    vm   = "vm-${local.org}-${local.env}-eastus-001"
    sa   = "st${local.org}${local.env}eus001"
  }
}
resource "azurerm_resource_group" "this" {
  name     = local.names.rg
  location = local.location
  tags     = local.common_tags
}
module "vnet" {
  source = "../../modules/vnet"
  resource_group_name = azurerm_resource_group.this.name
  location = local.location
  vnet_name = local.names.vnet
  address_space = ["10.20.0.0/16"]
  tags = merge(local.common_tags, {Workload="network"})
  subnets = {
    management = { name = "management-subnet", address_prefixes = ["10.20.0.0/24"], create_nsg = true }
    application = { name = "application-subnet", address_prefixes = ["10.20.1.0/24"], create_nsg = true }
    data = { name = "data-subnet", address_prefixes = ["10.20.2.0/24"], create_nsg = true }
    privateendpoint = { name = "private-endpoint-subnet", address_prefixes = ["10.20.3.0/24"] }
    future = { name = "future-reserved-subnet", address_prefixes = ["10.20.254.0/24"] }
  }
}
module "storage" {
  source                     = "../../modules/storage"
  resource_group_name        = azurerm_resource_group.this.name
  location                   = local.location
  storage_account_name       = local.names.sa
  containers                 = ["tfstate", "logs", "artifacts"]
  tags                       = local.common_tags
}
module "vm" {
  source = "../../modules/vm"
  resource_group_name = azurerm_resource_group.this.name
  location = local.location
  admin_username = "azureadmin"
  ssh_public_key = var.ssh_public_key
  boot_diagnostics_storage_uri = module.storage.primary_blob_endpoint
  tags = local.common_tags
  vms = { vm1 = { name = local.names.vm, size = "Standard_B2s", subnet_id = module.vnet.subnet_ids["management"], enable_public_ip = false } }
}
module "governance" {
  source = "../../modules/governance"
  resource_group_id = azurerm_resource_group.this.id
  policy_definitions = {
    mandatory-tags = { display_name = "Mandatory Tags", policy_rule = file("../../docs/policies/mandatory-tags.json") }
    allowed-regions = { display_name = "Allowed Regions", policy_rule = file("../../docs/policies/allowed-regions.json"), parameters = file("../../docs/policies/allowed-regions-params.json") }
    deny-public-ip = { display_name = "Deny Public IP", policy_rule = file("../../docs/policies/deny-public-ip.json") }
  }
}
