variable "name_prefix" {
  type = string
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "allowed_tcp_ports" {
  type = list(number)
}

variable "peer_public_ip" {
  type = string
}

variable "ssh_public_key" {
  type    = string
  default = null
}

variable "gcp_ssh_username" {
  type    = string
  default = "ubuntu"
}
