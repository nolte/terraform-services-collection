
module "backup_bucket" {
  source = "../../tf-modules/minio/backup-bucket"
}
module "stash_install" {
  depends_list                  = [module.backup_bucket.depend_on]
  source                        = "../../tf-modules/stash/install"
  minio_stash_backup_group_name = module.backup_bucket.backup_user_group_name
}


module "minecraft_install" {
  depends_list                  = [module.stash_install.depend_on, module.backup_bucket.depend_on]
  source                        = "../../tf-modules/minecraft/install"
  minio_stash_backup_group_name = module.backup_bucket.backup_user_group_name
  backup_bucket_name            = module.backup_bucket.backup_bucket_name
  s3_backup_endpoint            = "http://minio.minio.svc:9000"
}
