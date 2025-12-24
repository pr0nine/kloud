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

variable "endpoint_public_access_cidr" {
  default = "0.0.0.0/0"
  description = "add your public ip or cidr from which, wish to access the cluster"
}
