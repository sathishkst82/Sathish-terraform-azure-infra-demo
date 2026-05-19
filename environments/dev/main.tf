provider "azurerm" {
  features {}
}

locals {
  environment = "dev"
  region      = "eastus"
  cidr_map = {
    dev  = "10.10.0.0/16"
    uat  = "10.15.0.0/16"
    prod = "10.20.0.0/16"
  }
  common_tags = {
    Environment = upper("dev")
    Project     = var.project
    ManagedBy   = "Terraform"
    Owner       = var.owner
    CostCenter  = var.cost_center
    Region      = local.region
    Application = "platform"
  }
  env_tags = merge(local.common_tags, { Workload = "infra" })

  subnets = {
    "management-subnet"       = { address_prefixes = [cidrsubnet(local.cidr_map[local.environment], 8, 1)], nsg_name = "nsg-mgmt-dev" }
    "application-subnet"      = { address_prefixes = [cidrsubnet(local.cidr_map[local.environment], 8, 2)], nsg_name = "nsg-app-dev" }
    "data-subnet"             = { address_prefixes = [cidrsubnet(local.cidr_map[local.environment], 8, 3)], nsg_name = "nsg-data-dev" }
    "private-endpoint-subnet" = { address_prefixes = [cidrsubnet(local.cidr_map[local.environment], 8, 4)] }
    "future-reserved-subnet"  = { address_prefixes = [cidrsubnet(local.cidr_map[local.environment], 8, 5)] }
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-opella-dev-eastus"
  location = local.region
  tags     = local.env_tags
}

module "vnet" {
  source              = "../../modules/vnet"
  resource_group_name = azurerm_resource_group.this.name
  location            = local.region
  vnet_name           = "vnet-opella-dev-eastus"
  address_space       = [local.cidr_map[local.environment]]
  subnets             = local.subnets
  tags                = local.env_tags
}

module "vm" {
  source              = "../../modules/vm"
  resource_group_name = azurerm_resource_group.this.name
  location            = local.region
  subnet_id           = module.vnet.subnet_ids["application-subnet"]
  tags                = local.env_tags
  vms = {
    "vm-opella-dev-eastus-001" = {
      size           = "Standard_B2s"
      admin_username = var.vm_admin_username
      admin_password = var.vm_admin_password
    }
  }
}

module "storage" {
  source              = "../../modules/storage"
  resource_group_name = azurerm_resource_group.this.name
  location            = local.region
  name_prefix         = "stopelladeveus"
  containers          = ["tfstate", "app", "logs"]
  tags                = local.env_tags
}

module "governance" {
  source            = "../../modules/governance"
  resource_group_id = azurerm_resource_group.this.id
  allowed_locations = [local.region]
  tags              = local.env_tags
  depends_on        = [azurerm_resource_group.this]
}
