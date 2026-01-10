output "cloud_run_service_name" {
  value = google_cloud_run_v2_service.app_service.name
}

output "service_account_email" {
  value = google_service_account.app_sa.email
}

output "database_id" {
  value = google_firestore_database.database.id
}

output "artifact_registry_uri" {
  value = google_artifact_registry_repository.image_repo.registry_uri
}
