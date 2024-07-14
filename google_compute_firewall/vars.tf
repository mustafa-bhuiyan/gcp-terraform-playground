variable "project-name" {
  type        = string
  description = "GCP Project Name"
  default     = "sonic-trail-427517-r2"
}

variable "region" {
  type        = string
  description = "GCP Project Region"
  default     = "us-central1"
}

variable "vpc-name" {
  type        = string
  description = "The VPC name"
  default     = "infra-test-vpc"
}

variable "primary-subnet-name" {
  type        = string
  description = "The VPC Primary Subsnetwork name"
  default     = "infra-test-vpc-subnet-1"
}

variable "lb-subnet-name" {
  type        = string
  description = "The VPC Load Balancer Subsnetwork name"
  default     = "infra-test-vpc-internal-lb-subnet"
}

variable "primary-subnet-ip-range" {
  type    = string
  default = "10.20.0.0/24"
}

variable "gke-pods-ip-range" {
  type    = string
  default = "10.142.0.0/17"
}

variable "gke-services-ip-range" {
  type    = string
  default = "10.142.128.0/22"
}

variable "lb-ip-range" {
  type    = string
  default = "10.20.1.0/24"
}

variable "google-iap-ip-range" {
  type = string
  default = "35.235.240.0/20"
}