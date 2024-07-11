locals {
  function-version = "v1"
}

resource "random_id" "id" {
  byte_length = 8
}

resource "google_storage_bucket" "gcf-helloHttp-bucket" {
  name     = "gcf-${var.function-version}-${random_id.id.hex}-source" # Every bucket name must be globally unique
  location = "US"
  labels = {
    cloud_function = "tf-hello-http-cloudfunction"
  }
  uniform_bucket_level_access = true
}

data "archive_file" "gcf-helloHttp-archive" {
  type        = "zip"
  source_dir  = "helloHttp"
  output_path = "helloHttp.zip"
}

resource "google_storage_bucket_object" "gcf-helloHttp-source-artifact" {
  bucket = google_storage_bucket.gcf-helloHttp-bucket.id
  name   = "helloHttp.zip"
  source = data.archive_file.gcf-helloHttp-archive.output_path
}

resource "google_cloudfunctions_function" "gcf-helloHttp" {
  name        = "gcf-helloHttp-tf"
  description = "Cloud Function created by Terraform"
  runtime     = "nodejs20"
  build_environment_variables = {
    "FOO" = "bar"
  }
  available_memory_mb          = 128
  entry_point                  = "helloHttp"
  trigger_http                 = true
  https_trigger_security_level = "SECURE_ALWAYS"
  ingress_settings             = "ALLOW_ALL"
  source_archive_bucket        = google_storage_bucket.gcf-helloHttp-bucket.name
  source_archive_object        = google_storage_bucket_object.gcf-helloHttp-source-artifact.name
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "noauth" {
  project        = google_cloudfunctions_function.gcf-helloHttp.project
  cloud_function = google_cloudfunctions_function.gcf-helloHttp.name
  region         = google_cloudfunctions_function.gcf-helloHttp.region
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}