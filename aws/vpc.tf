terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
provider "aws" {
  region = var.aws_region
}

#fetch a list of all AZs that are currently available within the region defined
data "aws_availability_zones" "available" {}

locals {
  cluster_name = var.cluster_name
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name                    = "pi-vpc"
  cidr                    = "10.0.0.0/24"
  # /26 cidr block means 64 addresses per subnet, should be enough
  azs                     = data.aws_availability_zones.available.names
  private_subnets         = ["10.0.0.128/26", "10.0.0.192/26"]
  public_subnets          = ["10.0.0.0/26", "10.0.0.64/26"]
  map_public_ip_on_launch = true        #by default set to false
  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  # by default igw is created 
  
  #Using shared means multiple clusters could potentially use this VPC
  tags = { 
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
  
  #AWS LB Controller looks for this tag to place Internet-facing ELBs
  public_subnet_tags = { 
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  #and this for the internal Load Balancer, only reachable from inside VPC
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
