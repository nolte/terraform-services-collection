locals {
  s3_region = "minio"
}


provider "kubernetes" {
}

terraform {
  backend "s3" {
    key                         = "terraform.tfstate"
    workspace_key_prefix        = "k3s/services/devops/env:"
    region                      = "minio"
    bucket                      = "tf-state-files"
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_get_ec2_platforms      = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}

provider "minio" {
  minio_region = "us-east-1"
}

variable "gitea_endpoint" {
  default = "http://gitea.172-17-177-11.sslip.io"
}


provider "gitea" {
  token    = module.gitea_install.gitea_admin_token
  base_url = var.gitea_endpoint
}

# https://github.com/nabancard/terraform-provider-kubernetes-yaml
provider "k8sraw" {}
