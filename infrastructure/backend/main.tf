terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.15.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "7.15.0"
    }
  }
}

data "google_project" "project" {}

resource "google_project_service" "enabled_apis" {
  for_each = toset([
    "run.googleapis.com",
    "firestore.googleapis.com",
    "iam.googleapis.com",
    "cloudbuild.googleapis.com"
  ])
  service            = each.key
  disable_on_destroy = false
}

resource "google_service_account" "app_sa" {
  account_id   = "sub-rosa-backend-sa"
  display_name = "Sub Rosa Backend Service Account"
}

resource "google_project_iam_member" "user" {
  project = data.google_project.project.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}

resource "google_firestore_database" "database" {
  project                     = data.google_project.project.project_id
  name                        = "sub-rosa"
  location_id                 = var.region
  type                        = "FIRESTORE_NATIVE"
  concurrency_mode            = "OPTIMISTIC"
  app_engine_integration_mode = "DISABLED"
  deletion_policy             = "DELETE"
  depends_on                  = [google_project_service.enabled_apis]
}

resource "google_artifact_registry_repository" "image_repo" {
  format        = "docker"
  repository_id = "sub-rosa"
}

resource "google_cloud_run_v2_service" "app_service" {
  name                = "sub-rosa-${var.region}"
  location            = var.region
  ingress             = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  deletion_protection = false

  template {
    service_account = google_service_account.app_sa.email

    containers {
      image = var.service_image

      env {
        name  = "GCP_PROJECT_ID"
        value = data.google_project.project.project_id
      }

      env {
        name  = "FIRESTORE_DB_NAME"
        value = google_firestore_database.database.name
      }

      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 5
    }
  }

  depends_on = [google_project_service.enabled_apis]
}

resource "google_cloud_run_service_iam_member" "public_access" {
  member   = "allUsers"
  role     = "roles/run.invoker"
  service  = google_cloud_run_v2_service.app_service.name
  location = google_cloud_run_v2_service.app_service.location
}
