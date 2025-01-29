provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "6.18.0"
    }

  }
  required_version = ">=1.7"
  # backend "s3" {
  #   bucket = "terraform-state-bucket"
  #   region = "us-phoenix-1" # Replace with your region
  #   key    = "terraform.tfstate"
  #   endpoints = { s3 = "https://ax3gwmtmn6bp.compat.objectstorage.us-phoenix-1.oraclecloud.com"
  #   }
  #   profile                     = "default"
  #   skip_region_validation      = true
  #   skip_credentials_validation = true
  #   skip_requesting_account_id  = true
  #   use_path_style              = true
  #   skip_s3_checksum            = true
  #   skip_metadata_api_check = true
  # }
  # }
}

module "vcn" {
  source         = "./modules/vcn"
  compartment_id = var.compartment_id
  region         = var.region
  ssh_public_key = var.ssh_public_key
  subnets        = var.subnets
  cidr_block     = var.cidr_block
  lb-port        = var.lb-port
  igw            = true
}

module "load_balancer" {
  source         = "./modules/lb"
  vcn_id         = module.vcn.vcn_id
  subnet_ids     = module.vcn.subnet_ids_list
  compartment_id = var.compartment_id
  region         = var.region
  lb-port        = var.lb-port
}

module "asg" {
  source           = "./modules/asg"
  compartment_id   = var.compartment_id
  region           = var.region
  instance_shape   = var.instance_shape
  ssh_public_key   = var.ssh_public_key
  lb-port          = var.lb-port
  public_subnet_id = module.vcn.public_subnet_id
  lb_id            = module.load_balancer.id
  backend_set_name = module.load_balancer.applayer_lb_backend_set_name
}
