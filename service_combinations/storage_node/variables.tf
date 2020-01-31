variable "issuer_name" {
  default = "cluster-issuer"
}
variable "issuer_letsencrypt_enabled" {
  default = false
}

variable "issuer_selfsigned_enabled" {
  default = true
}

variable "issuer_letsencrypt" {
  default = "staging"
}

variable "issuer_letsencrypt_email" {
  default = "user@example.com"
}

variable "hcloud_csi_token" {
  type    = string
  default = ""
}
variable "hcloud_csi_enabled" {
  default = false
}

variable "minio_use_ssl" {
  default = false
}


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
