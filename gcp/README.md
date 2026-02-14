**AWS EKS Cluster Terraform Template**
--------------------------------------

This project contains a Terraform template to provision a production-ready **Amazon EKS (Elastic Kubernetes Service)** cluster. It automatically creates the necessary network infrastructure (VPC, Subnets, NAT Gateways) and deploys a managed Kubernetes cluster with a dedicated node group.

### 🏗 Architecture

The Terraform code deploys the following infrastructure:

*   **VPC:** A custom Virtual Private Cloud.
*   **Subnets:**
    *   **Public Subnets:** Host the NAT Gateway and Load Balancers.
    *   **Private Subnets:** Host the EKS Worker Nodes (securely isolated).
*   **Internet Access:**
    *   **NAT Gateway:** Allows private nodes to access the internet (for pulling images/updates) without exposing them to inbound traffic.
    *   **Internet Gateway:** Handles traffic for public subnets.
*   **EKS Cluster:**
    *   Control Plane (Managed by AWS).
    *   Managed Node Group (Worker nodes in private subnets).
    *   **IRSA:** IAM Roles for Service Accounts enabled.
*   **Security:**
    *   Security Groups configured for node-to-node communication.
    *   Public API Server endpoint restricted by CIDR.

### 🚀 Quick Start

#### 1\. Prerequisites

*   [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials.
*   `kubectl` installed.

#### 2\. Configuration (`terraform.tfvars`)

Create a file named `terraform.tfvars` in this directory. This file allows you to set your specific configuration without modifying the source code.

**Copy and paste this template into** `**terraform.tfvars**`**:**

```text-plain
# Region and Cluster Details
aws_region         = "us-east-1"
cluster_name       = "my-demo-cluster"
kubernetes_version = "1.30"

# Network Security
# Replace with your own IP (e.g., "1.2.3.4/32") to restrict API access
endpoint_public_access_cidr = "0.0.0.0/0" 

# Node Group Configuration
ami_type       = "AL2_x86_64"     # Amazon Linux 2 (x86)
instance_type  = "t3.medium"      # Size of the worker nodes
min_size       = 2
max_size       = 4
desired_size   = 2
```

#### 3\. Deployment

Run the following commands to provision the cluster:

```text-plain
# Initialize Terraform and download providers
terraform init

# Review the plan
terraform plan

# Apply the configuration (Type 'yes' when prompted)
terraform apply
```

#### 4\. Connect to Cluster

Once the deployment finishes, configure `kubectl` to talk to your new cluster:

```text-plain
aws eks update-kubeconfig --region $(terraform output -raw region) --name $(terraform output -raw cluster_name)
```

### 🛠 Modifying the Network (Template Guide)

This section explains how to modify the `module "vpc"` block in `vpc.tf` to fit different scale requirements.

#### Current Setup (Small Scale)

The default code provided uses a **small network sizing** (`/24` VPC), which is suitable for demos or very small dev environments but **not recommended for production**.

*   **VPC CIDR:** `10.0.0.0/24` (256 Total IPs)
*   **Subnets:** `/26` (64 IPs per subnet)

#### How to Scale Up (Production Recommended)

To add more subnets, provide those subnets in the `public_subnets` or `private_subnets` lists and to spread them in all Availability Zones AZs  remove the Slice function `slice(List, 0, 2)`

For a standard production environment, you should increase the CIDR ranges to ensure you don't run out of IP addresses for your Pods.

**To modify the network:**

1.  Open `vpc.tf`.
2.  Locate the `module "vpc"` block.
3.  Update the `cidr`, `private_subnets`, `public_subnets`, and `AZs` values as shown below:
    
    ```text-plain
    module "vpc" {
      source  = "terraform-aws-modules/vpc/aws"
      # ... other settings ...
    
      # 1. Change VPC CIDR to a larger block (e.g., /16 gives ~65k IPs)
      cidr = "10.0.0.0/16"
    
      # 2. Remove or adjust the Slice function
      azs  = slice(data.aws_availability_zones.available.names, 0, 2)
    
      # 3. Update Subnets to /24 (256 IPs each) or larger
      # Ensure these ranges are inside the new VPC CIDR
      public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
      private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]
      
      # ... rest of the module ...
    }
    ```
    

#### ⚠️ Important

 You cannot overlap CIDR ranges with other subnets in the same VPC or connected networks (VPN/Peering). Always check your network plan before changing these values.

🧹 Cleanup
----------

To destroy all resources and stop billing:

```text-plain
terraform destroy
```