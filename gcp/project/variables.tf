# Project IDs must be globally unique across ALL of Google Cloud.
variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "org_id" {
  description = "The Organization ID"
  type        = string
  default     = null 
}

variable "folder_id" {
  description = "The Folder ID"
  type        = string
  default     = null
}

variable "billing_account" {
  description = "The Billing Account"
  type        = string
}

variable "region" {
  description = "The GCP Region"
  default     = "us-central1"
}
