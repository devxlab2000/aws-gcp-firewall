# ========== AWS side ==========
resource "aws_vpc" "vpc" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "fw-only-aws-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "fw-only-aws-igw" }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.aws_subnet_cidr
  map_public_ip_on_launch = true
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  route { cidr_block = "0.0.0.0/0", gateway_id = aws_internet_gateway.igw.id }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

# Elastic IP for static addressing
resource "aws_eip" "eip" { domain = "vpc" }

# Security group allowing only GCP IP (will be filled after GCP address known)
resource "aws_security_group" "sg" {
  name   = "fw-only-aws-sg"
  vpc_id = aws_vpc.vpc.id

  # dynamic TCP ingress
  dynamic "ingress" {
    for_each = var.allowed_tcp_ports
    content {
      description = "TCP ${ingress.value} from GCP"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["${google_compute_address.gcp_ip.address}/32"]
    }
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${google_compute_address.gcp_ip.address}/32"]
  }

  egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
}

data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name", values = ["amzn2-ami-hvm-*-x86_64-gp2"] }
}

resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.al2.id
  instance_type               = var.aws_instance_type
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name                    = var.ssh_public_key == "" ? null : aws_key_pair.kp[0].key_name
  tags = { Name = "fw-only-aws-ec2" }
}

resource "aws_key_pair" "kp" {
  count      = var.ssh_public_key == "" ? 0 : 1
  key_name   = "fw-only-key"
  public_key = var.ssh_public_key
}

resource "aws_eip_association" "assoc" {
  instance_id   = aws_instance.ec2.id
  allocation_id = aws_eip.eip.id
}

# ========== GCP side ==========
resource "google_compute_network" "vpc" {
  name                    = "fw-only-gcp-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "fw-only-gcp-subnet"
  ip_cidr_range = var.gcp_subnet_cidr
  region        = var.gcp_region
  network       = google_compute_network.vpc.id
}

resource "google_compute_address" "gcp_ip" {
  name   = "fw-only-gcp-ip"
  region = var.gcp_region
}

locals { allowed_tcp_ports_str = [for p in var.allowed_tcp_ports : tostring(p)] }

resource "google_compute_firewall" "fw" {
  name    = "fw-only-allow-from-aws"
  network = google_compute_network.vpc.name
  allow { protocol = "icmp" }
  allow { protocol = "tcp", ports = local.allowed_tcp_ports_str }
  source_ranges = ["${aws_eip.eip.public_ip}/32"]
  direction     = "INGRESS"
  target_tags   = ["fw-only-allow-from-aws"]
}

resource "google_compute_instance" "vm" {
  name         = "fw-only-gcp-vm"
  machine_type = var.gcp_machine_type
  zone         = var.gcp_zone
  tags         = ["fw-only-allow-from-aws"]

  boot_disk { initialize_params { image = "ubuntu-os-cloud/ubuntu-2204-lts" } }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config { nat_ip = google_compute_address.gcp_ip.address }
  }

  metadata = var.ssh_public_key == "" ? {} : {
    ssh-keys = "${var.gcp_ssh_username}:${var.ssh_public_key}"
  }
}

# ========== Outputs ==========
output "aws_public_ip" { value = aws_eip.eip.public_ip }
output "gcp_public_ip" { value = google_compute_address.gcp_ip.address }

output "summary" {
  value = <<EOT
Direct connectivity established via firewalls:
- AWS instance: ${aws_eip.eip.public_ip}
- GCP instance: ${google_compute_address.gcp_ip.address}

Only each other's IPs are whitelisted on allowed ports (${join(",", local.allowed_tcp_ports_str)}).
No VPN or scripts used.
EOT
}
