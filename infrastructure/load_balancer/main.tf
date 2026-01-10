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

resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "dns.googleapis.com"
  ])

  service            = each.key
  disable_on_destroy = false
}

resource "google_compute_region_network_endpoint_group" "service_neg" {
  name   = "sub-rosa-api"
  region = var.region
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = var.cloud_run_service_name
  }
}

resource "google_compute_backend_service" "api" {
  name = "sub-rosa-api"
  protocol = "HTTP"
  port_name = "http"
  timeout_sec = 30

  backend {
    group = google_compute_region_network_endpoint_group.service_neg.id
  }
}

resource "google_compute_url_map" "http_redirect_map" {
  name = "sub-rosa-http-redirect"

  default_url_redirect {
    https_redirect = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query = false
  }
}

resource "google_compute_url_map" "https_url_map" {
  name = "sub-rosa"

  default_service = var.compute_backend_bucket_id

  host_rule {
    hosts = [var.domain]
    path_matcher = "api-paths"
  }

  path_matcher {
    name = "api-paths"
    default_service = var.compute_backend_bucket_id

    path_rule {
      paths = ["/v1/*"]
      service = google_compute_backend_service.api.id
    }
  }
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "sub-rosa-http"
  url_map = google_compute_url_map.http_redirect_map.id
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name    = "sub-rosa-https"
  url_map = google_compute_url_map.https_url_map.id
  ssl_certificates = [var.tls_cert_id]
}

resource "google_compute_global_address" "lb_ip" {
  name = "sub-rosa"
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name   = "sub-rosa-http-forwarding"
  target = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.lb_ip.address
}

resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name   = "sub-rosa"
  target = google_compute_target_https_proxy.https_proxy.id
  port_range = "443"
  ip_address = google_compute_global_address.lb_ip.address
}

resource "google_dns_record_set" "lb_a_record" {
  managed_zone = var.dns_zone_name
  name         = "${var.domain}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.lb_ip.address]
}

resource "google_dns_record_set" "lb_www_cname" {
  managed_zone = var.dns_zone_name
  name         = "www.${var.domain}."
  type         = "CNAME"
  ttl          = 300
  rrdatas      = [google_dns_record_set.lb_a_record.name]
}
