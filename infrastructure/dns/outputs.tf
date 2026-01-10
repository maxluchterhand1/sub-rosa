output "tls_cert_id" {
  value = google_compute_managed_ssl_certificate.cert.id
}

output "dns_zone_name" {
  value = google_dns_managed_zone.zone.name
}
