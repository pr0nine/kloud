**GKE Private Cluster** 
------------------------

This Terraform project provisions a secure, **VPC-native Google Kubernetes Engine (GKE)** cluster. It follows security best practices by placing worker nodes in a private subnet (no public IPs) while maintaining public access to the Control Plane via authorized networks.

### **🏗 Architecture**

*   **VPC Network:** Custom VPC (`gke-vpc`) with strict subnet isolation.
*   **Subnets:**
    *   `public-subnet`: Intended for Bastion hosts or Load Balancers.
    *   `private-subnet-1`: Dedicated for GKE Worker Nodes.
*   **NAT Gateway:** Cloud NAT configured to allow private nodes to pull images from the internet.
*   **GKE Cluster:**
    *   **Private Nodes:** Nodes have only internal IPs for security.
    *   **VPC Native:** Uses Alias IPs for high performance.
    *   **Authorized Networks:** Restricts Control Plane access to specific CIDRs.

### **🚀**Quick Start

#### 1\. Prerequisites

1.  [GCP CLI](https://docs.cloud.google.com/sdk/docs/install-sdk) installed
2.  **Google Cloud Project:** A project with billing enabled, use the cloud console or \_\_\_ to create one
3.  **APIs Enabled:** Ensure the following APIs are enabled:
    *   `compute.googleapis.com`
    *   `container.googleapis.com`

#### 2\. Authenticate

Login to your GCP account:

```text-plain
gcloud init
```

#### 3\. Configure Variables (`terraform.tfvars`)

Create a file named `terraform.tfvars` in this directory to customize your deployment without changing the code.

```text-plain
project_id          = "my-project-id"
region              = "us-central1"  #GCP Region
cluster_name        = "prod-gcp-cluster"  #Name of the GCP cluster
kubernetes_version  = "1.34"

# Node Configuration
machine_type        = "t2a-standard-4"  #VM Size for worker nodes
node_count          = 2                 # Initial node count

# Autoscaling Configuration
autoscaling    = true  #Enable Cluster Autoscaler
node_count_min = 2  #Minimum nodes (if autoscaling enabled)
node_count_max = 4  #Maximum nodes (if autoscaling enabled)

# Security
admin_cidr     = "203.0.113.5/32"  #Your specific Public IP for API access
```

#### 4\. Deploy

Initialize and apply the configuration:

```text-plain
# Initialize Terraform and download providers
terraform init

# Review the plan
terraform plan

# Apply the configuration (Type 'yes' when prompted)
terraform apply
```

#### 5\. Access Cluster

Once deployed, configure your local `kubectl`:

```text-plain
gcloud container clusters get-credentials $(terraform output -raw cluster_name) --region $(terraform output -raw region)
kubectl get nodes
```

### 🔧 Customize the Network

You can customize the IP ranges for the subnets, Pods, and Services by editing the `vpc.tf` file. This is done by modifying the resources in `vpc.tf` or, ideally, abstracting them into variables

#### Current Default Setup

*   **Public Subnet (LBs):** `10.0.0.0/24` (Allows ~250 IPs)
*   **Private Subnet (Nodes):** `10.0.1.0/24` (Allows ~250 IPs)
*   **Secondary Range (Pods):** `10.0.16.0/20` (Allows ~4,000 pods)
*   **Secondary Range (Services):** `10.0.32.0/20` (Allows ~4,000 services)

#### Adjust Subnet Prefixes

To change these ranges, locate the following resource in `vpc.tf` and modify the `ip_cidr_range` values.

**Public Subnet:**

```text-plain
resource "google_compute_subnetwork" "public_subnet" {
  # ...
  # CHANGE THIS:
  ip_cidr_range = "10.0.0.0/24"
}
```

**Private Subnet (GKE Nodes):**

```text-plain
resource "google_compute_subnetwork" "private_subnet_1" {
  # ...
  # CHANGE THIS:
  ip_cidr_range = "10.0.1.0/24"

  # Secondary ranges required for GKE (Pods and Services)
  secondary_ip_range {
    range_name    = "k8s-pod-range-1"
    # ...
    # CHANGE THIS:
    ip_cidr_range = "10.0.16.0/20"
  }
  secondary_ip_range {
    range_name    = "k8s-service-range-1"
    # ...
    # CHANGE THIS:
    ip_cidr_range = "10.0.32.0/20"
  }
}
```

#### ⚠️ Important

You cannot overlap CIDR ranges with other subnets in the same VPC or connected networks (VPN/Peering). Always check your network plan before changing these values.

### 🧹 Clean Up

To destroy all resources created by this template:

```text-plain
terraform destroy
```