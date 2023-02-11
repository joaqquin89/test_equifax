data "google_container_engine_versions" "default" {
  location = var.region
  version_prefix = "1.21."
}

resource "google_container_cluster" "clustergke" {
  name     = "clustergke"
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version = data.google_container_engine_versions.default.latest_master_version

  ip_allocation_policy {
    cluster_ipv4_cidr_block = var.pods_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }
  network = var.network_name
  subnetwork = var.subnet_name

  logging_service = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
    }
  }

  master_auth {

	client_certificate_config {
      issue_client_certificate = false
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = var.authorized_ipv4_cidr_block != null ? [var.authorized_ipv4_cidr_block] : []
    content {
      cidr_blocks {
        cidr_block   = master_authorized_networks_config.value
        display_name = "External Control Plane access"
      }
    }
  }

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  release_channel {
	  channel = "STABLE"
  }

  addons_config {
    // Enable network policy (Calico)
    network_policy_config {
        disabled = false
      }
  }

  /* Enable network policy configurations (like Calico).
  For some reason this has to be in here twice. */
  network_policy {
    enabled = "true"
  }

  workload_identity_config {
    workload_pool = format("%s.svc.id.goog", var.project_id)
  }
}

resource "google_container_node_pool" "linux_node_pool" {
  name           = "${google_container_cluster.clustergke.name}--linux-node-pool"
  location       = google_container_cluster.clustergke.location
  node_locations = var.node_zones
  cluster        = google_container_cluster.clustergke.name
  node_count     = 3
  autoscaling {
    max_node_count = 3
    min_node_count = 3
  }
  max_pods_per_node = 50

  node_config {
    preemptible  = true
    disk_size_gb = 10
    machine_type = "e2-micro"  
    service_account = var.service_account
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]

    labels = {
      cluster = google_container_cluster.clustergke.name
    }

    shielded_instance_config {
      enable_secure_boot = true
    }

    metadata = {
      // Set metadata on the VM to supply more entropy.
      google-compute-enable-virtio-rng = "true"
      // Explicitly remove GCE legacy metadata API endpoint.
      disable-legacy-endpoints = "true"
    }
  }

  upgrade_settings {
    max_surge       = 3
    max_unavailable = 3
  }
}
