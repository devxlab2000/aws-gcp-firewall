#######################################
# Global Naming
#######################################
variable "name_prefix" {
  type    = string
  default = "xcloud"
}

#######################################
# AWS Variables
#######################################
variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "aws_vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "aws_subnet_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

variable "aws_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "aws_key_name" {
  type        = string
  default     = null
  description = "Optional existing AWS EC2 key pair name for SSH access"
}

#######################################
# GCP Variables
#######################################
variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID where resources will be created"
}

variable "gcp_region" {
  type    = string
  default = "us-west2"
}

variable "gcp_zone" {
  type    = string
  default = "us-west2-a"
}

variable "gcp_vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "gcp_subnet_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "gcp_machine_type" {
  type    = string
  default = "e2-micro"
}

#######################################
# Shared & Firewall Rules
#######################################
variable "allowed_tcp_ports" {
  type        = list(number)
  default     = [22, 80, 443]
  description = "List of TCP ports to allow between AWS and GCP"
}

#######################################
# SSH / Metadata
#######################################
variable "ssh_public_key" {
  type        = string
  default     = null
  description = "Optional SSH public key to inject into GCP project metadata"
}

variable "gcp_ssh_username" {
  type        = string
  default     = "ubuntu"
  description = "Username used for GCP SSH access (defaults to ubuntu)"
}
