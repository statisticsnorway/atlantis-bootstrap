#-------------------------------------------------#
# Create a VPC network for the Kubernetes cluster #
#-------------------------------------------------#
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.5"

  project_id   = var.project_id
  network_name = "${var.project_id_prefix}-vpc"

  subnets = [
    {
      subnet_name               = "${var.project_id_prefix}-subnet"
      subnet_ip                 = "10.15.0.0/20"
      subnet_region             = var.region
      subnet_flow_logs          = "true"
      subnet_flow_logs_interval = "INTERVAL_10_MIN"
      subnet_flow_logs_sampling = 0.7
      subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
      subnet_private_access     = "true"
    },
  ]

  secondary_ranges = {
    "${var.project_id_prefix}-subnet" = [
      {
        range_name    = "${var.project_id_prefix}-pods"
        ip_cidr_range = "10.17.0.0/20"
      },
      {
        range_name    = "${var.project_id_prefix}-services"
        ip_cidr_range = "10.16.0.0/20"
      },
    ]
  }

}


#------------------#
# Create Cloud NAT #
#------------------#
module "cloud-nat" {
  source  = "terraform-google-modules/cloud-nat/google"
  version = "~> 1.3"

  project_id    = var.project_id
  region        = var.region
  create_router = true
  router        = "${var.project_id_prefix}-router"
  network       = module.vpc.network_name
}


#-------------------------------------#
# Create a private Kubernetes cluster #
#-------------------------------------#
module "private-cluster" {
  source                             = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version                            = "~> 11.0"

  project_id                         = var.project_id
  name                               = var.project_id_prefix
  region                             = var.region
  network                            = "${var.project_id_prefix}-vpc"
  subnetwork                         = "${var.project_id_prefix}-subnet"
  ip_range_pods                      = "${var.project_id_prefix}-pods"
  ip_range_services                  = "${var.project_id_prefix}-services"
  enable_resource_consumption_export = false
  enable_private_endpoint            = false
  enable_private_nodes               = true
  master_authorized_networks         = var.master_authorized_networks
  remove_default_node_pool           = true
  network_policy                     = false

  node_pools = [
    {
      name         = "default-node-pool"
      machine_type = "n1-standard-2"
      min_count    = 1
      max_count    = 3
      disk_size_gb = 100
      disk_type    = "pd-standard"
      image_type   = "COS"
      auto_repair  = true
      auto_upgrade = true
      preemptible  = false
      zone         = var.zone
    },
  ]
}
