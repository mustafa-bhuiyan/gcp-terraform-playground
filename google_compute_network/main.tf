# VPC Network
resource "google_compute_network" "infra-test-vpc-network" {
  name                    = "infra-test-vpc"
  description             = "infra-test-vpc for non-prod environment"
  auto_create_subnetworks = false
}

# Subnetwork with primary and secondary IP ranges, and Private Google Access ON
resource "google_compute_subnetwork" "infra-test-vpc-subnetwork" {
  name          = "infra-test-vpc-subnet-1"
  description   = "Primary Subnet"
  ip_cidr_range = "10.20.0.0/24"
  network       = google_compute_network.infra-test-vpc-network.self_link
  region        = "us-central1"

  secondary_ip_range = [{
    range_name    = "gke-pods"
    ip_cidr_range = "10.142.0.0/17"
    },
    {
      range_name    = "gke-services"
      ip_cidr_range = "10.142.128.0/22"
  }]
  private_ip_google_access = true
}

# Subnetwork for internal HTTPS load balancer or 
resource "google_compute_subnetwork" "infra-test-vpc-internal-lb-subnetwork" {
  name          = "infra-test-vpc-internal-lb-subnet"
  description   = "Internal HTTPS LB Subnetwork"
  region        = "us-central1"
  ip_cidr_range = "10.20.1.0/24"
  network       = google_compute_network.infra-test-vpc-network.self_link
  purpose       = "REGIONAL_MANAGED_PROXY" // previous value was "INTERNAL_HTTPS_LOAD_BALANCER
  role          = "ACTIVE"
}

output "vpc_fully_qualified_id" {
  value = google_compute_network.infra-test-vpc-network.self_link
}

output "infra-test-vpc-subnetwork_fully_qualified_id" {
  value = google_compute_subnetwork.infra-test-vpc-subnetwork.self_link
}

output "infra-test-vpc-internal-lb-subnetwork_fully_qualified_id" {
  value = google_compute_subnetwork.infra-test-vpc-internal-lb-subnetwork.self_link
}