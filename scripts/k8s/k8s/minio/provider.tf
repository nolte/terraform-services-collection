provider "kubernetes" {
}

terraform {
  backend "s3" {
    key                         = "terraform.tfstate"
    workspace_key_prefix        = "k3s/services/tekton-bucket-migrate/env:"
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

# https://github.com/nabancard/terraform-provider-kubernetes-yaml
provider "k8sraw" {}
