terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.15.0"
    }
  }
}

data "google_project" "project" {}

resource "google_storage_bucket" "frontend_bucket" {
  location = "US"
  name     = "sub-rosa-frontend"
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page = "index.html"
  }
}

resource "google_storage_bucket_object" "index_html" {
  bucket = google_storage_bucket.frontend_bucket.name
  name   = "index.html"
  source = "../frontend/index.html"
  content_type = "text/html"
}

resource "google_storage_bucket_object" "favicon" {
  bucket = google_storage_bucket.frontend_bucket.name
  name   = "favicon.png"
  source = "../frontend/favicon.png"
  content_type = "image/png"
}

resource "google_storage_bucket_iam_member" "lb_access" {
  bucket = google_storage_bucket.frontend_bucket.name
  role   = "roles/storage.objectViewer"
  member   = "allUsers"
}

resource "google_compute_backend_bucket" "compute_backend_bucket" {
  bucket_name = google_storage_bucket.frontend_bucket.name
  name        = "sub-rosa-frontend"
  enable_cdn  = true
}

