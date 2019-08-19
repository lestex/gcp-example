locals {
  prefix = var.bucket_prefix
}

resource "google_storage_bucket" "jenkins-artifacts" {
  name          = "${local.prefix}-jenkins-artifacts"
  project       = "${var.project_id}"
  force_destroy = true
}
