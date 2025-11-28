resource "azurerm_kubernetes_cluster" "aks" {
  for_each            = var.aks_clusters
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  dns_prefix          = each.value.dns_prefix

  default_node_pool {
    name       = each.value.default_node_pool.name
    node_count = each.value.default_node_pool.node_count
    vm_size    = each.value.default_node_pool.vm_size
  }

  identity {
    type = try(each.value.identity.type, "SystemAssigned")
  }
  network_profile {
    network_plugin    = each.value.network_profile.network_plugin
    load_balancer_sku = each.value.network_profile.load_balancer_sku
  }

  tags = {
    Environment = each.value.tags.Environment
    Project     = each.value.tags.Project
  }
}


