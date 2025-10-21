module "aws_side" {
  source            = "./modules/aws-ec2-firewall"
  name_prefix       = var.name_prefix
  region            = var.aws_region
  vpc_cidr          = var.aws_vpc_cidr
  subnet_cidr       = var.aws_subnet_cidr
  instance_type     = var.aws_instance_type
  allowed_tcp_ports = var.allowed_tcp_ports
  aws_key_name      = var.aws_key_name
}

module "gcp_side" {
  source            = "./modules/gcp-vm-firewall"
  name_prefix       = var.name_prefix
  project_id        = var.gcp_project_id
  region            = var.gcp_region
  zone              = var.gcp_zone
  vpc_cidr          = var.gcp_vpc_cidr
  subnet_cidr       = var.gcp_subnet_cidr
  machine_type      = var.gcp_machine_type
  allowed_tcp_ports = var.allowed_tcp_ports

  # Allow from AWS EIP /32 on the GCP firewall
  peer_public_ip = module.aws_side.public_ip

  ssh_public_key   = var.ssh_public_key
  gcp_ssh_username = var.gcp_ssh_username
}

# Tighten AWS ingress so only the GCP VM /32 can reach it
resource "aws_security_group_rule" "aws_ingress_from_gcp_tcp" {
  for_each          = toset([for p in var.allowed_tcp_ports : tostring(p)])
  type              = "ingress"
  protocol          = "tcp"
  from_port         = tonumber(each.key)
  to_port           = tonumber(each.key)
  security_group_id = module.aws_side.sg_id
  cidr_blocks       = ["${module.gcp_side.public_ip}/32"]
}

resource "aws_security_group_rule" "aws_ingress_from_gcp_icmp" {
  type              = "ingress"
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1
  security_group_id = module.aws_side.sg_id
  cidr_blocks       = ["${module.gcp_side.public_ip}/32"]
}
