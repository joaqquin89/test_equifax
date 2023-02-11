output "network" {
  value       = google_compute_network.vpc
}

output "subnet" {
  value       = google_compute_subnetwork.subnet
}

output "cluster_master_ip_cidr_range" {
  value       = local.cluster_master_ip_cidr_range
}

output "cluster_pods_ip_cidr_range" {
  value       = local.cluster_pods_ip_cidr_range
}

output "cluster_services_ip_cidr_range" {
  value       = local.cluster_services_ip_cidr_range
}
