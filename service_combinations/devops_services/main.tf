
module "gitea_install" {
  source                 = "../../tf-modules/gitea/install"
  gitea_ingress_host     = "gitea.172-17-177-11.sslip.io"
  gitea_ingress_redirect = false
}

# destroy problems ...
//module "gitea_configure" {
//  depends_list = [module.gitea_install]
//  source       = "../../tf-modules/gitea/base-config"
//}

module "chartmuseum_install" {
  source = "../../tf-modules/chartmuseum/install"
}
