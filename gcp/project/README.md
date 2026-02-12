**GCP Project**
---------------

This Terraform module automates the creation of a **Google Cloud Project**. It handles the essential “Day 0” setup required before you can deploy infrastructure like Kubernetes (GKE).

### 🏗 Overview

1.  **Creates a Project:** Provisions a new GCP project ID.
2.  **Links Billing:** Associates the project with your Billing Account.
3.  **Sets Parent:** Places the project under an Organization OR a Folder.
4.  **Enables APIs:** Activates the Compute Engine and Kubernetes Engine APIs immediately.
5.  **Clean Network:** Disables the “Default” VPC network (security best practice).

### **🚀** Quick Start

#### 1\. Prerequisites

*   [GCP CLI](https://docs.cloud.google.com/sdk/docs/install-sdk) installed
*   **Permissions:** The user/service account running this must have the `Project Creator` role on the Organization or Folder.
*   **Billing User:** The user must have permissions to link the Billing Account.

#### 2\. Authenticate

Login to your GCP account:

```text-plain
gcloud init
```

#### 3\. Configure Variables (`terraform.tfvars`)

Create a file named `terraform.tfvars` in this directory to customize your deployment without changing the code.

**Option A: Create inside an Organization**

```text-plain
project_id      = "my-new-gke-project-2026"
billing_account = "000000-000000-000000"
org_id          = "123456789012"
# folder_id is omitted (defaults to null)
```

**Option B: Create inside a Folder**

```text-plain
project_id      = "my-new-gke-project-2026"
billing_account = "000000-000000-000000"
folder_id       = "9876543210"
# org_id is omitted (defaults to null)
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

**\*Note**: You must provide either `org_id` OR `folder_id`.

### ⚠️ Common Errors

**Error:** `**Permission denied**`

*   **Cause:** The credentials running Terraform do not have permission to create projects in the target Organization/Folder.
*   **Fix:** Ask your Org Admin to grant you the **Project Creator** and **Billing Project Manager** roles.

**Error:** `**Project ID already exists**`

*   **Cause:** Project IDs must be unique across _all of Google Cloud_, not just your company.
*   **Fix:** Add a random suffix or change the `project_id` variable.

### 🧹 Clean Up

To destroy all resources created by this template:

```text-plain
terraform destroy
```