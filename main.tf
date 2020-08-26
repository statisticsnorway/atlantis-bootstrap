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
  azure_client_secret        = var.azure_client_secret
  create_secret              = var.create_secret
  gh-webhook-secret          = var.gh-webhook-secret
  gh-key-file                = var.gh-key-file
  master_authorized_networks = var.master_authorized_networks
}
