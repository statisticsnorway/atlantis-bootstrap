variable "project_id" {
  type        = string
  default     = ""
  description = "Project ID of the Atlantis project."
}

variable "cluster_name" {
  type        = string
  default     = ""
  description = "Cluster name of the Kubernetes cluster"
}

variable "master_authorized_networks" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  description = "The list of CIDR blocks of master authorized networks"
}

variable "region" {
  type        = string
  default     = "europe-north1"
  description = "Region in which to create the cluster and run Atlantis."
}