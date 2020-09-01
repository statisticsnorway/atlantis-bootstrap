#------------------#
# Google Providers #
#------------------#
# `GOOGLE_APPLICATION_CREDENTIALS` must be set in the environment before Terraform is run.

provider "google" {
  # Terraform will check the `GOOGLE_APPLICATION_CREDENTIALS` variable, so no `credentials`
  # value is needed here.
  version = "~> 3.27.0"
}


#-----------------#
# Azure Providers #
#-----------------#

provider "azurerm" {
  version = "~> 2.21.0"
  features {}

  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id

  # Make the AzureRM Provider skip registering any required Resource Providers
  # The reason we do this is because the client does not have the necessary
  # privileges to register a resource provider.
  # https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview
  skip_provider_registration = true
}


#------------------#
# GitHub providers #
#------------------#
provider github {
  version = "2.9.2"
}


#--------------------------------------------------------#
# Configure Kubernetes provider with OAuth2 access token #
#--------------------------------------------------------#
data "google_client_config" "default" {
}

provider "kubernetes" {
  load_config_file = false

  host  = "https://${module.gke.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}


module gcp {
  source = "./modules/gcp"

  project_name      = var.project_name
  project_id_prefix = var.project_id_prefix
  org_id            = var.org_id
  folder_id         = var.folder_id
  labels            = var.labels
  billing_account   = var.billing_account
}


module gke {
  source = "./modules/gke"

  project_id                 = module.gcp.project_id
  project_id_prefix          = var.project_id_prefix
  master_authorized_networks = var.master_authorized_networks
  region                     = var.region
  zone                       = var.zone
}


module ingress {
  source = "./modules/ingress"

  project_id        = module.gcp.project_id
  project_id_prefix = var.project_id_prefix
  zone_name         = var.zone_name
  resource_group    = var.resource_group
}


module atlantis {
  source = "./modules/atlantis"

  project_id                 = module.gcp.project_id
  cluster_name               = module.gke.name
  master_authorized_networks = var.master_authorized_networks

  depends_on = [module.gke]
}
