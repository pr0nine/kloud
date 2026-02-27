variable "tenancy_ocid" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}

variable "region" { 
  default = "us-ashburn-1" 
}

variable "compartment_id" {
  description = "OCID of the compartment where resources will be created"
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes version"
  default     = "v1.29.1"
}

variable "cluster_name" {
  default = "my_oke_cluster"
}

variable "cluster_type" {
  default = null
}

variable "node_shape" {
  type        = string
  default     = "VM.Standard.A1.Flex"
  description = "Type of OKE worker nodes"
}

variable "node_count" {
  type        = number
  default     = 3
  description = "Number of OKE worker nodes"
}

variable "node_memory_GBs" {
  type        = number
  default     = 4
  description = "Memory of OKE worker nodes in GB"
}

variable "node_ocpu" {
  type        = number
  default     = 2
  description = "Number of OCPUs per OKE worker nodes"
}

variable "admin_cidr" {
  description = "CIDR block allowed to access the K8s API Endpoint"
  type        = string
  default     = "0.0.0.0/0" # REPLACE THIS with your IP
}
