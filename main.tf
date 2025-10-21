module "aws_side" {
  source = "./modules/aws-ec2-firewall"
  name_prefix = "xcloud"
  region = var.aws_region
}

module "gcp_side" {
  source = "./modules/gcp-vm-firewall"
  name_prefix = "xcloud"
  project_id = var.gcp_project_id
  region = var.gcp_region
  zone = var.gcp_zone
}