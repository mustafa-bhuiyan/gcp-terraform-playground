// This is tf sdk for google. 
// This is optional to mention here as the latest will be automatically downloaded by tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.35.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = "sonic-trail-427517-r2"
  region  = "us-central1"
  zone    = "us-central1-a"
  //credentials = "../creds/keys.json"
}