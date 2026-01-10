resource "google_project_service" "dns_api" {
  for_each = toset([
    "dns.googleapis.com",
    "compute.googleapis.com"
  ])

  service            = each.key
  disable_on_destroy = false
}

resource "google_dns_managed_zone" "zone" {
  name     = "sub-rosa-dev"
  dns_name = "${var.domain}."
}

resource "google_compute_managed_ssl_certificate" "cert" {
  name = "sub-rosa-cert"

  managed {
    domains = [var.domain]
  }
}
