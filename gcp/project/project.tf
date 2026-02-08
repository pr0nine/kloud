terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  region  = var.region
}

# The Project Definition
resource "google_project" "my_project" {
  name       = "GKE Project"
  project_id = var.project_id

  # IMPORTANT: You must provide ONE of these parents
  # If you are using a personal account, you might not have an org_id
  org_id     = var.org_id 
  folder_id = var.folder_id

  # Link a Billing Account (Required to create resources)
  billing_account = var.billing_account
  
  # Auto-create the default network, set to false for custom VPCs
  auto_create_network = false
}

# Enable APIs
# New projects start with zero APIs enabled you must enable them before you can create a GKE cluster
resource "google_project_service" "container_api" {
  project = google_project.my_project.project_id
  service = "container.googleapis.com"

  # Don't disable the API when destroying the TF resource, prevents accidental data loss
  disable_on_destroy = false
}

resource "google_project_service" "compute_api" {
  project = google_project.my_project.project_id
  service = "compute.googleapis.com"
  disable_on_destroy = false
}
