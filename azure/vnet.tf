resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-vnet"
  location            = azurerm_resource_group.aks-rg.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  address_space       = ["10.0.0.0/24"]
}

# Public Subnet 
resource "azurerm_subnet" "public_subnet_1" {
  name                 = "public-subnet-1"
  resource_group_name  = azurerm_resource_group.aks-rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.0.0.0/26"]
}

# Private Subnets 
resource "azurerm_subnet" "private_subnet_1" {
  name                 = "private-subnet-1"
  resource_group_name  = azurerm_resource_group.aks-rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.0.0.64/26"]
}
# Public IP for NAT Gateway 
resource "azurerm_public_ip" "nat_pip" {
  name                = "nat-gateway-public-ip"
  location            = azurerm_resource_group.aks-rg.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
# NAT Gateway 
resource "azurerm_nat_gateway" "aks_nat_gw" {
  name                = "aks-nat-gateway"
  location            = azurerm_resource_group.aks-rg.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  sku_name            = "Standard"
}
resource "azurerm_nat_gateway_public_ip_association" "nat_chain" {
  nat_gateway_id       = azurerm_nat_gateway.aks_nat_gw.id
  public_ip_address_id = azurerm_public_ip.nat_pip.id
}
# Associate NAT Gateway with the Private Subnet
resource "azurerm_subnet_nat_gateway_association" "private_1_assoc" {
  subnet_id      = azurerm_subnet.private_subnet_1.id
  nat_gateway_id = azurerm_nat_gateway.aks_nat_gw.id
}

# NSG for Private Subnet
resource "azurerm_network_security_group" "private_nsg" {
  name                = "private-subnets-nsg"
  location            = azurerm_resource_group.aks-rg.location
  resource_group_name = azurerm_resource_group.aks-rg.name

  # Allow internal VNet traffic explicitly
  security_rule {
    name                       = "AllowVnetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  # Block Internet Access to these subnets explicitly
  security_rule {
    name                       = "DenyInternetInbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# Associate NSG to the Private Subnets
resource "azurerm_subnet_network_security_group_association" "nsg_assoc_1" {
  subnet_id                 = azurerm_subnet.private_subnet_1.id
  network_security_group_id = azurerm_network_security_group.private_nsg.id
}


