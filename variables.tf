variable "aws_region" { default = "us-west-2" }
variable "gcp_region" { default = "us-west2" }
variable "gcp_zone"   { default = "us-west2-a" }

variable "aws_vpc_cidr"    { default = "10.10.0.0/16" }
variable "aws_subnet_cidr" { default = "10.10.1.0/24" }
variable "gcp_vpc_cidr"    { default = "10.20.0.0/16" }
variable "gcp_subnet_cidr" { default = "10.20.1.0/24" }

variable "aws_instance_type" { default = "t3.micro" }
variable "gcp_machine_type"  { default = "e2-micro" }

# ports that will be allowed mutually
variable "allowed_tcp_ports" {
  type    = list(number)
  default = [22, 80, 443]
}

variable "ssh_public_key"   { default = "" }
variable "gcp_ssh_username" { default = "ubuntu" }

variable "gcp_project_id" {
  description = "Your GCP project ID (e.g. calm-repeater-475316-q0)"
  type        = string
}
