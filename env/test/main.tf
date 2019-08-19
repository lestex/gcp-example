
terraform {
  backend "gcs" {
    bucket = "terraform-248411-state-test"
    prefix = "terraform/state"
  }
  required_version = "~> 0.12.0"
}

provider "google" {
  project = "terraform-248411"
  region  = "us-east1"
  version = "~> 2.13"
}

module "vpc-network" {
  source       = "./network"
  project_id   = var.project_id
  network_name = var.network_name
}
