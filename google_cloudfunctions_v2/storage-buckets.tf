resource "random_id" "id" {
  byte_length = 8
}

# Cloud Function Storage bucket
resource "google_storage_bucket" "gcf-v2-hellohttp-bucket" {
  name     = "gcf-${var.function-version}-sources-${random_id.id.hex}"
  location = "us-central1"
  labels = {
    cloud_function = "tf-hello-http-cloudfunction-v2"
  }
  uniform_bucket_level_access = true
}

data "archive_file" "source-zip" {
  type        = "zip"
  source_dir  = "helloHttp"
  output_path = "helloHttp.zip"
}

resource "google_storage_bucket_object" "gcf-v2-hellohttp-source-artifact" {
  bucket = google_storage_bucket.gcf-v2-hellohttp-bucket.id
  name   = "helloHttp.zip"
  source = data.archive_file.source-zip.output_path
}

#Trigger bucket
resource "google_storage_bucket" "gcf-v2-test-trigger-bucket" {
  name     = "gcf-v2-test-trigger-bucket-${random_id.id.hex}"
  location = "us-central1"
  labels = {
    bucket-trigger-function = "gcf-v2-hello-http"
  }
}

# To use GCS CloudEvent triggers, the GCS service account requires the Pub/Sub Publisher(roles/pubsub.publisher) IAM role in the specified project.
# (See https://cloud.google.com/eventarc/docs/run/quickstart-storage#before-you-begin)
data "google_storage_project_service_account" "gcs-default-serviceAccount" {
}

# Before creating a trigger for direct events from Cloud Storage, grant the Pub/Sub Publisher role (roles/pubsub.publisher) to the Cloud Storage service agent:
resource "google_project_iam_member" "gcs_pubsub_publishing" {
  project = var.project-name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.gcs-default-serviceAccount.email_address}"
}

# Create a Service Account (SA) instead of using GCS default SA to test the event triggers
resource "google_service_account" "eventarc-test-service-account" {
  account_id   = "eventarc-test-service-account"
  display_name = "Test Service Account - used for both the cloud function and eventarc trigger in the test"
}

# Permissions on the service account used by the function and Eventarc trigger
resource "google_project_iam_member" "gcf-invoker" {
  project = var.project-name
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.eventarc-test-service-account.email}"
  depends_on = [google_project_iam_member.gcs_pubsub_publishing,
  google_service_account.eventarc-test-service-account]
}

# IAM policy binding for the Eventarc event receiver role
resource "google_project_iam_member" "eventarc_event_receiver_binding" {
  project    = var.project-name
  role       = "roles/eventarc.eventReceiver"
  member     = "serviceAccount:${google_service_account.eventarc-test-service-account.email}"
  depends_on = [google_project_iam_member.gcf-invoker]
}

#IAM Policy for gen2 cloudfunction to build container
resource "google_project_iam_member" "artifactregistry-reader" {
  project    = var.project-name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.eventarc-test-service-account.email}"
  depends_on = [google_project_iam_member.eventarc_event_receiver_binding]
}

output "gcs-default-serviceAccount-email" {
  value       = data.google_storage_project_service_account.gcs-default-serviceAccount.email_address
  description = "Default GCS service account given publisher role to publish event to eventarc"
}

output "eventarc-test-service-account-email" {
  value       = google_service_account.eventarc-test-service-account.email
  description = "The Test service account created for the eventarc and cloudfunction"
}

output "gcf-source-bucket-name" {
  value = google_storage_bucket.gcf-v2-hellohttp-bucket.name
}

output "gcf-trigger-bucket-name" {
  value = google_storage_bucket.gcf-v2-test-trigger-bucket.name
}