# GCP variables
variable "org_id" {
  type        = string
  description = "Google organization ID"
  default     = ""
}

variable "project_name" {
  type        = string
  description = "The name of the GCP project created for Atlantis resources"
}

variable "billing_account" {
  type        = string
  description = "Billing account ID"
}

variable "labels" {
  type        = map(string)
  description = "Labels to use on the project"
  default     = {}
}

variable "folder_id" {
  type        = string
  description = "The ID of a folder to host this project"
  default     = ""
}

variable "project_id_prefix" {
  type        = string
  default     = ""
  description = "Project prefix ID of the Atlantis project."
}

# GKE variables
variable "region" {
  type        = string
  default     = "europe-north1"
  description = "Region in which to create the cluster and run Atlantis."
}

variable "zone" {
  type        = string
  default     = "europe-north1-a"
  description = "GCP zone in which to create the cluster and run Atlantis"
}

# Azure variables
variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "azure_client_id" {
  type        = string
  description = "Azure client ID"
}

variable "azure_client_secret" {
  type        = string
  description = "Azure client secret"
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure tenant ID"
}


# GKE specific variables

variable "master_authorized_networks" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  description = "The list of CIDR blocks of master authorized networks"
}


# Ingress variables

variable "zone_name" {
  type        = string
  description = "DNS zone name"
}

variable "resource_group" {
  type        = string
  description = "Azure resource group name"
}
