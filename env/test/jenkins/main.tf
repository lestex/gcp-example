resource "google_project_service" "cloudresourcemanager" {
  project            = "${var.project_id}"
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = "false"
}

resource "google_project_service" "iam" {
  project            = "${google_project_service.cloudresourcemanager.project}"
  service            = "iam.googleapis.com"
  disable_on_destroy = "false"
}

data "google_compute_image" "jenkins_agent" {
  project = var.project_id
  family  = "jenkins-agent"
}

data "local_file" "example_job_template" {
  filename = "${path.module}/templates/example_job.xml.tpl"
}

data "template_file" "example_job" {
  template = data.local_file.example_job_template.content

  vars = {
    project_id            = var.project_id
    build_artifact_bucket = var.google_storage_bucket_artifacts
  }
}

resource "google_compute_firewall" "jenkins_agent_ssh_from_instance" {
  name    = "jenkins-agent-ssh-access"
  network = var.network
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["jenkins"]
  target_tags = ["jenkins-agent"]
}

resource "google_compute_firewall" "jenkins_agent_discovery_from_agent" {
  name    = "jenkins-agent-udp-discovery"
  network = var.network
  project = var.project_id

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "tcp"
  }

  source_tags = ["jenkins", "jenkins-agent"]
  target_tags = ["jenkins", "jenkins-agent"]
}

resource "google_compute_firewall" "jenkins_ssh_from_internet" {
  name    = "jenkins-ssh-access"
  network = var.network
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jenkins"]
}

module "jenkins-gce" {
  source                               = "../../../vendor/modules/terraform-google-jenkins"
  project_id                           = var.project_id
  region                               = "${var.region}"
  gcs_bucket                           = var.google_storage_bucket_artifacts
  jenkins_instance_zone                = "us-east1-b"
  jenkins_instance_network             = var.network
  jenkins_instance_subnetwork          = var.subnetwork
  jenkins_instance_additional_metadata = var.jenkins_instance_metadata

  jenkins_workers_region                         = "${var.region}"
  jenkins_workers_project_id                     = var.project_id
  jenkins_workers_zone                           = "us-east1-b"
  jenkins_workers_machine_type                   = "n1-standard-1"
  jenkins_workers_boot_disk_type                 = "pd-ssd"
  jenkins_workers_network                        = var.network
  jenkins_workers_network_tags                   = ["jenkins-agent"]
  jenkins_workers_boot_disk_source_image         = data.google_compute_image.jenkins_agent.name
  jenkins_workers_boot_disk_source_image_project = var.project_id

  jenkins_jobs = [
    {
      name     = "testjob"
      manifest = "${data.template_file.example_job.rendered}"
    },
  ]
}

