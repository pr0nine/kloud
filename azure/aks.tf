resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  location            = var.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  dns_prefix          = var.cluster_name
  role_based_access_control_enabled = true
  default_node_pool {
    name                = "system"
    vm_size             = var.vm_size
    type                = "VirtualMachineScaleSets"
    zones  = [1, 2, 3]
    vnet_subnet_id = azurerm_subnet.private_subnet_1.id
    node_public_ip_enabled = false

  # If autoscaling is FALSE, we need a fixed node_count. If TRUE node_count is ignored
    node_count = var.autoscaling ? null : var.node_count
    
  # Toggle auto_scaling on or off
    auto_scaling_enabled = var.autoscaling
  # If autoscaling is ON, set min/max. If OFF, these must be null.
    min_count = var.autoscaling ? var.node_count_min : null
    max_count = var.autoscaling ? var.node_count_max : null
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet"
    network_policy    = "calico"
    pod_cidr          = "192.168.0.0/16"
    outbound_type     = "userAssignedNATGateway"
  }

  # Ensure the cluster is NOT private (Public Control Plane)
  private_cluster_enabled = false

  # Whitelist specific IPs for API Server access
  api_server_access_profile {
    authorized_ip_ranges = [var.admin_cidr]
  }

  depends_on = [
    azurerm_subnet_nat_gateway_association.private_1_assoc
  ]
}

# Role Assignment
resource "azurerm_role_assignment" "aks_subnet_permission" {
    # The scope is the specific existing subnet
    scope                = azurerm_subnet.private_subnet_1.id
  
    # This role allows the cluster to manage IP addresses in the subnet
    role_definition_name = "Network Contributor"
  
    # Grant this permission to the AKS System Assigned Identity
    principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
