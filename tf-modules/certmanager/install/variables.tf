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

variable "issuer_letsencrypt_server" {
  type = "map"

  default = {
    staging = "https://acme-staging-v02.api.letsencrypt.org/directory"
    prod    = "https://acme-v02.api.letsencrypt.org/directory"
  }
}

variable "issuer_letsencrypt_secret" {
  default = {
    staging = "letsencrypt-staging"
    prod    = "letsencrypt-prod"
  }
}


variable "issuer_letsencrypt_email" {
  default = "user@example.com"
}
