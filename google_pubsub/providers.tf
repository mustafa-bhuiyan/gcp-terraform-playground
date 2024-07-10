provider "google" {
  project = var.project-name
  region  = "us-central1"
}

data "google_project" "project" {}