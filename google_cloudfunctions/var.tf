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

variable "function-version" {
  type        = string
  description = "Cloud Function Version"
  default     = "v1"
}