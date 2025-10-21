variable "name_prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "allowed_tcp_ports" {
  type = list(number)
}

variable "aws_key_name" {
  type    = string
  default = null
}
