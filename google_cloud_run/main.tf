resource "google_cloud_run_service" "tf-cloud-run-hello" {
  name                       = "tf-test-hello"
  autogenerate_revision_name = true
  location                   = var.region
  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"     = 1,
        "run.googleapis.com/cpu-throttling"    = true,
        "run.googleapis.com/startup-cpu-boost" = true
      }
    }
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        startup_probe {
          http_get {
            path = "/ready"
          }
          initial_delay_seconds = 5
          timeout_seconds       = 5
          failure_threshold     = 3
          period_seconds        = 5
        }
        liveness_probe {
          http_get {
            path = "/live"
          }
        }
      }
    }
  }

  traffic {
    latest_revision = true
    percent         = 100
  }
}

// Allow unauthenticated invocations from internet
data "google_iam_policy" "noauth" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.tf-cloud-run-hello.location
  project  = google_cloud_run_service.tf-cloud-run-hello.project
  service  = google_cloud_run_service.tf-cloud-run-hello.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

output "cloud_run_url" {
  value       = google_cloud_run_service.tf-cloud-run-hello.status[0].url
  description = "The URL of the Cloud Run service"
}

output "cloud_run_traffic_url" {
  value       = google_cloud_run_service.tf-cloud-run-hello.status[0].traffic[0].url
  description = "The traffic URL of the Cloud Run service"
}