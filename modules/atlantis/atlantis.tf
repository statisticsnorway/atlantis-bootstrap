locals {
  allow_ip = var.master_authorized_networks[*].cidr_block
}

data "github_ip_ranges" "gh" {}


#--------------------------------------------------------#
# Configure Kubernetes provider with OAuth2 access token #
#--------------------------------------------------------#
data "google_client_config" "default" {
}

data "google_container_cluster" "atlantis_cluster" {
  name = var.cluster_name
  region = var.region
  project = var.project_id
}

provider "kubernetes" {
  load_config_file = false

  host  = "https://${data.google_container_cluster.atlantis_cluster.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.atlantis_cluster.master_auth[0].cluster_ca_certificate,
  )
}


#-----------------------------------------#
# Create a Workload Identity for Atlantis #
#-----------------------------------------#
module "kubernetes-engine_workload-identity" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version      = "~> 11.0"
  cluster_name = var.cluster_name
  name         = "atlantis"
  namespace    = "default"
  project_id   = var.project_id
}


#--------------------------------------------------------#
# Create Cloud Armor Security Policy to protect Atlantis #
#--------------------------------------------------------#
resource "google_compute_security_policy" "policy" {
  name    = "atlantis-policy"
  project = var.project_id

  rule {
    action   = "allow"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = local.allow_ip
      }
    }
    description = "allow traffic from master authorized networks"
  }

  rule {
    action   = "allow"
    priority = "1001"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = data.github_ip_ranges.gh.hooks
      }
    }
    description = "allow traffic from GitHub webhook"
  }

  rule {
    action   = "deny(404)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Deny access from all IPs"
  }
}
