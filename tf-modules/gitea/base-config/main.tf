resource "gitea_user" "gitea_user_admin" {
  depends_on = [var.depends_list]
  login      = "giteaadmin2"
  username   = "giteaadmin2"
  password   = "giteaadmin"
  email      = "giteaadmin2@localhost.local"
  fullname   = "giteaadmin2"
  is_admin   = true
}

resource "gitea_organization" "gitea_public_org" {
  depends_on  = [gitea_user.gitea_user_admin]
  owner       = gitea_user.gitea_user_admin.username
  username    = "publicrepos"
  fullname    = "PublicRepos"
  description = "giteaadmin2@localhost.local"
  website     = "giteaadmin2"
}

resource "gitea_repository_migrate" "gitea_migrate_shared_lib" {
  depends_on        = [var.depends_list]
  mirror_clone_addr = "https://gitlab.com/nolte07/jenkins-shared-lib.git"
  uid               = gitea_organization.gitea_public_org.id
  name              = "jenkins-shared-lib"
  mirror            = true
  private           = false
  description       = "Jenkins Shared Lib"
  owner             = gitea_organization.gitea_public_org.username
}


resource "gitea_repository_migrate" "gitea_terraform_gitea" {
  depends_on        = [var.depends_list]
  mirror_clone_addr = "https://github.com/nlamirault/terraform-provider-gitea.git"
  uid               = gitea_organization.gitea_public_org.id
  name              = "terraform-provider-gitea"
  mirror            = true
  private           = false
  description       = "gitea"
  owner             = gitea_organization.gitea_public_org.username
}
resource "gitea_repository_migrate" "terraform_services_collection" {
  depends_on        = [var.depends_list]
  mirror_clone_addr = "https://github.com/nolte/terraform-services-collection.git"
  uid               = gitea_organization.gitea_public_org.id
  name              = "terraform-services-collection"
  mirror            = true
  private           = false
  description       = "gitea"
  owner             = gitea_organization.gitea_public_org.username
}


variable "depends_list" {
  default = []
}

output "depend_on" {
  # list all resources in this module here so that other modules are able to depend on this
  value = [gitea_repository_migrate.gitea_terraform_gitea.id]
}
