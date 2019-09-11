output "jenkins-image" {
  value = "${data.google_compute_image.jenkins_agent.name}"
}