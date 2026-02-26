resource "oci_core_vcn" "oke_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_id
  display_name   = "oke-vcn"
  dns_label      = "okevcn"
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-igw"
}

resource "oci_core_nat_gateway" "nat" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-nat"
}

resource "oci_core_service_gateway" "sgw" {
  # Recommended for OKE to access Oracle Services (Registry, Object Storage) internally
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-sgw"
  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }
}

# Route Table for Public Subnet (Traffic -> Internet Gateway)
resource "oci_core_route_table" "public_rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

# Route Table for Private Subnet (Traffic -> NAT Gateway)
resource "oci_core_route_table" "private_rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat.id
  }
  
  # Route to Oracle Services via Service Gateway
  route_rules {
    destination       = data.oci_core_services.all_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw.id
  }
}

# ---------------------------------------------------------------------------
# Security Lists & NSGs
# ---------------------------------------------------------------------------

# Security List for Public Subnet
resource "oci_core_security_list" "public_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-public-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    # Allow all traffic
    source   = "0.0.0.0/0"
    protocol = "all"
  }
}

# Security List for Private Subnet (Worker Nodes)
resource "oci_core_security_list" "private_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-private-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    # Allow VCN internal traffic (Node-to-Node, Control Plane-to-Node)
    source   = "10.0.0.0/16"
    protocol = "all"
  }
}

# NSG for K8s API Endpoint (Specific CIDR Access)
resource "oci_core_network_security_group" "k8s_api_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-k8s-api-nsg"
}

resource "oci_core_network_security_group_security_rule" "k8s_api_allow_admin" {
  network_security_group_id = oci_core_network_security_group.k8s_api_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = var.admin_cidr
  source_type               = "CIDR_BLOCK"
  
  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }
}

# ---------------------------------------------------------------------------
# Subnets
# ---------------------------------------------------------------------------

resource "oci_core_subnet" "public_subnet" {
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.oke_vcn.id
  display_name      = "oke-public-subnet"
  cidr_block        = "10.0.0.0/24"
  route_table_id    = oci_core_route_table.public_rt.id
  security_list_ids = [oci_core_security_list.public_sl.id]
}

resource "oci_core_subnet" "private_subnet" {
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.oke_vcn.id
  display_name      = "oke-private-subnet"
  cidr_block        = "10.0.1.0/24"
  route_table_id    = oci_core_route_table.private_rt.id
  security_list_ids = [oci_core_security_list.private_sl.id]
  prohibit_public_ip_on_vnic = true
}
