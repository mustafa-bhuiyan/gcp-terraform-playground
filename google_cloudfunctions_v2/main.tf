resource "google_cloudfunctions2_function" "gcf-v2-hellohttp" {
  depends_on = [google_project_iam_member.artifactregistry-reader,
    google_project_iam_member.eventarc_event_receiver_binding,
    google_project_iam_member.gcf-invoker,
    google_project_iam_member.gcs_pubsub_publishing,
    google_storage_bucket.gcf-v2-hellohttp-bucket,
  google_storage_bucket.gcf-v2-test-trigger-bucket]

  name        = "gcf-v2-hellohttp"
  location    = var.region
  description = "Gen2 CloudFunction invoked by CloudStorage Object Creation Event"

  build_config {
    runtime     = "nodejs20"
    entry_point = "helloHttp"
    environment_variables = {
      BUILD_CONFIG_TEST = "build_test"
    }
    source {
      storage_source {
        bucket = google_storage_bucket.gcf-v2-hellohttp-bucket.name
        object = google_storage_bucket_object.gcf-v2-hellohttp-source-artifact.name
      }
    }
  }

  service_config {
    max_instance_count = 3
    min_instance_count = 1
    timeout_seconds    = 60
    environment_variables = {
      SERVICE_CONFIG_TEST = "config_test"
    }
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.eventarc-test-service-account.email
  }

  event_trigger {
    event_type            = "google.cloud.storage.object.v1.finalized"
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.eventarc-test-service-account.email
    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.gcf-v2-test-trigger-bucket.name
    }
  }
}