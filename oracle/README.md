**OCI OKE Cluster** 
--------------------

This Terraform project provisions a fully managed **Oracle Kubernetes Engine (OKE)** cluster in Oracle Cloud Infrastructure (OCI). It implements a secure **VCN-Native** networking architecture with public/private subnet separation.

### **🏗 Architecture**

*   **VCN:** Custom Virtual Cloud Network.
    
*   **Subnets:**
    
    *   **Public Subnet:** Hosts the Kubernetes API Endpoint and Load Balancers.
        
    *   **Private Subnet:** Hosts the Worker Nodes (secure, no public IPs).
        
*   **Gateways:**
    
    *   **Internet Gateway:** For public subnet traffic.
        
    *   **NAT Gateway:** Allows private nodes to pull images/updates from the internet.
        
    *   **Service Gateway:** Optimized internal access to OCI services (Object Storage, OCIR).
        
*   **Security:**
    
    *   **NSGs:** Strict control over API Endpoint access (default: locked to Admin CIDR).
        
    *   **Security Lists:** Default rules for VCN internal communication.
        

### **🚀  & Setup**

#### 1\. Prerequisites

*   [Oracle CLI](https://docs.oracle.com/en-us/iaas/private-cloud-appliance/pca/installing-the-oci-cli.htm) installed
    
*   kubectl installed
    

#### 2\. Authenticate

Generate API Keys & Get OCIDs:

1.  **Login:** Go to the OCI Console and click your user profile icon.
2.  **API Keys:** Under "Resources," select **API Keys** and click **Add API Key**.
3.  **Generate or add public key :** If choose to generate a new key pair, download the private key and save it securely
4.  **Get Details:** Copy your **User OCID**, **Tenancy OCID**, **Compartment OCID**, and the **Fingerprint** generated for the key. 
5.  **To get an RSA key fingerprint:** Run the `ssh-keygen` command, replacing `~/.ssh/id_rsa.pub` with the actual path to your public key file
    
    ```text-plain
    ssh-keygen -lf ~/.ssh/id_rsa.pub
    ```
    

#### 3\. Configure Variables (`terraform.tfvars`)

Create a file named `terraform.tfvars` in this directory to customize your deployment without changing the code.

```text-plain
# terraform.tfvars

tenancy_ocid     = "ocid1.tenancy.oc1..aaaa..."
user_ocid        = "ocid1.user.oc1..aaaa..."
fingerprint      = "xx:xx:xx:xx:xx..."
private_key_path = "/path/to/your/private_key.pem"
region           = "us-ashburn-1" # Or your preferred region
compartment_id   = "ocid1.compartment.oc1..aaaa..."

# Security: Restrict API access to YOUR IP address
admin_cidr       = "203.0.113.15/32"
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
oci ce cluster create-kubeconfig --cluster-id=$(terraform output -raw oke_cluster_ocid) --file ~/.kube/config --overwrite
```

### 🔧 Customizing the Network

You can customize the IP addressing scheme by modifying the resource definitions in `vcn.tf`.

#### Changing the VCN Range

Locate the `oci_core_vcn` resource.

```text-plain
resource "oci_core_vcn" "oke_vcn" {
  cidr_block = "10.0.0.0/16" # <--- Change this (e.g., to 192.168.0.0/16)
  ...
}
```

#### Changing Subnets

If you change the VCN CIDR, you must update the subnets to fall _within_ that new range.

**Public Subnet (API & Load Balancers):**

```text-plain
resource "oci_core_subnet" "public_subnet" {
  cidr_block = "10.0.0.0/24" # <--- Change to fit new VCN (e.g., 192.168.10.0/24)
  ...
}
```

**Private Subnet (Worker Nodes):**

```text-plain
resource "oci_core_subnet" "private_subnet" {
  cidr_block = "10.0.1.0/24" # <--- Change to fit new VCN (e.g., 192.168.20.0/24)
  ...
}
```

> **Warning:** Ensure your `admin_cidr` variable is set correctly. If you leave it as `0.0.0.0/0`, your Kubernetes API server will be accessible from the entire public internet.

### 🧹 Clean Up

To destroy all resources created by this template:

```text-plain
terraform destroy
```