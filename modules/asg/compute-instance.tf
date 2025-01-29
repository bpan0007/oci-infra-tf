locals {
  appname = "App_Layer"
  privateAppName = "Private_Layer"
}


# data "template_file" "user_data" {
#   template = file("./cloud-init/vm_Web.tpl")

#   vars = {
#     #app_private_ip = "http://${oci_core_instance.applayerinstance.private_ip}:8080"
#     app_private_ip = "http://${oci_load_balancer_load_balancer.applayer_load_balancer.ip_address_details[0].ip_address}:8080"
#   }
# }

data "oci_core_images" "test_images" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}
data "oci_core_subnets" "test_subnets" {
  #Required
  compartment_id = var.compartment_id
  depends_on = [
    var.public_subnet_id
  ]
  #Optional
  # vcn_id = module.vcn.vcn_id
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.compartment_id
  ad_number      = 1
}
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}


resource "oci_core_instance" "applayerinstance" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_id
  display_name        = local.appname
  shape               = var.instance_shape
  fault_domain        = "FAULT-DOMAIN-3"
  create_vnic_details {
    subnet_id        = var.public_subnet_id
    assign_public_ip = true
  }
  source_details {
    source_type             = "image"
    source_id               = lookup(data.oci_core_images.test_images.images[0], "id")
    boot_volume_size_in_gbs = 50
  }
  metadata = {
    #ssh_authorized_keys = file(var.ssh_public_key)
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file("user_data.tpl"))}"
  }
  # depends_on = [ oci_core_subnet.subnets ]
}


resource "oci_core_instance" "private_instance"{
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_id
  display_name        = local.privateAppName
  shape               = var.instance_shape
  fault_domain        = "FAULT-DOMAIN-3"
  create_vnic_details {
    subnet_id        = data.oci_core_subnets.test_subnets.subnets[0].id
    assign_public_ip = false 
  }
  source_details {
    source_type             = "image"
    source_id               = lookup(data.oci_core_images.test_images.images[0], "id")
    boot_volume_size_in_gbs = 50
  }
  metadata = {
    #ssh_authorized_keys = file(var.ssh_public_key)
    ssh_authorized_keys = var.ssh_public_key
    # user_data           = base64encode(data.template_file.user_data.rendered)
  }
}
resource "oci_core_instance_configuration" "applayer_instance_configuration" {
  compartment_id = var.compartment_id
  display_name   = "instance-1"
  instance_id    = oci_core_instance.applayerinstance.id
  source         = "INSTANCE"
}

resource "oci_core_instance_pool" "app_instance_pool" {
  #Required
  size                      = 1
  compartment_id            = var.compartment_id
  instance_configuration_id = oci_core_instance_configuration.applayer_instance_configuration.id
  placement_configurations {
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    primary_subnet_id   = var.public_subnet_id
  }
  placement_configurations {
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
    primary_subnet_id   = var.public_subnet_id
  }
  placement_configurations {
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2].name
    primary_subnet_id   = var.public_subnet_id
  }
  load_balancers {
    backend_set_name = var.backend_set_name
    load_balancer_id = var.lb_id
    port             = var.lb-port
    vnic_selection   = "PrimaryVnic"
  }
}

resource "oci_autoscaling_auto_scaling_configuration" "applayer_as_configuration" {
  auto_scaling_resources {
    id   = oci_core_instance_pool.app_instance_pool.id
    type = "instancePool"
  }
  compartment_id       = var.compartment_id
  cool_down_in_seconds = "300"
  display_name = "as-config"
 
  is_enabled = "true"
  policies {
    capacity {
      initial = "2"
      max     = "3"
      min     = "1"
    }
    display_name = "scale-policy"
    is_enabled  = "true"
    policy_type = "threshold"
    rules {
      action {
        type  = "CHANGE_COUNT_BY"
        value = "1"
      }
      display_name = "scale-out-rule"
      metric {
        metric_type = "CPU_UTILIZATION"
        threshold {
          operator = "GT"
          value    = "50"
        }
      }
    }
    rules {
      action {
        type  = "CHANGE_COUNT_BY"
        value = "-1"
      }
      display_name = "scale-in-rule"
      metric {
        metric_type = "CPU_UTILIZATION"
        threshold {
          operator = "LT"
          value    = "30"
        }
      }
    }
  }
}
