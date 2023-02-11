variable "network_name" {
  default = "us-central1-01"
}
variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}

variable "region" {
  default = "us-central1"
}

variable "subnet_pods" {
}

variable "subnet_service" {

}

variable "project_id" {
  default = "terratest-377320"
}

variable "network" {
}

variable "sub_network" {
}

variable "disable_public_endpoint" {
  type    = bool
  default = true
}

variable "enable_private_nodes" {
  type    = bool
  default = true
}


variable "node_zones" {
  type = list(string)
}


variable "cluster_master_ip_cidr_range" {
  default = "10.100.100.0/28"
}

variable "service_account" {
  type = string
}

variable "main_zone" {
  type = string
}


variable "availability_type" {
  type = map
  default = {
    prod = "REGIONAL"
    dev  = "ZONAL"
  }
}


variable "sql_instance_size" {
  default     = "db-f1-micro"
}

variable "sql_disk_type" {
  default     = "PD_SSD"
}

variable "sql_disk_size" {
  default     = "10"
}

variable "sql_require_ssl" {
  type = bool
  default = false
}

variable "sql_master_zone" {
  default     = "a"
  }

variable "sql_replica_zone" {
  default     = "b"
}

variable "sql_connect_retry_interval" {
  default     = 60
}

variable "sql_user" {
  default     = "admin"
}

variable "sql_pass" {
  
}