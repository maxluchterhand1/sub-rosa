variable "project_id" {
    description = "The ID of the GCP project."
    type        = string
}

variable "region" {
    description = "The GCP region to deploy resources in."
    type        = string
}

variable "service_image" {
    description = "The Docker image for the service."
    type        = string
}
