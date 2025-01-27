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