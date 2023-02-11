output "public_url" {
  value = "http://${google_compute_address.loadbalancer_ip.address}"
}
