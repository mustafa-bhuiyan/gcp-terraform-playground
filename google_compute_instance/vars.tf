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