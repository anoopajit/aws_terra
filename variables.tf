variable "cloud_provider" {
  description = "Cloud provider to deploy to"
  type        = string
  validation {
    condition = contains(["aws", "azure", "gcp"], var.cloud_provider)
    error_message = "Cloud provider must be aws, azure, or gcp."
  }
}

variable "region" {
  description = "Region to deploy resources"
  type        = string
}

variable "instance_name" {
  description = "Name for the web server instance"
  type        = string
  default     = "webserver"
}



variable "allowed_ports" {
  description = "List of ports to allow inbound traffic"
  type        = list(number)
  default     = [80, 443, 22]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)."
  type        = string
}
