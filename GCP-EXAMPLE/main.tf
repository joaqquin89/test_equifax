terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}


module "google_networks" {
  source = "./modules/networks"

  project_id                     = var.project_id
  region                         = var.region
  cluster_master_ip_cidr_range   = "10.100.100.0/28"
  cluster_pods_ip_cidr_range     = "10.101.0.0/16"
  cluster_services_ip_cidr_range = "10.102.0.0/16"
}

module "gke" {
  depends_on = [
    module.google_networks
  ]
  source = "./modules/gke"

  project_id                 = var.project_id
  region                     = var.region
  node_zones                 = var.node_zones
  service_account            = var.service_account
  network_name               = module.google_networks.network.name
  subnet_name                = module.google_networks.subnet.name
  master_ipv4_cidr_block     = module.google_networks.cluster_master_ip_cidr_range
  pods_ipv4_cidr_block       = module.google_networks.cluster_pods_ip_cidr_range
  services_ipv4_cidr_block   = module.google_networks.cluster_services_ip_cidr_range
  authorized_ipv4_cidr_block = "${module.bastion.ip}/32"
}

module "bastion" {
  source = "./modules/bastion"
  depends_on = [
    module.google_networks
  ]
  project_id   = var.project_id
  region       = var.region
  zone         = var.main_zone
  bastion_name = "gke"
  network_name = module.google_networks.network.name
  subnet_name  = module.google_networks.subnet.name
}

data "google_client_config" "provider" {}


provider "kubernetes" {
  version = "1.10.0"
  host    = module.gke.host
  token   = data.google_client_config.provider.access_token
  client_certificate =  base64decode(module.gke.client_certificate)
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  client_key = base64decode(module.gke.client_key)
}

resource "google_compute_address" "loadbalancer_ip" {
  name   = "loadbalancerip"
  region = var.region
}

resource "kubernetes_service" "app" {
  metadata {
    name = "app"
  }

  spec {
    selector = {
      run = "app"
    }

    session_affinity = "None"

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 8080
    }

    type             = "LoadBalancer"
    load_balancer_ip = google_compute_address.loadbalancer_ip.address
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = "app"

    labels = {
      run = "app"
    }
  }

  spec {
    replicas = 1

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge       = 1
        max_unavailable = 0
      }
    }

    selector {
      match_labels = {
        run = "app"
      }
    }

    template {
      metadata {
        name = "app"
        labels = {
          run = "app"
        }
      }

      spec {
        container {
          image = "dockersamples/static-site"
          name  = "app"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}


module "cloudsql" {
  source                     = "./modules/cloudsql"
  region                     = var.region
  availability_type          = var.availability_type["prod"]
  sql_instance_size          = var.sql_instance_size
  sql_disk_type              = var.sql_disk_type
  sql_disk_size              = var.sql_disk_size
  sql_require_ssl            = var.sql_require_ssl
  sql_master_zone            = var.sql_master_zone
  sql_connect_retry_interval = var.sql_connect_retry_interval
  sql_replica_zone           = var.sql_replica_zone
  sql_user                   = var.sql_user
  sql_pass                   = var.sql_pass
  network_deploy             = data.google_client_config.provider
}


# Get the managed DNS zone
data "google_dns_managed_zone" "_" {
  provider = google
  project  = var.project_id
  name     = var.dns_zone
}

# Add the IP to the DNS
resource "google_dns_record_set" "_" {
  provider     = google
  project      = var.project_id
  name         = "gke-equifax-test.${data.google_dns_managed_zone._.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone._.name
  rrdatas      = [google_compute_address.loadbalancer_ip.address]
}

## REGISTRY

resource "google_container_registry" "registry" {
  project  = "my-project"
  location = "EU"
}