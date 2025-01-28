variable "sq_version" {
  description   = "version of SonrQube chosen by front end"
  type          = string
  sensitive     = false
  default       = "2025.1.0.102418"
}

variable "admin_password" {
  description = "The admin password for the VM"
  type        = string
  sensitive   = true
}

variable "port_run_id" {
    type        = string
    description = "The runID of the action run that created the entity"
}

variable "port_client_id" {
    type        = string
    description = "The Port client ID"
}

variable "port_client_secret" {
    type        = string
    description = "The Port client secret"
}

variable "base_url" {
    type        = string
    description = "The Port API URL"
}