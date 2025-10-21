resource "google_compute_network" "vpc" {
  name                    = "${var.name_prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name_prefix}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_address" "public" {
  name   = "${var.name_prefix}-addr"
  region = var.region
}

# Optional project-wide SSH key injection
resource "google_compute_project_metadata" "ssh" {
  count = var.ssh_public_key == null ? 0 : 1

  metadata = {
    ssh-keys = "${var.gcp_ssh_username}:${var.ssh_public_key}"
  }
}

resource "google_compute_firewall" "allow_peer" {
  name    = "${var.name_prefix}-allow-aws-peer"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  dynamic "allow" {
    for_each = var.allowed_tcp_ports
    content {
      protocol = "tcp"
      ports    = [allow.value]
    }
  }

  source_ranges = ["${var.peer_public_ip}/32"]
  target_tags   = ["${var.name_prefix}-vm"]
}

resource "google_compute_instance" "vm" {
  name         = "${var.name_prefix}-vm"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["${var.name_prefix}-vm"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {
      nat_ip = google_compute_address.public.address
    }
  }
}
