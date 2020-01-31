module "certmanager" {
  source = "../../tf-modules/certmanager/install"

  issuer_letsencrypt_enabled = var.issuer_letsencrypt_enabled
  issuer_selfsigned_enabled  = var.issuer_selfsigned_enabled

  issuer_letsencrypt_email = var.issuer_letsencrypt_email
  issuer_letsencrypt       = var.issuer_letsencrypt
}


module "csi_hcloud" {
  #depends_on       = [module.certmanager]
  depends_list     = [module.certmanager.depend_on]
  source           = "../../tf-modules/csi/hetzner-cloud/install"
  enabled          = var.hcloud_csi_enabled
  hcloud_csi_token = var.hcloud_csi_token
}


module "minio_install" {
  #depends_on = [module.certmanager, module.csi_hcloud]
  source                         = "../../tf-modules/minio/install"
  depends_list                   = [module.certmanager.depend_on, module.csi_hcloud.depend_on]
  minio_admin_access_key         = var.minio_admin_access_key
  minio_admin_secret_key         = var.minio_admin_secret_key
  minio_ingress_host             = var.minio_ingress_host
  minio_persistence_size         = var.minio_persistence_size
  minio_persistence_storageClass = var.minio_persistence_storageClass
  minio_ingress_redirect         = var.minio_ingress_redirect

}



provider "minio" {
  minio_ssl        = var.minio_use_ssl
  minio_server     = "minio.172-17-177-11.sslip.io"
  minio_access_key = module.minio_install.admin_access_key
  minio_secret_key = module.minio_install.admin_secret_key
}


module "minio_state_bucket" {
  #depends_on = [module.certmanager, module.csi_hcloud]
  source       = "../../tf-modules/minio/tf-state-bucket"
  depends_list = [module.minio_install.depend_on]
}
