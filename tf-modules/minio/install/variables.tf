variable "minio_admin_access_key" {
  default = "AKIAIOSFODNN7EXAMPLE"
}
variable "minio_admin_secret_key" {
  default = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

variable "minio_ingress_host" {
  default = ["minio.172-17-177-11.sslip.io"]
}
variable "minio_ingress_redirect" {
  default = false
}

variable "minio_persistence_size" {
  default = "10Gi"
}

variable "minio_persistence_storageClass" {
  default = ""
}
