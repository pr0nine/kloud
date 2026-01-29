# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "gke-vpc"
  auto_create_subnetworks = false
}

# Public Subnet 
resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
  private_ip_google_access = true
}

# Private Subnet (GKE Nodes)
resource "google_compute_subnetwork" "private_subnet_1" {
  name          = "private-subnet-1"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
  private_ip_google_access = true

  # Secondary ranges required for GKE (Pods and Services)
  secondary_ip_range {
    range_name    = "k8s-pod-range-1"
    ip_cidr_range = "10.0.16.0/20"
  }
  secondary_ip_range {
    range_name    = "k8s-service-range-1"
    ip_cidr_range = "10.0.32.0/20"
  }
}

# Cloud Router & NAT (The "IGW" for Private Nodes)
resource "google_compute_router" "router" {
  name    = "gke-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "gke-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  # Allow NAT for the private subnets
  subnetwork {
    name                    = google_compute_subnetwork.private_subnet_1.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
