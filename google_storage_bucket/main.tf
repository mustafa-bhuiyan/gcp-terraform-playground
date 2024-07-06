resource "google_storage_bucket" "gcp-tf-playground" {
  name          = "gcp-tf-playground"
  location      = "US"
  force_destroy = true
}

resource "google_storage_bucket_object" "webp1" {
  name       = "webp1"
  source     = "1.webp"
  bucket     = google_storage_bucket.gcp-tf-playground.name
  depends_on = [google_storage_bucket.gcp-tf-playground]
}

resource "google_storage_bucket_object" "butterfly" {
  name       = "butterfly"
  source     = "butterfly.webp"
  bucket     = google_storage_bucket.gcp-tf-playground.name
  depends_on = [google_storage_bucket.gcp-tf-playground]
}