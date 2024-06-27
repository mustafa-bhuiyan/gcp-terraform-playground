resource "google_storage_bucket" "gcp-tf-playground" {
  name     = "gcp-tf-playground"
  location = "US"
  force_destroy = true
}