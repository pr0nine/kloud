variable "resource_group_name" {
  type        = string
  description = "RG name in Azure"
  default     = "aks-RG"
}
variable "location" {
  type        = string
  description = "Resources location in Azure"
  default     = "East US"
}
variable "cluster_name" {
  type        = string
  description = "AKS name in Azure"
  default     = "kloud-cluster"
}
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.34"
}
variable "node_count" {
  type        = number
  default     = 2
  description = "Number of AKS worker nodes"
}
variable "vm_size" {
  type        = string
  default     = "Standard_D2ps_v5"
  description = "Node VM instance type"
}
variable "autoscaling" {
  type        = bool
  default     = true
  description = "Autoscaling toggle for Worker Nodes"
}
variable "node_count_min" {
  type        = number
  default     = 2
  description = "Minimum Number of AKS worker nodes"
}
variable "node_count_max" {
  type        = number
  default     = 4
  description = "Maximum Number of AKS worker nodes"
}
variable "admin_cidr" {
  type        = string
  description = "Add your public ip or cidr from which wish to access the cluster"
  default     = "0.0.0.0/0"
}
