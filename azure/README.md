**Azure AKS Cluster Template** (Private Nodes + NAT Gateway)
------------------------------------------------------------

This Terraform project deploys a production-ready Azure Kubernetes Service (AKS) cluster. It implements a secure network architecture where **worker nodes are isolated in private subnets** while maintaining outbound internet connectivity via a **NAT Gateway**. The Control Plane remains accessible via a secured public endpoint.

### 🏗 Architecture Overview

*   **Virtual Network (VNet):** Custom VNet with segmentation for Public and Private workloads.
*   **Subnets:**
    *   `public-subnet-1`: Reserved for Ingress Controllers / Load Balancers.
    *   `private-subnet-1`: Hosts the AKS Worker Nodes (No Public IPs).
*   **Connectivity:**
    *   **NAT Gateway:** Managed outbound internet access for private nodes.
    *   **NSG:** Strict security rules blocking direct internet inbound traffic to private nodes.
*   **AKS Cluster:**
    *   **Identity:** User Assigned Managed Identity.
    *   **Network Plugin:** Kubenet (with UserAssignedNATGateway outbound type).
    *   **Scaling:** Cluster Autoscaler enabled (configurable).

### 🚀 Quick Start

#### 1\. Prerequisites

*   [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed.
*   An active Azure Subscription.

#### 2\. Authenticate

Login to your Azure account:

```text-plain
az login
# If you have multiple subscriptions, set the correct one:
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

#### 3\. Configure Variables (`terraform.tfvars`)

Create a file named `terraform.tfvars` in this directory to customize your deployment without changing the code.

```text-plain
resource_group_name = "my-project-rg"
location            = "East US"  #Azure Region
cluster_name        = "prod-aks-cluster"  #Name of the AKS cluster
kubernetes_version  = "1.29"

# Node Configuration
vm_size        = "Standard_D2s_v5"  #VM Size for worker nodes
node_count     = 2                 # Initial node count

# Autoscaling Configuration
autoscaling    = true  #Enable Cluster Autoscaler
node_count_min = 2  #Minimum nodes (if autoscaling enabled)
node_count_max = 5  #Maximum nodes (if autoscaling enabled)

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
az aks get-credentials --resource-group my-project-rg --name prod-aks-cluster
kubectl get nodes
```

### 🛠 Customizing the Network

This template uses a default VNet size of `/24` (256 IPs), which is suitable for small-to-medium clusters using the **Kubenet** plugin.

To modify the network addressing (e.g., for larger environments or peering requirements), edit the `vnet.tf` file.

#### Step 1: Modify the VNet CIDR

Locate the `azurerm_virtual_network` resource. Change `address_space` to a larger range (e.g., `/16`) if needed.

```text-plain
resource "azurerm_virtual_network" "aks_vnet" {
  # ...
  # CHANGE THIS:
  address_space = ["10.0.0.0/16"] 
}
```

#### Step 2: Adjust Subnet Prefixes

Ensure your subnets fall within the new VNet range and do not overlap.

**Public Subnet:**

```text-plain
resource "azurerm_subnet" "public_subnet_1" {
  # ...
  # CHANGE THIS:
  address_prefixes = ["10.0.1.0/24"] 
}
```

**Private Subnet (AKS Nodes):**

```text-plain
resource "azurerm_subnet" "private_subnet_1" {
  # ...
  # CHANGE THIS:
  address_prefixes = ["10.0.2.0/24"]
}
```

### ⚠️ Important Networking Constraints

1.  **Kubenet vs. Azure CNI:** If you switch `network_plugin` to `"azure"`, every Pod gets an IP from the subnet. You **must** increase the subnet size (e.g., to `/20` or larger) to prevent IP exhaustion.
2.  **Service CIDR:** Ensure your VNet CIDR does not overlap with the Kubernetes Service CIDR (default usually `10.0.0.0/16` in some setups, or `192.168.0.0/16` for Pods).
3.  **Pod CIDR:** In the `network_profile` block, `pod_cidr` is used for the overlay network. Do not make this overlap with the VNet `address_space`.

### 🧹 Clean Up

To destroy all resources created by this template:

```text-plain
terraform destroy
```