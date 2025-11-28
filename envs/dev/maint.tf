module "infra_resource_group" {
  source = "../../modules/azurerm_resource_group"
  rgs    = var.rgs
}

module "networks" {
    source     = "../../modules/Network"
    networks   = var.networks
    depends_on = [ module.infra_resource_group ]
  
}

module "sql_server" {
  source          = "../../modules/azurerm_mssql_server"
  sql_server_name = "sql-dev-todoapp-9879"
  rg_name         = "todo_Infra_rg01"
  location        = "centralindia"
  admin_username  = "shyamubhagat"
  admin_password  = "Admin@1234"
  depends_on = [ module.infra_resource_group ]
}


module "sql_db" {
  depends_on  = [module.sql_server]
  source      = "../../modules/azurerm_mssql_database"
  sql_db_name = "sqldb-dev-todoapp"
  server_id   = module.sql_server.server_id
  max_size_gb = "2"
}

module "key_vault" {
  source     = "../../modules/azurerm_key_vault"
  key_vaults = var.key_vaults
  depends_on = [ module.infra_resource_group ]

}

module "comput" {
    source = "../../modules/Comput"
    vms = var.vms
    depends_on = [ module.infra_resource_group, module.networks ]

    subnet_id = module.networks.subnet_ids["vnet1"]
}


module "bastion" {
  source     = "../../modules/azurerm_bastion_host"
  bastions   = var.bastions
  subnet_ids = module.networks.AzureBastionSubnet_ids
  pip_ids    = module.networks.public_ip_ids
  depends_on = [ module.networks ]
}

module "aks_cluster" {
  source       = "../../modules/azurerm_kubernetes_cluster"
  aks_clusters = var.aks_clusters
  depends_on   = [ module.infra_resource_group, module.networks ]
}

module "acr" {
    source = "../../modules/azurerm_container_registry"
    acr_registries = var.acr_registries
    depends_on = [ module.infra_resource_group ]
  
}