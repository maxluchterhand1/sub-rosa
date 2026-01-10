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

provider "google" {
    project = var.project_id
    region  = var.region
}

module "backend" {
  source = "./backend"
  region = var.region
  service_image = var.service_image
}

module "frontend" {
  source = "./frontend"
}

module "dns" {
  source = "./dns"
  domain = "sub-rosa.dev"
}

module "load_balancer" {
  source = "./load_balancer"
  domain = "sub-rosa.dev"
  cloud_run_service_name = module.backend.cloud_run_service_name
  compute_backend_bucket_id = module.frontend.compute_backend_bucket_id
  tls_cert_id = module.dns.tls_cert_id
  dns_zone_name = module.dns.dns_zone_name
  region = var.region
  depends_on = [module.backend, module.frontend, module.dns]
}
