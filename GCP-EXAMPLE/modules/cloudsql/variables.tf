variable "region" {
}

variable "availability_type" {
}

variable "sql_instance_size" {

}

variable "sql_disk_type" {
    type = string
}

variable "sql_disk_size" {
    type = string
}

variable "sql_require_ssl" {
    type = bool
}

variable "sql_connect_retry_interval" {
    type = number
}

variable "sql_master_zone" {
}

variable "sql_replica_zone" {
}

variable "sql_user" {
}

variable "sql_pass" {
}

variable "network_deploy" {
}