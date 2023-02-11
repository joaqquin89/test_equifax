output "ip" {
  value       = google_compute_instance.bastion.network_interface.0.network_ip
}

output "ssh" {
  value       = "gcloud compute ssh ${google_compute_instance.bastion.name} --project ${var.project_id} --zone ${google_compute_instance.bastion.zone} -- -L8888:127.0.0.1:8888"
}

output "kubectl_command" {
  value       = "HTTPS_PROXY=localhost:8888 kubectl"
}