name_prefix       = "xcloud"

aws_region        = "us-west-2"
aws_vpc_cidr      = "10.10.0.0/16"
aws_subnet_cidr   = "10.10.1.0/24"
aws_instance_type = "t3.micro"
# aws_key_name    = "your-keypair"

gcp_project_id    = "YOUR_GCP_PROJECT_ID"
gcp_region        = "us-west2"
gcp_zone          = "us-west2-a"
gcp_vpc_cidr      = "10.20.0.0/16"
gcp_subnet_cidr   = "10.20.1.0/24"
gcp_machine_type  = "e2-micro"

allowed_tcp_ports = [22, 80, 443]
# ssh_public_key  = "ssh-ed25519 AAAA... user@host"
# gcp_ssh_username = "ubuntu"
