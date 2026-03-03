resource "oci_containerengine_cluster" "k8s_cluster" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.k8s_version
  name               = var.cluster_name
  vcn_id             = oci_core_vcn.oke_vcn.id

  # Public API Endpoint configuration
  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.public_subnet.id
    nsg_ids              = [oci_core_network_security_group.k8s_api_nsg.id]
  }

  options {
    service_lb_subnet_ids = [oci_core_subnet.public_subnet.id]
    
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }
  }
  # Set the cluster type
  type               = var.cluster_type
}

resource "oci_containerengine_node_pool" "k8s_node_pool" {
  cluster_id         = oci_containerengine_cluster.k8s_cluster.id
  compartment_id     = var.compartment_id
  kubernetes_version = var.k8s_version
  name               = "my-node-pool"
  node_shape         = var.node_shape

  node_shape_config {
    memory_in_gbs = var.node_memory_GBs
    ocpus         = var.node_ocpu
  }

  node_config_details {
    # Loops through every available AD in the region
    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.ads.availability_domains
      
      content {
        availability_domain = placement_configs.value.name
        subnet_id           = oci_core_subnet.private_subnet.id
      }
    }
    size = var.node_count
  }

  node_source_details {
    image_id    = data.oci_containerengine_node_pool_option.node_pool_options.sources[0].image_id
    source_type = "IMAGE"
  }
}

# ---------------------------------------------------------------------------
# Data Sources
# ---------------------------------------------------------------------------

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

data "oci_containerengine_node_pool_option" "node_pool_options" {
  node_pool_option_id = "all"
  compartment_id      = var.compartment_id
}
