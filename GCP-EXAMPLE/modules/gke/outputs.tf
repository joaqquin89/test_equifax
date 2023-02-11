output "name" {
  value = google_container_cluster.clustergke.name
}

output "host" {
  value = google_container_cluster.clustergke.endpoint
}

output "client_certificate" {
  value = google_container_cluster.clustergke.master_auth[0].client_certificate
}

output "cluster_ca_certificate" {
  value = google_container_cluster.clustergke.master_auth[0].cluster_ca_certificate
}

output "client_key" {
  value = google_container_cluster.clustergke.master_auth[0].client_key
}