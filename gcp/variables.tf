variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region" {
  description = "The GCP Region"
  default     = "us-central1"
}

variable "cluster_name" {
  type        = string
  description = "GKE cluster name in GCP"
  default     = "kloud-cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.34"
}

variable "node_count_min" {
  type        = number
  default     = 2
  description = "Minimum Number of GKE worker nodes"
}
variable "node_count_max" {
  type        = number
  default     = 4
  description = "Maximum Number of GKE worker nodes"
}

variable "autoscaling" {
  type        = bool
  default     = true
  description = "Autoscaling toggle for Worker Nodes"
}

variable "node_count" {
  type        = number
  default     = null
  description = "Number of GKE worker nodes"
}

variable "machine_type" {
  type        = string
  default     = "t2a-standard-4"
  description = "Node VM instance type"
}

variable "admin_cidr" {
  type        = string
  description = "Add your public ip or cidr from which wish to access the cluster"
  default     = "0.0.0.0/0"
}
