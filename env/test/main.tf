terraform {
  required_version = "~> 0.12.0"
#   backend "remote" {
#     organization = "leandevops"

#     workspaces {
#       name = "test_env_network"
#     }
#   }
}

provider "google" {
  project = "terraform-248411"
  region  = "us-east1"
  version = "~> 2.13"
}

module "vpc-network" {
  source = "./network"

  project_id   = var.project_id
  network_name = var.prefix
}

# module "gcs-bucket" {
#   source = "./gcs"

#   project_id    = var.project_id
#   bucket_prefix = var.prefix
# }

# module "jenkins" {
#   source = "./jenkins"

#   project_id                      = var.project_id
#   region                          = var.region
#   google_storage_bucket_artifacts = module.gcs-bucket.bucket_name
#   network                         = module.vpc-network.network_name
#   subnetwork                      = module.vpc-network.subnets_self_links[0]
# }
