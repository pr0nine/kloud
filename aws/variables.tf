variable "kubernetes_version" {
  default     = 1.33
  description = "kubernetes version"
}

variable "aws_region" {
  default = "ap-south-1"
  description = "aws region"
}

variable "cluster_name" {
  default = "kloud-kluster"
  description = "EKS cluster name"
}

variable "ami_type" {
  default = "AL2023_ARM_64_STANDARD"
  description = "Amazon Machine Image type"
}

variable "instance_type" {
  default = "t4g.small"
  description = "Virtual Machine architecture type"
}

variable "min_size" {
  default = 2 
  description = "Minimum number of worker nodes"
}

variable "max_size" {
  default = 4
  description = "Maximum number of worker nodes"
}

variable "desired_size" {
  default = 2 
  description = "Desired number of worker nodes"
}

variable "endpoint_public_access_cidr" {
  default = "0.0.0.0/0"
  description = "add your public ip or cidr from which, wish to access the cluster"
}
