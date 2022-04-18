terraform {
  required_providers {
    selectel = {
      source = "selectel/selectel"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.42.0"
    }
    local = {
      source = "hashicorp/local"
    }
    tls = {
      source = "hashicorp/tls"
    }
    external = {
      source = "hashicorp/external"
    }
  }

  required_version = ">= 0.13"

}

provider "selectel" {
  token = var.sel_token
}

provider "openstack" {
  user_name           = var.user_name
  password            = var.user_password
  tenant_id           = var.project_id
  project_domain_name = var.sel_account
  user_domain_name    = var.sel_account
  auth_url            = var.os_auth_url
  region              = var.region
  use_octavia         = true
}
