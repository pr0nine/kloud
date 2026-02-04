# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  
  min_master_version = var.kubernetes_version 

  # We remove the default node pool to manage it separately
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.private_subnet_1.id

  # IP Allocation Policy (VPC-native cluster) uses the secondary ranges
  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range-1"
    services_secondary_range_name = "k8s-service-range-1"
  }

  # Nodes have NO public IP & Control Plane IS accessible publicly
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false 
    master_ipv4_cidr_block  = "172.16.0.0/28" # Internal range for master-node and ILB VIP
  }

  # Enable Master Authorized Networks
  master_authorized_networks_config {
    
    cidr_blocks {
      display_name = "Public Subnet"
      cidr_block   = "10.0.0.0/24"
    }
    cidr_blocks {
      display_name = "Private Subnet"
      cidr_block   = "10.0.1.0/24"
    }
    cidr_blocks {
      display_name = "Control Plane access"
      cidr_block   = var.admin_cidr  
    }
  }
}

# GKE Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "my-node-pool"
  location   = google_container_cluster.primary.location
  cluster    = google_container_cluster.primary.name
  node_count = var.autoscaling ? null : var.node_count 

  node_config {
    preemptible  = false
    machine_type = var.machine_type

    # Google recommends custom service accounts with minimal permissions
    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  # Autoscaling Configuration
  dynamic "autoscaling" {
    for_each = var.autoscaling ? [1] : []
    
    content {
      # It is best practice to use TOTAL counts to avoid math errors.
      # If you set total_min = 3 and have 3 zones, GKE puts 1 node in each zone.
      total_min_node_count = var.node_count_min
      total_max_node_count = var.node_count_max
      
      # Alternatively, you can use per-zone limits:
      # min_node_count = var.node_count_min
      # max_node_count = var.node_count_max

      # "BALANCED" ensures GKE tries to keep node counts even across zones
      location_policy = "BALANCED"
    }
  }
}

# Service Account for Nodes
resource "google_service_account" "default" {
  account_id   = "gke-node-sa"
  display_name = "GKE Node Service Account"
}


