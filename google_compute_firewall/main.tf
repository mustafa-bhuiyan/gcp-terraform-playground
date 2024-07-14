resource "google_compute_firewall" "infra-test-vpc-allow-all-internal" {
  name    = "infra-test-vpc-allow-all-internal"
  network = var.vpc-name
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = [var.primary-subnet-ip-range, var.gke-pods-ip-range, var.gke-services-ip-range, var.lb-ip-range]
}

resource "google_compute_firewall" "infra-test-vpc-allow-ssh" {
  name    = "infra-test-vpc-allow-ssh"
  network = var.vpc-name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = [var.google-iap-ip-range]
}

resource "google_compute_firewall" "infra-test-vpc-allow-ssh-ftp" {
  name    = "infra-test-vpc-allow-ssh-ftp"
  network = var.vpc-name
  allow {
    protocol = "tcp"
    ports    = ["21", "22", "2222"]
  }
  source_ranges = [var.google-iap-ip-range]
}

resource "google_compute_firewall" "infra-test-vpc-allow-icmp" {
  name    = "allow-icmp"
  network = var.vpc-name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}