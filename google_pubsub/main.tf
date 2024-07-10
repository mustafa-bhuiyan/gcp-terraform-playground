resource "google_pubsub_topic" "tf-test-topic" {
  name = "tf-test-topic"
  labels = {
    env        = "test"
    topic-type = "regular"
  }
  message_retention_duration = "86600s" // 1 day
}

resource "google_pubsub_topic" "tf-test-dead-letter-topic" {
  name = "tf-test-dead-letter-topic"
  labels = {
    env        = "test"
    topic-type = "dead-letter"
  }
  message_retention_duration = "604800s" // 7 days
}

resource "google_pubsub_subscription" "tf-test-subscription" {
  name  = "tf-test-subscription"
  topic = google_pubsub_topic.tf-test-topic.id
  labels = {
    env               = "test"
    subscription-type = "regular"
  }
  message_retention_duration = "1200s" // 20 minutes
  ack_deadline_seconds       = 10
  retain_acked_messages      = false
  enable_message_ordering    = false
  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.tf-test-dead-letter-topic.id
    max_delivery_attempts = 5
  }
  depends_on = [google_pubsub_topic.tf-test-topic,
  google_pubsub_topic.tf-test-dead-letter-topic]
}

resource "google_pubsub_subscription" "tf-test-dead-letter-subscription" {
  name  = "tf-test-dead-letter-subscription"
  topic = google_pubsub_topic.tf-test-dead-letter-topic.id
  labels = {
    env               = "test"
    subscription-type = "dead-letter"
  }
  message_retention_duration = "604800s" // 7 days
  ack_deadline_seconds       = 10
  retain_acked_messages      = false
  enable_message_ordering    = false
  retry_policy {
    minimum_backoff = "10s"
  }
  depends_on = [google_pubsub_topic.tf-test-dead-letter-topic]
}

/* The publisher and subscriber roles are required to the google managed pubsub service account 
in order to enable publishing message to the dead-letter topic and forward/move the message 
from the subscription to the dead-letter topic.
*/
resource "google_project_iam_binding" "pubsub-publisher" {
  project = data.google_project.project.project_id
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"]
}

resource "google_project_iam_binding" "pubsub-subscriber" {
  project = data.google_project.project.project_id
  role    = "roles/pubsub.subscriber"
  members = ["serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"]
}

/*
    Steps to test dead lettering:
    1. Publish a Message: `gcloud pubsub topics publish tf-test-topic --message "Test message -1"`
    2. Pull the Message: `gcloud pubsub subscriptions pull tf-test-subscription` 
    // the msg will not be auto acked. Repeat this step until the message delivery attempts 
        exceed the configured max_delivery_attempts.
    3. Check Dead Letter Topic: gcloud pubsub subscriptions pull tf-test-dead-letter-subscription

    Notes:
	•	Timing: Ensure that your subscription’s ack_deadline_seconds and max_delivery_attempts are configured appropriately for your testing scenarios.
	•	Permissions: Make sure the Pub/Sub service account has sufficient permissions (roles/pubsub.publisher and roles/pubsub.subscriber) to perform these actions.
*/