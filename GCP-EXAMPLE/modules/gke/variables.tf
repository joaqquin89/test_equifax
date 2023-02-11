variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "node_zones" {
  type = list(string)
}

variable "network_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "service_account" {
  type = string
}

variable "pods_ipv4_cidr_block" {
  type = string
}

variable "services_ipv4_cidr_block" {
  type = string
}

variable "authorized_ipv4_cidr_block" {
  type = string
  default = null
}

variable "master_ipv4_cidr_block" {
  type = string
}
