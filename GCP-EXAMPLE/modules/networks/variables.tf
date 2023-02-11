variable "project_id" {
  type = string
  description = "The project ID to host the network in"
}

variable "region" {
  type = string
  description = "The region to use"
}

variable "cluster_master_ip_cidr_range" {
  type = string
}

variable "cluster_pods_ip_cidr_range" {
  type = string
}

variable "cluster_services_ip_cidr_range" {
  type = string
}
